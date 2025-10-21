# Queries Executed - UMA Oracle Analysis

**Analysis Period:** September 1-30, 2025  
**Data Source:** The Graph - UMA Optimistic Oracle v2 Subgraph  
**Network:** Polygon

---

## 1. Data Collection

### Question: How do we fetch all UMA oracle proposals for September 2025?

**Method:** GraphQL query to The Graph API  
**Script:** `data-transformation-scripts/uma_sept_human_readable_text.sh`

```graphql
{
  optimisticPriceRequests(
    first: 200,
    orderBy: time,
    orderDirection: desc,
    where: {
      time_gte: 1756684800,    # Sep 1, 2025 00:00:00 UTC
      time_lte: 1759276799,    # Sep 30, 2025 23:59:59 UTC
      identifier_contains_nocase: "YES_OR_NO_QUERY"
    }
  ) {
    id
    time
    state
    requester
    proposer
    disputer
    settlementRecipient
    currency
    bond
    reward
    finalFee
    proposedPrice
    settlementPrice
    ancillaryData
  }
}
```

**Result:** 14,448 proposals → `data-dumps/uma_sep_all_text_full.csv`

---

## 2. Data Filtering

### Question: Which proposals are crypto price predictions?

**Method:** Pattern matching on ancillaryData field  
**Script:** `data-transformation-scripts/filter_and_export.py`

**Filtering Logic:**
```python
# Must match BOTH conditions:
1. Price pattern: "will the price of"
2. Crypto keyword: bitcoin|ethereum|xrp|btc|eth|solana|sol|cardano|ada|litecoin|ltc|dogecoin|doge
```

**Result:** 7,759 crypto price predictions → `data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv`

---

## 3. Analysis Queries

All queries run in **DuckDB** against the filtered CSV.

### Setup
```sql
CREATE TABLE proposals AS 
SELECT * FROM read_csv_auto('data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv');
```

---

### Query 1: What are the total volumes?

**Question:** Total bond and reward volumes for crypto price predictions

```sql
SELECT 
    COUNT(*) as total_predictions,
    SUM(CAST(bond AS BIGINT)) as total_bond_smallest_unit,
    SUM(CAST(reward AS BIGINT)) as total_reward_smallest_unit,
    SUM(CAST(bond AS BIGINT)) / 1000000.0 as total_bond_usdc,
    SUM(CAST(reward AS BIGINT)) / 1000000.0 as total_reward_usdc
FROM proposals;
```

**Answer:**
- 7,759 crypto price predictions
- $3.88M USDC in bonds
- $28,166 USDC in rewards

---

### Query 2: How are predictions distributed by crypto asset?

**Question:** Which crypto assets have the most price prediction activity?

```sql
SELECT 
    CASE 
        WHEN LOWER(ancillaryData) LIKE '%bitcoin%' OR LOWER(ancillaryData) LIKE '%btc%' THEN 'BTC'
        WHEN LOWER(ancillaryData) LIKE '%ethereum%' OR LOWER(ancillaryData) LIKE '%eth%' THEN 'ETH'
        WHEN LOWER(ancillaryData) LIKE '%xrp%' THEN 'XRP'
        WHEN LOWER(ancillaryData) LIKE '%solana%' OR LOWER(ancillaryData) LIKE '%sol%' THEN 'SOL'
        ELSE 'OTHER'
    END as asset,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM proposals), 2) as percentage,
    SUM(CAST(bond AS BIGINT)) / 1000000.0 as total_bond_usdc
FROM proposals
GROUP BY asset
ORDER BY count DESC;
```

**Answer:**
- BTC: 1,967 (25.3%), $981k bonds
- ETH: 1,948 (25.1%), $973k bonds  
- SOL: 1,944 (25.1%), $973k bonds
- XRP: 1,900 (24.5%), $950k bonds

---

### Query 3: What is the settlement and dispute rate?

**Question:** How reliable are crypto price predictions?

```sql
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN state = 'Settled' THEN 1 ELSE 0 END) as settled,
    SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) as disputed,
    ROUND(100.0 * SUM(CASE WHEN state = 'Settled' THEN 1 ELSE 0 END) / COUNT(*), 2) as settlement_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as dispute_rate_pct
FROM proposals;
```

**Answer:**
- Settlement rate: 99.96% (7,756 of 7,759)
- Dispute rate: 0.35% (27 disputes)

---

### Query 4: Who are the dominant market participants?

**Question:** Market concentration - proposers, requesters, disputers

