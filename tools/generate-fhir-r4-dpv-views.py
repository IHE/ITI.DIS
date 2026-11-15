"""Generate the CSV and Volume 3 sample from the normative FHIR R4 mapping."""

import argparse
import csv
import io
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BINDINGS = ROOT / "input/images/bindings"
REVISION = "dis-fhir-r4-dpv-mapping-1"
VOLUME = ROOT / "input/pagecontent/volume-3-fhir-addressing.md"
START = "<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE -->\n"
END = "<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE -->"
DISPLAY_PATHS = {"Patient.name", "Practitioner.name", "ContactDetail.name", "Patient.birthDate"}


def csv_view(mapping, rows):
    fields = [
        "order", "category", "personRole", "location", "targetPath",
        "selectorLanguage", "roleRule", "expansionRule",
    ]
    headers = [
        "Mapping revision", "Payload binding", "FHIR release", "FHIR package",
        "DPV edition", "Manifest format", "Coverage rule", "Expansion order",
        "DPV category IRI", "Person role IRI", "Location IRI", "Target path",
        "Selector language IRI", "Role rule", "Expansion rule",
    ]
    prefix = [
        mapping[key] for key in [
            "@id", "payloadBinding", "payloadVersion", "fhirPackage",
            "dpvEdition", "manifestFormat", "coverageRule",
        ]
    ]
    output = io.StringIO(newline="")
    writer = csv.writer(output, lineterminator="\n")
    writer.writerow(headers)
    for row in rows:
        writer.writerow(prefix + [row[field] for field in fields])
    return output.getvalue()


def sample_table(rows):
    table = [
        "",
        "| Order | DPV category | Person role | FHIR R4 target |",
        "| --- | --- | --- | --- |",
    ]
    for row in rows:
        target = row["targetPath"]
        if target not in DISPLAY_PATHS:
            continue
        category = row["category"].rsplit("#", 1)[1]
        role = row["personRole"].rsplit("#", 1)[1]
        table.append(f"| {row['order']} | `pd:{category}` | `disdpv:{role}` | `{target}` |")
    return "\n".join(table + ["{: .grid}", "", ""])


def update(path, contents, check):
    if check:
        if not path.is_file() or path.read_text(encoding="utf-8") != contents:
            raise SystemExit(f"Regenerate {path.relative_to(ROOT)} with {Path(__file__).name}")
    else:
        path.write_text(contents, encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check that the views match the mapping")
    args = parser.parse_args()
    mapping = json.loads((BINDINGS / f"{REVISION}.jsonld").read_text(encoding="utf-8"))
    rows = sorted(mapping["entries"], key=lambda row: row["order"])
    if [row["order"] for row in rows] != list(range(1, len(rows) + 1)):
        raise SystemExit("Mapping entries must have a unique, consecutive expansion order")
    if len({row["targetPath"] for row in rows}) != len(rows):
        raise SystemExit("Duplicate target path in the FHIR R4 mapping")
    before, start, section = VOLUME.read_text(encoding="utf-8").partition(START)
    _, end, after = section.partition(END)
    if not start or not end:
        raise SystemExit("Missing generated sample markers in Volume 3")
    update(VOLUME, before + START + sample_table(rows) + END + after, args.check)
    update(BINDINGS / f"{REVISION}.csv", csv_view(mapping, rows), args.check)


if __name__ == "__main__":
    main()
