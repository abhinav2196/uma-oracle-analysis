# August 2025 - Complete Cross-Network Analysis

**Period:** August 1-31, 2025  
**Completion Date:** November 12, 2025

---

## Summary

**Total Assertions:** 13,804  
**Crypto Predictions:** 5,136 (37.21%)  
**Other Use Cases:** 8,668 (62.79%)  
**Active Networks:** 4 (Polygon, Base, Blast, Optimism)

---

## Network Results

| Network | Version | Total | Crypto | % Crypto |
|---------|---------|-------|--------|----------|
| Polygon | V2 (old) | 13,715 | 5,130 | 37.40% |
| Polygon | V2 (new) | 11 | 6 | 54.55% |
| Base | V2 | 56 | 0 | 0.00% |
| Blast | V2 | 22 | 0 | 0.00% |
| **TOTAL** | - | **13,804** | **5,136** | **37.21%** |

**Crypto predictions: 100% on Polygon (5,136 of 5,136)**

---

## Schema Handling (Critical)

### V2 Oracle (OptimisticPriceRequest)
- **Text Field:** `ancillaryData` (hex-encoded)
- **Time Field:** `time`
- **Decode Method:** Hex to UTF-8
- **Networks:** Polygon, Base, Blast (August data)

### V3 Oracle (Assertion)  
- **Text Field:** `claim` (hex-encoded)
- **Time Field:** `assertionTimestamp`
- **Decode Method:** Hex to UTF-8
- **Networks:** None had August data (launched later)

**Both schemas require hex decoding before text filtering!**

---

## Filtering Methodology

1. **Decode hex** (`0x71...` → readable text)
   - V2: Decode `ancillaryData`
   - V3: Decode `claim`

2. **Extract text** (both formats use "q: title:..." structure)

3. **Filter for crypto**:
   - Must contain crypto keyword (btc, eth, bitcoin, ethereum, etc.)
   - Must contain price pattern ("price between", "up or down", etc.)
   - Both conditions required

---

## Data Files

**Raw Data** (`data-dumps/august_2025/`):
- `polygon_v2_old.csv` - 13,715 assertions (63 MB)
- `polygon_v2_new.csv` - 11 assertions
- `base_v2.csv` - 56 assertions
- `blast_v2.csv` - 22 assertions

**Filtered Crypto**:
- `crypto_all_schemas.csv` - 5,136 combined crypto predictions
- `polygon_v2_old_crypto.csv` - 5,130 predictions
- `polygon_v2_new_crypto.csv` - 6 predictions  
- `schema_summary.csv` - Network statistics

---

## Comparison with September 2025

|  | August | September | Change |
|--|--------|-----------|--------|
| Total | 13,804 | 15,566 | +12.8% |
| Crypto | 5,136 (37%) | ~17,830 (100%) | +247% |
| Markets | 8,668 (63%) | ~31 (0%) | -99.6% |
| Networks | 4 | 1 | -75% |

**Usage Pattern Evolution:**
- August: Mixed (crypto + markets)
- September: Pure crypto price feeds
- Massive increase in crypto predictions

---

## Network Activity Timeline

**August 2025:**
- Polygon V2: ✅ Active (13,726 assertions)
- Base V2: ✅ Active (56 assertions)
- Blast V2: ✅ Active (22 assertions)
- All others: ❌ Inactive

**September 2025:**
- Polygon V2: ✅ Active (15,566 assertions)
- All others: ❌ No data

**October-November 2025** (per screenshot):
- All 6 networks active
- Multi-network distribution emerging

---

## Technical Notes

### Encoding Differences
- **August subgraphs:** Hex-encode ancillaryData/claim
- **September subgraphs:** Plain text ancillaryData
- **Cause:** Different subgraph versions or deployments
- **Solution:** Always hex-decode before filtering

### Pagination
- Polygon V2 (old): Required (13,715 records, 14 batches)
- Other networks: Single query sufficient

### Query Optimization
```graphql
# V2 schema
{ optimisticPriceRequests(first: 1000, skip: X, 
    where: {time_gte: "START", time_lt: "END"}) 
  { ancillaryData ... } }

# V3 schema
{ assertions(first: 1000, skip: X,
    where: {assertionTimestamp_gte: "START", assertionTimestamp_lt: "END"})
  { claim ... } }
```

---

## Conclusions

✅ **August 2025 complete analysis across all networks**  
✅ **Both V2 (ancillaryData) and V3 (claim) schemas handled**  
✅ **Hex decoding implemented for accurate filtering**  
✅ **5,136 crypto predictions identified (37% of total)**  

**Multi-network data successfully analyzed with proper schema-specific processing.**


