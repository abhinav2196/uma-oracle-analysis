#!/usr/bin/env python3
import argparse
import csv
import os
from typing import Dict, List

from scripts.lib.io_utils import output_paths


def parse_condition(cond: str):
    """
    Very simple parser for conditions like:
      column==value
      column!=value
      column~substring   (contains)
      column!~substring  (not contains)
    Returns (column, op, value)
    """
    for op in ["==", "!=", "~", "!~"]:
        if op in cond:
            left, right = cond.split(op, 1)
            return left.strip(), op, right.strip()
    raise ValueError(f"Unsupported condition: {cond}")


def row_matches(row: Dict[str, str], conditions: List[str]) -> bool:
    for cond in conditions:
        col, op, val = parse_condition(cond)
        rv = row.get(col, "")
        if op == "==":
            if rv != val:
                return False
        elif op == "!=":
            if rv == val:
                return False
        elif op == "~":
            if val not in rv:
                return False
        elif op == "!~":
            if val in rv:
                return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Filter CSV rows with simple AND conditions")
    parser.add_argument("--network", required=True)
    parser.add_argument("--period", required=True)
    parser.add_argument("--input-csv", required=True)
    parser.add_argument("--where", nargs="+", required=True, help="conditions like column==value column~substr")
    parser.add_argument("--stem", required=False, help="output stem name")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    base_dir = os.path.join(repo_root, "data-dumps")
    stem = args.stem or os.path.splitext(os.path.basename(args.input_csv))[0] + "_filtered"
    _dir_path, _json_path, out_csv = output_paths(base_dir, args.network, args.period, stem)

    with open(args.input_csv, "r", encoding="utf-8") as f_in, open(out_csv, "w", newline="", encoding="utf-8") as f_out:
        reader = csv.DictReader(f_in)
        writer = csv.DictWriter(f_out, fieldnames=reader.fieldnames)
        writer.writeheader()
        count_in = 0
        count_out = 0
        for row in reader:
            count_in += 1
            if row_matches(row, args.where):
                writer.writerow(row)
                count_out += 1
    print(f"Filtered {count_out}/{count_in} rows -> {out_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


