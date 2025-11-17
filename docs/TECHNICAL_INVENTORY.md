# UMA Oracle Subgraph Technical Inventory

**API Key:** `5ff06e4966bc3378b2bda95a5f7f98d3`  
**Gateway:** `https://gateway.thegraph.com/api/{API_KEY}/subgraphs/id/{ID}`  
**Date:** November 12, 2025

---

## ACTIVE SUBGRAPHS (2025)

### Polygon
```json
{
  "network": "Polygon",
  "version": "V2",
  "id": "CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork",
  "entity": "OptimisticPriceRequest",
  "time_field": "time",
  "latest_activity": "2025-11-12",
  "september_2025": 15566
}
```

### Ethereum
```json
{
  "network": "Ethereum",
  "version": "V3",
  "id": "Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof",
  "entity": "Assertion",
  "time_field": "assertionTimestamp",
  "latest_activity": "2025-11-11",
  "september_2025": 0
}
```

### Base
```json
{
  "network": "Base",
  "version": "V2",
  "id": "2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D",
  "entity": "OptimisticPriceRequest",
  "time_field": "time",
  "latest_activity": "2025-11-05",
  "september_2025": 0
}
```

```json
{
  "network": "Base",
  "version": "V3",
  "id": "2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C",
  "entity": "Assertion",
  "time_field": "assertionTimestamp",
  "latest_activity": "2025-11-11",
  "september_2025": 0
}
```

### Blast
```json
{
  "network": "Blast",
  "version": "V2",
  "id": "EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k",
  "entity": "OptimisticPriceRequest",
  "time_field": "time",
  "latest_activity": "2025-10-06",
  "september_2025": 0
}
```

---

## HISTORICAL SUBGRAPHS

### Ethereum V2 (Inactive)
- ID: `GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m`
- Last: April 2024

### Arbitrum V2 (Inactive)
- ID: `Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm`
- Last: April 2024

### Polygon V3 (Inactive)
- ID: `7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf`
- Last: March 2024

### Optimism V2 (Older)
- ID: `DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6`
- Last: February 2025

---

## QUERY TEMPLATES

### V2 Oracle (OptimisticPriceRequest)
```graphql
{
  optimisticPriceRequests(
    first: 1000,
    where: { time_gte: "1756930724", time_lt: "1759276343" },
    orderBy: time
  ) {
    id
    time
    identifier
    ancillaryData
    proposer
    disputer
    settled
    proposedPrice
    resolvedPrice
    reward
    bond
    currency
  }
}
```

### V3 Oracle (Assertion)
```graphql
{
  assertions(
    first: 1000,
    where: { assertionTimestamp_gte: "1756930724", assertionTimestamp_lt: "1759276343" },
    orderBy: assertionTimestamp
  ) {
    id
    assertionId
    assertionTimestamp
    claim
    asserter
    bond
    currency
    domainId
    identifier
    settled
  }
}
```

---

## DUPLICATES & ISSUES

### Confirmed Duplicates
- Base V2: `2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D` (use this)
- Base V2: `DMWJanhFZn9SiqiLCJz5VEVGEgQbMvi45ggwzPyf5cDW` (duplicate, identical data)

### Schema Mislabeling
Multiple "V1" subgraphs use V2 schema - these appear to be naming inconsistencies, not actual V1 oracle deployments.

---

## TIMESTAMP REFERENCE

**September 2025 (Actual data period):**
- Start: 1756930724 (Sept 3, 2025 22:18:44 UTC)
- End: 1759276343 (Oct 1, 2025 01:52:23 UTC)

**September 2024 (Wrong period initially used):**
- Start: 1725148800 (Sept 1, 2024 00:00:00 UTC)
- End: 1727827200 (Oct 1, 2024 00:00:00 UTC)


