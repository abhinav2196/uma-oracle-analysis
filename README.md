# UMA Oracle Price Prediction Analysis

Crypto price prediction proposals from UMA Optimistic Oracle v2 (September 2025).

## 📁 Files

| File | Purpose |
|------|---------|
| `data-dumps/polygon/uma_september_2025_crypto_price_predictions.csv` | **7,759 filtered proposals** (Polygon, Sep 2025) |
| `sql-queries/CRYPTO_PRICE_FILTER.sql` | SQL queries (DuckDB) to reproduce the filtering |
| `docs/UMA_ANALYSIS_REPORT.md` | Complete analysis & findings |
| `docs/QUERIES_EXECUTED.md` | All queries run with Q&A format |
| `docs/CEO_FAQ.md` | **Answers to CEO questions** |
| `docs/MULTI_NETWORK_SETUP.md` | Multi-network analysis setup guide |
| `network-config.json` | Network configuration (Polygon, Ethereum, Arbitrum, Optimism) |

## 🔍 What's in the Data

**Current Scope:** Polygon Network, September 2025

**Filtered Dataset (7,759 proposals):**
- **BTC:** 1,967 proposals (25.3%)
- **ETH:** 1,948 proposals (25.1%)
- **SOL:** 1,944 proposals (25.1%)
- **XRP:** 1,900 proposals (24.5%)

**Key Metrics:**
- Total USDC Bond: $3.88 million
- Total USDC Rewards: $28,166 ($28.2k)
- Settlement Rate: 99.96%
- Dispute Rate: 0.35%

**Multi-Network Support:** Ready to extend to Ethereum, Arbitrum, Optimism (see `docs/MULTI_NETWORK_SETUP.md`)

## 🚀 How to Use

### Option 0: Fetch Data from Other Networks (New!)

Multi-network support is now available:

```bash
# Set up API key (see docs/API_KEY_SETUP.md)
export THE_GRAPH_API_KEY='your_key'

# Fetch Polygon data (already have this)
cd data-transformation-scripts
./fetch_uma_data.sh polygon september_2025
./convert_json_to_csv.sh polygon september_2025
python3 filter_crypto_predictions.py polygon september_2025

# Fetch Ethereum data (configure subgraph ID first)
./fetch_uma_data.sh ethereum september_2025
# ... then convert and filter
```

See `docs/MULTI_NETWORK_SETUP.md` for complete guide.

### Option 1: Query with SQL (DuckDB)
```bash
duckdb
# Polygon September 2025
CREATE TABLE proposals AS SELECT * FROM read_csv_auto('data-dumps/polygon/uma_september_2025_crypto_price_predictions.csv');
-- Copy-paste queries from sql-queries/CRYPTO_PRICE_FILTER.sql
```

### Option 2: Regenerate Filtered CSV
```bash
python3 data-transformation-scripts/filter_and_export.py
```
*(Requires original CSV - paths are configured in script)*

### Option 3: Read Analysis
- `docs/UMA_ANALYSIS_REPORT.md` - Complete findings and business insights
- `docs/QUERIES_EXECUTED.md` - All queries with Q&A format
- `docs/CEO_FAQ.md` - **Answers to leadership questions**
- `docs/MULTI_NETWORK_SETUP.md` - Multi-chain analysis guide

## 📊 CSV Schema

```
id, time, state, requester, proposer, disputer, currency, bond, reward, 
ancillaryData, settlementRecipient, finalFee, proposedPrice, settlementPrice
```

**Important:** Bond and reward values are in USDC's smallest unit (6 decimals). Divide by 1,000,000 for actual USD amounts.

## ⚙️ Tech Stack

- **DuckDB** - SQL analysis on CSV
- **Python** - Data filtering & export

## 📝 Notes

- Data period: **September 1-30, 2025**
- Network: **Polygon**
- Filtering: Regex-based on price patterns & crypto keywords
- Settlement rate: **99.96%** (7,756 of 7,759)
- Dispute rate: **0.35%** (27 disputes)
