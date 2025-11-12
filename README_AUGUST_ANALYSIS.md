# August 2025 UMA Oracle Analysis - Complete

## What Was Done

1. **Network Discovery:** 17 working subgraph IDs across 6 networks
2. **Data Fetch:** August 2025 from Polygon, Base, Blast (13,804 assertions)  
3. **Schema Handling:** V2 (time) and V3 (assertionTimestamp) properly differentiated
4. **Hex Decoding:** Fixed encoding issue (August uses hex, September uses plain text)
5. **Crypto Filtering:** Text-based filtering with proper decoding

## Results

**August 2025:**
- Total: 13,804 assertions
- Crypto: 5,136 (37%)
- Networks: Polygon (100%), Base, Blast

**Files:**
- `data-dumps/august_2025/august_2025_crypto_all_networks.csv` - 5,136 crypto predictions
- `data-dumps/august_2025/polygon_v2_old_crypto.csv` - 5,130 predictions
- Individual network CSVs in `data-dumps/august_2025/`

## Key Finding

**August had BOTH crypto predictions and prediction markets:**
- Crypto: 37% (5,136)
- Markets: 63% (8,668)

**September specialized in crypto:**
- Crypto: 100% (~17,830)
- Markets: 0%

## Technical Achievement

✅ All 17 subgraph IDs validated  
✅ Multi-network data fetched  
✅ Hex decoding implemented  
✅ Text filtering working  
✅ Clean CSV exports generated

