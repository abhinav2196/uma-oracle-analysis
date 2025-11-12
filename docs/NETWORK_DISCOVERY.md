# Network Discovery - L2 Oracle Deployments Found

**Date:** November 12, 2025  
**Discovery Method:** Manual inspection of UMA Oracle UI  
**Status:** 🚨 CRITICAL - Multiple networks with V2 oracles not in our config

---

## Problem Statement

Our initial validation only checked **configured subgraphs** but didn't systematically search for **ALL** UMA Oracle deployments across networks.

**Through manual UI inspection, we discovered V2 Oracle activity on:**

| Network | Oracle Version | Activity Observed | In Our Config? |
|---------|----------------|-------------------|----------------|
| **Base** | V2 | ✅ Many queries (MidTermElection, FED, UEFA) | ❌ NO (only V3 configured) |
| **Ethereum** | V1 | ✅ DEXTFUSD price identifiers | ❌ NO (broken ID) |
| **Ethereum** | V2 | ✅ Cozy Finance, Across Protocol | ❌ NO (broken ID) |
| **Optimism** | V2 | ✅ Cozy Finance, sports predictions | ❌ NOT CONFIGURED |
| **Arbitrum** | V2 | ✅ YES_OR_NO_QUERY, Cozy Finance | ❌ NOT CONFIGURED |
| **Blast** | V2 | ✅ Predict.Fun predictions | ❌ NOT CONFIGURED |
| **Polygon** | V2 | ✅ Polymarket (already have) | ✅ YES |

---

## UI Screenshots Analysis

### Base Network - V2 Oracle
```
Example queries found:
- MidTermElection_1762344874461-460 (11/05/2025)
- FED_1762337872431-456 (11/05/2025)
- UEFA_1761878206215-454 (10/31/2025)
- Test Event (MetaMarket, 10/24/2025)

Bond/Reward patterns:
- 250.5 USDC bond / 0 reward (most common)
- 251 USDC bond / 1 reward
- Event-based queries

Finding: Base has BOTH V2 and V3 oracles deployed simultaneously
```

### Ethereum - V1 & V2 Oracles
```
V1 Examples:
- DEXTFUSD (07/01/2022) - 6,600 DEXTF bond
- General_KPI (10/25/2021) - 66,000 YEL bond

V2 Examples:
- "Did Across Protocol get hacked?" (04/23/2024) - 1,250 USDC / 25 reward
- Cozy Finance queries

Finding: Ethereum has V1, V2, AND V3 all active
```

### Optimism - V2 Oracle
```
Examples:
- "Did Lido get hacked?" (Cozy Finance, 02/18/2025) - 1,250 / 0.01
- "Did Uniswap get hacked?" (Cozy Finance)
- "Did Aave get hacked?" (Cozy Finance)
- "Who will win: Nebraska or Texas A&M?" (04/04/2024) - 250 / 0

Finding: Active V2 oracle with varied use cases
```

### Blast - V2 Oracle
```
Examples:
- "Will a federal judge order Google to sell off Chrome Browser before 2025?" (Predict.Fun, 11/19/2024) - 1,000 / 5
- "Will SOL hit $600 by December 31st 2025?" (Predict.Fun, 11/08/2024) - 1,000 / 5

Finding: Predict.Fun integration on Blast using V2 oracle
```

### Arbitrum - V2 Oracle
```
Examples:
- "Did Open Dollar get hacked?" (Cozy Finance, 04/10/2024) - 1,250 / 25
- YES_OR_NO_QUERY (10/31/2023) - 500 / 5
- YES_OR_NO_QUERY (10/18/2023) - 500 / 4

Finding: Longer history, diverse applications
```

---

## Impact on Analysis

### Current State
**Your September 2025 analysis captured:**
- ✅ Polygon V2: 17,830 crypto predictions
- ✅ Ethereum V3: 1,025 assertions (governance)
- ✅ Base V3: 49 assertions (minimal)

**MISSING from analysis:**
- ❌ Base V2: Unknown count (potentially thousands)
- ❌ Ethereum V1: Price identifiers (DEXTFUSD, etc.)
- ❌ Ethereum V2: Cozy Finance, Across, etc.
- ❌ Optimism V2: Cozy Finance, sports, etc.
- ❌ Arbitrum V2: Cozy Finance, various queries
- ❌ Blast V2: Predict.Fun predictions

### Potential Data Volume

Based on UI observations and deployment dates:

