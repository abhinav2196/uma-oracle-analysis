#!/usr/bin/env python3
import argparse
import csv
import os
import sys
from typing import Dict, List

# Add parent directory to path for imports when run from repo root
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
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


def is_price_identifier(identifier: str) -> bool:
    """
    Check if an identifier represents a price query.
    Examples: DEXTFUSD, BTCUSD, ETHUSD, FOXUSD, PERPUSD
    """
    if not identifier:
        return False
    
    price_suffixes = ['USD', 'USDT', 'BTC', 'ETH']
    price_keywords = ['PRICE', 'TWAP']
    
    id_upper = identifier.upper()
    
    # Check for price suffixes
    for suffix in price_suffixes:
        if id_upper.endswith(suffix):
            return True
    
    # Check for price keywords
    for keyword in price_keywords:
        if keyword in id_upper:
            return True
    
    return False


def row_matches(row: Dict[str, str], conditions: List[str]) -> bool:
    """
    Enhanced matching that supports:
    - Standard conditions: column==value, column~substring
    - Special: PRICE_QUERY matches both ancillaryData and identifier-only queries
    """
    for cond in conditions:
        # Special handling for PRICE_QUERY meta-condition
        if cond.strip() == "PRICE_QUERY":
            # Match if either:
            # 1. ancillaryData_text contains "price of"
            # 2. identifier is a price query (XXXUSD, etc.)
            ancillary = row.get("ancillaryData_text", "").lower()
            identifier = row.get("identifier", "")
            
            has_price_text = "price of" in ancillary or "price above" in ancillary or "price below" in ancillary
            has_price_id = is_price_identifier(identifier)
            
            if not (has_price_text or has_price_id):
                return False
            continue
        
        # Standard condition parsing
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
    parser = argparse.ArgumentParser(
        description="Filter CSV rows with simple AND conditions",
        epilog="""
Examples:
  # Standard conditions
  --where 'ancillaryData_text~price of'
  --where 'identifier==YES_OR_NO_QUERY'
  
  # Special meta-condition for price queries (catches both ancillaryData and identifier-only queries)
  --where PRICE_QUERY
  
  # Catches: "Will the price of Bitcoin..." AND "DEXTFUSD", "BTCUSD", etc.
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--network", required=True)
    parser.add_argument("--period", required=True)
    parser.add_argument("--input-csv", required=True)
    parser.add_argument("--where", nargs="+", required=True, 
                       help="conditions like 'column==value' or 'column~substr', or special: PRICE_QUERY")
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


