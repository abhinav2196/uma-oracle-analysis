# Subgraph ID Discovery - Complete Status Update

**Date:** November 12, 2025  
**Investigation Method:** Browser automation + Network inspection  
**Status:** Partially Complete

---

## Summary

Successfully identified Base V2 oracle subgraph with a **public endpoint** (no API key required). However, discovered that The Graph's ecosystem has changed - most subgraphs now use gateway-arbitrum.network.thegraph.com with different API keys.

---

## ✅ FOUND - Working Solutions

### Base V2 Oracle (CONFIRMED WORKING)
```
Public Endpoint: https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest
Subgraph Name: base-optimistic-oracle
Entity: OptimisticPriceRequest
API Key: NOT REQUIRED
Status: ✅ TESTED - Returns data successfully
```

**Test Query:**
```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { types { name } } }"}' \
  "https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest" \
  | jq -r '.data.__schema.types[].name' | grep OptimisticPriceRequest
```

### ✅ BONUS DISCOVERIES - Public Endpoints (No API Key)

#### Polygon V2 - Goldsky Public API
```
Endpoint: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/polygon-optimistic-oracle-v2/latest/gn
Status: ✅ Public endpoint
Note: Alternative to existing gateway.thegraph.com endpoint
```

#### Core DAO Network
```
V1: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle
V2: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v2  
V3: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v3
Status: ✅ Public endpoints
```

#### Story Network - Goldsky Public API
```
V1: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle/0.0.1/gn
V2: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v2/0.0.1/gn
V3: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v3/0.0.1/gn
Status: ✅ Public endpoints
```

---

## ❌ CHALLENGE - Not Found with Our API Key

The Oracle UI (oracle.uma.xyz) uses **gateway-arbitrum.network.thegraph.com** with API key `0c76d91772c59c6a2ba8be7da366ee4c`

This means the 47 subgraph IDs captured from network requests don't work with our API key (`5ff06e4966bc3378b2bda95a5f7f98d3`)

**Gateway Difference:**
- Our key works with: `gateway.thegraph.com`  
- Oracle UI uses: `gateway-arbitrum.network.thegraph.com`

---

## 📋 Subgraph IDs Found But Not Accessible

From network inspection, captured these deployment IDs (sample):

**Gateway-Arbitrum.network (Oracle UI's gateway):**
- Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm
- EW4zXq9Ky3uSvcrGk2BYNMTmunfDqz8GTSNcbeDEKT9U
- 7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf
- 56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw
- FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn
- 9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW
- (and 41 more...)

These IDs require a different gateway system that our API key doesn't support.

---

## 🎯 REMAINING NETWORKS TO FIND

Using The Graph Explorer manual search:

1. **Ethereum V1 Oracle** (for DEXTFUSD price identifiers)
2. **Ethereum V2 Oracle** (for Cozy Finance, Across Protocol)
3. **Optimism V2 Oracle** (for sports predictions, Cozy Finance)
4. **Arbitrum V2 Oracle** (for Cozy Finance queries)
5. **Blast V2 Oracle** (for Predict.Fun)

---

## 📝 NEXT STEPS

### Option A: Manual Graph Explorer Search (Recommended)
1. Visit https://thegraph.com/explorer
2. Search "UMA Optimistic Oracle" for each network
3. Filter by network (Ethereum, Optimism, Arbitrum, Blast)
4. Look for subgraphs published by UMA Protocol
5. Copy deployment IDs from the subgraph details page

**Estimated Time:** 15-30 minutes  
**Success Rate:** High - Most reliable method

### Option B: Check UMA GitHub Repository
1. Visit https://github.com/UMAprotocol/subgraphs
2. Look for deployment configs or README
3. Find deployed subgraph IDs per network

**Estimated Time:** 10-20 minutes  
**Success Rate:** Medium to High

### Option C: Contact UMA Community
- Discord: http://discord.uma.xyz
- Ask for complete list of subgraph endpoints

**Estimated Time:** Depends on response time

---

## 🔄 WHAT WORKS NOW

### Immediate Available Data Sources

**Base V2 Oracle:**
```bash
# Already tested and working
https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest
```

**Core DAO (All three oracle versions):**
```bash
# Public endpoints - no API key needed
https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v2
```

**Story Network (All three oracle versions):**
```bash
# Goldsky public endpoints - no API key needed
https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v2/0.0.1/gn
```

---

## 💡 KEY INSIGHT

The Graph's infrastructure has evolved:
- **Studio (api.studio.thegraph.com)**: Public endpoints, no API key
- **Gateway (gateway.thegraph.com)**: Requires API key
- **Arbitrum Gateway (gateway-arbitrum.network.thegraph.com)**: Different API key system

This explains why our API key doesn't work with the IDs captured from oracle.uma.xyz's network requests.

---

## ✅ RECOMMENDED ACTION

**UPDATE CONFIGURATION NOW with what we have:**

Add to `network-config.json`:
- Base V2 (confirmed working)
- Core DAO oracles (public endpoints)
- Story Network oracles (public endpoints)

**FOR REMAINING NETWORKS:**

The most reliable method is manual search on The Graph Explorer:
1. Go to https://thegraph.com/explorer
2. Search for each network's UMA subgraph
3. Copy the deployment ID from each subgraph's detail page

This should take approximately 15-30 minutes of manual work to find all remaining IDs.

---

## 📊 STATUS SUMMARY

| Network | Oracle | Status |
|---------|--------|--------|
| **Base** | V2 | ✅ FOUND & TESTED |
| **Core DAO** | V1, V2, V3 | ✅ FOUND (Public) |
| **Story** | V1, V2, V3 | ✅ FOUND (Public) |
| **Ethereum** | V1 | ❌ Manual search needed |
| **Ethereum** | V2 | ❌ Manual search needed |
| **Optimism** | V2 | ❌ Manual search needed |
| **Arbitrum** | V2 | ❌ Manual search needed |
| **Blast** | V2 | ❌ Manual search needed |

---

**Next Recommended Action:** Use The Graph Explorer to manually search and copy the remaining 5 subgraph IDs.

