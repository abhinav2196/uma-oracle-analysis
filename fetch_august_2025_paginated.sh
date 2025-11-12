#!/bin/bash

# Fetch AUGUST 2025 with proper pagination
API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
GATEWAY="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id"

START_TS="1753999200"  # Aug 1, 2025
END_TS="1756677600"    # Sep 1, 2025

OUTPUT_DIR="data-dumps/august_2025"
mkdir -p "$OUTPUT_DIR"

# Paginated V2 fetch
fetch_v2_paginated() {
    local NETWORK=$1
    local ID=$2
    local OUTPUT="${OUTPUT_DIR}/${NETWORK}_full.json"
    
    echo "Fetching: $NETWORK (V2, paginated)..."
    
    SKIP=0
    TOTAL=0
    > "$OUTPUT"  # Clear file
    echo '{"data":{"optimisticPriceRequests":[' >> "$OUTPUT"
    
    while true; do
        BATCH=$(curl -s --max-time 60 -X POST \
            -H "Content-Type: application/json" \
            --data "{\"query\":\"{ optimisticPriceRequests(first: 1000, skip: ${SKIP}, where: {time_gte: \\\"${START_TS}\\\", time_lt: \\\"${END_TS}\\\"}, orderBy: time) { id time identifier ancillaryData state requester proposer disputer settlementRecipient currency bond reward finalFee proposedPrice settlementPrice } }\"}" \
            "${GATEWAY}/${ID}")
        
        COUNT=$(echo "$BATCH" | jq '.data.optimisticPriceRequests | length')
        
        if [ "$COUNT" -eq 0 ]; then
            break
        fi
        
        # Append data (handle comma separation)
        if [ $SKIP -gt 0 ]; then
            echo "," >> "$OUTPUT"
        fi
        echo "$BATCH" | jq -c '.data.optimisticPriceRequests[]' >> "$OUTPUT"
        
        TOTAL=$((TOTAL + COUNT))
        SKIP=$((SKIP + 1000))
        
        echo "  → Batch: $COUNT (Total: $TOTAL)"
        
        if [ "$COUNT" -lt 1000 ]; then
            break
        fi
        
        sleep 1
    done
    
    echo ']}}' >> "$OUTPUT"
    echo "  → FINAL: $TOTAL assertions"
}

# Regular V3 fetch (unlikely to hit limit)
fetch_v3() {
    local NETWORK=$1
    local ID=$2
    
    echo "Fetching: $NETWORK (V3 schema)..."
    
    curl -s --max-time 60 -X POST \
        -H "Content-Type: application/json" \
        --data "{\"query\":\"{ assertions(first: 1000, where: {assertionTimestamp_gte: \\\"${START_TS}\\\", assertionTimestamp_lt: \\\"${END_TS}\\\"}, orderBy: assertionTimestamp) { id assertionId assertionTimestamp claim asserter callbackRecipient escalationManager caller expirationTime currency bond identifier settled } }\"}" \
        "${GATEWAY}/${ID}" > "${OUTPUT_DIR}/${NETWORK}_full.json"
    
    COUNT=$(cat "${OUTPUT_DIR}/${NETWORK}_full.json" | jq '.data.assertions | length' 2>/dev/null || echo "0")
    echo "  → $COUNT assertions"
}

# Fetch all networks
echo "=== POLYGON ==="
fetch_v2_paginated "polygon_v2_old" "BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK"
fetch_v2_paginated "polygon_v2_new" "CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork"
fetch_v3 "polygon_v3" "7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf"
echo ""

echo "=== ETHEREUM ==="
fetch_v2_paginated "ethereum_v2" "GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m"
fetch_v3 "ethereum_v3" "Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
echo ""

echo "=== BASE ==="
fetch_v2_paginated "base_v2" "2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D"
fetch_v3 "base_v3" "2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C"
echo ""

echo "=== OPTIMISM ==="
fetch_v2_paginated "optimism_v2" "DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6"
fetch_v3 "optimism_v3" "FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn"
echo ""

echo "=== BLAST ==="
fetch_v2_paginated "blast_v2" "EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k"
echo ""

echo "=== ARBITRUM ==="
fetch_v2_paginated "arbitrum_v2" "Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm"
fetch_v3 "arbitrum_v3" "9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW"

echo ""
echo "=== COMPLETE SUMMARY ==="
cat data-dumps/august_2025/*_full.json | jq -s 'map(select(.data != null)) | map(if .data.optimisticPriceRequests then .data.optimisticPriceRequests elif .data.assertions then .data.assertions else [] end) | add | length' 2>/dev/null || echo "Calculating..."

