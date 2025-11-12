#!/usr/bin/env python3
"""
Filter August 2025 data for crypto price predictions across all networks
"""

import pandas as pd
from pathlib import Path

# Crypto identifiers to filter for
CRYPTO_IDENTIFIERS = [
    'BTCUSD', 'ETHUSD', 'USDETH', 'USDBTC', 
    'EURUSD', 'USDJPY', 'GBPUSD',
    'AAVEUSD', 'ADAUSD', 'ALGOUSD', 'ATOMUSD', 'AVAXUSD',
    'BCHUSD', 'BNBUSD', 'COMPUSD', 'DOGEUSD', 'DOTUSD',
    'EOSUSD', 'ETCUSD', 'FILUSD', 'LINKUSD', 'LTCUSD',
    'MATICUSD', 'MKRUSD', 'NEOUSD', 'SNXUSD', 'SOLUSD',
    'SUSHIUSD', 'THETAUSD', 'TRXUSD', 'UNIUSD', 'VETUSD',
    'XLMUSD', 'XMRUSD', 'XRPUSD', 'XTZUSD', 'ZECUSD'
]

def is_crypto_prediction(identifier):
    """Check if identifier is a crypto price prediction"""
    if pd.isna(identifier):
        return False
    
    identifier = str(identifier).upper()
    return any(crypto in identifier for crypto in CRYPTO_IDENTIFIERS)

def main():
    input_dir = Path("data-dumps/august_2025")
    
    all_data = []
    network_summaries = []
    
    print("=== FILTERING AUGUST 2025 FOR CRYPTO PREDICTIONS ===\n")
    
    # Process each network
    networks = {
        'Polygon V2 (old)': 'polygon_v2_old.csv',
        'Polygon V2 (new)': 'polygon_v2_new.csv',
        'Base V2': 'base_v2.csv',
        'Blast V2': 'blast_v2.csv'
    }
    
    for network_name, csv_file in networks.items():
        csv_path = input_dir / csv_file
        
        if not csv_path.exists():
            print(f"{network_name}: File not found")
            continue
        
        try:
            df = pd.read_csv(csv_path)
            
            total = len(df)
            crypto = df[df['identifier'].apply(is_crypto_prediction)]
            crypto_count = len(crypto)
            percentage = (crypto_count / total * 100) if total > 0 else 0
            
            print(f"{network_name}:")
            print(f"  Total: {total:,}")
            print(f"  Crypto: {crypto_count:,} ({percentage:.2f}%)")
            
            # Add network column for combined data
            crypto['network'] = network_name
            all_data.append(crypto)
            
            network_summaries.append({
                'Network': network_name,
                'Total Assertions': total,
                'Crypto Predictions': crypto_count,
                'Percentage': f"{percentage:.2f}%"
            })
            
        except Exception as e:
            print(f"{network_name}: Error - {e}")
        
        print()
    
    # Combine all networks
    if all_data:
        combined_df = pd.concat(all_data, ignore_index=True)
        combined_path = input_dir / "august_2025_crypto_all_networks.csv"
        combined_df.to_csv(combined_path, index=False)
        
        print(f"=== COMBINED RESULTS ===")
        print(f"Total assertions (all networks): {sum(n['Total Assertions'] for n in network_summaries):,}")
        print(f"Total crypto predictions: {len(combined_df):,}")
        print(f"Overall percentage: {(len(combined_df) / sum(n['Total Assertions'] for n in network_summaries) * 100):.2f}%")
        print(f"\nCombined data saved to: {combined_path.name}")
        
        # Save summary
        summary_df = pd.DataFrame(network_summaries)
        summary_path = input_dir / "network_summary.csv"
        summary_df.to_csv(summary_path, index=False)
        print(f"Summary saved to: {summary_path.name}")
    else:
        print("No data processed!")

if __name__ == "__main__":
    main()

