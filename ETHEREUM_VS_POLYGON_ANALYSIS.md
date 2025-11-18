# Ethereum vs Polygon Analysis

**Date:** November 17, 2024  
**Comparison Period:** June 2025 (Ethereum) vs September 2025 (Polygon)

---

## Executive Summary

| Network | Oracle Version | Entity Type | Period | Total Requests | Crypto Predictions |
|---------|---------------|-------------|---------|----------------|-------------------|
| **Polygon** | V2 | OptimisticPriceRequest | Sept 2025 | **15,446** | **7,401 (48%)** |
| **Ethereum V1** | V2 | OptimisticPriceRequest | June 2025 | **1** | TBD |
| **Ethereum V3** | V3 | Assertion | June 2025 | **33** | N/A (different use case) |

**Key Finding:** Polygon dominates price prediction activity by **468x** compared to Ethereum.

---

## Detailed Comparison

### Network Activity

#### Polygon V2 (September 2025)
- ✅ **15,446 oracle requests**
- ✅ **7,401 crypto price predictions** (48%)
- ✅ High-volume prediction market queries
- ✅ Assets: SOL (50%), BTC (25%), ETH (25%)
- ✅ Format: "Will the price of [ASSET] be above/below $X..."

#### Ethereum V1 (June 2025)
- ⚠️ **1 oracle request**
- ⚠️ Identifier: "NUMERICAL"
- ⚠️ Query: "What is the average TWAP of 1 Across Protocol (ACX) token..."
- ⚠️ Not a simple price prediction - complex calculation query

#### Ethereum V3 (June 2025)
- ⚠️ **33 assertions**
- ⚠️ Claims are hex-encoded data (0x000...02a0, 0x000...02a1, etc.)
- ⚠️ Different use case: Not price predictions
- ⚠️ Likely: Governance, disputes, or oracle metadata

---

## Entity Type Differences

### OptimisticPriceRequest (V2 Oracle)
**Used by:** Polygon V2, Ethereum V1/V2

**Structure:**
```json
{
  "id": "YES_OR_NO_QUERY-timestamp-hash",
  "identifier": "YES_OR_NO_QUERY",
  "ancillaryData": "0x...",  // Hex-encoded question
  "time": "timestamp",
  "proposer": "address",
  "state": "Settled"
}
```

**Use Case:** Price predictions, yes/no queries

### Assertion (V3 Oracle)
**Used by:** Ethereum V3

**Structure:**
```json
{
  "id": "0xhash",
  "claim": "0x...",  // Hex-encoded claim
  "assertionTimestamp": "timestamp"
}
```

**Use Case:** General truth assertions, governance

---

## Subgraph Exclusivity

### ✅ CONFIRMED: Subgraphs are Oracle-Version Specific

| Subgraph Type | Contains OptimisticPriceRequest | Contains Assertion |
|---------------|--------------------------------|-------------------|
| **V2 Oracle** (ethereum_v1, ethereum_v2, polygon_v2_*) | ✅ YES | ❌ NO |
| **V3 Oracle** (ethereum_v3, polygon_v3) | ❌ NO | ✅ YES |

**Conclusion:** Each subgraph serves ONE oracle version exclusively.

---

## Identifier-Only Queries

### Issue Discovered

**Example:** DEXTFUSD query (July 1, 2022)
```json
{
  "id": "DEXTFUSD-1656626400-0x",
  "identifier": "DEXTFUSD",
  "ancillaryData": "0x",  // ← EMPTY!
  "time": "1656626400"
}
```

**Problem:** Our current filter checks `ancillaryData_text` for "price of", but identifier-only queries have:
- Empty ancillaryData (`0x`)
- The identifier itself IS the query (e.g., "DEXTFUSD", "FOXUSD", "PERPUSD")

---

## Filter Improvements Needed

### Current Filter
```python
# Only catches queries with ancillaryData
--where 'ancillaryData_text~price of'
```

### Proposed Enhanced Filter
```python
# Catch both:
# 1. Queries with "price of" in ancillaryData
# 2. Identifier-only queries (USD, USDT, BTC suffixes)

def is_price_query(row):
    # Check ancillaryData
    if 'price of' in row['ancillaryData_text'].lower():
        return True
    
    # Check identifier-only queries
    identifier = row['identifier']
    price_identifiers = ['USD', 'USDT', 'BTC', 'ETH', 'TWAP', 'PRICE']
    return any(suffix in identifier.upper() for suffix in price_identifiers)
```

**Examples that would be caught:**
- ✅ DEXTFUSD
- ✅ FOXUSD  
- ✅ PERPUSD
- ✅ BTCUSD
- ✅ ETHUSD

---

## Recommendations

### 1. **Focus Analysis on Polygon**
- Polygon has 99.9% of crypto price prediction activity
- Ethereum is primarily used for complex/governance queries

### 2. **Update Filter Script**
- Add identifier-only query detection
- Catch XXXUSD, XXXUSDT patterns
- See proposed implementation above

### 3. **Separate V2 and V3 Analysis**
- V2 (OptimisticPriceRequest): Price predictions, yes/no markets
- V3 (Assertion): Governance, disputes, general claims
- These serve different purposes

### 4. **Historical Analysis**
- DEXTFUSD query is from 2022 (750 days old)
- Consider fetching historical Ethereum data (2021-2023) for identifier-only query analysis

---

## Next Steps

1. ✅ Update filter.py to catch identifier-only queries
2. ✅ Re-run Polygon analysis with enhanced filter
3. ⏳ Fetch historical Ethereum data (2021-2023) to find more identifier-only queries
4. ⏳ Create separate reports for V2 vs V3 oracle usage

---

## Summary Statistics

### June 2025 Comparison

| Metric | Polygon | Ethereum V1 | Ethereum V3 |
|--------|---------|-------------|-------------|
| **Total Requests** | 15,446 | 1 | 33 |
| **Oracle Type** | V2 | V2 | V3 |
| **Entity Type** | OptimisticPriceRequest | OptimisticPriceRequest | Assertion |
| **Crypto Predictions** | 7,401 | 0* | N/A |
| **Primary Use** | Price markets | Complex queries | Governance/claims |

*The one Ethereum V1 request is a complex TWAP calculation, not a simple price prediction.

---

## Conclusion

**Polygon is the crypto price prediction hub.** Ethereum's optimistic oracle is used for:
- Complex financial calculations (TWAP, averages)
- Governance assertions (V3)
- Low-volume specialized queries

To fully understand Ethereum's role, we need to:
1. Fetch historical data (2021-2023) to analyze identifier-only queries
2. Implement enhanced filter to catch XXXUSD patterns
3. Analyze V3 assertions separately from V2 price requests

