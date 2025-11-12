# Oracle Versions and Subgraph Information Needed

## Current Status

We are missing complete oracle coverage. Currently only fetching partial data.

## What We Need

### For Each Network:

Please provide the subgraph IDs and confirm which oracle versions exist:

---

### 1. **Ethereum Mainnet**

Known info:
- ✅ General subgraph ID: `41LCrgtCNBQyDiVVyZEuPxbvkBH9BxxLU3nEZst77V8o` ([docs](https://docs.uma.xyz/resources/subgraph-data))
- ✅ V3 subgraph ID: `Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof` (already configured)

Need to confirm:
- [ ] Does the general subgraph include V1 data? (for DEXTFUSD - 750 days old)
- [ ] Does it include V2 data?
- [ ] What GraphQL entities are available? (`priceRequests` for V1? `optimisticPriceRequests` for V2?)

Contracts:
- V1: `0xeE3Afe347D5C74317041E2618C49534dAf887c24`
- V2: `0xA0Ae6609447e57a42c51B50EAe921D701823FFAe`
- V3: `0xfb55F43fB9F48F63f9269DB7Dde3BbBe1ebDC0dE`

---

### 2. **Polygon**

Current config:
- ✅ V2 subgraph ID: `CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork`

Need:
- [ ] V3 subgraph ID (if exists)
- [ ] V1 subgraph ID (if exists)

Activity: 21,544 entries

---

### 3. **Base**

Current config:
- ✅ V3 subgraph ID: `2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C`

Need:
- [ ] Confirm: Only V3 exists on Base?
- [ ] V2/V1 subgraph IDs (if they exist)

Activity: 259 entries

---

### 4. **Optimism**

Current: Not configured

Need:
- [ ] V3 subgraph ID
- [ ] V2 subgraph ID (if exists)
- [ ] V1 subgraph ID (if exists)
- [ ] Oracle contract addresses

Activity: 202 entries

---

### 5. **Blast**

Current: Not configured

Need:
- [ ] V3 subgraph ID
- [ ] V2 subgraph ID (if exists)
- [ ] Oracle contract addresses

Activity: 2 entries

---

### 6. **Arbitrum**

Current: Not configured

Need:
- [ ] V3 subgraph ID
- [ ] V2 subgraph ID (if exists)
- [ ] V1 subgraph ID (if exists)
- [ ] Oracle contract addresses

Activity: 3 entries

---

## Schema Information Needed

For each oracle version, what are the GraphQL entity names?

### Optimistic Oracle V1
- Entity name: `priceRequests`? `requests`?
- Fields: ?
- Example query: ?

### Optimistic Oracle V2
- ✅ Entity name: `optimisticPriceRequests`
- ✅ Fields: id, time, state, requester, proposer, disputer, currency, bond, reward, finalFee, proposedPrice, settlementPrice, ancillaryData, identifier
- ✅ Example query: Working

### Optimistic Oracle V3
- ✅ Entity name: `assertions`
- ✅ Fields: id, identifier, claim, asserter, disputer, bond, currency, expirationTime, settlementResolution
- ✅ Example query: Working

---

## Resources

**Official Docs:**
- https://docs.uma.xyz/resources/subgraph-data

**The Graph Explorer:**
- https://thegraph.com/explorer
- Search for "UMA" to find all published subgraphs

**UMA GitHub:**
- Subgraph source code: https://github.com/UMAprotocol/subgraphs

**Contract Addresses:**
- Check docs.uma.xyz/resources/network-information for all networks

---

## Why This Matters

1. **DEXTFUSD** is on Ethereum Optimistic Oracle **V1** (not V2 or V3)
2. Current scripts only fetch **YES_OR_NO_QUERY** identifiers (market predictions)
3. Price identifiers like **DEXTFUSD, ETHUSD, BTCUSD** are being filtered out
4. We're missing **~750 days of V1 data** on Ethereum

Once we have all subgraph IDs, we can:
- Fetch complete historical data from all oracle versions
- Include price identifiers (not just market predictions)
- Provide comprehensive cross-chain analysis



