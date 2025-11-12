# UMA Subgraph Quick Reference

**Last Validated:** November 12, 2025

---

## TL;DR

**Your 3 Questions Answered:**

1. **Oracle Types:** V1 (legacy), V2 (`OptimisticPriceRequest`), V3 (`Assertion`)
2. **Architecture:** Each network has **separate subgraphs per oracle version**
3. **Official Source:** [UMA GitHub](https://github.com/UMAprotocol/subgraphs) + [The Graph Explorer](https://thegraph.com/explorer)

**Status:** ✅ Your current scripts are correct. One invalid Ethereum V1/V2 ID needs fixing.

---

## Working Subgraphs

| Network | Oracle | Subgraph ID (first 5 chars) | Entity Type | Status |
|---------|--------|------------------------------|-------------|--------|
| Polygon | V2 | CFjwx... | `OptimisticPriceRequest` | ✅ Active |
| Polygon | V2 (old) | BpK8A... | `OptimisticPriceRequest` | ✅ Active (different filter) |
| Ethereum | V3 | Bm3yt... | `Assertion` | ✅ Active |
| Base | V3 | 2Q4i8... | `Assertion` | ✅ Active |

## Invalid Subgraphs

| Network | Oracle | Subgraph ID | Error |
|---------|--------|-------------|-------|
| Ethereum | V1/V2 | 41LCr... | ❌ "subgraph not found" |

---

## Entity Type Cheat Sheet

### V2: OptimisticPriceRequest

```graphql
{
  optimisticPriceRequests(first: 10) {
    id
    identifier          # e.g., "YES_OR_NO_QUERY"
    ancillaryData       # hex-encoded question
    time
    state               # Requested, Proposed, Settled, etc.
    bond
    reward
    proposer
    disputer
    settlementPrice
  }
}
```

**Use For:**
- Polymarket predictions
- Price assertions
- Market questions

### V3: Assertion

```graphql
{
  assertions(first: 10) {
    id
    assertionId
    domainId            # replaces "identifier"
    claim               # replaces "ancillaryData"
    asserter            # replaces "proposer"
    bond
    disputer
    settlementResolution
  }
}
```

**Use For:**
- Governance proposals
- Generalized assertions
- oSnap integrations

---

## LSP vs EMP vs Oracle Subgraphs

| Subgraph Type | Entities | Purpose | Your Project Uses This? |
|---------------|----------|---------|-------------------------|
| **Optimistic Oracle** | `OptimisticPriceRequest`, `Assertion` | Price feeds, assertions | ✅ YES |
| **LSP (Long Short Pair)** | `FinancialContract`, `Position` | Synthetic tokens | ❌ NO |
| **EMP (Expiring Multiparty)** | `FinancialContract`, `Liquidation` | Synthetic tokens | ❌ NO |

**Key Insight:** Oracle subgraphs are **separate** from LSP/EMP subgraphs.

---

## Quick Test Commands

### Test Polygon V2
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 1) { id identifier time } }"}' \
  "https://gateway.thegraph.com/api/YOUR_KEY/subgraphs/id/CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork"
```

### Test Ethereum V3
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ assertions(first: 1) { id assertionId claim } }"}' \
  "https://gateway.thegraph.com/api/YOUR_KEY/subgraphs/id/Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof"
```

### Discover Schema
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { types { name kind } } }"}' \
  "https://gateway.thegraph.com/api/YOUR_KEY/subgraphs/id/SUBGRAPH_ID" \
  | jq -r '.data.__schema.types[] | select(.kind == "OBJECT") | .name'
```

---

## Script Validation Results

| Script | Entity Queried | Networks | Status |
|--------|----------------|----------|--------|
| `fetch_uma_data.sh` | `optimisticPriceRequests` | Polygon V2 | ✅ Correct |
| `fetch_uma_v3_data.sh` | `assertions` | Ethereum/Base V3 | ✅ Correct |
| `fetch_uma_data_all_identifiers.sh` | `optimisticPriceRequests` (no filter) | Any V2 | ✅ Correct |

**Conclusion:** No script changes needed!

---

## Common Gotchas

### 1. V2 vs V3 Field Names Changed

| V2 Field | V3 Equivalent |
|----------|---------------|
| `identifier` | `domainId` |
| `ancillaryData` | `claim` |
| `proposer` | `asserter` |
| `reward` | (removed) |

### 2. Multiple Subgraphs, Same Contract

Polygon has two V2 subgraphs indexing the **same contract**:
- **CFjwx...** → Tracks requester `0x6507...`
- **BpK8A...** → Tracks requester `0x2f5e...`

Use **both** for complete Polygon data.

### 3. Oracle ≠ Financial Contracts

Don't confuse:
- **Oracle subgraphs** → Price requests, assertions
- **LSP/EMP subgraphs** → Synthetic token contracts

They're separate!

---

## Action Items

### ❌ Needs Fixing
1. Remove or replace invalid Ethereum V1/V2 subgraph ID (`41LCr...`)
2. Find correct Ethereum V2 subgraph for DEXTFUSD price identifiers

### 🔍 Needs Research
1. Check if Arbitrum, Optimism, Avalanche have UMA oracle deployments
2. Verify if separate V1 and V2 Ethereum subgraphs exist (not combined)

### ✅ Already Good
1. All fetch scripts correctly target Oracle subgraphs
2. Polygon V2, Ethereum V3, Base V3 all validated and working
3. Schema introspection confirmed entity types

---

## Official Resources

1. **UMA Docs:** https://docs.uma.xyz/resources/subgraph-data  
   Sample queries, entity schemas

2. **UMA GitHub:** https://github.com/UMAprotocol/subgraphs  
   Deployment configs, source code (most authoritative)

3. **The Graph Explorer:** https://thegraph.com/explorer  
   Live status, sync progress, query playground

4. **GraphQL Playground:** https://thegraph.com/hosted-service/subgraph/...  
   Interactive query testing

---

## Summary: Are We Using the Right Subgraphs?

**YES!** ✅

Your current setup correctly:
- Targets Optimistic Oracle subgraphs (not LSP/EMP)
- Uses correct entity types (OptimisticPriceRequest for V2, Assertion for V3)
- Queries appropriate fields for crypto price predictions
- Covers the main networks (Polygon, Ethereum, Base)

**Only issue:** Invalid Ethereum V1/V2 subgraph ID (not critical, as you're not actively using it yet).

