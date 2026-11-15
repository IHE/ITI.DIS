"""Generate the CSVs and Volume 3 sample tables from the FHIR R4 DPV mappings."""

import argparse
import csv
import io
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BINDINGS = ROOT / "input/images/bindings"
MAPPING_PAGE = ROOT / "input/pagecontent/volume-3-execution-plan.md"
SAMPLE_PATHS = {
    1: {"Patient.name", "Practitioner.name", "Patient.birthDate", "ContactDetail.name"},
    2: {"Patient.name", "Patient.address.postalCode", "Patient.telecom.where(system = 'email')",
        "Condition.code", "Coverage.type"},
}


def csv_view(mapping, rows, include_context):
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
    if include_context:
        fields.extend(["subjectPath", "subjectResourceType", "subjectRule"])
        headers.extend(["Subject reference path", "Subject resource type", "Subject rule"])
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
        writer.writerow(prefix + [row.get(field, "") for field in fields])
    return output.getvalue()


def sample_table(rows, revision):
    table = [
        "",
        "| Order | DPV category | Person role | FHIR R4 target |",
        "| --- | --- | --- | --- |",
    ]
    for row in rows:
        target = row["targetPath"]
        if target not in SAMPLE_PATHS[revision]:
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


def update_sample(section, rows, revision):
    start_marker = f"<!-- BEGIN GENERATED FHIR R4 DPV MAPPING SAMPLE {revision} -->\n"
    end_marker = f"<!-- END GENERATED FHIR R4 DPV MAPPING SAMPLE {revision} -->"
    before, start, following = section.partition(start_marker)
    _, end, after = following.partition(end_marker)
    if not start or not end:
        raise SystemExit(f"Missing generated sample markers for revision {revision}")
    return before + start + sample_table(rows, revision) + end + after


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check that the views match the mappings")
    args = parser.parse_args()
    section = MAPPING_PAGE.read_text(encoding="utf-8")
    for revision in sorted(SAMPLE_PATHS):
        basename = BINDINGS / f"dis-fhir-r4-dpv-mapping-{revision}"
        mapping = json.loads(basename.with_suffix(".jsonld").read_text(encoding="utf-8"))
        rows = sorted(mapping["entries"], key=lambda row: row["order"])
        if [row["order"] for row in rows] != list(range(1, len(rows) + 1)):
            raise SystemExit(f"Revision {revision} has missing or duplicate expansion orders")
        keys = {(row["category"], row["personRole"], row["location"], row["targetPath"]) for row in rows}
        if len(keys) != len(rows):
            raise SystemExit(f"Revision {revision} has duplicate mapping entries")
        section = update_sample(section, rows, revision)
        update(basename.with_suffix(".csv"), csv_view(mapping, rows, revision >= 2), args.check)
    update(MAPPING_PAGE, section, args.check)


if __name__ == "__main__":
    main()
