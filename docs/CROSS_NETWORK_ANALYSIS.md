# Cross-Network Analysis - UMA Oracle (September 2025)

**Analysis Date:** October 23, 2025  
**Period Analyzed:** September 1-30, 2025  
**Networks:** Polygon (V2), Ethereum (V3), Base (V3)

---

## Executive Summary

**Key Finding:** Crypto price prediction activity is **heavily concentrated on Polygon**.

| Network | Oracle Version | Total Assertions | Crypto Predictions | % Crypto |
|---------|----------------|------------------|--------------------|----------|
| **Polygon (OLD)** | V2 | 14,448 | 7,759 | 53.7% |
| **Polygon (NEW)** | V2 | 15,566 | 10,071 | 64.7% |
| **Polygon Combined** | **V2** | **30,014** | **17,830** | **59.4%** |
| **Ethereum** | V3 | 1,025 | 0 | 0% |
| **Base** | V3 | 49 | 3 | 6.1% |
| **TOTAL** | - | **31,088** | **17,833** | **57.4%** |

**Conclusion:** **Polygon dominates** crypto price prediction activity (99.98% of all crypto predictions).

---

## Network Breakdown

### Polygon (Optimistic Oracle V2)

**Total Activity:** 30,014 assertions across 2 subgraphs  
**Crypto Predictions:** 17,830 (59.4%)

#### Subgraph 1 (OLD - BpK8...)
- **Records:** 14,448
- **Crypto:** 7,759 (53.7%)
- **Adapter:** `0x2f5e...` & `0x56ad...`
- **Bond/Reward:** $500 / $2 (standardized)
- **Asset Split:** BTC: 25.4% | ETH: 25.1% | SOL: 25.0% | XRP: 24.5%

#### Subgraph 2 (NEW - CFjw...)
- **Records:** 15,566
- **Crypto:** 10,071 (64.7%)
- **Adapter:** `0x6507...`
- **Bond/Reward:** $500 / $2-$5 (varied)
- **Asset Split:** BTC: 25.0% | ETH: 25.0% | SOL: 25.0% | XRP: 24.9%

**Insight:** Perfect asset distribution maintained across both adapters.

---

### Ethereum (Optimistic Oracle V3)

**Total Activity:** 1,025 assertions  
**Crypto Predictions:** 0

**What Ethereum V3 is used for:**
- Proposal hashes and governance
- Contract/payment disputes
- General assertions (non-price related)

**Sample Claims:**
- Empty strings
- `"proposalHash:34c5ce8a..."`
- Contract dispute messages

**Why no crypto predictions?**
- V3 is designed for different use cases (assertions vs price requests)
- Polymarket doesn't use Ethereum mainnet for crypto price oracles (too expensive)
- V3 = generalized assertions, V2 = price requests

**Financial Metrics:**
- Bonds: Vary ($600k+ observed)
- Currency: USDC (0xa0b86991...)
- Use case: Governance and disputes, not prediction markets

---

### Base (Optimistic Oracle V3)

**Total Activity:** 49 assertions  
**Crypto Predictions:** 3 (6.1%)

**Crypto Breakdown:**
- BTC: 3 predictions (100%)
- ETH: 0
- SOL: 0  
- XRP: 0

**What Base V3 is used for:**
- Payment/contract disputes (majority)
- Social media claims
- Minimal crypto price activity

**Sample Claims:**
- `"Two parties agreed on a contract...payment should be RETURNED"`
- `"Will a memecoin officially affiliated with Truth Social be launched..."`
- `"As of assertion timestamp..."`

**Why so little crypto activity?**
- Base is newer network (less adoption)
- V3 oriented toward assertions, not price predictions
- Most Base activity is payment disputes, not predictions

---

## Oracle Version Comparison

### V2 (Polygon) - Price Requests
- **Purpose:** Prediction market price verification
- **Query Type:** `optimisticPriceRequests`
- **Data Field:** `ancillaryData` (human-readable text)
- **Use Case:** Crypto prices, sports outcomes, event predictions
- **Volume:** HIGH (30,014 in September)
- **Economics:** Standardized ($500/$2 typical)