| Network | Estimated Volume | Reasoning |
|---------|------------------|-----------|
| Base V2 | 1,000 - 10,000+ | Very active, recent queries (Nov 2025) |
| Ethereum V1 | 100 - 500 | Legacy, older dates (2021-2022) |
| Ethereum V2 | 500 - 2,000 | Cozy Finance integration, 2024-2025 |
| Optimism V2 | 500 - 5,000 | Cozy Finance + sports, active 2024-2025 |
| Arbitrum V2 | 1,000 - 5,000 | Longer history (2023+), multiple apps |
| Blast V2 | 100 - 1,000 | Newer network, Predict.Fun only |

**Total potential additional records: 3,200 - 23,500+**

---

## Next Steps - Action Plan

### IMMEDIATE (Priority 1)

1. **Find ALL Subgraph IDs**

**Method A: UMA GitHub Repository**
```bash
# Clone UMA subgraphs repo
git clone https://github.com/UMAprotocol/subgraphs.git uma-subgraphs-repo
cd uma-subgraphs-repo

# Look for deployment configs
find . -name "subgraph.yaml" -o -name "networks.json" -o -name "*.config.json"
grep -r "8453\|10\|42161\|81457" . # Chain IDs for Base, Optimism, Arbitrum, Blast
```

**Method B: The Graph Explorer Manual Search**
- Visit: https://thegraph.com/explorer
- Search: "UMA Optimistic Oracle" for each network
- Filter by network (Base, Optimism, Arbitrum, Blast, Ethereum)
- Note subgraph IDs and deployment status

**Method C: Query The Graph Studio API**
```bash
# Search for UMA subgraphs programmatically
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ indexingStatuses { subgraph chains { network } } }"}' \
  "https://api.thegraph.com/index-node/graphql"
```

**Method D: Check UMA Oracle UI Source Code**
- Inspect network requests in browser DevTools
- UI must be querying these subgraphs - capture the endpoints!

2. **Validate Each Subgraph ID**

Once found, test each with schema introspection:
```bash
# Template for testing
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { types { name } } }"}' \
  "https://gateway.thegraph.com/api/$API_KEY/subgraphs/id/$SUBGRAPH_ID" \
  | jq -r '.data.__schema.types[].name' | grep -E "Optimistic|Assertion|Price"
```

3. **Update network-config.json**

Add discovered subgraphs:
```json
{
  "networks": {
    "base_v2": {
      "name": "Base V2",
      "subgraph_id": "DISCOVERED_ID_HERE",
      "oracle_version": "v2",
      "chain_id": 8453,
      "description": "Base - Optimistic Oracle V2",
      "contract_address": "TBD"
    },
    "optimism": {
      "name": "Optimism",
      "subgraph_id": "DISCOVERED_ID_HERE",
      "oracle_version": "v2",
      "chain_id": 10
    },
    "arbitrum": {
      "name": "Arbitrum",
      "subgraph_id": "DISCOVERED_ID_HERE",
      "oracle_version": "v2",
      "chain_id": 42161
    },
    "blast": {
      "name": "Blast",
      "subgraph_id": "DISCOVERED_ID_HERE",
      "oracle_version": "v2",
      "chain_id": 81457
    }
  }
}
```

### SHORT-TERM (Priority 2)

4. **Fetch September 2025 Data from All Networks**

```bash
# Once subgraph IDs are found, fetch data
for network in base_v2 optimism arbitrum blast; do
  ./fetch_uma_data.sh $network september_2025
  ./convert_json_to_csv.sh $network september_2025
  python3 filter_crypto_predictions.py $network september_2025
done
```

5. **Re-run Cross-Network Analysis**

Update `CROSS_NETWORK_ANALYSIS.md` with complete data:
- Add new networks
- Recalculate totals
- Compare deployment patterns

### LONG-TERM (Priority 3)

6. **Create Automated Subgraph Discovery Script**

```bash
#!/bin/bash
# discover_uma_subgraphs.sh
# Automatically finds all UMA subgraphs across all networks
```

7. **Set Up Monitoring**

- Track new network deployments
- Alert when new subgraphs are published
- Validate subgraph sync status

---

## Questions to Answer

### Data Scope Questions

1. **How many total assertions across ALL networks in September 2025?**
   - Current: 31,088
   - Estimated with new networks: 35,000 - 55,000+

2. **Which network has the most V2 oracle activity?**
   - Current answer: Polygon (17,830)
   - May change with Base/Arbitrum/Optimism data

3. **What % of assertions are crypto price predictions vs other use cases?**
   - Current: 57.4% (17,833 / 31,088)
   - Will likely decrease with DeFi insurance (Cozy) and prediction markets (Predict.Fun)

