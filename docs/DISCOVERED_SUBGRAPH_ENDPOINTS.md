# UMA Oracle Subgraph Endpoints - Complete Discovery

**Discovery Method:** Browser Network Analysis of oracle.uma.xyz  
**Date:** November 12, 2025  
**Source:** Network requests captured from https://oracle.uma.xyz

---

## ✅ WORKING PUBLIC ENDPOINTS

### Base (V2 Oracle)
```
Endpoint: https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest
Entity: OptimisticPriceRequest
API Key: NOT REQUIRED (public endpoint)
Status: ✅ CONFIRMED WORKING
```

### Polygon (V2 Oracle - Goldsky Public API)
```
Endpoint 1: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/polygon-optimistic-oracle-v2/latest/gn
Endpoint 2: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/polygon-managed-optimistic-oracle-v2/1.0.2/gn
Entity: OptimisticPriceRequest
API Key: NOT REQUIRED (public endpoint)
Status: ✅ CONFIRMED WORKING
Note: These are public Goldsky endpoints (already in use)
```

### Core DAO (All Versions - Public)
```
V1: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle
V2: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v2
V3: https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v3
Entity: PriceRequest (V1), OptimisticPriceRequest (V2), Assertion (V3)
API Key: NOT REQUIRED (public endpoint)
Status: ✅ CONFIRMED WORKING
```

### Story Network (All Versions - Goldsky Public)
```
V1: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle/0.0.1/gn
V2: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v2/0.0.1/gn
V3: https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v3/0.0.1/gn
Entity: PriceRequest (V1), OptimisticPriceRequest (V2), Assertion (V3)
API Key: NOT REQUIRED (public endpoint)
Status: ✅ CONFIRMED WORKING
```

---

## 🔒 ARBITRUM GATEWAY ENDPOINTS (Require Different API Key)

These endpoints use The Graph's Arbitrum Gateway with API key: `0c76d91772c59c6a2ba8be7da366ee4c`

**Note:** This API key does NOT work with our key (5ff06e4966bc3378b2bda95a5f7f98d3)

### Ethereum (V3)
```
Subgraph ID: Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof
Full URL: https://gateway-arbitrum.network.thegraph.com/api/0c76d91772c59c6a2ba8be7da366ee4c/subgraphs/id/Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof
Entity: Assertion
Status: ❌ Requires oracle's API key
```

### Base (V3)
```
Subgraph ID: 2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C
Full URL: https://gateway-arbitrum.network.thegraph.com/api/0c76d91772c59c6a2ba8be7da366ee4c/subgraphs/id/2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C
Entity: Assertion
Status: ❌ Requires oracle's API key
```

### Optimism (V2)
```
Subgraph ID: 7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf
Full URL: https://gateway-arbitrum.network.thegraph.com/api/0c76d91772c59c6a2ba8be7da366ee4c/subgraphs/id/7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf
Entity: OptimisticPriceRequest
Status: ❌ Requires oracle's API key
```

### Arbitrum (V2)
```
Subgraph ID: FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn
Full URL: https://gateway-arbitrum.network.thegraph.com/api/0c76d91772c59c6a2ba8be7da366ee4c/subgraphs/id/FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn
Entity: OptimisticPriceRequest
Status: ❌ Requires oracle's API key
```

### Blast (V2)
```
Subgraph ID: 9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW
Full URL: https://gateway-arbitrum.network.thegraph.com/api/0c76d91772c59c6a2ba8be7da366ee4c/subgraphs/id/9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW
Entity: OptimisticPriceRequest
Status: ❌ Requires oracle's API key
```

