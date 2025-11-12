#!/usr/bin/env python3
"""
Convert August 2025 JSONL data to CSV for all networks
Handles both V2 (OptimisticPriceRequest) and V3 (Assertion) schemas
"""

import json
import pandas as pd
from pathlib import Path

def process_v2_jsonl(network_name, jsonl_file):
    """Process V2 schema JSONL file"""
    records = []
    
    with open(jsonl_file, 'r') as f:
        for line in f:
            if line.strip():
                try:
                    record = json.loads(line)
                    records.append(record)
                except json.JSONDecodeError as e:
                    print(f"  Warning: Skipping malformed line in {network_name}")
                    continue
    
    if records:
        df = pd.DataFrame(records)
        return df
    return None

def main():
    output_dir = Path("data-dumps/august_2025")
    
    print("=== CONVERTING AUGUST 2025 DATA ===\n")
    
    # V2 Networks
    v2_networks = {
        'polygon_v2_old': 'polygon_v2_old_all.jsonl',
        'polygon_v2_new': 'polygon_v2_new_all.jsonl',
        'base_v2': 'base_v2_all.jsonl',
        'blast_v2': 'blast_v2_all.jsonl'
    }
    
    total_records = 0
    
    for network, jsonl_file in v2_networks.items():
        file_path = output_dir / jsonl_file
        
        if not file_path.exists():
            print(f"{network}: File not found")
            continue
            
        print(f"Processing: {network}")
        df = process_v2_jsonl(network, file_path)
        
        if df is not None and len(df) > 0:
            csv_path = output_dir / f"{network}.csv"
            df.to_csv(csv_path, index=False)
            
            print(f"  ✓ {len(df)} records")
            print(f"  ✓ Saved to: {csv_path.name}")
            total_records += len(df)
        else:
            print(f"  ✗ No valid data")
        
        print()
    
    print(f"=== CONVERSION COMPLETE ===")
    print(f"Total records: {total_records}")
    print(f"\nFiles created in: {output_dir}")

if __name__ == "__main__":
    main()