### Integration Analysis

4. **Which applications use V2 oracles?**

Based on UI screenshots:
| Application | Networks | Use Case |
|-------------|----------|----------|
| Polymarket | Polygon | Crypto prices, events |
| Cozy Finance | Ethereum, Optimism, Arbitrum | Protocol hack insurance |
| Predict.Fun | Blast | General predictions |
| MetaMarket | Base | Events (?)  |
| Across Protocol | Ethereum | Bridge security |

5. **Why do some networks have V2 AND V3?**
- Base: Both V2 and V3 deployed
- Ethereum: V1, V2, and V3 all active
- Hypothesis: V3 for governance, V2 for price feeds/predictions

---

## Risk Assessment

### Data Completeness Risk: 🔴 HIGH

**Current understanding of UMA ecosystem:**
- Estimated completeness: 60-70% (missing 6+ networks)
- Confidence in "total activity": LOW
- Ability to answer "how much total value secured": CANNOT ANSWER

### Analysis Validity Risk: 🟡 MEDIUM

**Published analysis validity:**
- ✅ Polygon analysis is correct (but limited scope)
- ⚠️ Cross-network comparison is incomplete
- ⚠️ "Polygon is the hub" conclusion may be wrong

### Script Correctness Risk: 🟢 LOW

**Existing scripts:**
- ✅ Scripts work correctly for configured networks
- ✅ Logic and queries are sound
- ✅ Just need to run on additional networks

---

## Recommendations

### For Immediate Action

1. **Top Priority:** Find subgraph IDs using Method D (inspect Oracle UI network requests)
   - This is fastest and most reliable
   - Open browser DevTools → Network tab
   - Visit: oracle.uma.xyz
   - Filter by network
   - Capture GraphQL endpoint URLs

2. **Quick Win:** Search The Graph Explorer manually
   - Takes 15-30 minutes
   - Guaranteed to find published subgraphs
   - Can validate deployment status

3. **Documentation:** Update README with caveat
   ```markdown
   ⚠️ **Analysis Scope Note:** 
   Current analysis covers Polygon V2, Ethereum V3, and Base V3 only.
   Additional V2 oracle deployments exist on Base, Optimism, Arbitrum, 
   Blast, and Ethereum but are not yet included.
   ```

### For Project Scope Decision

**Option A: Complete Deep Dive (Recommended)**
- Find ALL subgraph IDs
- Fetch ALL network data for September 2025
- Re-run complete analysis
- **Timeline:** 2-3 days
- **Value:** Complete picture of UMA ecosystem

**Option B: Focus on High-Value Networks**
- Add Base V2, Ethereum V2, Optimism V2 only
- Skip Blast/Arbitrum for now
- **Timeline:** 1 day
- **Value:** Captures 80-90% of additional activity

**Option C: Document and Defer**
- Document discovery in current analysis
- Note as "future work"
- **Timeline:** 1 hour
- **Value:** Transparent about limitations

---

## Lessons Learned

### What Went Wrong

1. ❌ **Assumption:** "One oracle version per network"
   - **Reality:** Networks can have multiple oracle versions

2. ❌ **Validation Method:** Only tested configured subgraphs
   - **Should have:** Searched for ALL UMA subgraphs first

3. ❌ **Discovery Process:** Worked backward from config
   - **Should have:** Worked forward from UMA deployments

### What to Do Differently

1. ✅ **Start with official sources** (UMA GitHub, docs)
2. ✅ **Validate against UI** (oracle.uma.xyz shows ground truth)
3. ✅ **Search systematically** across all known L2s
4. ✅ **Don't assume** - verify everything

---

## Action Tracking

- [ ] Find subgraph IDs for Base V2
- [ ] Find subgraph IDs for Ethereum V1
- [ ] Find subgraph IDs for Ethereum V2
- [ ] Find subgraph IDs for Optimism V2
- [ ] Find subgraph IDs for Arbitrum V2
- [ ] Find subgraph IDs for Blast V2
- [ ] Validate each subgraph with test query
- [ ] Update network-config.json
- [ ] Fetch September 2025 data from new networks
- [ ] Re-run cross-network analysis
- [ ] Update all documentation
- [ ] Update README with scope caveat

---

**Status:** 🚨 **DISCOVERY PHASE**  
**Next Action:** Inspect Oracle UI network requests to find subgraph IDs  
**Blocker:** Need subgraph IDs before proceeding with data fetch  
**ETA:** Can resolve in 1-2 hours with browser DevTools inspection

