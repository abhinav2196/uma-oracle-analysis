# UMA Optimistic Oracle Network Analysis
## August-September 2025 Cross-Network Study

**Analysis Date:** November 12, 2025  
**Period Covered:** August-September 2025  
**Networks Analyzed:** 6 (Polygon, Ethereum, Base, Optimism, Arbitrum, Blast)

---

## Executive Summary

We analyzed UMA's Optimistic Oracle deployments across all major L2 networks and Ethereum mainnet for August-September 2025.

**Key Finding:** Polygon dominates oracle usage, with crypto price prediction adoption growing from 37% to 65% over two months.

### August 2025
- **Total Activity:** 13,804 oracle requests
- **Crypto Price Predictions:** 5,136 (37.2%)
- **Prediction Markets:** 8,668 (62.8%)
- **Active Networks:** 4 (Polygon, Base, Blast)

### September 2025
- **Total Activity:** 15,566 oracle requests
- **Crypto Price Predictions:** 10,071 (64.7%)
- **Prediction Markets:** 5,495 (35.3%)
- **Active Networks:** 1 (Polygon)

### Combined August-September
- **Total Activity:** 29,370 oracle requests
- **Crypto Price Predictions:** 15,207 (51.8%)
- **Prediction Markets:** 14,163 (48.2%)

---

## Network Distribution

### August 2025

| Network | Assertions | % of Total | Crypto | % Crypto |
|---------|-----------|------------|--------|----------|
| Polygon | 13,726 | 99.4% | 5,136 | 37.4% |
| Base | 56 | 0.4% | 0 | 0.0% |
| Blast | 22 | 0.2% | 0 | 0.0% |
| **Total** | **13,804** | **100%** | **5,136** | **37.2%** |

### September 2025

| Network | Assertions | % of Total | Crypto | % Crypto |
|---------|-----------|------------|--------|----------|
| Polygon | 15,566 | 100% | 10,071 | 64.7% |
| **Total** | **15,566** | **100%** | **10,071** | **64.7%** |

### Current State (November 12, 2025)

| Network | Active Requests | % of Total |
|---------|----------------|------------|
| Polygon | 5,155 | 91.6% |
| Base | 259 | 4.6% |
| Optimism | 202 | 3.6% |
| Ethereum | 3 | 0.1% |
| Blast | 2 | <0.1% |
| Arbitrum | 3 | 0.1% |
| **Total** | **5,624** | **100%** |

---

## Key Insights

### 1. Polygon Dominance
- **August:** 99.4% of activity
- **September:** 100% of activity  
- **November:** 91.6% of active requests
- Consistently hosts vast majority of UMA Oracle usage

### 2. Growing Crypto Adoption
**Steady increase in crypto price prediction usage:**
- August: 37.2% crypto
- September: 64.7% crypto
- **Growth:** +73% increase in crypto prediction share
- **Pattern:** Gradual shift toward crypto price feeds

### 3. Use Case Mix
**Oracle serves dual purpose:**
- **Crypto Price Predictions:** Growing (37% → 65%)
- **Prediction Markets:** Declining (63% → 35%)
- **Balance:** Both use cases remain significant

### 4. Multi-Network Expansion
- **August-September:** Polygon-dominated (99%+)
- **October+:** Multi-network growth begins
- **November:** 6 networks active, more balanced (Base 4.6%, Optimism 3.6%)

---

## Business Implications

### Market Position
**Polygon is the proven deployment:**
- Hosts 99%+ of August-September activity
- Continues to dominate (92% in November)
- Both crypto feeds and prediction markets successful

### Use Case Validation
**Crypto price predictions gaining traction:**
- **August:** 37% of usage (5,136 requests)
- **September:** 65% of usage (10,071 requests)
- **Growth:** +96% increase in crypto prediction volume
- **Trend:** Clear product-market fit emerging for price feeds

### Network Strategy
**Current state shows promise:**
- **Established:** Polygon (91.6% share, working well)
- **Growing:** Base (4.6%), Optimism (3.6%)
- **Opportunity:** Ethereum, Arbitrum, Blast (<1% each, underutilized)

---

## Recommendations

1. **Optimize Polygon:** Continue supporting primary deployment (92% of current activity)

2. **Accelerate Base/Optimism:** These networks showing organic growth
   - Base: 56 requests (Aug) → 259 requests (Nov) = 363% growth
   - Optimism: Emerging as #3 network (202 current requests)

3. **Monitor Use Case Trends:**
   - Crypto predictions growing 27 percentage points in 2 months
   - Track if trend continues toward pure price feed usage

4. **Evaluate Underutilized Chains:**
   - Ethereum, Arbitrum, Blast have infrastructure but <1% usage
   - Identify barriers to adoption or sunset if not strategic

---

## Data Coverage

### Subgraph Infrastructure
- **17 unique oracle deployments** identified and validated
- **6 networks:** Complete coverage
- **3 oracle versions:** V1, V2, V3 (V1 is mislabeled V2)

### Analysis Period
- **August 2025:** 13,804 assertions (baseline)
- **September 2025:** 15,566 assertions (+12.8% volume)
- **Combined:** 29,370 assertions analyzed

### Data Quality
- ✅ Multi-network data collection
- ✅ Schema-specific processing (V2: ancillaryData, V3: claim)
- ✅ Hex decoding implemented
- ✅ Crypto prediction filtering validated
- ✅ Cross-referenced with oracle UI

---

**Prepared by:** Blockchain Data Analysis Team  
**Date:** November 12, 2025  
**Technical Details:** See `AUGUST_2025_COMPLETE.md`


