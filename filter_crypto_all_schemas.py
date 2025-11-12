#!/usr/bin/env python3
"""
Filter crypto predictions from both V2 and V3 oracle schemas
Handles hex decoding for both ancillaryData (V2) and claim (V3)
"""

import pandas as pd
import re
from pathlib import Path

def decode_hex(hex_string):
    """Decode hex-encoded data to readable text"""
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
        'chainlink', 'link', 'uniswap', 'uni', 'polkadot', 'dot'
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

def filter_v2_data(csv_path, network_name):
    """Filter V2 schema data (ancillaryData field)"""
    df = pd.read_csv(csv_path)
    
    # Decode and filter
    df['decoded_text'] = df['ancillaryData'].apply(decode_hex)
    df['is_crypto'] = df['decoded_text'].apply(is_crypto_price_prediction)
    
    crypto = df[df['is_crypto'] == True].copy()
    
    return len(df), crypto

def filter_v3_data(csv_path, network_name):
    """Filter V3 schema data (claim field)"""
    df = pd.read_csv(csv_path)
    
    # Decode and filter - V3 uses 'claim' field instead of 'ancillaryData'
    df['decoded_text'] = df['claim'].apply(decode_hex)
    df['is_crypto'] = df['decoded_text'].apply(is_crypto_price_prediction)
    
    crypto = df[df['is_crypto'] == True].copy()
    
    return len(df), crypto

def main():
    print("=== AUGUST 2025 CRYPTO FILTERING (MULTI-SCHEMA) ===\n")
    print("V2: Decoding ancillaryData field")
    print("V3: Decoding claim field\n")
    
    all_crypto = []
    network_stats = []
    
    # V2 Networks (use ancillaryData)
    v2_networks = {
        'Polygon V2 (old)': 'data-dumps/august_2025/polygon_v2_old.csv',
        'Polygon V2 (new)': 'data-dumps/august_2025/polygon_v2_new.csv',
        'Base V2': 'data-dumps/august_2025/base_v2.csv',
        'Blast V2': 'data-dumps/august_2025/blast_v2.csv'
    }
    
    for network, path in v2_networks.items():
        if not Path(path).exists():
            continue
            
        try:
            total, crypto = filter_v2_data(path, network)
            crypto_count = len(crypto)
            pct = (crypto_count / total * 100) if total > 0 else 0
            
            print(f"{network} (V2):")
            print(f"  Total: {total:,}")
            print(f"  Crypto: {crypto_count:,} ({pct:.2f}%)")
            print(f"  Field: ancillaryData (hex-decoded)")
            
            network_stats.append({
                'network': network,
                'schema': 'V2',
                'field': 'ancillaryData',
                'total': total,
                'crypto': crypto_count,
                'percentage': pct
            })
            
            if crypto_count > 0:
                crypto['network'] = network
                crypto['schema'] = 'V2'
                all_crypto.append(crypto)
            
        except Exception as e:
            print(f"{network}: Error - {e}")
        
        print()
    
    # V3 Networks (use claim field) - likely no August data but check anyway
    v3_networks = {
        'Polygon V3': 'data-dumps/august_2025/polygon_v3.csv',
        'Ethereum V3': 'data-dumps/august_2025/ethereum_v3.csv',
        'Base V3': 'data-dumps/august_2025/base_v3.csv',
        'Optimism V3': 'data-dumps/august_2025/optimism_v3.csv',
        'Arbitrum V3': 'data-dumps/august_2025/arbitrum_v3.csv'
    }
    
    v3_had_data = False
    for network, path in v3_networks.items():
        if Path(path).exists():
            try:
                total, crypto = filter_v3_data(path, network)
                crypto_count = len(crypto)
                
                if total > 0:
                    v3_had_data = True
                    pct = (crypto_count / total * 100) if total > 0 else 0
                    
                    print(f"{network} (V3):")
                    print(f"  Total: {total:,}")
                    print(f"  Crypto: {crypto_count:,} ({pct:.2f}%)")
                    print(f"  Field: claim (hex-decoded)")
                    
                    network_stats.append({
                        'network': network,
                        'schema': 'V3',
                        'field': 'claim',
                        'total': total,
                        'crypto': crypto_count,
                        'percentage': pct
                    })
                    
                    if crypto_count > 0:
                        crypto['network'] = network
                        crypto['schema'] = 'V3'
                        all_crypto.append(crypto)
                    
                    print()
            except Exception as e:
                pass  # File might not have data
    
    if not v3_had_data:
        print("V3 Networks: No August 2025 data (as expected)\n")
    
    # Summary
    total_assertions = sum(s['total'] for s in network_stats)
    total_crypto = sum(s['crypto'] for s in network_stats)
    
    print(f"=== FINAL TOTALS ===")
    print(f"Total Assertions: {total_assertions:,}")
    print(f"Crypto Predictions: {total_crypto:,}")
    print(f"Overall %: {100 * total_crypto / total_assertions:.2f}%\n")
    
    # Save combined data
    if all_crypto:
        combined = pd.concat(all_crypto, ignore_index=True)
        output_path = 'data-dumps/august_2025/crypto_all_schemas.csv'
        combined.to_csv(output_path, index=False)
        print(f"✅ Combined: {output_path} ({len(combined):,} records)")
        
        # Save summary
        summary_df = pd.DataFrame(network_stats)
        summary_df.to_csv('data-dumps/august_2025/schema_summary.csv', index=False)
        print(f"✅ Summary: data-dumps/august_2025/schema_summary.csv")
        
        print(f"\nPer-network breakdown:")
        for _, row in summary_df.iterrows():
            print(f"  {row['network']:20s} ({row['schema']}): {row['crypto']:5,d} crypto ({row['percentage']:5.2f}%)")

if __name__ == "__main__":
    main()

