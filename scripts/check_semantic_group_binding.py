#!/usr/bin/env python3
"""Check the authoritative Volume 3 FHIR selector table."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TABLE_HEADER = "| Semantic group | FHIR R4 (4.0.1) | FHIR R5 (5.0.0) |"


def main():
    volume = (ROOT / "input/pagecontent/volume-3.md").read_text()
    if volume.count(TABLE_HEADER) != 1:
        raise SystemExit("Volume 3 must contain one R4/R5 semantic group binding table.")

    fsh = (ROOT / "input/fsh/CodeSystems.fsh").read_text()
    definition = re.search(r"^CodeSystem: DisSemanticGroup\n(.*?)(?=^CodeSystem:|\Z)", fsh, re.M | re.S)
    if not definition:
        raise SystemExit("The DIS Semantic Group CodeSystem is missing.")
    codes = re.findall(r'^\* #([\w-]+) "', definition[1], re.M)

    lines = volume.split(TABLE_HEADER + "\n", 1)[1].split("{: .grid}", 1)[0].splitlines()
    groups = []
    for line in lines[1:]:
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != 3 or not re.fullmatch(r"`[\w-]+`", cells[0]):
            raise SystemExit(f"Invalid semantic group row: {line}")
        groups.append(cells[0].strip("`"))
        for cell in cells[1:]:
            if not re.fullmatch(r"`[^`]+`(?:, `[^`]+`)*", cell):
                raise SystemExit(f"Invalid selector list for {cells[0]}: {cell}")
            selectors = re.findall(r"`([^`]+)`", cell)
            if len(selectors) != len(set(selectors)):
                raise SystemExit(f"Duplicate selector for {cells[0]}: {cell}")

    if sorted(groups) != sorted(codes):
        raise SystemExit("The binding table must define each CodeSystem code exactly once.")


if __name__ == "__main__":
    main()
