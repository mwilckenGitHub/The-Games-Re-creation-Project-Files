"""Check the complete GameMaker Unicode tables against independent UCD properties."""
import argparse
import csv
import json
from pathlib import Path


LIMIT = 0x110000
SHORT_BIDI = {"Left_To_Right": "L", "Right_To_Left": "R", "Arabic_Letter": "AL",
              "European_Terminator": "ET"}
LEGACY_COLUMN_COUNT = 18


def property_ranges(document):
    for raw in document.read_text(encoding="utf-8").splitlines():
        if raw.startswith("# @missing:"):
            source = raw.removeprefix("# @missing:")
            missing = True
        else:
            source = raw.partition("#")[0]
            missing = False
        if not source.strip():
            continue
        code, *properties = map(str.strip, source.split(";"))
        start, _, stop = code.partition("..")
        yield int(start, 16), int(stop or start, 16), properties, missing


def verify(inputs, tables):
    category = ["Cn"] * LIMIT
    bidi = ["L"] * LIMIT
    whitespace = bytearray(LIMIT)
    noncharacters = set()
    for lo, hi, values, _ in property_ranges(inputs / "DerivedGeneralCategory.txt"):
        category[lo:hi+1] = [values[0]] * (hi-lo+1)
    for lo, hi, values, missing in property_ranges(inputs / "DerivedBidiClass.txt"):
        code = SHORT_BIDI.get(values[0], values[0]) if missing else values[0]
        bidi[lo:hi+1] = [code] * (hi-lo+1)
    for lo, hi, values, _ in property_ranges(inputs / "PropList.txt"):
        if values[0] == "White_Space":
            whitespace[lo:hi+1] = b"\x01" * (hi-lo+1)
        if values[0] == "Noncharacter_Code_Point":
            noncharacters.update(range(lo, hi+1))
    names, numeric = {}, {}
    for lo, hi, values, _ in property_ranges(inputs / "DerivedName.txt"):
        names.update((cp, values[0].replace("*", f"{cp:04X}")) for cp in range(lo, hi+1))
    for lo, hi, values, _ in property_ranges(inputs / "DerivedNumericValues.txt"):
        numeric.update((cp, values[2]) for cp in range(lo, hi+1))

    sample_points = {0x378, 0xAC01, 0x4E01, 0x20001, 0xE001, 0xD801, 0x10FFFF}
    samples = {}
    dense_count = compact_count = 0
    with (tables / "UnicodeData.csv").open(newline="", encoding="utf-8") as compact_stream:
        compact = csv.reader(compact_stream)
        for plane in range(17):
            with (tables / "Planes" / f"Unicode Plane {plane}.csv").open(newline="", encoding="utf-8") as stream:
                rows = csv.reader(stream)
                for cp in range(plane << 16, (plane+1) << 16):
                    row = next(rows, [])
                    assert len(row) == LEGACY_COLUMN_COUNT, (hex(cp), row)
                    assert (row[0], row[1], row[2], row[17]) == (
                        f"{cp:08X}", str(cp), f"{cp:04X}", str(cp)), (hex(cp), row)
                    assert (row[4], row[6]) == (category[cp], bidi[cp]), (hex(cp), row, category[cp], bidi[cp])
                    if cp in names:
                        assert row[3] == names[cp], (hex(cp), row[3], names[cp])
                    if cp in numeric:
                        assert row[10] == numeric[cp], (hex(cp), row[10], numeric[cp])
                    if row[4] in {"Cs", "Co", "Cn"}:
                        label = {"Cs": "<surrogate>", "Co": "<private-use>", "Cn": "<unassigned>"}[row[4]]
                        assert row[3] == ("<noncharacter>" if cp in noncharacters else label), (hex(cp), row)
                    if category[cp] != "Cn":
                        assert next(compact, []) == row, (hex(cp), row)
                        compact_count += 1
                    if cp in sample_points:
                        samples[f"U+{cp:04X}"] = dict(name=row[3], category=row[4], bidi=row[6], numeric=row[10])
                    dense_count += 1
                assert next(rows, None) is None, plane
        assert next(compact, None) is None

    labels = "Cn Lu Ll Lt Lm Lo Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co".split()
    with (tables / "text-properties.csv").open(newline="", encoding="utf-8") as stream:
        previous = -1
        for lo, hi, props in (list(map(int, row)) for row in csv.reader(stream)):
            assert 0 <= lo <= hi < LIMIT and lo > previous, (lo, hi)
            assert all(c == "Cn" for c in category[previous+1:lo]) and not any(whitespace[previous+1:lo])
            code = labels[(props >> 17) & 31]
            assert all(c == code for c in category[lo:hi+1]), (lo, hi, code)
            assert all(bool(value) == bool(props & (1 << 22)) for value in whitespace[lo:hi+1]), (lo, hi)
            previous = hi
        assert all(c == "Cn" for c in category[previous+1:]) and not any(whitespace[previous+1:])
    return {"ok": True, "checked_plane_rows":dense_count,"checked_compact_rows":compact_count,
            "with_character_name":len(names),"with_numeric_property":len(numeric),
            "noncharacters":len(noncharacters),"samples":samples}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", type=Path)
    parser.add_argument("tables", type=Path)
    args = parser.parse_args()
    print(json.dumps(verify(args.inputs, args.tables),indent=2))
