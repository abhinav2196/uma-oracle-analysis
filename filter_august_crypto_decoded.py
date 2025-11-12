#!/usr/bin/env python3
"""
Properly filter August 2025 crypto predictions with hex decoding
"""

import pandas as pd
import re
from pathlib import Path

def decode_hex_ancillary(hex_string):
    """Decode hex ancillaryData to readable text"""
    if not isinstance(hex_string, str):
        return ""
    
    try:
        if hex_string.startswith('0x'):
            hex_string = hex_string[2:]
        decoded = bytes.fromhex(hex_string).decode('utf-8', errors='ignore')
        return decoded
    except:
        return ""

def is_crypto_price_prediction(text):
    """Check if decoded text matches crypto price prediction patterns"""
    if not isinstance(text, str):
        return False
    
    lower_text = text.lower()
    
    crypto_keywords = [
        'bitcoin', 'ethereum', 'xrp', 'btc', 'eth', 'solana', 'sol', 
        'cardano', 'ada', 'litecoin', 'ltc', 'dogecoin', 'doge',
        'bnb', 'binance', 'avalanche', 'avax', 'polygon', 'matic',
        'chainlink', 'link', 'uniswap', 'uni'
    ]
    
    price_patterns = [
        r'will the.*price',
        r'price.*(?:greater than|less than|above|below|between)',
        r'(?:up|down).*(?:usdt|usd)',
        r'eth/usdt|btc/usdt|sol/usdt',
        r'close price.*open price'
    ]
    
    has_crypto = any(keyword in lower_text for keyword in crypto_keywords)
    has_price_pattern = any(re.search(pattern, lower_text, re.IGNORECASE) for pattern in price_patterns)
    
    return has_crypto and has_price_pattern

# Process all networks
networks = {
    'Polygon V2 (old)': 'data-dumps/august_2025/polygon_v2_old.csv',
    'Polygon V2 (new)': 'data-dumps/august_2025/polygon_v2_new.csv',
    'Base V2': 'data-dumps/august_2025/base_v2.csv',
    'Blast V2': 'data-dumps/august_2025/blast_v2.csv'
}

print("=== AUGUST 2025 CRYPTO FILTERING (WITH HEX DECODING) ===\n")

all_crypto = []
network_stats = []

for network, path in networks.items():
    try:
        df = pd.read_csv(path)
        total = len(df)
        
        # Decode and filter
        df['decoded_ancillary'] = df['ancillaryData'].apply(decode_hex_ancillary)
        df['is_crypto'] = df['decoded_ancillary'].apply(is_crypto_price_prediction)
        
        crypto = df[df['is_crypto'] == True].copy()
        crypto_count = len(crypto)
        pct = (crypto_count / total * 100) if total > 0 else 0
        
        print(f"{network}:")
        print(f"  Total: {total:,}")
        print(f"  Crypto: {crypto_count:,} ({pct:.2f}%)")
        
        network_stats.append({
            'network': network,
            'total': total,
            'crypto': crypto_count,
            'percentage': pct
        })
        
        if crypto_count > 0:
            crypto['network'] = network
            all_crypto.append(crypto)
        
    except Exception as e:
        print(f"{network}: Error - {e}")
    
    print()

# Combine and save
total_assertions = sum(s['total'] for s in network_stats)
total_crypto = sum(s['crypto'] for s in network_stats)

print(f"=== TOTALS ===")
print(f"Total Assertions: {total_assertions:,}")
print(f"Crypto Predictions: {total_crypto:,}")
print(f"Overall %: {100 * total_crypto / total_assertions:.2f}%\n")

if all_crypto:
    combined = pd.concat(all_crypto, ignore_index=True)
    
    # Save combined
    output_path = 'data-dumps/august_2025/august_2025_crypto_all_networks.csv'
    combined.to_csv(output_path, index=False)
    print(f"✅ Combined crypto data: {output_path}")
    print(f"   {len(combined):,} records\n")
    
    # Save per-network
    for network in combined['network'].unique():
        network_data = combined[combined['network'] == network]
        safe_name = network.replace(' ', '_').replace('(', '').replace(')', '').lower()
        out_path = f'data-dumps/august_2025/{safe_name}_crypto.csv'
        network_data.to_csv(out_path, index=False)
        print(f"  {network}: {len(network_data):,} → {out_path}")
    
    # Summary
    summary_df = pd.DataFrame(network_stats)
    summary_df.to_csv('data-dumps/august_2025/crypto_summary.csv', index=False)
    print(f"\n✅ Summary: data-dumps/august_2025/crypto_summary.csv")

else:
    print("❌ No crypto predictions found")

PYTHON

