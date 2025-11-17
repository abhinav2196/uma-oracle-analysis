# Quick Guide: Find Missing Subgraph IDs

**Goal:** Discover the subgraph IDs for Base V2, Ethereum V1/V2, Optimism, Arbitrum, and Blast oracles.

**Estimated Time:** 15-30 minutes

---

## Method 1: Browser DevTools (FASTEST) ⚡

### Step-by-Step:

1. **Open Oracle UI in your browser:**
   - Visit: https://oracle.uma.xyz

2. **Open DevTools:**
   - Chrome/Edge: Press `F12` or `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows)
   - Firefox: Press `F12` or `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows)

3. **Go to Network tab:**
   - Click "Network" tab at top of DevTools
   - Filter by "Fetch/XHR" or search for "graph"

4. **Filter by network (e.g., Base):**
   - In the Oracle UI, select "Base" network
   - Watch Network tab for GraphQL requests

5. **Find the subgraph request:**
   - Look for requests to domains like:
     - `gateway.thegraph.com`
     - `api.thegraph.com`
     - `thegraph.com/subgraphs`
   - Click on the request

6. **Extract subgraph ID:**
   - Look at the URL in Request Headers
   - Format: `https://gateway.thegraph.com/api/[API_KEY]/subgraphs/id/[SUBGRAPH_ID]`
   - Copy the `SUBGRAPH_ID` part (long alphanumeric string)

7. **Repeat for each network:**
   - Switch to Ethereum → capture ID
   - Switch to Optimism → capture ID
   - Switch to Arbitrum → capture ID
   - Switch to Blast → capture ID

### Example:

```
Request URL: https://gateway.thegraph.com/api/abc123.../subgraphs/id/H7gQHv3qKN...
                                                                     ^^^^^^^^^^^^
                                                                   SUBGRAPH ID
```

---

## Method 2: Search The Graph Explorer (Manual)

### Step-by-Step:

1. **Visit The Graph Explorer:**
   - URL: https://thegraph.com/explorer

2. **Search for UMA subgraphs:**
   - In search box, type: "UMA Optimistic Oracle"
   - Or: "UMA" + filter by network

3. **Filter by network:**
   - Use network dropdown to select:
     - Base
     - Optimism  
     - Arbitrum One
     - Blast
     - Ethereum

4. **Find relevant subgraphs:**
   - Look for subgraphs with names like:
     - "UMA Optimistic Oracle V2"
     - "UMA OOv2"
     - Check "Publisher" is UMA Protocol

5. **Copy subgraph ID:**
   - Click on the subgraph
   - Copy the ID from the URL or page

6. **Verify it's active:**
   - Check "Status" shows "Syncing" or "Synced"
   - Check "Last Indexed Block" is recent

---

## Method 3: GitHub Repository Search

### Step-by-Step:

1. **Visit UMA's subgraphs repo:**
   - URL: https://github.com/UMAprotocol/subgraphs

2. **Look for deployment configs:**
   - Check `README.md` for deployment table
   - Look for files like:
     - `networks.json`
     - `deployed-subgraphs.json`
     - `subgraph-endpoints.json`

3. **Search for network names:**
   - Use GitHub search (press `/`)
   - Search for: "optimism", "arbitrum", "blast", "base"
   - Look in deployment scripts or config files

4. **Find subgraph deployment IDs:**
   - May be in deployment logs
   - Check `.github/workflows` for CI/CD scripts
   - Look at recent commits for deployment updates

---

## Method 4: Direct API Query (Advanced)

If you can find even ONE subgraph ID for a network, you can query it to find contract addresses, then search for other subgraphs indexing the same contract.

```bash
# Once you have ONE subgraph ID for a network:
SUBGRAPH_ID="found_id_here"
API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"

# Query for contract address
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 1) { id } }"}' \
  "https://gateway.thegraph.com/api/$API_KEY/subgraphs/id/$SUBGRAPH_ID" \
  | jq '.'

# The contract address will be in the data
# Then search The Graph Explorer for other subgraphs indexing that contract
```

---

## Recording Template

As you find IDs, record them here:

```markdown
### Base
- **V2 Subgraph ID:** _______________________________________________
- **V3 Subgraph ID:** 2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C (already have)
- **Contract Address V2:** _______________________________________________
- **Verified:** Yes / No

### Ethereum  
- **V1 Subgraph ID:** _______________________________________________
- **V2 Subgraph ID:** _______________________________________________
- **V3 Subgraph ID:** Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof (already have)
- **Contract Address V1:** _______________________________________________
- **Contract Address V2:** 0xA0Ae6609447e57a42c51B50EAe921D701823FFAe (known)
- **Verified:** Yes / No

### Optimism
- **V2 Subgraph ID:** _______________________________________________
- **Contract Address:** _______________________________________________
- **Verified:** Yes / No

### Arbitrum
- **V2 Subgraph ID:** _______________________________________________
- **Contract Address:** _______________________________________________
- **Verified:** Yes / No

### Blast
- **V2 Subgraph ID:** _______________________________________________
- **Contract Address:** _______________________________________________
- **Verified:** Yes / No
```

---

## Validation Test

Once you have a subgraph ID, test it immediately:

```bash
API_KEY="5ff06e4966bc3378b2bda95a5f7f98d3"
SUBGRAPH_ID="your_found_id_here"

# Test 1: Check if it exists
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { queryType { name } } }"}' \
  "https://gateway.thegraph.com/api/$API_KEY/subgraphs/id/$SUBGRAPH_ID"

# Should return: {"data":{"__schema":{"queryType":{"name":"Query"}}}}

# Test 2: Check entity types
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { types { name kind } } }"}' \
  "https://gateway.thegraph.com/api/$API_KEY/subgraphs/id/$SUBGRAPH_ID" \
  | jq -r '.data.__schema.types[] | select(.kind == "OBJECT") | .name' \
  | grep -v "Query\|Subscription\|_"

# Should show: OptimisticPriceRequest (for V2) or Assertion (for V3) or PriceRequest (for V1)

# Test 3: Fetch one record
curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"query":"{ optimisticPriceRequests(first: 1) { id time } }"}' \
  "https://gateway.thegraph.com/api/$API_KEY/subgraphs/id/$SUBGRAPH_ID" \
  | jq '.'

# Should return actual data
```

---

## Expected Results

After finding all IDs, you should have:

- ✅ 6 new subgraph IDs
- ✅ Validation that each returns data
- ✅ Network and oracle version confirmed
- ✅ Contract addresses documented

---

## Next Steps After Finding IDs

1. **Update `network-config.json`** with new subgraph IDs
2. **Run validation script** to test all subgraphs
3. **Fetch September 2025 data** from all networks:
   ```bash
   for network in base_v2 optimism arbitrum blast; do
     ./fetch_uma_data.sh $network september_2025
   done
   ```
4. **Re-run analysis** with complete data

---

## Need Help?

**If Method 1 (DevTools) doesn't work:**
- Try Method 2 (The Graph Explorer)
- The subgraphs MUST be published somewhere since the UI is using them

**If you find the IDs:**
- Paste them here and I'll update the config
- Run validation tests
- Start fetching data

**If you're stuck:**
- Share screenshots of DevTools Network tab
- Share what you see on The Graph Explorer
- We'll figure it out together!

---

**Your Action:** Try Method 1 (DevTools) first - should take 5-10 minutes to find all IDs!

