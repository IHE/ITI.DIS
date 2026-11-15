"""Generate the FHIR R4 resource coverage inventory from HL7's 4.0.1 package."""

import argparse
from collections import defaultdict
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "input/images/bindings"


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


def paths_without_filters(path):
    """Remove where filters while preserving the declared path and choice constraints."""
    start = path.find(".where(")
    while start >= 0:
        depth, end, quoted = 1, start + len(".where("), False
        while end < len(path) and depth:
            char = path[end]
            if char == "'":
                quoted = not quoted
            if not quoted and char == "(":
                depth += 1
            if not quoted and char == ")":
                depth -= 1
            end += 1
        if depth or quoted:
            raise SystemExit(f"Unbalanced selector filter: {path}")
        path = path[:start] + path[end:]
        start = path.find(".where(")
    return path


def revision_two_rows(resources, mapping):
    selectors_by_resource = defaultdict(list)
    for entry in mapping["entries"]:
        selector = entry["targetPath"]
        resource = selector.split(".", 1)[0]
        if resource == "ContactDetail":
            continue
        if resource not in resources:
            raise SystemExit(f"Unknown selector resource type: {selector}")
        if "subjectPath" in entry:
            path = entry["subjectPath"]
            declared = {e["path"]: e for e in declared_elements(resources[resource])}
            field = declared.get(path)
            if field is None or "Reference" not in type_codes(field):
                raise SystemExit(f"Subject path is not a reference on {resource}: {path}")
            profiles = {
                profile.split("/")[-1] for type_ in field["type"]
                for profile in type_.get("targetProfile", [])
            }
            if profiles and not {entry["subjectResourceType"], "Resource"} & profiles:
                raise SystemExit(f"Subject type is not allowed by {path}")
        selectors_by_resource[resource].append(selector)

    candidate_types = {"HumanName", "Identifier", "ContactPoint", "Address", "Age", "Attachment",
                       "Money", "Dosage", "CodeableConcept", "Quantity", "Period"}
    for resource, info in sorted(resources.items()):
        elements = declared_elements(info)
        selectors = selectors_by_resource[resource]
        expanded = [paths_without_filters(selector) for selector in selectors]
        other = []
        contact_sites = 0
        for element in elements:
            path = element["path"]
            if type_codes(element) == {"ContactDetail"}:
                contact_sites += 1
                continue
            variants = {path}
            if path.endswith("[x]"):
                variants.update(path[:-3] + f".ofType({t})" for t in type_codes(element))
            mapped = any(selector == variant or selector.startswith(variant + ".")
                         for selector in expanded for variant in variants)
            if not mapped and (candidate(element) or type_codes(element) & candidate_types):
                other.append(path)
        yield [
            mapping["@id"], info["url"], info["version"], resource,
            "abstract" if info.get("abstract") else "concrete",
            len(elements), " | ".join(selectors), contact_sites, " | ".join(other),
        ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package", type=Path, help="package directory for hl7.fhir.r4.core#4.0.1")
    parser.add_argument("--revision", type=int, choices=[1, 2, 3], default=3, help="mapping revision to review")
    args = parser.parse_args()
    mapping_path = ROOT / f"dis-fhir-r4-dpv-mapping-{args.revision}.jsonld"
    review_path = ROOT / f"dis-fhir-r4-dpv-resource-review-{args.revision}.csv"
    mapping = json.loads(mapping_path.read_text(encoding="utf-8"))
    review = generate_rows if args.revision == 1 else revision_two_rows
    rows = list(review(resource_definitions(args.package), mapping))
    with review_path.open("w", encoding="utf-8", newline="") as output:
        writer = csv.writer(output, lineterminator="\n")
        writer.writerow([
            "Mapping revision", "StructureDefinition", "FHIR version", "Resource type", "Kind",
            "Locally declared element count", "Direct mapped selectors",
            "Shared ContactDetail use site count", "Other screened declaration paths",
        ])
        writer.writerows(rows)


if __name__ == "__main__":
    main()
