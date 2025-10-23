# UMA Oracle Price Prediction Analysis

Crypto price prediction proposals from UMA Optimistic Oracle v2 (September 2025).

## 📁 Files

| File | Purpose |
|------|---------|
| `docs/UMA_ANALYSIS_REPORT.md` | Original analysis (7,759 Polygon predictions) |
| `docs/CROSS_NETWORK_ANALYSIS.md` | **Multi-network comparison** (Polygon/Ethereum/Base) |
| `docs/DISCOVERY_STORY.md` | **How we found 10k additional Polygon predictions** |
| `docs/ETHEREUM_FINDINGS.md` | Ethereum V3 analysis (governance/disputes) |
| `docs/BASE_FINDINGS.md` | Base V3 analysis (minimal activity) |
| `docs/CEO_FAQ.md` | Answers to CEO questions |
| `docs/QUERIES_EXECUTED.md` | All queries with Q&A format |
| `docs/SUBGRAPH_INVESTIGATION.md` | Technical investigation details |
| `network-config.json` | Verified network configuration |

## 🔍 What's in the Data

**Current Scope:** Polygon Network, September 2025

### Original Analysis (Published)
**Filtered Dataset (7,759 proposals from Polymarket Adapter 0x2f5e...):**
- **BTC:** 1,967 proposals (25.3%)
- **ETH:** 1,948 proposals (25.1%)
- **SOL:** 1,938 proposals (25.0%)
- **XRP:** 1,900 proposals (24.5%)

**Key Metrics:**
- Total USDC Bond: $3.88 million
- Total USDC Rewards: $28,166 ($28.2k)
- Settlement Rate: 99.96%
- Dispute Rate: 0.35%

### 🔍 Discovery Update (Oct 23, 2025)

**We found a second Polygon subgraph tracking a different Polymarket adapter!**

**Additional Dataset (10,071 proposals from Polymarket Adapter 0x6507...):**
- **BTC:** 2,517 | **ETH:** 2,520 | **SOL:** 2,522 | **XRP:** 2,510

**Combined Polygon Total: 17,830 crypto predictions** (2.3x original count)

📖 **Read the full story:** `docs/DISCOVERY_STORY.md`

## 🌐 All Networks Analyzed

| Network | Oracle | Total Assertions | Crypto Predictions | Status |
|---------|--------|------------------|--------------------|--------|
| **Polygon** | V2 | 30,014 | **17,830** (99.98%) | ✅ Complete |
| **Ethereum** | V3 | 1,025 | 0 (0%) | ✅ Complete |
| **Base** | V3 | 49 | 3 (0.02%) | ✅ Complete |
| **TOTAL** | - | **31,088** | **17,833** | ✅ |

**Key Insight:** Polygon V2 is the crypto price prediction hub. Ethereum/Base V3 serve different purposes (governance/disputes).

📊 **See full analysis:** `docs/CROSS_NETWORK_ANALYSIS.md`

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

**Original Analysis:**
- `docs/UMA_ANALYSIS_REPORT.md` - Complete findings (7,759 predictions from one Polymarket adapter)
- `docs/QUERIES_EXECUTED.md` - All queries with Q&A format

**Follow-Up Discovery:**
- `docs/DISCOVERY_STORY.md` - **How we found 10,071 additional predictions** (must-read!)
- `docs/SUBGRAPH_INVESTIGATION.md` - Technical investigation details

**Leadership Resources:**
- `docs/CEO_FAQ.md` - Answers to all CEO questions
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
