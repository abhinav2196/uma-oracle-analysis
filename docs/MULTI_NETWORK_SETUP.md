# Multi-Network Setup Guide

This guide explains how to analyze UMA Optimistic Oracle v2 data across multiple blockchain networks.

---

## Quick Start

### 1. Set Up API Key

Get your API key from [The Graph Studio](https://thegraph.com/studio/).

```bash
# Set environment variable (add to your ~/.bashrc or ~/.zshrc)
export THE_GRAPH_API_KEY='your_api_key_here'
```

### 2. Fetch Data for a Network

```bash
cd data-transformation-scripts

# Polygon (September 2025)
./fetch_uma_data.sh polygon september_2025

# Ethereum (when configured)
./fetch_uma_data.sh ethereum september_2025
```

### 3. Convert to CSV

```bash
./convert_json_to_csv.sh polygon september_2025
```

### 4. Filter for Crypto Price Predictions

```bash
cd ..
python3 data-transformation-scripts/filter_crypto_predictions.py polygon september_2025
```

---

## Directory Structure

```
uma-oracle-analysis/
├── data-dumps/
│   ├── polygon/
│   │   ├── uma_september_2025.json                      # Raw JSON from The Graph
│   │   ├── uma_september_2025_full.csv                  # All proposals
│   │   └── uma_september_2025_crypto_price_predictions.csv  # Filtered
│   ├── ethereum/
│   │   └── (same structure)
│   ├── arbitrum/
│   │   └── (same structure)
│   └── optimism/
│       └── (same structure)
├── data-transformation-scripts/
│   ├── fetch_uma_data.sh                    # Multi-network data fetcher
│   ├── convert_json_to_csv.sh               # JSON → CSV converter
│   └── filter_crypto_predictions.py         # Crypto price filter
├── network-config.json                       # Network configurations
└── docs/
    └── MULTI_NETWORK_SETUP.md               # This file
```

---

## Supported Networks

| Network | Status | Subgraph ID |
|---------|--------|-------------|
| **Polygon** | ✅ Configured | `BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK` |
| **Ethereum** | ⚠️ Needs Config | Find subgraph ID |
| **Arbitrum** | ⚠️ Needs Config | Find subgraph ID |
| **Optimism** | ⚠️ Needs Config | Find subgraph ID |

---

## Network Configuration

Edit `network-config.json` to add or update networks:

```json
{
  "networks": {
    "ethereum": {
      "name": "Ethereum Mainnet",
      "subgraph_id": "YOUR_ETHEREUM_SUBGRAPH_ID_HERE",
      "chain_id": 1,
      "description": "Ethereum Mainnet - Primary network"
    }
  }
}
```

### Finding Subgraph IDs

1. Go to [The Graph Explorer](https://thegraph.com/explorer)
2. Search for "UMA Optimistic Oracle v2"
3. Filter by network
4. Copy the Subgraph ID from the URL

---

## Complete Workflow Example

### Analyze Ethereum Mainnet

```bash
# 1. Configure Ethereum subgraph ID in network-config.json

# 2. Set API key
export THE_GRAPH_API_KEY='your_key'

# 3. Fetch data
cd data-transformation-scripts
./fetch_uma_data.sh ethereum september_2025

# 4. Convert to CSV
./convert_json_to_csv.sh ethereum september_2025

# 5. Filter crypto predictions
cd ..
python3 data-transformation-scripts/filter_crypto_predictions.py ethereum september_2025

# 6. Analyze with DuckDB
duckdb
CREATE TABLE ethereum_proposals AS 
  SELECT * FROM read_csv_auto('data-dumps/ethereum/uma_september_2025_crypto_price_predictions.csv');

-- Run your queries...
SELECT COUNT(*) FROM ethereum_proposals;
```

---

## Cross-Network Comparison

Once you have data from multiple networks:

```sql
-- Load all networks
CREATE TABLE polygon_proposals AS 
  SELECT *, 'Polygon' as network 
  FROM read_csv_auto('data-dumps/polygon/uma_september_2025_crypto_price_predictions.csv');

CREATE TABLE ethereum_proposals AS 
  SELECT *, 'Ethereum' as network 
  FROM read_csv_auto('data-dumps/ethereum/uma_september_2025_crypto_price_predictions.csv');

-- Compare volumes
SELECT 
    network,
    COUNT(*) as proposals,
    SUM(CAST(bond AS BIGINT)) / 1000000.0 as total_bond_usdc,
    COUNT(DISTINCT proposer) as unique_proposers
FROM (
    SELECT * FROM polygon_proposals
    UNION ALL
    SELECT * FROM ethereum_proposals
)
GROUP BY network
ORDER BY proposals DESC;
```

---

## Time Periods

Add new time periods in `network-config.json`:

```json
{
  "time_periods": {
    "october_2025": {
      "from": 1759276800,
      "to": 1761955199,
      "description": "Oct 1-31, 2025"
    }
  }
}
```

Then fetch with:
```bash
./fetch_uma_data.sh polygon october_2025
```

---

## Troubleshooting

### "API key not set"
```bash
export THE_GRAPH_API_KEY='your_key_here'
```

### "Subgraph ID not configured"
Update `network-config.json` with the correct subgraph ID for that network.

### "Network not found"
Check available networks:
```bash
cat network-config.json | jq '.networks | keys'
```

### Rate Limits
The Graph has rate limits. The scripts include a 0.2s delay between pages.
If you hit limits, increase `sleep 0.2` to `sleep 0.5` in `fetch_uma_data.sh`.

---

## Migration from Old Structure

If you have existing Polygon data in the old structure:

```bash
# Create new directory structure
mkdir -p data-dumps/polygon

# Move files (if they exist in root data-dumps/)
mv data-dumps/uma_sep_all_text.json data-dumps/polygon/uma_september_2025.json 2>/dev/null || true
mv data-dumps/uma_sep_all_text_full.csv data-dumps/polygon/uma_september_2025_full.csv 2>/dev/null || true
mv data-dumps/uma_sep_all_FILTERED_PRICE_PREDICTIONS.csv data-dumps/polygon/uma_september_2025_crypto_price_predictions.csv 2>/dev/null || true
```

---

## Best Practices

1. **Always use environment variable for API key** - Never hardcode it
2. **Organize by network** - Keep each network's data in its own directory
3. **Use descriptive time periods** - Makes it easy to track what data you have
4. **Verify JSON output** - Check record count after fetching
5. **Test on one network first** - Validate your workflow before scaling

---

## Next Steps

1. Configure Ethereum subgraph ID
2. Fetch Ethereum data for September 2025
3. Compare Polygon vs Ethereum volumes
4. Extend to Arbitrum and Optimism
5. Build cross-chain analysis queries


