#!/usr/bin/env bash
set -euo pipefail

# Get script directory and set paths relative to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IN="${1:-${PROJECT_ROOT}/data-dumps/uma_sep_all_text.json}"
OUT="${2:-${PROJECT_ROOT}/data-dumps/uma_sep_all_text_full.csv}"

jq -r '
  ([
    "id","time","state","requester","proposer","disputer",
    "settlementRecipient","currency","bond","reward","finalFee",
    "proposedPrice","settlementPrice","ancillaryData"
  ]),
  (.[] | [
    .id,
    (.time // "0" | tonumber),
    (.state // ""),
    (.requester // ""),
    (.proposer // ""),
    (.disputer // ""),
    (.settlementRecipient // ""),
    (.currency // ""),
    (.bond // "0" | tonumber),
    (.reward // "0" | tonumber),
    (.finalFee // "0" | tonumber),
    (.proposedPrice // "0" | tonumber),
    (.settlementPrice // "0" | tonumber),
    (.ancillaryData // "" | gsub("\r?\n"; " "))
  ]) | @csv
' "$IN" > "$OUT"

echo "Wrote $OUT"

