# UMA Optimistic Oracle v2 Analysis — September 2025

## Introduction / Objective
The purpose of this analysis was to examine UMA's Optimistic Oracle v2 activity during September 2025, with a focus on identifying and quantifying asset price prediction proposals (such as markets referencing BTC, ETH, or FX rates).
The broader objective was to understand how UMA's oracle is being utilized on-chain and to assess potential opportunities for our company to contribute or integrate as a data or verification provider.

---

## Process Followed

### Data Retrieval
- Data was sourced directly from UMA's public Optimistic Oracle v2 Subgraph, providing structured access to all oracle requests on both Ethereum and Polygon.
- A GraphQL query was used to collect all oracle requests where the identifier was YES_OR_NO_QUERY and the ancillary data contained asset-related terms such as "BTC," "ETH," or "price."
- A custom script paginated through the subgraph API for the period September 1–30, 2025, ensuring complete coverage.

### Data Preparation
- Retrieved data was stored in JSON format, converted into flat CSV structure, and cleaned for analysis.
- Key fields: timestamps, requester addresses, bond and reward amounts, transaction states, and full proposal descriptions (ancillaryData).

### Filtering & Analysis
- Two analytical approaches were applied:
  1. **Unfiltered Analysis**: All 14,448 proposals examined
  2. **Filtered Analysis**: Only crypto price predictions (7,759 proposals) isolated using regex pattern matching
- Filtering criteria:
  - Must contain price pattern: `"will the price of"` OR `"price between $"` OR `"price (less than|greater than|above|below)"`
  - Must contain crypto asset keyword: `bitcoin|ethereum|xrp|btc|eth|solana|sol|etc.`
- Analysis executed in DuckDB for reliable aggregate queries and validation.

---

## Results / Questions Answered

### 1. Total Oracle Activity (Unfiltered)
- **Total proposals:** 14,448
- **Time period:** September 1–30, 2025
- **Network:** Polygon (Ethereum-compatible chain)
- **Query type:** Predominantly YES_OR_NO_QUERY (binary prediction markets)

### 2. Filtered Analysis: Crypto Price Predictions

#### Volume Comparison
| Metric | Unfiltered | Filtered | % of Total |
|--------|-----------|----------|-----------|
| Total Proposals | 14,448 | 7,759 | 53.7% |
| Settled | ~14,400 | 7,756 | 99.96% |
| Disputed | ~27 | 27 | 0.35% |

**Key Finding:** Over half of all proposals (53.7%) are specifically crypto asset price predictions, with extremely high settlement rates (99.96%) and low dispute rates (0.35%), indicating high data quality.

#### Asset Breakdown (7,759 Price Predictions)
| Asset | Proposals | % Share | USDC Bond Value | USDC Reward Value |
|-------|-----------|---------|-----------------|------------------|
| **Bitcoin (BTC)** | 1,967 | 25.3% | ~$981k | ~$7,126 |
| **Ethereum (ETH)** | 1,948 | 25.1% | ~$973k | ~$7,070 |
| **Solana (SOL)** | 1,944 | 25.1% | ~$973k | ~$7,070 |
| **Ripple (XRP)** | 1,900 | 24.5% | ~$950k | ~$6,901 |
| **TOTAL** | **7,759** | **100%** | **~$3.88M** | **~$28.2k** |

**Key Finding:** Crypto price predictions are evenly distributed across 4 major assets, with no single asset dominating (each ~25%), indicating systematic price prediction trading rather than speculation on one asset.

#### Market Structure (7,759 Price Predictions)
- **Proposers (Market Makers):** 29 unique addresses
  - Top proposer: `0x53692dbf47...` = **76.8%** of market (5,956 proposals)
  - Top 3 proposers: **88.7%** of market
  - **Concentration Risk:** Highly centralized proposition supply

- **Requesters (Oracle Users):** 3 unique addresses
  - Top requester: `0x2f5e3684cb...` = **85.4%** of market (6,624 proposals)
  - Second requester: `0x157ce2d67...` = **14.6%** of market (1,131 proposals)
  - **Observation:** Market driven by 2 primary requesters (Polymarket adapters)

- **Disputers (Market Challengers):** 2 primary addresses
  - Top disputer: `0x8c3afdea...` = **55.6%** of all disputes (15 out of 27)
  - Second disputer: `0xb7ad15ad...` = **29.6%** of all disputes (8 out of 27)
  - **Observation:** Dispute activity concentrated in 2 professional arbitrageurs

#### Financial Economics (7,759 Price Predictions)
- **Total Bond Value:** 3,877,750,000,000 (smallest USDC unit)
  - **Actual USD Value:** ~$3.88 million USDC locked as collateral
  - **Average per proposal:** ~$500 USDC per proposal (highly standardized)
  - **Min/Max:** Consistent $250-$500 USDC bonds across all proposals

- **Total Reward Value:** 28,166,000,000 (smallest USDC unit)
  - **Actual USD Value:** ~$28,166 USDC in incentives
  - **Average per proposal:** ~$3.63 USDC per proposal (standardized)
  - **Min/Max:** Consistent $1-$5 USDC rewards across proposals

- **Reward/Bond Ratio:** **0.73%**
  - Indicates conservative incentive structure
  - Proposers must be highly confident in accuracy to accept 0.73% ROI on disputes

#### Temporal Patterns (7,759 Price Predictions)
| Period | Avg Daily Volume | Daily Range |
|--------|-----------------|-------------|
| Sept 1-21 | ~300 proposals/day | 250-330 |
| Sept 22-26 | ~300 proposals/day | 260-330 |
| Sept 27-30 | ~100 proposals/day | 45-50 |

