# Finding DEXTFUSD in Ethereum V2 Oracle Data

## Problem

DEXTFUSD is not showing up in the filtered data because:

1. **Ethereum has BOTH V2 and V3 oracles** running simultaneously
2. **Current setup only fetches V3 data** (assertions)
3. **DEXTFUSD is a price identifier in V2**, not V3
4. **The V2 fetch script filters out non-YES_OR_NO_QUERY identifiers**

## Transaction Evidence

The DEXTFUSD request can be seen here:
https://etherscan.io/tx/0xd42cd07cf5319ed8de2f3959a74ba0f98162f78b09da83c062d31c0e48767d87

This transaction calls the Optimistic Oracle V2 contract with the identifier "DEXTFUSD".

## Solution

### Step 1: Get Ethereum V2 Subgraph ID

We need to find the correct subgraph ID for Ethereum Optimistic Oracle V2:

1. Visit https://thegraph.com/explorer
2. Search for "UMA Optimistic Oracle V2 Ethereum"
3. Look for the subgraph published by UMA Protocol
4. Copy the subgraph ID

Common possibilities:
- Check UMA's official documentation
- Look at The Graph Explorer for "uma-optimistic-oracle-v2"
- The contract address is: `0xA0Ae6609447e57a42c51B50EAe921D701823FFAe`

### Step 2: Update Configuration

Once you have the subgraph ID, update `network-config.json`:

```json
"ethereum_v2": {
  "name": "Ethereum Mainnet V2",
  "subgraph_id": "YOUR_ACTUAL_SUBGRAPH_ID_HERE",
  "oracle_version": "v2",
  "chain_id": 1,
  "description": "Ethereum Mainnet - Optimistic Oracle V2",
  "contract_address": "0xA0Ae6609447e57a42c51B50EAe921D701823FFAe",
  "note": "V2 oracle for price identifiers like DEXTFUSD"
}
```

### Step 3: Fetch ALL Identifiers (Not Just YES_OR_NO_QUERY)

Use the new script that fetches ALL identifiers:

```bash
cd data-transformation-scripts
./fetch_uma_data_all_identifiers.sh ethereum_v2 september_2025
```

This script:
- ✅ Fetches ALL price requests (no identifier filter)
- ✅ Decodes both `ancillaryData` AND `identifier` from hex
- ✅ Includes identifier breakdown in output

### Step 4: Convert to CSV

```bash
./convert_json_to_csv.sh ethereum_v2 september_2025
```

### Step 5: Search for DEXTFUSD

```bash
cd ../data-dumps/ethereum_v2
grep -i DEXTF uma_september_2025_full.csv
```

Or search in the JSON:

```bash
grep -i DEXTF uma_september_2025.json
```

## Filter Script Update

The existing filter scripts (`filter_crypto_predictions.py`) only look for common crypto keywords (bitcoin, ethereum, xrp, etc.). To include DEXTFUSD, you have two options:

### Option 1: Create a custom filter for price identifiers

Create a new script `filter_price_identifiers.py` that:
- Looks for entries with non-empty `identifier` field
- Filters out governance proposals (ASSERT_TRUTH)
- Keeps price feeds like DEXTFUSD, ETHUSD, BTCUSD, etc.

### Option 2: Manual extraction

```bash
# Find all DEXTFUSD entries
grep "DEXTFUSD" data-dumps/ethereum_v2/uma_september_2025_full.csv > dextfusd_entries.csv
```

## Expected Result

After fetching ethereum_v2 data with all identifiers, you should see:

```
Identifier breakdown (top 10):
  1500 YES_OR_NO_QUERY
   150 DEXTFUSD
    80 ETHUSD
    50 BTCUSD
   ...
```

And DEXTFUSD entries will appear in the CSV with:
- Decoded identifier: "DEXTFUSD"  
- AncillaryData: Price request details
- Timestamp: Within September 2025 range

## Why This Was Missed

1. **Network Configuration**: Ethereum was only configured as V3
2. **Identifier Filter**: The V2 fetch script had a hardcoded filter for `YES_OR_NO_QUERY`
3. **Price vs Market Questions**: DEXTFUSD is a price identifier, not a market prediction question

## Related Files

- `/network-config.json` - Network configurations
- `/data-transformation-scripts/fetch_uma_data_all_identifiers.sh` - New all-identifier fetcher
- `/data-transformation-scripts/fetch_uma_data.sh` - Original (filtered) fetcher
- `/data-transformation-scripts/fetch_uma_v3_data.sh` - V3 assertions fetcher

## Notes

- Price identifiers (like DEXTFUSD) are different from market questions (YES_OR_NO_QUERY)
- Ethereum V2 and V3 oracles run side-by-side with different use cases
- V2 is for price feeds, V3 is for assertion-based markets
- Both should be fetched separately for complete data coverage



