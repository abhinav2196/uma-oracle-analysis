#!/usr/bin/env python3
import argparse
import binascii
import csv
import json
import os
from typing import Any, Dict, Iterable, List, Optional

from scripts.lib.io_utils import output_paths


def hex_to_text(value: str) -> str:
    if not isinstance(value, str):
        return value
    s = value.strip()
    if s.startswith("0x"):
        s = s[2:]
    if len(s) == 0:
        return ""
    try:
        # try hex -> bytes -> utf-8
        b = binascii.unhexlify(s)
        return b.decode("utf-8", errors="replace")
    except Exception:
        return value


def convert_records(records: List[Dict[str, Any]], hex_fields: List[str]) -> List[Dict[str, Any]]:
    for row in records:
        for field in hex_fields:
            if field in row and isinstance(row[field], str):
                row[field + "_text"] = hex_to_text(row[field])
    return records


def write_csv(path: str, rows: List[Dict[str, Any]]) -> None:
    if not rows:
        # Write empty file with no headers
        open(path, "w", encoding="utf-8").close()
        return
    # Union of keys for headers
    headers: List[str] = []
    seen = set()
    for r in rows:
        for k in r.keys():
            if k not in seen:
                seen.add(k)
                headers.append(k)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow(r)


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert JSON records to CSV and decode hex fields")
    parser.add_argument("--network", required=True)
    parser.add_argument("--period", required=True)
    parser.add_argument("--input-json", required=True, help="path to input JSON array file")
    parser.add_argument("--hex-fields", nargs="*", default=["identifier", "ancillaryData"], help="fields to hex-decode into *_text")
    parser.add_argument("--stem", required=False, help="filename stem; defaults to input filename without extension")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    base_dir = os.path.join(repo_root, "data-dumps")

    with open(args.input_json, "r", encoding="utf-8") as f:
        records = json.load(f)
    if not isinstance(records, list):
        raise SystemExit("input JSON must be an array of objects")

    converted = convert_records(records, args.hex_fields)

    stem = args.stem or os.path.splitext(os.path.basename(args.input_json))[0]
    _dir_path, _json_out, csv_out = output_paths(base_dir, args.network, args.period, stem)
    write_csv(csv_out, converted)
    print(f"Wrote CSV: {csv_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


