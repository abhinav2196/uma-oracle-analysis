#!/bin/bash

API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
GATEWAY="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id"

echo "=== TESTING ALL 20 SUBGRAPH IDS ==="
echo ""

# Array of all subgraph IDs with names
declare -A SUBGRAPHS
SUBGRAPHS["Polygon V2 (old)"]="BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK"
SUBGRAPHS["Polygon V1"]="2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um"
SUBGRAPHS["Arbitrum V3"]="9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW"
SUBGRAPHS["Ethereum V3"]="Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
SUBGRAPHS["Blast V2"]="EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k"
SUBGRAPHS["Ethereum V2"]="GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m"
SUBGRAPHS["Arbitrum V1"]="8UmLeHVL3LDrvCrjhehVaj4oHEUVhTqeY2pdwS3RdSPV"
SUBGRAPHS["Arbitrum V2"]="Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm"
SUBGRAPHS["Blast V1"]="C2cBAgmb47t9Q4nx32k6Jgqn3A8f4rxy87MPc9xm3t5Y"
SUBGRAPHS["Polygon V3"]="7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf"
SUBGRAPHS["Optimism V1"]="E5E5muqrrzhp8PhYwSLTGFx7xKrCqtNzqwMPiYGn1CkF"
SUBGRAPHS["Base V3"]="2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C"
SUBGRAPHS["Optimism V3"]="FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn"
SUBGRAPHS["Ethereum V1"]="56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw"
SUBGRAPHS["Optimism V2"]="DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6"
SUBGRAPHS["Base V2 (A)"]="2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D"
SUBGRAPHS["Base V2 (B)"]="DMWJanhFZn9SiqiLCJz5VEVGEgQbMvi45ggwzPyf5cDW"

# Test each subgraph
for NAME in "${!SUBGRAPHS[@]}"; do
    ID="${SUBGRAPHS[$NAME]}"
    URL="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/${ID}"
    
    echo "=== Testing: $NAME ==="
    echo "ID: $ID"
    
    # Test 1: Get schema types
    SCHEMA=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        --data '{"query":"{ __schema { types { name kind } } }"}' \
        "$URL" | jq -r '.data.__schema.types[] | select(.kind == "OBJECT" and (.name | startswith("_") | not)) | .name' 2>/dev/null | grep -v "Query\|Subscription" | head -5)
    
    if [ ! -z "$SCHEMA" ]; then
        echo "✅ WORKS with our API key"
        echo "Entity types:"
        echo "$SCHEMA"
        
        # Test 2: Check for September 2025 data
        # Try V3 (Assertion) query first
        TEST_DATA=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            --data '{"query":"{ assertions(first: 1, where: {assertionTimestamp_gte: \"1725148800\", assertionTimestamp_lt: \"1727827200\"}) { id assertionTimestamp } }"}' \
            "$URL" 2>/dev/null)
        
        if echo "$TEST_DATA" | jq -e '.data.assertions[0]' > /dev/null 2>&1; then
            echo "📊 HAS September 2025 data (V3 Assertion schema)"
        else
            # Try V2 (OptimisticPriceRequest) query
            TEST_DATA=$(curl -s -X POST \
                -H "Content-Type: application/json" \
                --data '{"query":"{ optimisticPriceRequests(first: 1, where: {timestamp_gte: \"1725148800\", timestamp_lt: \"1727827200\"}) { id timestamp } }"}' \
                "$URL" 2>/dev/null)
            
            if echo "$TEST_DATA" | jq -e '.data.optimisticPriceRequests[0]' > /dev/null 2>&1; then
                echo "📊 HAS September 2025 data (V2 OptimisticPriceRequest schema)"
            else
                # Try V1 (PriceRequest) query
                TEST_DATA=$(curl -s -X POST \
                    -H "Content-Type: application/json" \
                    --data '{"query":"{ priceRequests(first: 1, where: {time_gte: \"1725148800\", time_lt: \"1727827200\"}) { id time } }"}' \
                    "$URL" 2>/dev/null)
                
                if echo "$TEST_DATA" | jq -e '.data.priceRequests[0]' > /dev/null 2>&1; then
                    echo "📊 HAS September 2025 data (V1 PriceRequest schema)"
                else
                    echo "❌ NO September 2025 data (or empty subgraph)"
                fi
            fi
        fi
    else
        echo "❌ FAILED - Does not work with our API key"
    fi
    
    echo ""
    echo "---"
    echo ""
    sleep 1
done

echo "=== TESTING COMPLETE ==="
