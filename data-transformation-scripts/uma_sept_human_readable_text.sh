#!/usr/bin/env bash
# Fetch UMA OOv2 requests for Sep 2025 and store ancillaryData as human-readable text (decoded).
# Ready to run: no env vars needed. Uses your provided API key.
# Requires: curl, jq, xxd, iconv

set -euo pipefail

# -------- Fixed configuration (edit if you must) --------
API_KEY="58ca9224aaa0bb477c81bcef15a89b1c"
SUBGRAPH_ID="BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK"
ENDPOINT="https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/${SUBGRAPH_ID}"

FROM=1756684800     # 2025-09-01 00:00:00 UTC
TO=1759276799       # 2025-09-30 23:59:59 UTC
PAGE_SIZE=200
OUT="uma_sep_all_text.json"
# --------------------------------------------------------

for bin in curl jq xxd iconv; do
  command -v "$bin" >/dev/null 2>&1 || { echo "ERROR: '$bin' not found"; exit 1; }
done

echo "Using endpoint: $ENDPOINT"
echo "Time window   : $FROM .. $TO (UTC seconds)"
echo "Page size     : $PAGE_SIZE"
echo "Output file   : $OUT"
echo "Starting…"

# Start a fresh JSON array
: > "$OUT"
printf "[" > "$OUT"
FIRST=1

time_lte="$TO"
page=0

build_body() {
  local from_ts="$1"
  local to_ts="$2"
  local page_sz="$3"

  # Build a plain GraphQL string (no shell escapes needed), then wrap in JSON via jq
  local graph_query
  read -r -d '' graph_query <<GQL
{
  optimisticPriceRequests(
    first: ${page_sz},
    orderBy: time,
    orderDirection: desc,
    where: {
      time_gte: ${from_ts},
      time_lte: ${to_ts},
      identifier_contains_nocase: "YES_OR_NO_QUERY"
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
  }
}
GQL

  jq -n --arg q "$graph_query" '{query:$q}'
}

while :; do
  page=$((page+1))
  echo "── Fetching page $page (time_lte=${time_lte}) [identifier filter: YES_OR_NO_QUERY]"

  BODY=$(build_body "$FROM" "$time_lte" "$PAGE_SIZE")
  RESP="__page.json"

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
  echo "   → Page $page returned $COUNT items"
  if [ "$COUNT" -eq 0 ]; then
    echo "   No more results in window. Stopping."
    rm -f "$RESP"
    break
  fi

  # Stream each item, decode ancillaryData hex → UTF-8 text, and replace the field
  while IFS= read -r line; do
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

    updated=$(jq -c --arg t "$TEXT" '.ancillaryData = $t' <<<"$line")

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
    echo "Reached beginning of window."
    break
  fi
  time_lte=$(( NEW_MIN - 1 ))

  sleep 0.2
done

printf "]" >> "$OUT"
echo "✅ Done. $(jq 'length' "$OUT") records saved to $OUT"

