# UMA Oracle Analysis

Analysis of UMA's Optimistic Oracle deployments across multiple networks to understand crypto price prediction activity.

## 📊 Quick Results

**Period Analyzed:** September 2025  
**Total Crypto Price Predictions:** 17,833  
**Primary Network:** Polygon (99.98% of activity)

See full analysis: [`docs/FINAL_SUMMARY.md`](docs/FINAL_SUMMARY.md)

---

## 🚀 Quick Start

### Prerequisites

1. **Get a Graph API Key**  
   - Sign up at [The Graph Studio](https://thegraph.com/studio/)
   - See detailed instructions: [`docs/API_KEY_SETUP.md`](docs/API_KEY_SETUP.md)

2. **Set API Key**
   ```bash
   export THE_GRAPH_API_KEY='your_key_here'
   ```

### Verify Setup

```bash
# Test that all subgraphs are accessible
make verify-subgraphs
```

---

## 📋 Usage

The repository provides a unified workflow for fetching, converting, and filtering UMA oracle data.

### 1. Fetch Data

```bash
make fetch NETWORK=polygon_v2_new PERIOD=september_2025 FIELDS='identifier ancillaryData'
```

**Output:** `data-dumps/polygon_v2_new/september_2025/polygon_v2_new_september_2025.json`

### 2. Convert to CSV

```bash
make convert \
  NETWORK=polygon_v2_new \
  PERIOD=september_2025 \
  INPUT=data-dumps/polygon_v2_new/september_2025/polygon_v2_new_september_2025.json
```

**Output:** CSV with decoded hex fields (`identifier_text`, `ancillaryData_text`)

### 3. Filter Data

```bash
make filter \
  NETWORK=polygon_v2_new \
  PERIOD=september_2025 \
  INPUT=data-dumps/polygon_v2_new/september_2025/polygon_v2_new_september_2025.csv \
  WHERE='identifier_text~PRICE'
```

**Output:** Filtered CSV with only crypto price predictions

### Available Networks

Run `make verify-subgraphs` to see all 17 configured networks:
- Polygon V2 (old & new adapters)
- Ethereum V3
- Base V2 & V3
- Arbitrum V2 & V3
- Optimism V2 & V3
- Blast V2 & V3

---

## 🛠️ Available Commands

```bash
make help              # Show all available targets
make verify-subgraphs  # Verify all subgraph endpoints
make fetch             # Fetch subgraph data
make convert           # Convert JSON to CSV
make filter            # Filter CSV rows
make inventory-scripts # Generate scripts documentation
```

---

## 📁 Repository Structure

```
uma-oracle-analysis/
├── README.md                    # This file
├── Makefile                     # Workflow automation
├── network-config-COMPLETE.json # 17 networks configured
│
├── scripts/                     # Analysis scripts
│   ├── fetch.py                 # Fetch from subgraphs
│   ├── convert.py               # JSON→CSV converter
│   ├── filter.py                # CSV filter
│   ├── verify_subgraphs.py      # Subgraph verification
│   └── lib/io_utils.py          # Shared utilities
│
├── docs/                        # Documentation
│   ├── FINAL_SUMMARY.md         # Complete analysis report
│   └── API_KEY_SETUP.md         # Setup instructions
│
├── sql-queries/                 # SQL reference queries
│   └── CRYPTO_PRICE_FILTER.sql  # DuckDB queries for filtering
│
├── subgraphs/                   # Subgraph registry
│   ├── README.md                # Registry documentation
│   ├── REGISTRY.json            # Machine-readable (generated)
│   └── REGISTRY.md              # Human-readable (generated)
│
└── data-dumps/                  # Raw data (gitignored)
    └── {network}/{period}/      # Organized by network & period
```

---

## 🔍 Analysis Approach

### Data Pipeline

1. **Fetch** - Query The Graph subgraphs via GraphQL
2. **Convert** - Transform JSON to CSV, decode hex fields
3. **Filter** - Extract crypto price predictions using pattern matching
4. **Analyze** - Use DuckDB/SQL for aggregations

### Filtering Logic

Crypto price predictions are identified by:
- **Price patterns:** "will the price of", "price between $", etc.
- **Crypto keywords:** bitcoin, ethereum, btc, eth, solana, xrp, etc.

See: [`sql-queries/CRYPTO_PRICE_FILTER.sql`](sql-queries/CRYPTO_PRICE_FILTER.sql)

---

## 📖 Key Findings

From September 2025 analysis:

- **Total oracle requests:** 31,088 across all networks
- **Crypto price predictions:** 17,833 (57.3%)
- **Polygon dominance:** 99.98% of crypto predictions
- **Settlement rate:** 99.96% (extremely reliable)
- **Dispute rate:** 0.35% (very low)

**Insight:** Polygon V2 is the hub for crypto price predictions (via Polymarket). Ethereum/Base V3 serve different use cases (governance, disputes, general assertions).

Full details: [`docs/FINAL_SUMMARY.md`](docs/FINAL_SUMMARY.md)

---

## 🧪 Testing

All scripts and workflows have been tested. See [`TESTING.md`](TESTING.md) for detailed results.

**Status:** ✅ All tests passing

---

## 📝 Notes

- **Time periods** and **networks** are configured in `network-config-COMPLETE.json`
- All scripts use Python stdlib only (no external dependencies)
- Data dumps are excluded from git (via `.gitignore`)
- Large data files are excluded from AI context (via `.cursorignore`)

---

## 🤝 Contributing

To add a new network:
1. Add entry to `network-config-COMPLETE.json`
2. Run `make verify-subgraphs` to test
3. Fetch data with `make fetch NETWORK=your_network PERIOD=your_period`

---

## 📄 License

Analysis and scripts for research purposes.
