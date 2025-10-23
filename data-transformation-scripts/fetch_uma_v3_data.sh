#!/usr/bin/env bash
# UMA Optimistic Oracle V3 data fetcher
# V3 uses "assertions" schema (different from V2's "optimisticPriceRequests")
#
# Usage: ./fetch_uma_v3_data.sh <network> [time_period]
# Example: ./fetch_uma_v3_data.sh ethereum september_2025

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/network-config.json"

# Auto-load .env file
if [ -f "${PROJECT_ROOT}/.env" ]; then
  set -a
  source "${PROJECT_ROOT}/.env"
  set +a
  echo "✓ Loaded API key from .env"
fi

if [ -z "${THE_GRAPH_API_KEY:-}" ]; then
  echo "❌ ERROR: THE_GRAPH_API_KEY not found"
  exit 1
fi

# Parse arguments
NETWORK="${1:-ethereum}"
TIME_PERIOD="${2:-september_2025}"

echo "==================================================================="
echo "  UMA Optimistic Oracle V3 Data Fetcher"
echo "==================================================================="

# Load configuration
SUBGRAPH_ID=$(jq -r ".networks.${NETWORK}.subgraph_id // empty" "$CONFIG_FILE")
NETWORK_NAME=$(jq -r ".networks.${NETWORK}.name // empty" "$CONFIG_FILE")
ORACLE_VERSION=$(jq -r ".networks.${NETWORK}.oracle_version // empty" "$CONFIG_FILE")
FROM=$(jq -r ".time_periods.${TIME_PERIOD}.from // empty" "$CONFIG_FILE")
TO=$(jq -r ".time_periods.${TIME_PERIOD}.to // empty" "$CONFIG_FILE")

if [ "$ORACLE_VERSION" != "v3" ]; then
  echo "❌ ERROR: $NETWORK is configured as $ORACLE_VERSION, not v3"
  echo "Use fetch_uma_data.sh for V2 networks"
  exit 1
fi

if [ -z "$SUBGRAPH_ID" ]; then
  echo "❌ ERROR: Network '$NETWORK' not found"
  exit 1
fi

# Setup
DATA_DIR="${PROJECT_ROOT}/data-dumps/${NETWORK}"
mkdir -p "$DATA_DIR"
OUT="${DATA_DIR}/uma_${TIME_PERIOD}.json"
ENDPOINT="https://gateway.thegraph.com/api/${THE_GRAPH_API_KEY}/subgraphs/id/${SUBGRAPH_ID}"
PAGE_SIZE=200

echo "Network:  $NETWORK_NAME (Oracle V3)"
echo "Output:   $OUT"
echo "Starting fetch..."
echo "==================================================================="

# Initialize
: > "$OUT"
printf "[" > "$OUT"
FIRST=1
page=0
total_fetched=0
last_id=""

# V3 uses different pagination (by ID not timestamp)
while :; do
  page=$((page+1))
  echo "📄 Fetching page $page..."

  # Build query - V3 uses simple ID-based pagination
  if [ -z "$last_id" ]; then
    QUERY='{"query":"{ assertions(first: '$PAGE_SIZE', orderBy: id, orderDirection: asc) { id identifier claim asserter disputer bond currency expirationTime settlementResolution } }"}'
  else
    QUERY='{"query":"{ assertions(first: '$PAGE_SIZE', orderBy: id, orderDirection: asc, where: {id_gt: \"'$last_id'\"}) { id identifier claim asserter disputer bond currency expirationTime settlementResolution } }"}'
  fi

  RESP="${DATA_DIR}/__page.json"
  HTTP=$(curl -sS -X POST -H "Content-Type: application/json" \
         --data "$QUERY" "$ENDPOINT" \
         --write-out "%{http_code}" --output "$RESP")

  if [ "$HTTP" != "200" ]; then
    echo "❌ HTTP $HTTP"
    cat "$RESP"
    rm -f "$RESP"
    exit 1
  fi

  if jq -e 'has("errors")' "$RESP" >/dev/null 2>&1; then
    echo "❌ GraphQL errors:"
    jq '.errors' "$RESP"
    rm -f "$RESP"
    exit 1
  fi

  COUNT=$(jq '.data.assertions | length' "$RESP")
  echo "   ✓ Received $COUNT items"

  if [ "$COUNT" -eq 0 ]; then
    rm -f "$RESP"
    break
  fi

  total_fetched=$((total_fetched + COUNT))

  # Decode claim hex to UTF-8 (like ancillaryData in V2)
  while IFS= read -r line; do
    CLAIM_HEX=$(jq -r '(.claim // "")' <<<"$line")
    if [[ "$CLAIM_HEX" =~ ^0x[0-9A-Fa-f]+$ ]]; then
      CLAIM_TEXT=$(printf '%s' "$CLAIM_HEX" \
        | sed 's/^0x//' \
        | xxd -r -p 2>/dev/null \
        | tr -d '\000' \
        | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || true)
    else
      CLAIM_TEXT="$CLAIM_HEX"
    fi

    updated=$(jq -c --arg t "$CLAIM_TEXT" '.claim = $t' <<<"$line")

    if [ $FIRST -eq 1 ]; then
      printf "%s" "$updated" >> "$OUT"
      FIRST=0
    else
      printf ",%s" "$updated" >> "$OUT"
    fi
  done < <(jq -c '.data.assertions[]' "$RESP")

  last_id=$(jq -r '.data.assertions[-1].id' "$RESP")
  rm -f "$RESP"

  sleep 0.2
done

printf "]" >> "$OUT"

echo ""
echo "==================================================================="
echo "✅ Success!"
echo "==================================================================="
echo "Total records:  $total_fetched"
echo "Saved to:       $OUT"
echo ""

