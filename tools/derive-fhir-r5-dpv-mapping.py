"""Derive the R5 DPV draft and review report from pinned FHIR definitions."""

import argparse
from copy import deepcopy
import csv
import io
import json
from pathlib import Path
import re

BINDINGS = Path(__file__).resolve().parents[1] / "input/images/bindings"
DIS = "https://profiles.ihe.net/ITI/DIS/"
RULES = f"{DIS}volume-3.html#fhir-"
R5_ID = f"{DIS}bindings/dis-fhir-r5-dpv-mapping-1.jsonld"


def definitions(package, release, version):
    metadata = json.loads((package / "package.json").read_text())
    if (metadata["name"], metadata["version"]) != (f"hl7.fhir.{release}.core", version):
        raise SystemExit(f"Use hl7.fhir.{release}.core#{version}")
    result = {}
    for path in sorted(package.glob("StructureDefinition-*.json")):
        item = json.loads(path.read_text())
        if item.get("derivation") != "constraint" and "snapshot" in item:
            result[item["type"]] = {
                element["path"]: element for element in item["snapshot"]["element"]
            }
    return result


def selector_shape(types, selector):
    root, *terms = re.split(r"\.(?![^()]*\))", selector)
    current_path = root
    fields = types.get(root, {})
    shape = []
    for index, term in enumerate(terms):
        candidate = current_path + "." + term
        element = fields.get(candidate)
        choice = None
        if element is None and index + 1 < len(terms):
            match = re.fullmatch(r"ofType\((\w+)\)", terms[index + 1])
            if match:
                element = fields.get(candidate + "[x]")
                choice = match[1]
        if term.startswith("ofType("):
            continue
        if element is None and shape:
            previous_types = shape[-1][2]
            if len(previous_types) == 1:
                datatype = previous_types[0][0]
                fields = types.get(datatype, {})
                candidate = datatype + "." + term
                element = fields.get(candidate)
        if element is None:
            return None
        element_types = tuple(sorted(
            (item["code"], tuple(sorted(item.get("profile", []))), tuple(sorted(item.get("targetProfile", []))))
            for item in element.get("type", [])
            if choice is None or item["code"] == choice
        ))
        if not element_types and choice is not None:
            return None
        binding = element.get("binding", {})
        shape.append((
            element["min"], element["max"], element_types,
            binding.get("strength"), binding.get("valueSet", "").split("|")[0],
            " ".join(element.get("definition", "").split()),
        ))
        current_path = candidate
    return shape or None


def patient_reference(types, selector):
    shape = selector_shape(types, selector)
    if not shape:
        return False
    return any(
        code == "Reference" and any(target.endswith("/Patient") for target in targets)
        for code, _, targets in shape[-1][2]
    )


def derive(source, r4, r5):
    # Published care-team rules assume these paths retain their FHIR roles.
    for path in ("CareTeam.subject", "CareTeam.status", "CareTeam.participant.member"):
        earlier = selector_shape(r4, path)
        current = selector_shape(r5, path)
        if not earlier or not current or earlier[-1][:5] != current[-1][:5]:
            raise SystemExit(f"Review the R5 care-team rules for {path}")
    contact = selector_shape(r5, "ActivityDefinition.contact")
    if not contact or tuple(item[0] for item in contact[-1][2]) != ("ContactDetail",):
        raise SystemExit("Review the R5 ContactDetail zero-match selector")

    result = deepcopy(source)
    result.update({
        "@id": R5_ID,
        "payloadVersion": "R5",
        "fhirPackage": "hl7.fhir.r5.core#5.0.0",
        "coverageRule": RULES + "r5-dpv-coverage-1",
        "entries": [],
    })
    review = io.StringIO(newline="")
    writer = csv.writer(review, lineterminator="\n")
    writer.writerow(["R4 expansion order", "DPV category", "Person role", "R4 selector", "R5 selector", "Review result"])
    for original in source["entries"]:
        entry = deepcopy(original)
        selector = entry["targetPath"]
        shape4 = selector_shape(r4, selector)
        shape5 = selector_shape(r5, selector)
        subject = entry.get("subjectPath")
        subject4 = selector_shape(r4, subject) if subject else None
        subject5 = selector_shape(r5, subject) if subject else None
        if selector == "Encounter.period":
            destination = "Encounter.actualPeriod"
            assert shape4 and selector_shape(r5, destination)
            assert shape4[-1][:3] == selector_shape(r5, destination)[-1][:3]
            assert patient_reference(r4, subject) and patient_reference(r5, subject)
            decision = "Reviewed rename"
        elif ".where(" in selector:
            destination, decision = "", "Review filter fields, terminology, and extension definitions"
        elif subject and (not subject4 or subject4 != subject5):
            destination, decision = "", "Review changed subject reference"
        elif not shape4 or not shape5:
            destination, decision = "", "Review missing or changed element path or choice type"
        elif shape4 != shape5:
            destination, decision = "", "Review changed definition, cardinality, type, or terminology binding"
        else:
            destination, decision = selector, "Carried forward with matching declarations"
        writer.writerow([entry["order"], entry["category"], entry["personRole"], selector, destination, decision])
        if destination:
            entry["targetPath"] = destination
            if selector.startswith("ContactDetail."):
                entry["expansionRule"] = RULES + "r5-dpv-contact-detail-1"
            result["entries"].append(entry)

    # A report subject may identify a patient only after the reference is verified.
    selector = "DiagnosticReport.subject"
    assert patient_reference(r5, selector) and selector_shape(r5, selector)[-1][0:2] == (0, "1")
    entry = deepcopy(next(entry for entry in result["entries"] if entry["targetPath"] == "Patient.identifier"))
    entry.update({
        "category": "https://w3id.org/dpv/pd#Identifying",
        "targetPath": selector,
        "subjectPath": selector,
        "subjectResourceType": "Patient",
        "subjectRule": RULES + "r4-dpv-verified-subject-2",
    })
    result["entries"].append(entry)
    writer.writerow(["", entry["category"], entry["personRole"], "", selector, "Reviewed R5 addition with verified Patient"])
    for order, row in enumerate(result["entries"], 1):
        row.update({"@id": f"{R5_ID}#{order}", "order": order})
    return result, review.getvalue()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("r4", type=Path, help="package directory for hl7.fhir.r4.core#4.0.1")
    parser.add_argument("r5", type=Path, help="package directory for hl7.fhir.r5.core#5.0.0")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    r4 = definitions(args.r4, "r4", "4.0.1")
    r5 = definitions(args.r5, "r5", "5.0.0")
    source = json.loads((BINDINGS / "dis-fhir-r4-dpv-mapping-3.jsonld").read_text())
    mapping, review = derive(source, r4, r5)
    outputs = {
        "dis-fhir-r5-dpv-mapping-1.jsonld": json.dumps(mapping, ensure_ascii=False, indent=2) + "\n",
        "dis-fhir-r4-to-r5-dpv-review-1.csv": review,
    }
    for name, content in outputs.items():
        path = BINDINGS / name
        if args.check:
            if not path.exists() or path.read_text() != content:
                raise SystemExit(f"Regenerate {name}")
        else:
            path.write_text(content)


if __name__ == "__main__":
    main()
