import pandas as pd
import re

print("Loading CSV...")
df = pd.read_csv('/Users/abhinavtaneja/Developer/uma-research/uma_sep_all_text_full.csv')

print(f"Total rows in CSV: {len(df)}")

# Define the filter function
def is_crypto_price_prediction(text):
    if not isinstance(text, str):
        return False
    
    lower_text = text.lower()
    
    # Crypto keywords
    crypto_keywords = [
        'bitcoin', 'ethereum', 'xrp', 'btc', 'eth', 'solana', 'sol', 
        'cardano', 'ada', 'litecoin', 'ltc', 'dogecoin', 'doge'
    ]
    
    # Price patterns
    price_patterns = [
        r'will the price of',
        r'price.*between.*\$',
        r'price.*(?:less than|greater than|above|below)',
    ]
    
    has_crypto = any(keyword in lower_text for keyword in crypto_keywords)
    has_price_pattern = any(re.search(pattern, lower_text, re.IGNORECASE) for pattern in price_patterns)
    
    return has_crypto and has_price_pattern

print("Filtering for crypto price predictions...")
df['is_price_prediction'] = df['ancillaryData'].apply(is_crypto_price_prediction)

filtered_df = df[df['is_price_prediction'] == True].copy()
print(f"Filtered rows: {len(filtered_df)}")

# Drop the helper column
filtered_df = filtered_df.drop('is_price_prediction', axis=1)

# Save to new CSV
output_path = '/Users/abhinavtaneja/Developer/uma-research/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv'
filtered_df.to_csv(output_path, index=False)

print(f"\n✅ Saved to: {output_path}")
print(f"Total filtered proposals: {len(filtered_df)}")
print(f"File size: {filtered_df.memory_usage(deep=True).sum() / 1024 / 1024:.2f} MB")
