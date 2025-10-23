# CEO FAQ - UMA Oracle Analysis

**Date:** October 21, 2025  
**Analysis Period:** September 1-30, 2025  
**Current Scope:** Polygon Network Only

---

## Q1: What did the inquiries for the 7,759 crypto price predictions look like?

### Exact Filter Logic Used

We filtered using **BOTH** conditions (AND logic):

**Condition 1 - Must contain a crypto keyword:**
```
bitcoin, ethereum, xrp, btc, eth, solana, sol, cardano, ada, litecoin, ltc, dogecoin, doge
```

**Condition 2 - Must match at least ONE price pattern (OR logic):**
```regex
1. "will the price of"
2. "price.*between.*\$"  (price + between + dollar sign)
3. "price.*(?:less than|greater than|above|below)"
```

### Real Examples from Dataset

**Example 1** - Greater than pattern:
```
Will the price of Ethereum be greater than $4,600 on October 7?
```

**Example 2** - Between pattern:
```
Will the price of Ethereum be between $4,500 and $4,600 on October 7?
```

**Example 3** - Less than pattern:
```
Will the price of Bitcoin be less than $65,000 on October 10?
```

**Example 4** - Range comparison:
```
Will the price of Solana be between $140 and $150 on October 15?
```

### Full Query Structure

Each query contains:
- **Title**: The question (e.g., "Will the price of...")
- **Description**: Resolution source (usually Binance, specific candle timing)
- **Market ID**: Polymarket market identifier
- **Resolution data**: p1 (No), p2 (Yes), p3 (Unknown)
- **Bulletin board**: Update mechanism address

### Did ALL 7,759 match this pattern?

**Answer:** Yes, by definition. Our filter only kept proposals that matched BOTH conditions.

However, there's a potential issue: Some non-price queries might have slipped through if they:
- Mentioned a crypto keyword AND
- Had "will the price of" in the description text (even if not about crypto prices)

**Recommendation:** Run a manual spot-check on a random sample of 100 queries to verify false positives.

---

## Q2: Have we only analyzed Polygon?

**Answer:** Yes, currently only Polygon network.  
**Update:** We discovered we analyzed only **44% of Polygon crypto predictions** (7,759 of 17,830 total).

### Why Only Polygon?

Our data source (The Graph subgraph) was specifically for:
- **Network:** Polygon
- **Contract:** UMA Optimistic Oracle v2
- **Subgraph ID:** `BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK` (OLD)

**⚠️ Important Discovery:** 
We found a second Polygon subgraph (`CFjw...`) tracking different Polymarket adapters.
- OLD subgraph: 7,759 crypto predictions (what we analyzed)
- NEW subgraph: 10,071 crypto predictions (missed in original analysis)
- **Combined:** 17,830 crypto predictions total
- **Zero overlap:** Different Polymarket adapter contracts

See `docs/SUBGRAPH_INVESTIGATION.md` for detailed investigation.

### Where Else Does UMA OOv2 Operate?

UMA Optimistic Oracle v2 is deployed on multiple networks:
1. **Ethereum Mainnet** - Primary network, likely highest volume
2. **Polygon** - Layer 2, lower costs (what we analyzed)
3. **Arbitrum** - Layer 2 solution
4. **Optimism** - Layer 2 solution
5. **Base** - Coinbase's Layer 2
6. **Gnosis Chain** - Alternative EVM chain

### Next Steps

To get a complete picture, we should:
1. Extend analysis to Ethereum Mainnet (likely to be substantial)
2. Add Arbitrum and Optimism (other major L2s)
3. Compare cross-chain activity patterns

**Status:** Multi-network infrastructure is being developed.

---

## Q3: Can we analyze proposer response latency?

**Challenge:** The `time` field in our current dataset is ambiguous.

### What We Have

Our CSV contains a single `time` field (Unix timestamp), but we don't currently know if this represents:
- Request creation time
- Proposal submission time
- Settlement time

### What We Need

To calculate latency properly, we need:
```
Proposer Response Time = Proposal Timestamp - Request Creation Timestamp
```

### Investigation Required

1. **Check GraphQL schema** - Determine what the `time` field represents
2. **Fetch additional timestamps** - Request creation time vs proposal time
3. **Re-fetch data** - If needed, pull these fields from The Graph

### Preliminary Analysis Plan

Once we have proper timestamps:
1. Calculate average latency for top proposer (`0x53692dbf47...`)
2. Break down by:
   - Asset (BTC vs ETH vs SOL vs XRP)
   - Time of day
   - Market volatility
3. Compare top proposers' latencies
4. Identify fastest/slowest responses

**Status:** Investigating data schema to determine available timestamp fields.

---

## Q4: Did we filter for the exact queries shown in the screenshot?

### Screenshot Analysis

The queries shown were:
1. **"Did Across Protocol get hacked?"** - Security/hack question (Yes/No)
2. **"DEXTFUSD"** - Token price oracle query
3. **"General_KPI"** - KPI metric query

### Would These Match Our Filter?

**"Did Across Protocol get hacked?"**
- ✅ Contains crypto (if "Across Protocol" mentioned)
- ❌ Does NOT contain price patterns
- **Result:** EXCLUDED from our analysis ✓

**"DEXTFUSD"**
- ⚠️ Might contain "DEXT" (not in our keyword list)
- Depends on ancillaryData text content
- **Result:** Likely EXCLUDED (no explicit crypto keyword)

**"General_KPI"**
- ❌ No crypto keyword
- ❌ No price pattern
- **Result:** EXCLUDED from our analysis ✓

### Why These Appear Different

The screenshot shows:
- **Different Oracle Versions:** V1 vs V2 (we analyzed V2 only)
- **Different Networks:** Ethereum vs Polygon
- **Different Bond Amounts:** 1,250/6,600/66,000 vs our $500 standard
- **Different Time Periods:** 2021-2024 vs our September 2025 data

### Our Focus

We specifically filtered for **crypto asset price predictions**, which excludes:
- Security/hack questions
- KPI metrics
- General governance queries
- Non-crypto oracle queries

This was intentional to focus the analysis on prediction market price activity.

---

## Data Quality Verification

### Recommended Checks

1. **Random Sample Inspection**
   - Pull 100 random queries from our 7,759
   - Manually verify they're all legitimate crypto price predictions
   - Identify any false positives

2. **Edge Case Review**
   - Search for queries with unusual patterns
   - Check if any security/hack questions slipped through
   - Verify all match our intended scope

3. **Pattern Coverage**
   - Are there price prediction patterns we missed?
   - Check unfiltered data for queries that should have been included

**Status:** Quality verification in progress.

---

## Summary Table

| Question | Current Status | Next Action |
|----------|---------------|-------------|
| **Filter Logic** | ✅ Documented | Verify with random sample |
| **Network Coverage** | ⚠️ Polygon only | Extend to Ethereum, Arbitrum, Optimism |
| **Proposer Latency** | ❌ Need timestamp clarity | Investigate schema, re-fetch if needed |
| **Data Quality** | ⚠️ Assumed clean | Run 100-sample spot check |

---

## Immediate Action Items

1. **Verify data quality** - Random sample of 100 queries
2. **Clarify timestamps** - Investigate GraphQL schema
3. **Multi-network setup** - Extend scripts for Ethereum, Arbitrum, Optimism
4. **Re-run with proper timestamps** - If latency analysis is priority


