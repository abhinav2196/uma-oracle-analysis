#!/usr/bin/env python3
"""
Filter crypto price predictions from UMA oracle proposals
Supports multiple networks and time periods

Usage: python3 filter_crypto_predictions.py <network> [time_period]
Example: python3 filter_crypto_predictions.py polygon september_2025
"""

import pandas as pd
import re
import sys
from pathlib import Path

def is_crypto_price_prediction(text):
    """Check if text matches crypto price prediction patterns"""
    if not isinstance(text, str):
        return False
    
    lower_text = text.lower()
    
    # Crypto keywords
    crypto_keywords = [
        'bitcoin', 'ethereum', 'xrp', 'btc', 'eth', 'solana', 'sol', 
        'cardano', 'ada', 'litecoin', 'ltc', 'dogecoin', 'doge'
    ]
    
    # Price patterns (must match at least one)
    price_patterns = [
        r'will the price of',
        r'price.*between.*\$',
        r'price.*(?:less than|greater than|above|below)',
    ]
    
    has_crypto = any(keyword in lower_text for keyword in crypto_keywords)
    has_price_pattern = any(re.search(pattern, lower_text, re.IGNORECASE) for pattern in price_patterns)
    
    return has_crypto and has_price_pattern


def main():
    # Parse arguments
    network = sys.argv[1] if len(sys.argv) > 1 else 'polygon'
    time_period = sys.argv[2] if len(sys.argv) > 2 else 'september_2025'
    
    # Setup paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    data_dir = project_root / 'data-dumps' / network
    
    input_csv = data_dir / f'uma_{time_period}_full.csv'
    output_csv = data_dir / f'uma_{time_period}_crypto_price_predictions.csv'
    
    print(f"=================================================================")
    print(f"  UMA Crypto Price Prediction Filter")
    print(f"=================================================================")
    print(f"Network:      {network}")
    print(f"Time Period:  {time_period}")
    print(f"Input:        {input_csv}")
    print(f"Output:       {output_csv}")
    print()
    
    # Check if input exists
    if not input_csv.exists():
        print(f"❌ ERROR: Input file not found: {input_csv}")
        print()
        print("Run convert_json_to_csv.sh first:")
        print(f"  ./convert_json_to_csv.sh {network} {time_period}")
        sys.exit(1)
    
    # Load data
    print("Loading CSV...")
    df = pd.read_csv(input_csv)
    print(f"Total rows: {len(df):,}")
    
    # Apply filter
    print("Filtering for crypto price predictions...")
    df['is_price_prediction'] = df['ancillaryData'].apply(is_crypto_price_prediction)
    
    filtered_df = df[df['is_price_prediction'] == True].copy()
    filtered_df = filtered_df.drop('is_price_prediction', axis=1)
    
    print(f"Filtered rows: {len(filtered_df):,}")
    print(f"Filter rate: {100 * len(filtered_df) / len(df):.2f}%")
    print()
    
    # Save output
    filtered_df.to_csv(output_csv, index=False)
    
    file_size_mb = filtered_df.memory_usage(deep=True).sum() / 1024 / 1024
    
    print("=================================================================")
    print("✅ Success!")
    print("=================================================================")
    print(f"Saved to:            {output_csv}")
    print(f"Total proposals:     {len(filtered_df):,}")
    print(f"File size:           {file_size_mb:.2f} MB")
    print()
    
    # Show breakdown by asset
    print("Asset breakdown:")
    
    def get_asset(text):
        if not isinstance(text, str):
            return 'OTHER'
        lower_text = text.lower()
        # Use word boundaries to avoid false matches
        if re.search(r'\bbitcoin\b|\bbtc\b', lower_text):
            return 'BTC'
        elif re.search(r'\bethereum\b|\beth\b', lower_text):
            return 'ETH'
        elif re.search(r'\bxrp\b|\bripple\b', lower_text):
            return 'XRP'
        elif re.search(r'\bsolana\b|\bsol\b', lower_text):
            return 'SOL'
        elif re.search(r'\bcardano\b|\bada\b', lower_text):
            return 'ADA'
        elif re.search(r'\blitecoin\b|\bltc\b', lower_text):
            return 'LTC'
        elif re.search(r'\bdogecoin\b|\bdoge\b', lower_text):
            return 'DOGE'
        else:
            return 'OTHER'
    
    filtered_df['asset'] = filtered_df['ancillaryData'].apply(get_asset)
    breakdown = filtered_df['asset'].value_counts()
    
    for asset, count in breakdown.items():
        pct = 100 * count / len(filtered_df)
        print(f"  {asset:8s} {count:6,d} ({pct:5.2f}%)")
    
    print()


if __name__ == '__main__':
    main()

