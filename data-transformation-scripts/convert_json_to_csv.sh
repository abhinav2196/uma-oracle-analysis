#!/usr/bin/env bash
# Convert UMA JSON data to CSV format
#
# Usage: ./convert_json_to_csv.sh <network> [time_period]
# Example: ./convert_json_to_csv.sh polygon september_2025

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
NETWORK="${1:-polygon}"
TIME_PERIOD="${2:-september_2025}"

DATA_DIR="${PROJECT_ROOT}/data-dumps/${NETWORK}"
IN="${DATA_DIR}/uma_${TIME_PERIOD}.json"
OUT="${DATA_DIR}/uma_${TIME_PERIOD}_full.csv"

if [ ! -f "$IN" ]; then
  echo "❌ ERROR: Input file not found: $IN"
  echo ""
  echo "Run fetch_uma_data.sh first:"
  echo "  ./fetch_uma_data.sh $NETWORK $TIME_PERIOD"
  exit 1
fi

echo "Converting JSON to CSV..."
echo "Input:  $IN"
echo "Output: $OUT"

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

ROW_COUNT=$(wc -l < "$OUT" | tr -d ' ')
RECORD_COUNT=$((ROW_COUNT - 1))  # Subtract header row

echo "✅ Success!"
echo "Wrote $OUT"
echo "Records: $RECORD_COUNT"
echo ""
echo "Next step:"
echo "  Filter for crypto predictions:"
echo "  cd $PROJECT_ROOT"
echo "  python3 data-transformation-scripts/filter_and_export.py $NETWORK"
echo ""