```sql
-- Top Proposers
SELECT 
    proposer,
    COUNT(*) as proposals,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM proposals), 2) as market_share_pct
FROM proposals
GROUP BY proposer
ORDER BY proposals DESC
LIMIT 5;

-- Top Requesters
SELECT 
    requester,
    COUNT(*) as requests,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM proposals), 2) as market_share_pct
FROM proposals
GROUP BY requester
ORDER BY requests DESC;

-- Top Disputers
SELECT 
    disputer,
    COUNT(*) as disputes
FROM proposals
WHERE disputer IS NOT NULL
GROUP BY disputer
ORDER BY disputes DESC;
```

**Answer:**
- **Proposers:** Top 1 controls 76.8% (5,956 proposals), 29 unique total
- **Requesters:** Top 2 control 100% (Polymarket adapters)
  - `0x2f5e3684cb...` = 85.4% (6,624 requests)
  - `0x157ce2d672...` = 14.6% (1,131 requests)
- **Disputers:** 2 addresses account for 85% of all disputes

---

### Query 5: What are typical bond and reward amounts?

**Question:** Standard economics of a crypto price prediction

```sql
SELECT 
    CAST(bond AS BIGINT) / 1000000.0 as bond_usdc,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM proposals), 2) as percentage
FROM proposals
GROUP BY bond_usdc
ORDER BY count DESC;

SELECT 
    CAST(reward AS BIGINT) / 1000000.0 as reward_usdc,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM proposals), 2) as percentage
FROM proposals
GROUP BY reward_usdc
ORDER BY count DESC;
```

**Answer:**
- **Bonds:** Highly standardized
  - $500 USDC: 7,757 proposals (99.97%)
  - $250 USDC: 2 proposals
- **Rewards:** Standardized tiers
  - $2 USDC: Most common
  - $1-$5 USDC: Standard range
- **Reward/Bond Ratio:** 0.73% average

---

## 4. Complete Overview Query

### Question: Give me all key metrics in one query

```sql
WITH crypto_predictions AS (
    SELECT 
        *,
        CASE 
            WHEN LOWER(ancillaryData) LIKE '%bitcoin%' OR LOWER(ancillaryData) LIKE '%btc%' THEN 'BTC'
            WHEN LOWER(ancillaryData) LIKE '%ethereum%' OR LOWER(ancillaryData) LIKE '%eth%' THEN 'ETH'
            WHEN LOWER(ancillaryData) LIKE '%xrp%' THEN 'XRP'
            WHEN LOWER(ancillaryData) LIKE '%solana%' OR LOWER(ancillaryData) LIKE '%sol%' THEN 'SOL'
            ELSE 'OTHER'
        END as crypto_asset
    FROM proposals
)
SELECT 
    COUNT(*) as total_predictions,
    COUNT(DISTINCT crypto_asset) as unique_assets,
    COUNT(DISTINCT proposer) as unique_proposers,
    COUNT(DISTINCT requester) as unique_requesters,
    SUM(CASE WHEN state = 'Settled' THEN 1 ELSE 0 END) as settled,
    SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) as disputed,
    SUM(CAST(bond AS BIGINT)) / 1000000.0 as total_bond_usdc,
    SUM(CAST(reward AS BIGINT)) / 1000000.0 as total_reward_usdc,
    ROUND(AVG(CAST(bond AS BIGINT)) / 1000000.0, 2) as avg_bond_usdc,
    ROUND(AVG(CAST(reward AS BIGINT)) / 1000000.0, 2) as avg_reward_usdc
FROM crypto_predictions;
```

**Answer:** Complete summary in one row

---

## Key Findings Summary

| Metric | Value |
|--------|-------|
| **Total Crypto Price Predictions** | 7,759 |
| **Total Bond (USDC)** | $3.88M |
| **Total Rewards (USDC)** | $28,166 |
| **Settlement Rate** | 99.96% |
| **Dispute Rate** | 0.35% |
| **Unique Assets Tracked** | 4 major (BTC, ETH, SOL, XRP) |
| **Market Concentration** | Top proposer: 76.8%, Top 2 requesters: 100% |
| **Average Bond** | $500 USDC |
| **Average Reward** | $3.63 USDC |

---

## Reproducibility

To reproduce this analysis:

1. **Fetch data:**
   ```bash
   ./data-transformation-scripts/uma_sept_human_readable_text.sh
   ./data-transformation-scripts/json_to_csv.sh uma_sep_all_text.json
   ```

2. **Filter for crypto:**
   ```bash
   python3 data-transformation-scripts/filter_and_export.py
   ```

3. **Run analysis:**
   ```bash
   duckdb
   CREATE TABLE proposals AS SELECT * FROM read_csv_auto('data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv');
   -- Copy-paste queries from sql-queries/CRYPTO_PRICE_FILTER.sql
   ```

---

**All queries available in:** `sql-queries/CRYPTO_PRICE_FILTER.sql`  
**Complete analysis:** `docs/UMA_ANALYSIS_REPORT.md`

