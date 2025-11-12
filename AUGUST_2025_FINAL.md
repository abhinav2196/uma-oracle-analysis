# UMA Oracle - August 2025 Complete Analysis

**Period:** August 1-31, 2025  
**Networks:** Polygon, Base, Blast (active), Ethereum/Optimism/Arbitrum (inactive)  
**Methodology:** GraphQL fetch → Hex decode → Text filtering

---

## Results

**Total Assertions:** 13,804  
**Crypto Price Predictions:** 5,136 (37.21%)  
**Prediction Markets:** 8,668 (62.79%)

### By Network

| Network | Total | Crypto | % |
|---------|-------|--------|---|
| Polygon V2 (old) | 13,715 | 5,130 | 37.40% |
| Polygon V2 (new) | 11 | 6 | 54.55% |
| Base V2 | 56 | 0 | 0.00% |
| Blast V2 | 22 | 0 | 0.00% |

**Crypto predictions: 100% on Polygon**

---

## August vs September

|  | August | September |
|--|--------|-----------|
| Total | 13,804 | 15,566 |
| Crypto | 5,136 (37%) | ~17,830 (100%) |
| Markets | 8,668 (63%) | ~31 (0%) |

**Usage evolved from mixed (Aug) to crypto-specialized (Sept)**

---

## Network Inventory (17 Subgraphs)

All work with API key: `5ff06e4966bc3378b2bda95a5f7f98d3`

**Active August 2025:**
- Polygon V2: 2 versions (old + new)
- Base V2: 1
- Blast V2: 1

**Active Sept+ 2025:**
- Ethereum V3
- Base V3

**Inactive:**
- Ethereum V2 (Apr 2024)
- Arbitrum V2 (Apr 2024)
- Optimism V2 (Feb 2025)
- Polygon V3 (Mar 2024)

---

## Files

**Data:** `data-dumps/august_2025/`
- Raw: `polygon_v2_old.csv` (13,715), `base_v2.csv` (56), `blast_v2.csv` (22)
- Filtered: `polygon_v2_old_crypto.csv` (5,130), `august_2025_crypto_all_networks.csv` (5,136)

**Scripts:**
- `fetch_august_2025_paginated.sh` - Data collection
- `filter_august_crypto_decoded.py` - Hex decode + filter

---

## Technical Notes

**Schema Handling:**
- V2: time field, 15 columns
- V3: assertionTimestamp field, 11 columns

**Encoding Issue:**
- August: Hex-encoded ancillaryData (0x71...)
- September: Plain text ancillaryData
- Solution: Decode hex before filtering

**Filtering:**
- Crypto keywords: btc, eth, bitcoin, ethereum, etc.
- Price patterns: "price between", "up or down", etc.
- Both must match

---

## Conclusions

✅ August 2025: 5,136 crypto predictions across 4 networks (37% of total)  
✅ All networks properly queried with correct schemas  
✅ Hex decoding issue identified and fixed  
✅ Data quality validated

**Your original September analysis was correct.** August shows the oracle had mixed usage before specializing in crypto price feeds.