### V3 (Ethereum, Base) - Assertions
- **Purpose:** General truth claims and assertions
- **Query Type:** `assertions`
- **Data Field:** `claim` (can be empty, hash, or text)
- **Use Case:** Governance, disputes, social verification
- **Volume:** LOW (1,074 in September)
- **Economics:** Varied (wide range)

---

## Why Polygon Dominates

### 1. Cost Efficiency
- **Polygon:** Low gas fees → affordable for high-frequency price checks
- **Ethereum:** High gas fees → prohibitive for frequent predictions
- **Base:** New network → low adoption

### 2. Polymarket's Choice
- Polymarket uses Polygon for price oracles (cost-effective)
- Ethereum for governance/high-value disputes only
- Base still experimental/low volume

### 3. Oracle Version Fit
- **V2 optimized for price requests** → Polygon
- **V3 optimized for general assertions** → Ethereum/Base
- Different tools for different purposes

---

## Financial Comparison

| Network | Crypto Predictions | Total Bond Value | Avg Bond | Reward Structure |
|---------|-------------------|------------------|----------|------------------|
| **Polygon OLD** | 7,759 | $3.88M | $500 | $2 standard |
| **Polygon NEW** | 10,071 | ~$5.04M | $500 | $2-$5 varied |
| **Ethereum** | 0 | N/A | N/A | N/A |
| **Base** | 3 | $11 | ~$3.67 | Minimal |
| **TOTAL** | **17,833** | **~$8.92M** | - | - |

**Note:** Bond calculations pending for Polygon NEW (estimate based on $500 avg).

---

## Content Type Distribution

### Polygon V2 (Combined 30,014 records)
- Crypto Price Predictions: 59.4%
- Gaming/Esports: ~25%
- Politics/Entertainment: ~15%
- Other: ~1%

### Ethereum V3 (1,025 records)
- Governance/Proposals: ~60%
- Payment Disputes: ~30%
- Other Assertions: ~10%
- Crypto Predictions: 0%

### Base V3 (49 records)
- Payment Disputes: ~90%
- Crypto/Misc: ~10%

---

## Recommendations

### For Crypto Price Analysis

**Use Polygon V2 exclusively:**
- 17,830 of 17,833 crypto predictions (99.98%)
- Ethereum and Base contribute <0.02%
- Polygon is the de facto standard for crypto price oracles

### For Multi-Network Analysis

**Different networks serve different purposes:**
- **Polygon V2:** Prediction markets (crypto prices, sports, entertainment)
- **Ethereum V3:** Governance and high-value disputes
- **Base V3:** Payment disputes and experimental assertions

**Don't compare V2 vs V3 directly** - they're different products.

### For Future Analysis

1. **Polygon:** Focus here for crypto predictions (use both subgraphs)
2. **Ethereum:** Analyze governance/dispute patterns
3. **Base:** Monitor growth as network matures
4. **Cross-network:** Compare V2 vs V3 use cases, not volumes

---

## Summary Table

|  | Polygon V2 | Ethereum V3 | Base V3 |
|---|------------|-------------|---------|
| **Purpose** | Price predictions | Governance | Disputes |
| **Volume** | HIGH (30k) | MEDIUM (1k) | LOW (49) |
| **Crypto Focus** | ✅ Primary | ❌ None | ⚠️ Minimal |
| **Economics** | Standardized | Varied | Minimal |
| **Polymarket Use** | ✅ Active | ❌ Not used | ⚠️ Limited |

---

## Data Files Generated

**Polygon:**
- `data-dumps/polygon_old/uma_september_2025_crypto_price_predictions.csv` (7,759 records)
- `data-dumps/polygon_new/uma_september_2025_crypto_price_predictions.csv` (10,071 records)

**Ethereum:**
- `data-dumps/ethereum/uma_september_2025_full.csv` (1,025 records)
- No crypto predictions

**Base:**
- `data-dumps/base/uma_september_2025_crypto_price_predictions.csv` (3 BTC predictions)

---

## Conclusion

**Polygon is the crypto price prediction hub.**

Ethereum V3 and Base V3 serve different purposes (governance and disputes). For crypto price analysis, Polygon V2 contains 99.98% of all activity.

**Next steps:** Focus on combined Polygon analysis (17,830 predictions) for most comprehensive insights.


