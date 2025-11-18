# DEXTFUSD Detection Test

**Query:** DEXTFUSD (Ethereum V1, July 1, 2022)  
**Age:** 750+ days old

---

## Query Structure

```json
{
  "id": "DEXTFUSD-1656626400-0x",
  "identifier": "DEXTFUSD",
  "ancillaryData": "0x",  // ← EMPTY!
  "time": "1656626400",
  "state": "Requested"
}
```

---

## After CSV Conversion

| Field | Value |
|-------|-------|
| `identifier` | DEXTFUSD |
| `identifier_text` | DEXTFUSD |
| `ancillaryData` | 0x |
| `ancillaryData_text` | **(empty string)** |

---

## Detection Test

### ❌ OLD Filter (What We Used on Polygon)

**Filter:** `--where 'ancillaryData_text~price of'`

**Logic:**
- Checks if "price of" is in `ancillaryData_text`
- DEXTFUSD has empty `ancillaryData_text`

**Result:** ❌ **NOT DETECTED**

**Why:** Because `ancillaryData_text` is empty, it doesn't contain "price of"

---

### ✅ NEW Filter (Enhanced Version)

**Filter:** `--where PRICE_QUERY`

**Logic:**
1. Check if "price of" in `ancillaryData_text` → **No** (empty)
2. Check if identifier ends with USD/USDT/BTC/ETH → **Yes!** (DEXTFUSD ends with USD)

**Result:** ✅ **DETECTED**

**Why:** The identifier "DEXTFUSD" ends with "USD", which triggers the price identifier detection

---

## Summary Table

| Filter Type | Command | Detects DEXTFUSD? | Reason |
|-------------|---------|-------------------|---------|
| **OLD** | `ancillaryData_text~price of` | ❌ NO | Empty ancillaryData |
| **NEW** | `PRICE_QUERY` | ✅ YES | Identifier ends with USD |

---

## Impact on Polygon Analysis

### What We Found (with old filter):
- **7,401 crypto price predictions**
- Filter: `ancillaryData_text~price of`
- Caught: Only queries with text in ancillaryData

### What We Would Find (with new filter):
- **7,401+ crypto price predictions**
- Filter: `PRICE_QUERY`
- Catches: Both text queries AND identifier-only queries (XXXUSD, XXXUSDT)

### Potential Additional Queries:
If Polygon has identifier-only queries like:
- `BTCUSD`
- `ETHUSDT`
- `SOLUSD`
- Any `XXXUSD` pattern

They would NOW be detected!

---

## Recommendation

### Re-run Polygon Analysis with Enhanced Filter

```bash
cd /Users/abhinavtaneja/Developer/uma-oracle-analysis

# Re-filter with new PRICE_QUERY
python3 scripts/filter.py \
  --network polygon_v2_new \
  --period september_2025 \
  --input-csv data-dumps/polygon_v2_new/september_2025/polygon_v2_new_1756677600_1759269599.csv \
  --where PRICE_QUERY \
  --stem crypto_predictions_enhanced
```

**Expected Result:**
- Same 7,401 queries (from ancillaryData text)
- PLUS any identifier-only queries (if they exist)
- More accurate count of total price queries

---

## Conclusion

**Question:** Would DEXTFUSD have been detected with our current Polygon filter?

**Answer:** ❌ **NO** - We used `ancillaryData_text~price of` which misses identifier-only queries

**Solution:** ✅ Use the new `PRICE_QUERY` filter to catch ALL price queries including DEXTFUSD-style queries

**Next Step:** Re-run Polygon analysis with `PRICE_QUERY` to get complete count

