"""Check the published patient lookup examples after SUSHI compilation.

Requires jsonschema. Run with python3 scripts/validate_mapping_examples.py.
"""
import base64
import hashlib
import json
from pathlib import Path

from jsonschema import Draft202012Validator
from referencing import Registry, Resource

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / "fsh-generated/resources"
EXAMPLES = ROOT / "input/examples"


def load(path):
    return json.loads(path.read_text())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_table(document, encoded, validator):
    table = json.loads(base64.b64decode(encoded, validate=True))
    validator.validate(table)
    scope = {
        item["url"]: item
        for item in next(
            ext["extension"] for ext in document["extension"]
            if ext["url"].endswith("/dis-identity-linkage-scope")
        )
    }
    identifier = scope["scopeIdentifier"]["valueIdentifier"]
    require(
        table["identity-linkage-scope"] == {
            "type": scope["scopeType"]["valueCode"],
            "identifier": {key: identifier[key] for key in ("system", "value")},
        },
        "DocumentReference and lookup content scopes differ",
    )
    require(any(entry["value"] == table["tableId"] for entry in document["identifier"]),
            "DocumentReference identifier does not identify the lookup table")
    source_pairs = {(entry["sourceSystem"], entry["sourceValue"]) for entry in table["entries"]}
    require(len(source_pairs) == len(table["entries"]), "Duplicate source identifier in lookup table")
    return table


def inline_table(directory, name, validator):
    document = load(directory / f"DocumentReference-{name}.json")
    return read_table(document, document["content"][0]["attachment"]["data"], validator)


def main():
    directory = ROOT / "input/images/schemas"
    policy_schema = load(directory / "dis-policy.schema.json")
    table_schema = load(directory / "dis-lookup-table.schema.json")
    registry = Registry().with_resource(policy_schema["$id"], Resource.from_contents(policy_schema))
    validator = Draft202012Validator(table_schema, registry=registry)

    binary = load(GENERATED / "Binary-lookup-content-example.json")
    document = load(GENERATED / "DocumentReference-lookup-document-example.json")
    url = document["content"][0]["attachment"]["url"]
    require(url.endswith(f"/Binary/{binary['id']}/_history/{binary['meta']['versionId']}"),
            "Lookup document does not locate the fixture Binary version")
    source = read_table(document, binary["data"], validator)
    require(source == inline_table(GENERATED, "lookup-inline-example", validator),
            "Binary and inline lookup tables differ")
    for folder, source_name, task_name in (
        (GENERATED, "lookup-inline-example", "lookup-task-s1"),
        (EXAMPLES, "pathology-supplied-lookup", "pathology-task-lookup"),
    ):
        original = inline_table(folder, source_name, validator)
        scoped = inline_table(folder, task_name, validator)
        require(scoped["identity-linkage-scope"] == original["identity-linkage-scope"],
                "Task and source lookup scopes differ")
        require(len(scoped["entries"]) == 1 and scoped["entries"][0] in original["entries"],
                "Task lookup does not contain the assigned source mapping")

    generated = inline_table(GENERATED, "generated-lookup-uc3", validator)
    mapping, = generated["entries"]
    scope = generated["identity-linkage-scope"]
    fields = ["DIS-patient-identifier-v1", scope["type"], scope["identifier"]["system"],
              scope["identifier"]["value"], mapping["sourceSystem"], mapping["sourceValue"]]
    message = json.dumps(fields, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    digest = hashlib.sha256(message + bytes(range(16))).hexdigest()
    patient = load(GENERATED / "Patient-pseudonym-abc123.json")
    require(mapping["targetValue"] == digest, "Generated mapping does not match the test vector")
    require(any(entry.get("system") == mapping["targetSystem"] and entry.get("value") == digest
                for entry in patient["identifier"]),
            "Pseudonymized Patient does not carry the generated mapping")
    print("Published patient lookup examples passed.")


if __name__ == "__main__":
    main()