**Question:** Month-end decline from 300+ to 100 proposals/day suggests either:
- Seasonal project wind-down
- Data collection limitation
- Legitimate market slowdown

### 3. Major Requesters (All Proposals)
Two addresses generated over 90% of all proposals:
- `0x2f5e3684cb1f318ec51b00edba38d79ac2c0aa9d` – Polymarket: UMA CTF Adapter V3
- `0x157ce2d672854c848c9b79c49a8cc6cc89176a49` – Polymarket UMA Adapter contract

These findings indicate that most UMA Optimistic Oracle activity originates from Polymarket, rather than from individual users.

### 4. Bond and Reward Volumes (All Proposals - Unfiltered)
- **Total bond value:** 6,850,000,000,000 USDC (smallest unit)
  - **Actual USD:** ~$6.85 million USDC
- **Total rewards distributed:** 57,600,000,000 USDC (smallest unit)
  - **Actual USD:** ~$57,600 USDC (~$57.6k)
- **Currency dominance:** Over 99% in USDC (token: `0x2791bca1f2de4661ed88a30c99a7a9449aa84174`)

**Note on Denominations:** All bond and reward values are stored in USDC's smallest unit (6 decimals). The values shown above represent actual USDC amounts when divided by 1,000,000.

### 5. Nature of Requests
Most ancillary data strings referenced crypto asset prices (BTC, ETH, XRP, etc.), confirming that UMA's Oracle is primarily used for price outcome verification in prediction markets.

**Filtered Analysis Finding:** 53.7% of all proposals are crypto price predictions, with the remaining 46.3% covering other prediction types (sports, weather, entertainment, etc.).

---

## Key Takeaways

### Overall Market Dynamics
1. **UMA oracle ecosystem in September 2025 was heavily driven by Polymarket**
   - 90%+ of all proposals originated from 2 Polymarket adapter addresses
   - 53.7% of these are crypto asset price predictions

2. **Crypto Price Predictions represent a substantial sub-market**
   - 7,759 proposals with ~$3.88M in bond collateral
   - 99.96% settlement rate indicates high proposal quality
   - Only 0.35% dispute rate (27 disputes total)

3. **Market is highly concentrated but professional**
   - Single proposer controls 76.8% of price predictions
   - Proposers use standardized $500 USDC bonds, suggesting protocol-enforced minimums
   - Conservative 0.73% reward-to-bond ratio indicates confidence-driven participation

4. **Four major crypto assets drive prediction volume**
   - Bitcoin, Ethereum, Solana, and XRP have nearly equal market share (~25% each)
   - Indicates systematic price tracking rather than speculative interest in single assets

5. **High data quality and low dispute rates**
   - 99.96% settlement rate suggests accurate proposals
   - 0.35% dispute rate reflects effective arbitrageurs catching outliers
   - 2 primary disputers (professionals) manage quality assurance

### Business Implications for Our Company

**Opportunity Areas:**
1. **Proposer Reliability Analytics:** Build reputation/scoring system for the 29 proposers, selling to protocols needing confidence in oracle data
2. **Dispute Prediction:** Develop models to predict which proposals are likely to be disputed, enabling risk management
3. **Price Feed Verification:** Offer cross-chain price verification to validate Polymarket/UMA price predictions
4. **Market Intelligence:** Aggregate and sell market sentiment from price prediction volumes and trends

**Risk Factors:**
- Market concentration (single proposer = 76.8%, single requester = 85.4%) creates dependency risk
- If top proposer or requester exits, market volume could collapse
- Limited to crypto assets; expansion opportunities to other assets or oracle networks needed for scale

**Data Quality Validation:**
- High settlement rates and low dispute rates suggest reliable oracle mechanism
- Potential partnership opportunity: provide enhanced dispute detection or prevention services

---

## Appendix: Data Sources & Methodology

### Data Files Used
- `data-dumps/uma_sep_all_text_full.csv` – Full 14,448 proposals with ancillaryData
- `data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv` – 7,759 filtered crypto price predictions

### SQL Queries
All filtering and aggregation performed via DuckDB SQL:
- **Filtering Logic:** `ancillaryData LIKE '%will the price of%' AND ancillaryData LIKE '%{crypto_keyword}%'`
- **Crypto Keywords:** bitcoin, ethereum, xrp, btc, eth, solana, sol, cardano, ada, litecoin, ltc, dogecoin, doge
- **See:** `sql-queries/CRYPTO_PRICE_FILTER.sql` for complete query set

### Python Scripts
- `data-transformation-scripts/filter_and_export.py` – Filtered CSV generation
- `data-transformation-scripts/price_prediction_analysis.py` – Metric extraction and validation
- `data-transformation-scripts/duckdb_advanced_analysis.py` – Advanced aggregate analysis

### USDC Denomination Note
All bond and reward values are recorded in USDC's smallest unit (1e-6 USDC = 1 unit). To convert to actual USD amounts:
- Divide by 1,000,000 (or 1e6)
- Example: 3,877,750,000,000 (smallest units) ÷ 1,000,000 = $3,877,750 = $3.88M

---

**Analysis Date:** October 20, 2025  
**Data Period:** September 1–30, 2025  
**Total Proposals Analyzed:** 14,448 (unfiltered) | 7,759 (filtered - crypto price predictions)  
**Status:** Complete with filtered analysis & USDC denomination clarifications
