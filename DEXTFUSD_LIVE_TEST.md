# DEXTFUSD Live Test Results

**Date:** November 17, 2024  
**Test:** End-to-end verification of DEXTFUSD detection

---

## Test Data

**Fetched 4 queries from Ethereum V1 (June-July 2022):**

| ID | Identifier | ancillaryData | ancillaryData_text |
|----|------------|---------------|-------------------|
| 1 | ZODIAC | 0x7072... | proposalHash:9811cf... |
| 2 | **DEXTFUSD** | **0x** | **(empty)** |
| 3 | USDDEXTF | 0xbd0c... | (binary data) |
| 4 | uSPAC10 | 0xd8e6... | (binary data) |

---

## Filter Test Results

### ❌ OLD Filter: `ancillaryData_text~'price of'`

**Command:**
```bash
python3 scripts/filter.py --where 'ancillaryData_text~price of'
```

**Result:** **0/4 rows matched**

**Caught:**
- None

**Why:** DEXTFUSD has empty `ancillaryData_text`, so it doesn't contain "price of"

---

### ✅ NEW Filter: `PRICE_QUERY`

**Command:**
```bash
python3 scripts/filter.py --where PRICE_QUERY
```

**Result:** **1/4 rows matched**

**Caught:**
- ✅ **DEXTFUSD** (identifier ends with USD)

**Not Caught:**
- ❌ ZODIAC (governance query, has proposalHash)
- ❌ USDDEXTF (ends with "TF", not USD/USDT - inverse pair)
- ❌ uSPAC10 (ends with "10", not a price identifier)

**Why It Worked:**
```python
identifier = "DEXTFUSD"
identifier.upper().endswith("USD")  # True!
```

---

## Full Test Log

### Step 1: Fetch with curl
```json
{
  "id": "DEXTFUSD-1656626400-0x",
  "identifier": "DEXTFUSD",
  "ancillaryData": "0x",
  "time": "1656626400"
}
```
✅ Confirmed empty ancillaryData

---

### Step 2: Fetch with fetch.py
```bash
python3 scripts/fetch.py --network ethereum_v1 --from 1655251200 --to 1657843199
```
**Result:** ✅ 4 rows fetched, including DEXTFUSD

---

### Step 3: Convert to CSV
```bash
python3 scripts/convert.py --network ethereum_v1 --input-json ...
```

**CSV Output:**
```csv
identifier,ancillaryData_text
DEXTFUSD,         ← EMPTY!
```
✅ Empty ancillaryData_text confirmed

---

### Step 4: Filter Test (OLD)
```bash
python3 scripts/filter.py --where 'ancillaryData_text~price of'
```
**Result:** ❌ 0/4 rows (DEXTFUSD not caught)

---

### Step 5: Filter Test (NEW)
```bash
python3 scripts/filter.py --where PRICE_QUERY
```
**Result:** ✅ 1/4 rows (DEXTFUSD caught!)

**Output:**
```csv
ancillaryData,id,identifier,time,identifier_text,ancillaryData_text
0x,DEXTFUSD-1656626400-0x,DEXTFUSD,1656626400,DEXTFUSD,
```

---

## Conclusion

### Question: Would DEXTFUSD have been detected with our Polygon filter?

**Answer:** ❌ **NO**

- Polygon filter used: `ancillaryData_text~'price of'`
- DEXTFUSD has empty `ancillaryData_text`
- Result: **NOT DETECTED**

---

### Question: Does the new PRICE_QUERY filter catch it?

**Answer:** ✅ **YES**

- New filter: `PRICE_QUERY`
- Checks identifier endings: USD, USDT, BTC, ETH
- DEXTFUSD ends with USD
- Result: **DETECTED**

---

## Impact on Polygon Analysis

### Current Count (with old filter):
- **7,401 crypto price predictions**
- Filter: `ancillaryData_text~'price of'`

### Potential Missing Queries:
If Polygon data contains identifier-only queries like:
- BTCUSD
- ETHUSDT
- SOLUSD
- Any XXXUSD pattern

They were **NOT counted** in our 7,401 total.

---

## Recommendation

**Re-run Polygon analysis with new filter:**

```bash
python3 scripts/filter.py \
  --network polygon_v2_new \
  --period september_2025 \
  --input-csv data-dumps/polygon_v2_new/september_2025/polygon_v2_new_1756677600_1759269599.csv \
  --where PRICE_QUERY \
  --stem crypto_predictions_complete
```

**Expected:** 7,401+ (includes any identifier-only queries if they exist)

---

## Test Files Generated

- `data-dumps/ethereum_v1/test_dextf/ethereum_v1_1655251200_1657843199.json` - Raw data (4 queries)
- `data-dumps/ethereum_v1/test_dextf/ethereum_v1_1655251200_1657843199.csv` - Converted CSV
- `data-dumps/ethereum_v1/test_dextf/old_filter_test.csv` - OLD filter result (0 rows)
- `data-dumps/ethereum_v1/test_dextf/new_filter_test.csv` - NEW filter result (1 row: DEXTFUSD)

---

## Summary

✅ **Test PASSED**  
✅ **DEXTFUSD confirmed as identifier-only query**  
✅ **OLD filter: MISSED it (0/4)**  
✅ **NEW filter: CAUGHT it (1/4)**  
✅ **Filter enhancement validated**

**The PRICE_QUERY filter correctly detects identifier-only price queries like DEXTFUSD!**

