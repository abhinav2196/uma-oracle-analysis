# August 2025 UMA Oracle Analysis - CORRECTED REPORT

**Period:** August 1-31, 2025  
**Report Date:** November 12, 2025  
**Method:** Hex-decoded ancillaryData text filtering

---

## FINAL RESULTS

### Total Activity
- **Total Assertions:** 13,804
- **Crypto Price Predictions:** 5,136 (37.21%)
- **Other (Prediction Markets):** 8,668 (62.79%)

### Network Distribution
| Network | Total | Crypto | % Crypto | % of Total |
|---------|-------|--------|----------|------------|
| **Polygon V2 (old)** | 13,715 | 5,130 | 37.40% | 99.35% |
| **Polygon V2 (new)** | 11 | 6 | 54.55% | 0.08% |
| **Base V2** | 56 | 0 | 0.00% | 0.41% |
| **Blast V2** | 22 | 0 | 0.00% | 0.16% |
| **TOTAL** | **13,804** | **5,136** | **37.21%** | **100%** |

---

## COMPARISON: AUGUST vs SEPTEMBER 2025

| Metric | August 2025 | September 2025 |
|--------|-------------|----------------|
| Total Assertions | 13,804 | 15,566 |
| Crypto Predictions | 5,136 (37.2%) | ~17,830 (99.98%) |
| Other Use Cases | 8,668 (62.8%) | ~31 (0.02%) |
| Active Networks | 4 | 1 |
| Dominant Network | Polygon (99.4%) | Polygon (100%) |

### Key Insight
**Oracle usage evolved from mixed (Aug) to specialized (Sept):**
- **August:** Mixed use - 37% crypto, 63% prediction markets
- **September:** Almost pure crypto price predictions (99.98%)

---

## AUGUST 2025 USE CASES

### Crypto Price Predictions (37.21%)
- 5,136 assertions
- "Ethereum Up or Down" style queries
- Price movement predictions
- ETH, BTC, and other crypto assets
- **All on Polygon**

### Prediction Markets (62.79%)
- 8,668 assertions
- Sports, weather, politics
- YES_OR_NO_QUERY identifier
- Examples: MLB games, temperature predictions, League of Legends
- **Across Polygon, Base, Blast**

---

## TECHNICAL DETAILS

### Data Collection
- **Subgraphs Queried:** 17
- **Networks with Data:** 4 (Polygon, Base, Blast, Optimism shown but 0 crypto)
- **Pagination:** Implemented (Polygon hit 13,715 records)
- **Schema Handling:** V2 (time field) vs V3 (assertionTimestamp field)

### Filtering Method
1. Decode hex ancillaryData (e.g., `0x713a20...` → readable text)
2. Search for crypto keywords (bitcoin, ethereum, btc, eth, etc.)
3. Search for price patterns ("price between", "up or down", etc.)
4. Must match BOTH crypto keyword AND price pattern

### Files Generated
- `polygon_v2_old_crypto.csv` - 5,130 records
- `polygon_v2_new_crypto.csv` - 6 records
- `august_2025_crypto_all_networks.csv` - 5,136 combined
- `crypto_summary.csv` - Network statistics

---

## CORRECTED CONCLUSIONS

### August 2025 Oracle Usage
✅ **Total Activity:** 13,804 assertions across 4 networks  
✅ **Crypto Predictions:** 5,136 (37%) - Mixed with prediction markets  
✅ **Polygon Dominance:** 99.4% of all activity, 100% of crypto  
✅ **Emerging Networks:** Base and Blast active but no crypto queries

### Evolution to September
- **Crypto %:** 37% → 99.98% (massive shift)
- **Total Volume:** 13,804 → 15,566 (+12.8%)
- **Use Case:** Mixed → Pure crypto price feeds
- **Networks:** 4 active → 1 with data (Polygon)

### Current State (November 2025)
- Per screenshot: 5,624 active requests across 6 networks
- Multi-network expansion post-September
- Polygon remains dominant (91.6%)

---

## FILES & DATA QUALITY

✅ All 17 subgraph IDs tested and validated  
✅ Hex decoding implemented correctly  
✅ Pagination handled (13,715 Polygon records)  
✅ V2 and V3 schemas properly differentiated  
✅ Text-based filtering matching September methodology  
✅ Cross-network data merged

**Data Location:** `data-dumps/august_2025/`


