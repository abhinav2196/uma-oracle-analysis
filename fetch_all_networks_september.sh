#!/bin/bash

# Comprehensive fetch script for ALL UMA Oracle networks - September 2025
# Created: November 12, 2025
# Networks: Polygon, Ethereum, Optimism, Arbitrum, Blast, Base (17 subgraphs)

API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
GATEWAY="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id"

# September 2025 timestamps
START_TS="1725148800"  # Sept 1, 2025 00:00:00 UTC
END_TS="1727827200"     # Oct 1, 2025 00:00:00 UTC

OUTPUT_DIR="data-dumps/complete"
mkdir -p "$OUTPUT_DIR"

echo "=== FETCHING SEPTEMBER 2025 DATA FROM ALL NETWORKS ==="
echo "Start: $(date -r $START_TS)"
echo "End: $(date -r $END_TS)"
echo ""

# Function to fetch V2 data (OptimisticPriceRequest)
fetch_v2() {
    local NETWORK=$1
    local ID=$2
    local TIME_FIELD=$3  # "time" or "timestamp"
    
    echo "Fetching: $NETWORK (V2 schema, field: $TIME_FIELD)..."
    
    curl -s -X POST \
        -H "Content-Type: application/json" \
        --data "{\"query\":\"{ optimisticPriceRequests(first: 1000, where: {${TIME_FIELD}_gte: \\\"${START_TS}\\\", ${TIME_FIELD}_lt: \\\"${END_TS}\\\"}) { id ${TIME_FIELD} identifier ancillaryData proposer disputer settled proposedPrice resolvedPrice reward bond currency } }\"}" \
        "${GATEWAY}/${ID}" > "${OUTPUT_DIR}/${NETWORK}_september_2025.json"
    
    COUNT=$(cat "${OUTPUT_DIR}/${NETWORK}_september_2025.json" | jq '.data.optimisticPriceRequests | length' 2>/dev/null || echo "0")
    echo "  → $COUNT assertions fetched"
}

# Function to fetch V3 data (Assertion)
fetch_v3() {
    local NETWORK=$1
    local ID=$2
    
    echo "Fetching: $NETWORK (V3 schema)..."
    
    curl -s -X POST \
        -H "Content-Type: application/json" \
        --data "{\"query\":\"{ assertions(first: 1000, where: {assertionTimestamp_gte: \\\"${START_TS}\\\", assertionTimestamp_lt: \\\"${END_TS}\\\"}) { id assertionId assertionTimestamp claim asserter bond currency domainId identifier settled } }\"}" \
        "${GATEWAY}/${ID}" > "${OUTPUT_DIR}/${NETWORK}_september_2025.json"
    
    COUNT=$(cat "${OUTPUT_DIR}/${NETWORK}_september_2025.json" | jq '.data.assertions | length' 2>/dev/null || echo "0")
    echo "  → $COUNT assertions fetched"
}

# POLYGON
echo "=== POLYGON ==="
fetch_v2 "polygon_v1" "2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um" "time"
fetch_v2 "polygon_v2_old" "BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK" "time"
fetch_v2 "polygon_v2_new" "CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork" "time"
fetch_v3 "polygon_v3" "7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf"
echo ""

# ETHEREUM
echo "=== ETHEREUM ==="
fetch_v2 "ethereum_v1" "56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw" "time"
fetch_v2 "ethereum_v2" "GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m" "time"
fetch_v3 "ethereum_v3" "Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
echo ""

# OPTIMISM
echo "=== OPTIMISM ==="
fetch_v2 "optimism_v1" "E5E5muqrrzhp8PhYwSLTGFx7xKrCqtNzqwMPiYGn1CkF" "time"
fetch_v2 "optimism_v2" "DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6" "time"
fetch_v3 "optimism_v3" "FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn"
echo ""

# ARBITRUM
echo "=== ARBITRUM ==="
fetch_v2 "arbitrum_v1" "8UmLeHVL3LDrvCrjhehVaj4oHEUVhTqeY2pdwS3RdSPV" "time"
fetch_v2 "arbitrum_v2" "Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm" "time"
fetch_v3 "arbitrum_v3" "9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW"
echo ""

# BLAST
echo "=== BLAST ==="
fetch_v2 "blast_v1" "C2cBAgmb47t9Q4nx32k6Jgqn3A8f4rxy87MPc9xm3t5Y" "time"
fetch_v2 "blast_v2" "EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k" "time"
echo ""

# BASE
echo "=== BASE ==="
fetch_v2 "base_v2" "2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D" "time"
fetch_v3 "base_v3" "2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C"
echo ""

echo "=== FETCH COMPLETE ==="
echo "Data saved to: $OUTPUT_DIR"
echo ""
echo "Summary:"
find "$OUTPUT_DIR" -name "*.json" -exec sh -c 'echo "$(basename {}): $(cat {} | jq -r \".data | to_entries[0].value | length\" 2>/dev/null || echo 0) assertions"' \;

