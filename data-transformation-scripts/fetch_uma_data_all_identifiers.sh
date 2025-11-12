#!/usr/bin/env bash
# Multi-network UMA OOv2 data fetcher - ALL IDENTIFIERS
# Fetches ALL proposals (not just YES_OR_NO_QUERY) and decodes ancillaryData
# 
# Usage: ./fetch_uma_data_all_identifiers.sh <network> [time_period]
# Example: ./fetch_uma_data_all_identifiers.sh ethereum_v2 september_2025
#
# Requires: curl, jq, xxd, iconv
# Environment: THE_GRAPH_API_KEY must be set

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/network-config.json"

# Auto-load .env file if it exists
if [ -f "${PROJECT_ROOT}/.env" ]; then
  set -a
  source "${PROJECT_ROOT}/.env"
  set +a
  echo "✓ Loaded API key from .env"
fi

# Check for API key
if [ -z "${THE_GRAPH_API_KEY:-}" ]; then
  echo "❌ ERROR: THE_GRAPH_API_KEY not found"
  echo ""
  echo "Option 1: Create .env file in project root:"
  echo "  THE_GRAPH_API_KEY=your_api_key_here"
  echo ""
  echo "Option 2: Export as environment variable:"
  echo "  export THE_GRAPH_API_KEY='your_api_key_here'"
  echo ""
  echo "Get your API key from: https://thegraph.com/studio/"
  exit 1
fi

# Parse arguments
NETWORK="${1:-ethereum_v2}"
TIME_PERIOD="${2:-september_2025}"

echo "==================================================================="
echo "  UMA Optimistic Oracle v2 Data Fetcher (ALL IDENTIFIERS)"
echo "==================================================================="
echo "Network: $NETWORK"
echo "Period:  $TIME_PERIOD"
echo ""

# Load network configuration
if ! command -v jq &> /dev/null; then
  echo "❌ ERROR: 'jq' not found. Please install jq."
  exit 1
fi

SUBGRAPH_ID=$(jq -r ".networks.${NETWORK}.subgraph_id // empty" "$CONFIG_FILE")
NETWORK_NAME=$(jq -r ".networks.${NETWORK}.name // empty" "$CONFIG_FILE")
ORACLE_VERSION=$(jq -r ".networks.${NETWORK}.oracle_version // empty" "$CONFIG_FILE")
FROM=$(jq -r ".time_periods.${TIME_PERIOD}.from // empty" "$CONFIG_FILE")
TO=$(jq -r ".time_periods.${TIME_PERIOD}.to // empty" "$CONFIG_FILE")
PERIOD_DESC=$(jq -r ".time_periods.${TIME_PERIOD}.description // empty" "$CONFIG_FILE")

# Validate configuration
if [ -z "$SUBGRAPH_ID" ] || [ "$SUBGRAPH_ID" = "null" ]; then
  echo "❌ ERROR: Network '$NETWORK' not found in network-config.json"
  echo ""
  echo "Available networks:"
  jq -r '.networks | keys[]' "$CONFIG_FILE" | sed 's/^/  - /'
  exit 1
fi

if [[ "$SUBGRAPH_ID" == REPLACE_WITH_* ]]; then
  echo "❌ ERROR: Subgraph ID for $NETWORK not configured"
  echo "Please update network-config.json with the correct subgraph ID"
  exit 1
fi

if [ "$ORACLE_VERSION" != "v2" ]; then
  echo "❌ ERROR: This script is for V2 oracles only"
  echo "Network $NETWORK is configured as $ORACLE_VERSION"
  exit 1
fi

if [ -z "$FROM" ] || [ -z "$TO" ]; then
  echo "❌ ERROR: Time period '$TIME_PERIOD' not found in network-config.json"
  exit 1
fi

# Setup paths
DATA_DIR="${PROJECT_ROOT}/data-dumps/${NETWORK}"
mkdir -p "$DATA_DIR"

OUT="${DATA_DIR}/uma_${TIME_PERIOD}.json"
ENDPOINT="https://gateway.thegraph.com/api/${THE_GRAPH_API_KEY}/subgraphs/id/${SUBGRAPH_ID}"
PAGE_SIZE=200

echo "Network Name:   $NETWORK_NAME"
echo "Time Range:     $PERIOD_DESC"
echo "From Timestamp: $FROM"
echo "To Timestamp:   $TO"
echo "Output:         $OUT"
echo "Endpoint:       ${ENDPOINT:0:60}..."
echo ""
echo "⚠️  FETCHING ALL IDENTIFIERS (not just YES_OR_NO_QUERY)"
echo ""
echo "Starting fetch..."
echo "==================================================================="

# Check dependencies
for bin in curl jq xxd iconv; do
  command -v "$bin" >/dev/null 2>&1 || { echo "❌ ERROR: '$bin' not found"; exit 1; }
done

# Initialize JSON output
: > "$OUT"
printf "[" > "$OUT"
FIRST=1

time_lte="$TO"
page=0
total_fetched=0

