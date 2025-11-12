#!/bin/bash

# Fetch AUGUST 2025 data from ALL networks
# Handles both V2 (OptimisticPriceRequest) and V3 (Assertion) schemas

API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
GATEWAY="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id"

# AUGUST 2025 timestamps
START_TS="1753999200"  # Aug 1, 2025 00:00:00
END_TS="1756677600"    # Sep 1, 2025 00:00:00

OUTPUT_DIR="data-dumps/august_2025"
mkdir -p "$OUTPUT_DIR"

echo "=== FETCHING AUGUST 2025 DATA FROM ALL NETWORKS ==="
echo "Period: August 1-31, 2025"
echo "Start TS: $START_TS"
echo "End TS: $END_TS"
echo ""

# Function for V2 oracle (OptimisticPriceRequest with 'time' field)
fetch_v2() {
    local NETWORK=$1
    local ID=$2
    
    echo "Fetching: $NETWORK (V2 schema)..."
    
    curl -s --max-time 60 -X POST \
        -H "Content-Type: application/json" \
        --data "{\"query\":\"{ optimisticPriceRequests(first: 1000, where: {time_gte: \\\"${START_TS}\\\", time_lt: \\\"${END_TS}\\\"}, orderBy: time) { id time identifier ancillaryData state requester proposer disputer settlementRecipient currency bond reward finalFee proposedPrice settlementPrice } }\"}" \
        "${GATEWAY}/${ID}" > "${OUTPUT_DIR}/${NETWORK}_raw.json"
    
    COUNT=$(cat "${OUTPUT_DIR}/${NETWORK}_raw.json" | jq '.data.optimisticPriceRequests | length' 2>/dev/null || echo "0")
    echo "  → $COUNT assertions"
    
    # Save count
    echo "$NETWORK,$COUNT" >> "${OUTPUT_DIR}/fetch_summary.txt"
}

# Function for V3 oracle (Assertion with 'assertionTimestamp' field)
fetch_v3() {
    local NETWORK=$1
    local ID=$2
    
    echo "Fetching: $NETWORK (V3 schema)..."
    
    curl -s --max-time 60 -X POST \
        -H "Content-Type: application/json" \
        --data "{\"query\":\"{ assertions(first: 1000, where: {assertionTimestamp_gte: \\\"${START_TS}\\\", assertionTimestamp_lt: \\\"${END_TS}\\\"}, orderBy: assertionTimestamp) { id assertionId assertionTimestamp claim asserter callbackRecipient escalationManager caller expirationTime currency bond identifier settled } }\"}" \
        "${GATEWAY}/${ID}" > "${OUTPUT_DIR}/${NETWORK}_raw.json"
    
    COUNT=$(cat "${OUTPUT_DIR}/${NETWORK}_raw.json" | jq '.data.assertions | length' 2>/dev/null || echo "0")
    echo "  → $COUNT assertions"
    
    # Save count
    echo "$NETWORK,$COUNT" >> "${OUTPUT_DIR}/fetch_summary.txt"
}

# Clear summary
> "${OUTPUT_DIR}/fetch_summary.txt"

# Fetch from all networks
echo "=== POLYGON ==="
fetch_v2 "polygon_v2_new" "CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork"
fetch_v2 "polygon_v2_old" "BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK"
fetch_v3 "polygon_v3" "7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf"
echo ""

echo "=== ETHEREUM ==="
fetch_v2 "ethereum_v2" "GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m"
fetch_v3 "ethereum_v3" "Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
echo ""

echo "=== BASE ==="
fetch_v2 "base_v2" "2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D"
fetch_v3 "base_v3" "2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C"
echo ""

echo "=== OPTIMISM ==="
fetch_v2 "optimism_v2" "DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6"
fetch_v3 "optimism_v3" "FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn"
echo ""

echo "=== BLAST ==="
fetch_v2 "blast_v2" "EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k"
echo ""

echo "=== ARBITRUM ==="
fetch_v2 "arbitrum_v2" "Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm"
fetch_v3 "arbitrum_v3" "9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW"
echo ""

echo "=== FETCH COMPLETE ==="
echo ""
echo "Summary:"
cat "${OUTPUT_DIR}/fetch_summary.txt" | awk -F',' '{sum+=$2; print $1": "$2" assertions"} END {print "\nTOTAL: "sum" assertions"}'

