#!/bin/bash
API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"

check_v2() {
    RESULT=$(curl -s --max-time 10 -X POST \
        -H "Content-Type: application/json" \
        --data '{"query":"{ optimisticPriceRequests(first: 1, orderBy: time, orderDirection: desc) { time } }"}' \
        "https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/$2" 2>&1)
    
    TS=$(echo "$RESULT" | jq -r '.data.optimisticPriceRequests[0].time' 2>/dev/null)
    if [ "$TS" != "null" ] && [ ! -z "$TS" ]; then
        DATE=$(python3 -c "import datetime; print(datetime.datetime.fromtimestamp($TS).strftime('%Y-%m-%d'))")
        echo "$1: $DATE (ts: $TS)"
    else
        echo "$1: NO DATA or ERROR"
    fi
}

check_v3() {
    RESULT=$(curl -s --max-time 10 -X POST \
        -H "Content-Type: application/json" \
        --data '{"query":"{ assertions(first: 1, orderBy: assertionTimestamp, orderDirection: desc) { assertionTimestamp } }"}' \
        "https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/$2" 2>&1)
    
    TS=$(echo "$RESULT" | jq -r '.data.assertions[0].assertionTimestamp' 2>/dev/null)
    if [ "$TS" != "null" ] && [ ! -z "$TS" ]; then
        DATE=$(python3 -c "import datetime; print(datetime.datetime.fromtimestamp($TS).strftime('%Y-%m-%d'))")
        echo "$1: $DATE (ts: $TS)"
    else
        echo "$1: NO DATA or ERROR"
    fi
}

echo "=== NETWORK ACTIVITY CHECK ==="
echo "Latest assertion date per network:"
echo ""
check_v2 "Polygon V2-new" "CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork"
check_v2 "Ethereum V2" "GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m"
check_v2 "Optimism V2" "DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6"
check_v2 "Arbitrum V2" "Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm"
check_v2 "Blast V2" "EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k"
check_v2 "Base V2" "2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D"
check_v3 "Polygon V3" "7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf"
check_v3 "Ethereum V3" "Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
check_v3 "Base V3" "2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C"