### Additional Identified IDs (Unknown Networks)
```
- EW4zXq9Ky3uSvcrGk2BYNMTmunfDqz8GTSNcbeDEKT9U
- Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm
- GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m
- GLwHWuAfpa8C9chPZPH1GmK7zbnh8fCHzTk4YUYiM8mq
- 56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw
- GjAL9TDfnD2B5QYoJ4Q625zR53wYorV8yQyQfhQv4hJQ
- 2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D
- DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6
- Cee6h62RefVtS9fxCi6B4ghYv9uQvXVg3s6AGpANjL4f
- FD6iN9CmhYdBsigQCn4xHE4wqbZkXvUFFSbnjKE3M9yz
- EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k
- 2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um

All using gateway-arbitrum.network.thegraph.com with oracle's API key
Status: ❌ Cannot be used with our API key
```

---

## 🎯 IMMEDIATELY USABLE ENDPOINTS

### Networks with Public Endpoints (No API Key Needed)

1. **Base V2**
   - https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest
   - ✅ Ready to fetch data

2. **Core DAO (V1, V2, V3)**
   - All three versions available via public endpoints
   - ✅ Ready to fetch data

3. **Story Network (V1, V2, V3)**
   - All three versions available via Goldsky public API
   - ✅ Ready to fetch data

---

## ⚠️ LIMITATIONS

### Arbitrum Gateway Issue
The oracle UI uses The Graph's "Arbitrum Gateway" with their own API key: `0c76d91772c59c6a2ba8be7da366ee4c`

Our API key (`5ff06e4966bc3378b2bda95a5f7f98d3`) does NOT work with this gateway system.

This affects:
- Ethereum V1 & V2
- Base V3 (but V2 is public!)
- Optimism V2
- Arbitrum V2
- Blast V2
- And several other unknown networks

---

## 📊 NEXT STEPS

### Immediate Actions (Public Endpoints)
1. ✅ Add Base V2 to configuration
2. ✅ Add Core DAO (all versions) to configuration
3. ✅ Add Story Network (all versions) to configuration
4. ✅ Fetch September 2025 data from these networks
5. ✅ Re-run complete cross-network analysis

### Future Actions (Requires Oracle's API Key)
To access Ethereum, Optimism, Arbitrum, and Blast data, we would need:
- The specific Arbitrum Gateway API key used by oracle.uma.xyz
- OR find alternative public endpoints for these networks
- OR contact UMA team for access

---

## 💡 KEY FINDINGS

1. **Base V2 Oracle Found!**
   - Public Studio endpoint (no API key needed)
   - This is the missing piece we discovered in your screenshots

2. **Two New Networks Discovered:**
   - Core DAO (full V1, V2, V3 support)
   - Story Network (full V1, V2, V3 support)
   - Both with public endpoints

3. **Arbitrum Gateway Mystery Solved:**
   - Oracle UI uses a different API key system
   - Our decentralized gateway key doesn't work with Arbitrum gateway
   - This explains why the 47 discovered IDs don't work

4. **Immediate Expansion Possible:**
   - Can immediately add Base V2 data
   - Can immediately add Core DAO data (3 versions!)
   - Can immediately add Story Network data (3 versions!)
   - This will significantly expand our dataset beyond just Polygon

---

## 🔬 TEST QUERY EXAMPLES

### Base V2 (Public Studio API)
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 5) { id timestamp } }"}' \
  "https://api.studio.thegraph.com/query/1057/base-optimistic-oracle/version/latest"
```

### Core DAO V2 (Public)
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 5) { id timestamp } }"}' \
  "https://thegraph.coredao.org/subgraphs/name/umaprotocol/core-optimistic-oracle-v2"
```

### Story Network V2 (Goldsky Public)
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 5) { id timestamp } }"}' \
  "https://api.goldsky.com/api/public/project_clus2fndawbcc01w31192938i/subgraphs/story-optimistic-oracle-v2/0.0.1/gn"
```

---

## 📝 NOTES

- All public endpoints have been tested and confirmed working
- Arbitrum gateway endpoints require oracle.uma.xyz's specific API key
- We've identified 3 immediately usable networks (Base, Core DAO, Story)
- This represents a significant expansion beyond just Polygon data
- Base V2 data is particularly valuable as you identified it in screenshots


