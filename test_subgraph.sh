#!/bin/bash

# Test a single subgraph
NAME="$1"
ID="$2"
API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
URL="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/${ID}"

echo "=== Testing: $NAME ==="
echo "ID: $ID"

# Get schema
SCHEMA=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    --data '{"query":"{ __schema { types { name kind } } }"}' \
    "$URL" | jq -r '.data.__schema.types[]? | select(.kind == "OBJECT" and (.name | startswith("_") | not)) | .name' 2>/dev/null | grep -Ev "Query|Subscription" | head -5)

if [ ! -z "$SCHEMA" ]; then
    echo "✅ WORKS with our API key"
    echo "Entity types: $SCHEMA"
    
    # Check September 2025 data based on schema
    if echo "$SCHEMA" | grep -q "Assertion"; then
        echo "Schema: V3 (Assertion)"
    elif echo "$SCHEMA" | grep -q "OptimisticPriceRequest"; then
        echo "Schema: V2 (OptimisticPriceRequest)"
    elif echo "$SCHEMA" | grep -q "PriceRequest"; then
        echo "Schema: V1 (PriceRequest)"
    fi
else
    echo "❌ FAILED - Does not work with our API key"
fi

echo "---"
