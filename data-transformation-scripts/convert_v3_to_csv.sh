#!/usr/bin/env bash
# Convert UMA V3 JSON (assertions) to CSV
# V3 has different schema than V2
#
# Usage: ./convert_v3_to_csv.sh <network> [time_period]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

NETWORK="${1:-ethereum}"
TIME_PERIOD="${2:-september_2025}"

DATA_DIR="${PROJECT_ROOT}/data-dumps/${NETWORK}"
IN="${DATA_DIR}/uma_${TIME_PERIOD}.json"
OUT="${DATA_DIR}/uma_${TIME_PERIOD}_full.csv"

if [ ! -f "$IN" ]; then
  echo "❌ ERROR: Input file not found: $IN"
  exit 1
fi

echo "Converting V3 JSON to CSV..."
echo "Input:  $IN"
echo "Output: $OUT"

jq -r '
  ([
    "id","identifier","claim","asserter","disputer","bond","currency",
    "expirationTime","settlementResolution"
  ]),
  (.[] | [
    .id,
    (.identifier // ""),
    (.claim // ""),
    (.asserter // ""),
    (.disputer // ""),
    (.bond // "0"),
    (.currency // ""),
    (.expirationTime // "0" | tonumber),
    (.settlementResolution // "")
  ]) | @csv
' "$IN" > "$OUT"

ROW_COUNT=$(wc -l < "$OUT" | tr -d ' ')
RECORD_COUNT=$((ROW_COUNT - 1))

echo "✅ Success!"
echo "Records: $RECORD_COUNT"
echo ""

