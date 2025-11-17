# Discovered Subgraph IDs from Oracle UI Network Requests

**Date:** November 12, 2025  
**Source:** Browser network inspection of oracle.uma.xyz

---

## ✅ CONFIRMED WORKING - Public Endpoints

### 1. Base V2 Oracle
```
Endpoint: https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest
Entity: OptimisticPriceRequest
Status: ✅ TESTED AND WORKING
API Key Required: NO (public endpoint)
```

### 2. Polygon V2 Oracle (Goldsky - Public)
```
Endpoint 1: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/polygon-optimistic-oracle-v2/latest/gn
Endpoint 2: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/polygon-managed-optimistic-oracle-v2/1.0.2/gn
Entity: OptimisticPriceRequest
Status: ✅ CONFIRMED (Goldsky public API)
API Key Required: NO (public endpoint)
Note: These are the SAME subgraphs we're already using, just different endpoints!
```

---

## 🔍 NEEDS INVESTIGATION - Gateway IDs

The Oracle UI uses `gateway-arbitrum.network.thegraph.com` with their own API key.  
The following subgraph IDs were found but require The Graph's decentralized network API:

**Found IDs (47 total unique):**
- `Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm`
- `EW4zXq9Ky3uSvcrGk2BYNMTmunfDqz8GTSNcbeDEKT9U`
- `7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf`
- `56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw`
- `FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn`
- `GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m`
- `2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C` (Base V3 - already have)
- `GLwHWuAfpa8C9chPZPH1GmK7zbnh8fCHzTk4YUYiM8mq`
- `8UmLeHVL3LDrvCrjhehVaj4oHEUVhTqeY2pdwS3RdSPV`
- `C2cBAgmb47t9Q4nx32k6Jgqn3A8f4rxy87MPc9xm3t5Y`
- `E5E5muqrrzhp8PhYwSLTGFx7xKrCqtNzqwMPiYGn1CkF`
- `GjAL9TDfnD2B5QYoJ4Q625zR53wYorV8yQyQfhQv4hJQ`
- `9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW`
- `Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof` (Ethereum V3 - already have)
- `2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D`
- `FD6iN9CmhYdBsigQCn4xHE4wqbZkXvUFFSbnjKE3M9yz`
- `DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6`
- `Cee6h62RefVtS9fxCi6B4ghYv9uQvXVg3s6AGpANjL4f`
- `2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um`
- `EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k`
- ... (27 more)

**Issue:** These IDs don't work with user's API key via `gateway.thegraph.com`  
**Reason:** Oracle UI uses different API key and gateway endpoint

---

## 🌐 OTHER NETWORKS FOUND

### Core DAO
```
Endpoint: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle
Endpoint: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v2
Endpoint: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v3
Status: ✅ Public endpoints (no API key)
Note: Core DAO is a separate blockchain we didn't know about
```

### Story Network
```
Endpoint: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle/0.0.1/gn
Endpoint: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v2/0.0.1/gn
Endpoint: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v3/0.0.1/gn
Status: ✅ Public endpoints (Goldsky)
Note: Story is a new blockchain for IP/content
```

---

## ❌ STILL MISSING

Based on your screenshots, we still need to find:

1. **Ethereum V1 Oracle** (DEXTFUSD)
2. **Ethereum V2 Oracle** (Cozy Finance, Across)
3. **Optimism V2 Oracle** (Cozy Finance, sports)
4. **Arbitrum V2 Oracle** (Cozy Finance, various)
5. **Blast V2 Oracle** (Predict.Fun)

---

## 📝 Next Steps

### Option A: Use The Graph Explorer (Manual Search)
1. Visit https://thegraph.com/explorer
2. Search for "UMA Optimistic Oracle" for each network
3. Filter by network (Optimism, Arbitrum, Blast, Ethereum)
4. Find published subgraph IDs

### Option B: Check UMA's GitHub
1. Visit https://github.com/UMAprotocol/subgraphs
2. Look for `subgraph.yaml` or deployment configs
3. Find deployed subgraph IDs per network

### Option C: Contact UMA
- Ask in UMA Discord for official subgraph list
- Check UMA documentation for complete endpoint list

---

## 🎯 Summary

**Found:**
- ✅ Base V2: Public Studio API endpoint
- ✅ Polygon V2: Goldsky public endpoints (same data, different API)
- ✅ Core DAO V1/V2/V3: Public endpoints
- ✅ Story Network V1/V2/V3: Goldsky public endpoints

**Still Need:**
- ❌ Ethereum V1 & V2
- ❌ Optimism V2
- ❌ Arbitrum V2
- ❌ Blast V2

**Recommendation:**  
Use The Graph Explorer manual search as most reliable method to find remaining subgraph IDs.

