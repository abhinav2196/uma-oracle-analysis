# UMA Oracle Price Prediction Analysis

Crypto price prediction proposals from UMA Optimistic Oracle v2 (September 2025).

## 📁 Files

| File | Purpose |
|------|---------|
| `data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv` | **7,759 filtered proposals** with crypto price predictions |
| `sql-queries/CRYPTO_PRICE_FILTER.sql` | SQL queries (DuckDB) to reproduce the filtering |
| `docs/UMA_ANALYSIS_REPORT.md` | Complete analysis & findings |
| `docs/QUERIES_EXECUTED.md` | **All queries run with Q&A format** |
| `data-transformation-scripts/filter_and_export.py` | Python script to regenerate filtered CSV |

## 🔍 What's in the Data

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

## 🚀 How to Use

### Option 0: Regenerate Data from Scratch (Optional)

If you want to re-fetch the raw data:

```bash
# Fetch from The Graph API
cd data-transformation-scripts
./uma_sept_human_readable_text.sh    # → data-dumps/uma_sep_all_text.json

# Convert to CSV
./json_to_csv.sh                      # → data-dumps/uma_sep_all_text_full.csv

# Filter for crypto predictions
cd ..
python3 data-transformation-scripts/filter_and_export.py  # → filtered CSV
```

### Option 1: Query with SQL (DuckDB)
```bash
duckdb
CREATE TABLE proposals AS SELECT * FROM read_csv_auto('data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv');
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
