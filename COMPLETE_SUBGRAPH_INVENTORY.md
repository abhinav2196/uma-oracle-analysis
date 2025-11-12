# Complete UMA Subgraph Inventory - The Graph Explorer

**Source:** Manual extraction from https://thegraph.com/explorer (search: "UMA")  
**Date:** November 12, 2025  
**Total Found:** 20 subgraphs across 6 networks  
**Status:** ANALYZING - Testing each for schema, duplicates, and usability

---

## 📊 RAW INVENTORY (As Provided)

### Polygon (4 subgraphs)
1. **Polygon Optimistic Oracle V2**
   - ID: `BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK`
   - Status: 🔍 TESTING

2. **Polygon Optimistic Oracle** (V1 implied)
   - ID: `2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um`
   - Status: 🔍 TESTING

10. **Polygon Optimistic Oracle V3**
   - ID: `7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf`
   - Status: 🔍 TESTING
   - Note: ⚠️ This was in our existing config as "polygon_new"

### Ethereum Mainnet (3 subgraphs)
4. **Mainnet Optimistic Oracle V3**
   - ID: `Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof`
   - Status: 🔍 TESTING
   - Note: ✅ This was in our existing config

6. **Mainnet Optimistic Oracle V2**
   - ID: `GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m`
   - Status: 🔍 TESTING

14. **Mainnet Optimistic Oracle** (V1 implied)
   - ID: `56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw`
   - Status: 🔍 TESTING

### Arbitrum (3 subgraphs)
3. **Arbitrum Optimistic Oracle V3**
   - ID: `9wpkM5tHgJBHYTzKEKk4tK8a7q6MimfS9QnW7Japa8hW`
   - Status: 🔍 TESTING

7. **Arbitrum Optimistic Oracle** (V1 implied)
   - ID: `8UmLeHVL3LDrvCrjhehVaj4oHEUVhTqeY2pdwS3RdSPV`
   - Status: 🔍 TESTING

8. **Arbitrum Optimistic Oracle V2**
   - ID: `Ek5indViKvyNhCiBQNGAS1x7h35vQ3wKsPSfsLsKxpUm`
   - Status: 🔍 TESTING

### Base (4 subgraphs)
12. **Base Optimistic Oracle V3**
   - ID: `2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C`
   - Status: 🔍 TESTING
   - Note: ✅ This was in our existing config

16. **Base Optimistic Oracle V2**
   - ID: `2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D`
   - Status: 🔍 TESTING
   - Note: ⚠️ POTENTIAL DUPLICATE - checking

17. **Base Optimistic Oracle V2** (DUPLICATE!)
   - ID: `DMWJanhFZn9SiqiLCJz5VEVGEgQbMvi45ggwzPyf5cDW`
   - Status: 🔍 TESTING
   - Note: ⚠️ DUPLICATE of #16 - will test both

### Blast (2 subgraphs)
5. **Blast Optimistic Oracle V2**
   - ID: `EzV7USiaSsLRx8hdAYhZoMYjMoifLQ9M62aFCjqsQr5k`
   - Status: 🔍 TESTING

9. **Blast Optimistic Oracle** (V1 implied)
   - ID: `C2cBAgmb47t9Q4nx32k6Jgqn3A8f4rxy87MPc9xm3t5Y`
   - Status: 🔍 TESTING

### Optimism (4 subgraphs)
11. **Optimism Optimistic Oracle** (V1 implied)
   - ID: `E5E5muqrrzhp8PhYwSLTGFx7xKrCqtNzqwMPiYGn1CkF`
   - Status: 🔍 TESTING

13. **Optimism Optimistic Oracle V3**
   - ID: `FyJQyV5TLNeowZrL6kLUTB9JNPyWQNCNXJoxJWGEtBcn`
   - Status: 🔍 TESTING

15. **Optimism Optimistic Oracle V2**
   - ID: `DF7sPTV4tcdaMBmKjpmLWtH7Ad6pVX61EQKsgJBRLqd6`
   - Status: 🔍 TESTING

---

## 🔍 COMPARISON WITH EXISTING CONFIG

### Already in Config (network-config.json)
- ✅ Polygon V2 (new): `CFjwxrBWKLnWSfCvP1aiA3F252H3cD3uyFUvvMSpEork`
- ✅ Polygon V2 (old): `BpK8AdxzBUVnFN3ZCt2u3PgnKRNnS4WbM6MUETZ6b3yK` ← MATCHES #1!
- ✅ Ethereum V3: `Bm3ytsa1YvcyFJahdfQQgscFQVCcMvoXujzkd3Cz6aof` ← MATCHES #4!
- ✅ Base V3: `2Q4i8YgVZd6bAmLyDxXgrKPL2B6QwySiEUqbTyQ4vm4C` ← MATCHES #12!
- ❌ Ethereum V1/V2: `41LCrgtCNBQyDiVVyZEuPxbvkBH9BxxLU3nEZst77V8o` ← BROKEN!

### New Discoveries from Your List
- Ethereum V2: `GwhSFqXRgL9TPRCo2RdwveeJEYFtKQenGRGHJhXZJc2m` (#6) ← NEW!
- Ethereum V1: `56QVFcqGEp1A6R7B3CqLi8qRvtaiVh1LJmkayorF4Czw` (#14) ← NEW!
- All Optimism versions (4 subgraphs) ← ALL NEW!
- All Arbitrum versions (3 subgraphs) ← ALL NEW!
- All Blast versions (2 subgraphs) ← ALL NEW!
- Polygon V1: `2ytyuHupZX1r8WBKxkX9YZZ1GyaFUExzi7RQrKHq28Um` (#2) ← NEW!
- Polygon V3: `7KWbDhUE5Eqcfn3LXQtLbCfJLkNucnhzJLpi2jKhqNuf` (#10) ← NEW!
- Base V2: Multiple IDs (#16, #17) ← NEW!

---

## ⚠️ IDENTIFIED DUPLICATES

### Base V2 Oracle (2 different IDs)
- ID #16: `2GnL9JwU3bzQY3uRGnC3Nxc3vApnLDvqecq1sdTHio2D`
- ID #17: `DMWJanhFZn9SiqiLCJz5VEVGEgQbMvi45ggwzPyf5cDW`
- Action: Test both to determine which is active/preferred

---

## 🎯 TESTING PLAN

I will now systematically test each subgraph to determine:

1. ✅ **Schema Type** (V1: PriceRequest, V2: OptimisticPriceRequest, V3: Assertion)
2. ✅ **Entity Fields** (What data is available)
3. ✅ **Data Availability** (Does it have September 2025 data?)
4. ✅ **API Key Requirement** (Works with our key vs Arbitrum gateway)
5. ✅ **Active Status** (Is it receiving new data?)

Testing will use: `https://gateway.thegraph.com/api/5ff06e4966bc3378b2bda95a5f7f98d3/subgraphs/id/[ID]`

---

## 📋 ANALYSIS IN PROGRESS

Testing each subgraph now to complete the inventory...