# GraphQL query builder - NO identifier filter
build_body() {
  local from_ts="$1"
  local to_ts="$2"
  local page_sz="$3"

  local graph_query
  read -r -d '' graph_query <<GQL
{
  optimisticPriceRequests(
    first: ${page_sz},
    orderBy: time,
    orderDirection: desc,
    where: {
      time_gte: ${from_ts},
      time_lte: ${to_ts}
    }
  ) {
    id
    time
    state
    requester
    proposer
    disputer
    settlementRecipient
    currency
    bond
    reward
    finalFee
    proposedPrice
    settlementPrice
    ancillaryData
    identifier
  }
}
GQL

  jq -n --arg q "$graph_query" '{query:$q}'
}

# Fetch loop
while :; do
  page=$((page+1))
  echo "📄 Fetching page $page (time_lte=${time_lte})..."

  BODY=$(build_body "$FROM" "$time_lte" "$PAGE_SIZE")
  RESP="${DATA_DIR}/__page.json"

  HTTP=$(curl -sS -X POST -H "Content-Type: application/json" \
         --data "$BODY" "$ENDPOINT" \
         --write-out "%{http_code}" --output "$RESP")

  if [ "$HTTP" != "200" ]; then
    echo "❌ HTTP $HTTP on page $page"
    head -c 400 "$RESP" || true; echo
    rm -f "$RESP"
    exit 1
  fi
  
  if ! jq -e . "$RESP" >/dev/null 2>&1; then
    echo "❌ Non-JSON response on page $page"
    head -c 400 "$RESP" || true; echo
    rm -f "$RESP"
    exit 1
  fi
  
  if jq -e 'has("errors") and .errors!=null' "$RESP" >/dev/null; then
    echo "❌ GraphQL errors:"
    jq '.errors' "$RESP"
    rm -f "$RESP"
    exit 1
  fi

  COUNT=$(jq '.data.optimisticPriceRequests | length' "$RESP")
  echo "   ✓ Received $COUNT items"
  
  if [ "$COUNT" -eq 0 ]; then
    echo "   No more results. Stopping."
    rm -f "$RESP"
    break
  fi

  total_fetched=$((total_fetched + COUNT))

  # Decode ancillaryData AND identifier from hex to UTF-8 and append to output
  while IFS= read -r line; do
    # Decode ancillaryData
    HEX=$(jq -r '(.ancillaryData // "")' <<<"$line")
    if [[ "$HEX" =~ ^0x[0-9A-Fa-f]+$ ]]; then
      TEXT=$(printf '%s' "$HEX" \
        | sed 's/^0x//' \
        | xxd -r -p 2>/dev/null \
        | tr -d '\000' \
        | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || true)
    else
      TEXT="$HEX"
    fi

    # Decode identifier
    IDENT_HEX=$(jq -r '(.identifier // "")' <<<"$line")
    if [[ "$IDENT_HEX" =~ ^0x[0-9A-Fa-f]+$ ]]; then
      IDENT_TEXT=$(printf '%s' "$IDENT_HEX" \
        | sed 's/^0x//' \
        | xxd -r -p 2>/dev/null \
        | tr -d '\000' \
        | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || true)
    else
      IDENT_TEXT="$IDENT_HEX"
    fi

    updated=$(jq -c --arg t "$TEXT" --arg i "$IDENT_TEXT" '.ancillaryData = $t | .identifierDecoded = $i' <<<"$line")

    if [ $FIRST -eq 1 ]; then
      printf "%s" "$updated" >> "$OUT"
      FIRST=0
    else
      printf ",%s" "$updated" >> "$OUT"
    fi
  done < <(jq -c '.data.optimisticPriceRequests[]' "$RESP")

  NEW_MIN=$(jq -r '.data.optimisticPriceRequests | map(.time|tonumber) | min' "$RESP")
  rm -f "$RESP"

  if [ -z "$NEW_MIN" ] || [ "$NEW_MIN" -le "$FROM" ]; then
    echo "   Reached beginning of time window."
    break
  fi
  
  time_lte=$(( NEW_MIN - 1 ))
  sleep 0.2
done

printf "]" >> "$OUT"

echo ""
echo "==================================================================="
echo "✅ Success!"
echo "==================================================================="
echo "Total records:  $total_fetched"
echo "Saved to:       $OUT"
echo "Network:        $NETWORK_NAME"
echo "Period:         $PERIOD_DESC"
echo ""

# Verify JSON
RECORD_COUNT=$(jq 'length' "$OUT")
echo "Verified: $RECORD_COUNT records in JSON file"
echo ""

# Show identifier breakdown
echo "Identifier breakdown (top 10):"
jq -r '.[].identifierDecoded // .[].identifier' "$OUT" \
  | sort | uniq -c | sort -rn | head -10 | sed 's/^/  /'
echo ""

echo "Next steps:"
echo "  1. Convert to CSV:"
echo "     cd ${PROJECT_ROOT}/data-transformation-scripts"
echo "     ./convert_json_to_csv.sh $NETWORK $TIME_PERIOD"
echo "  2. Search for DEXTFUSD:"
echo "     grep -i DEXTF $OUT"
echo ""



