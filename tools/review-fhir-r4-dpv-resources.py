"""Generate the FHIR R4 resource coverage inventory from HL7's 4.0.1 package."""

import argparse
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "input/images/bindings"
MAPPING = ROOT / "dis-fhir-r4-dpv-mapping-1.jsonld"
REVIEW = ROOT / "dis-fhir-r4-dpv-resource-review-1.csv"


def resource_definitions(package):
    metadata = json.loads((package / "package.json").read_text())
    if (metadata["name"], metadata["version"]) != ("hl7.fhir.r4.core", "4.0.1"):
        raise SystemExit("Use the HL7 FHIR R4 core package, version 4.0.1")
    resources = {}
    for path in sorted(package.glob("StructureDefinition-*.json")):
        info = json.loads(path.read_text())
        if info.get("kind") == "resource" and info.get("derivation", "specialization") == "specialization":
            resources[info["type"]] = info
    if len(resources) != 148:
        raise SystemExit(f"Expected 148 R4 resource definitions, found {len(resources)}")
    return resources


def declared_elements(info):
    effective = {row["id"]: row for row in info["snapshot"]["element"]}
    return [
        effective[row["id"]] for row in info["differential"]["element"] if "." in row["path"]
    ]


def type_codes(element):
    return {type_["code"] for type_ in element.get("type", [])}


def candidate(element):
    leaf = element["path"].rsplit(".", 1)[-1]
    words = re.sub(r"([a-z])([A-Z])", r"\1 \2", leaf).lower()
    return (
        bool(type_codes(element) & {"HumanName", "Identifier", "ContactDetail"})
        or any(fragment in words for fragment in ("name", "identifi", "birth"))
        or "id" in words.split()
        or leaf == "born[x]"
    )


def generate_rows(resources, mapping):
    mapped_paths = {entry["targetPath"] for entry in mapping["entries"]}
    mapped_paths.remove("ContactDetail.name")
    matched = set()
    for type_, info in sorted(resources.items()):
        elements = declared_elements(info)
        direct, other = [], []
        contact_sites = 0
        for element in elements:
            path = element["path"]
            if type_codes(element) == {"ContactDetail"}:
                contact_sites += 1
                continue
            selectors = {path}
            if path.endswith("[x]"):
                selectors.update(path[:-3] + f".ofType({name})" for name in type_codes(element))
            selected = sorted(selectors & mapped_paths)
            matched.update(selected)
            direct.extend(selected)
            if candidate(element) and not selected:
                other.append(path)
            if selected and path.endswith("[x]"):
                remaining_types = sorted(
                    name for name in type_codes(element) if path[:-3] + f".ofType({name})" not in selected
                )
                other.extend(path[:-3] + f".ofType({name})" for name in remaining_types)
        yield [
            mapping["@id"], info["url"], info["version"], type_,
            "abstract" if info.get("abstract") else "concrete",
            len(elements), " | ".join(direct), contact_sites, " | ".join(other),
        ]
    if matched != mapped_paths:
        raise SystemExit(f"Unmatched resource selectors: {sorted(mapped_paths - matched)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package", type=Path, help="package directory for hl7.fhir.r4.core#4.0.1")
    args = parser.parse_args()
    mapping = json.loads(MAPPING.read_text(encoding="utf-8"))
    rows = list(generate_rows(resource_definitions(args.package), mapping))
    with REVIEW.open("w", encoding="utf-8", newline="") as output:
        writer = csv.writer(output, lineterminator="\n")
        writer.writerow([
            "Mapping revision", "StructureDefinition", "FHIR version", "Resource type", "Kind",
            "Locally declared element count", "Direct mapped selectors",
            "Shared ContactDetail use site count", "Other screened declaration paths",
        ])
        writer.writerows(rows)


if __name__ == "__main__":
    main()
