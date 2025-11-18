-- ============================================================================
-- MULTI-NETWORK COMPARISON - September 2025
-- ============================================================================
-- Compare oracle activity across different networks and adapters
-- ============================================================================

-- Load all raw data (not just crypto predictions)
CREATE OR REPLACE TABLE polygon_new AS 
SELECT *, 'polygon_v2_new' as network FROM read_csv_auto('data-dumps/polygon_v2_new/september_2025/polygon_v2_new_1756677600_1759269599.csv');

CREATE OR REPLACE TABLE polygon_old AS 
SELECT *, 'polygon_v2_old' as network FROM read_csv_auto('data-dumps/polygon_v2_old/september_2025/polygon_v2_old_1756677600_1759269599.csv');

CREATE OR REPLACE TABLE blast AS 
SELECT *, 'blast_v2' as network FROM read_csv_auto('data-dumps/blast_v2/september_2025/blast_v2_1756677600_1759269599.csv');

CREATE OR REPLACE TABLE base AS 
SELECT *, 'base_v2' as network FROM read_csv_auto('data-dumps/base_v2/september_2025/base_v2_1756677600_1759269599.csv');


-- Combine all V2 oracle data
CREATE OR REPLACE TABLE all_v2_requests AS
SELECT * FROM polygon_new
UNION ALL SELECT * FROM polygon_old
UNION ALL SELECT * FROM blast
UNION ALL SELECT * FROM base;


-- ============================================================================
-- QUERY 1: Network Activity Summary
-- ============================================================================

SELECT 
    network,
    COUNT(*) as total_requests,
    COUNT(DISTINCT identifier) as unique_identifiers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM all_v2_requests), 1) as pct_of_total
FROM all_v2_requests
GROUP BY network
ORDER BY total_requests DESC;


-- ============================================================================
-- QUERY 2: Crypto Predictions by Network
-- ============================================================================

SELECT 
    network,
    COUNT(*) as total_requests,
    SUM(CASE 
        WHEN LOWER(ancillaryData_text) LIKE '%price of%' 
          OR LOWER(ancillaryData_text) LIKE '%price above%' 
          OR LOWER(ancillaryData_text) LIKE '%price below%'
        THEN 1 ELSE 0 
    END) as crypto_predictions,
    ROUND(100.0 * SUM(CASE 
        WHEN LOWER(ancillaryData_text) LIKE '%price of%' 
          OR LOWER(ancillaryData_text) LIKE '%price above%' 
          OR LOWER(ancillaryData_text) LIKE '%price below%'
        THEN 1 ELSE 0 
    END) / COUNT(*), 1) as pct_crypto
FROM all_v2_requests
GROUP BY network
ORDER BY crypto_predictions DESC;


-- ============================================================================
-- QUERY 3: Polygon Adapter Comparison
-- ============================================================================
-- Compare the two Polygon adapters

WITH polygon_only AS (
    SELECT * FROM all_v2_requests 
    WHERE network IN ('polygon_v2_new', 'polygon_v2_old')
),
crypto_only AS (
    SELECT * FROM polygon_only
    WHERE LOWER(ancillaryData_text) LIKE '%price of%' 
       OR LOWER(ancillaryData_text) LIKE '%price above%' 
       OR LOWER(ancillaryData_text) LIKE '%price below%'
)
SELECT 
    network,
    COUNT(*) as crypto_predictions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM crypto_only), 1) as pct_of_polygon_crypto,
    -- Asset breakdown
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%' THEN 1 ELSE 0 END) as sol_queries,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%' THEN 1 ELSE 0 END) as btc_queries,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%' THEN 1 ELSE 0 END) as eth_queries
FROM crypto_only
GROUP BY network
ORDER BY crypto_predictions DESC;


-- ============================================================================
-- QUERY 4: ETH/USDT Across All Networks
-- ============================================================================
-- Answer: How many ETH/USDT queries across all networks?

SELECT 
    network,
    COUNT(*) as eth_queries
FROM all_v2_requests
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' 
   OR LOWER(ancillaryData_text) LIKE '%eth/usdt%'
   OR LOWER(ancillaryData_text) LIKE '%eth/usd%'
GROUP BY network
ORDER BY eth_queries DESC;

-- Total across all networks
SELECT 
    'TOTAL' as network,
    COUNT(*) as eth_queries,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM all_v2_requests), 1) as pct_of_all_requests
FROM all_v2_requests
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' 
   OR LOWER(ancillaryData_text) LIKE '%eth/usdt%'
   OR LOWER(ancillaryData_text) LIKE '%eth/usd%';


-- ============================================================================
-- QUERY 5: Asset Distribution (All Networks Combined)
-- ============================================================================

WITH crypto_only AS (
    SELECT * FROM all_v2_requests
    WHERE LOWER(ancillaryData_text) LIKE '%price of%' 
       OR LOWER(ancillaryData_text) LIKE '%price above%' 
       OR LOWER(ancillaryData_text) LIKE '%price below%'
)
SELECT 
    CASE 
        WHEN LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%' THEN 'Solana (SOL)'
        WHEN LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%' THEN 'Bitcoin (BTC)'
        WHEN LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%' THEN 'Ethereum (ETH)'
        WHEN LOWER(ancillaryData_text) LIKE '%xrp%' THEN 'XRP'
        WHEN LOWER(ancillaryData_text) LIKE '%dogecoin%' OR LOWER(ancillaryData_text) LIKE '%doge%' THEN 'Dogecoin (DOGE)'
        ELSE 'Other'
    END as asset,
    COUNT(*) as queries,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM crypto_only), 1) as percentage
FROM crypto_only
GROUP BY asset
ORDER BY queries DESC;


-- ============================================================================
-- QUERY 6: Identifier Analysis
-- ============================================================================
-- Check what identifiers are used across networks

SELECT 
    identifier,
    COUNT(*) as count,
    COUNT(DISTINCT network) as networks_using,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM all_v2_requests), 1) as pct_total
FROM all_v2_requests
GROUP BY identifier
ORDER BY count DESC;


-- ============================================================================
-- QUERY 7: Identifier-Only Queries Detection
-- ============================================================================
-- Check for DEXTFUSD-style queries (identifier ends in USD/USDT)

SELECT 
    network,
    identifier,
    COUNT(*) as count
FROM all_v2_requests
WHERE (identifier LIKE '%USD' OR identifier LIKE '%USDT')
  AND LENGTH(ancillaryData_text) < 10  -- Empty or minimal ancillaryData
GROUP BY network, identifier
ORDER BY count DESC;


-- ============================================================================
-- QUERY 8: Network Comparison Table
-- ============================================================================
-- Complete comparison across all active networks

SELECT 
    network,
    COUNT(*) as total_requests,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%price%' THEN 1 ELSE 0 END) as price_queries,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%' THEN 1 ELSE 0 END) as btc,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%' THEN 1 ELSE 0 END) as eth,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%' THEN 1 ELSE 0 END) as sol,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%xrp%' THEN 1 ELSE 0 END) as xrp
FROM all_v2_requests
GROUP BY network
ORDER BY total_requests DESC;


-- ============================================================================
-- QUERY 9: Time Distribution
-- ============================================================================
-- See when queries are happening (by day)

SELECT 
    DATE_TRUNC('day', TO_TIMESTAMP(CAST(time AS BIGINT))) as date,
    COUNT(*) as total_queries,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%price%' THEN 1 ELSE 0 END) as crypto_queries
FROM all_v2_requests
GROUP BY date
ORDER BY date
LIMIT 10;


-- ============================================================================
-- QUERY 10: Simple Answer Format
-- ============================================================================
-- Quick answers to common questions

-- How many total crypto predictions?
SELECT 'Total Crypto Predictions' as metric, COUNT(*) as value FROM crypto_predictions
UNION ALL
-- How many ETH queries?
SELECT 'ETH/USDT Queries', COUNT(*) FROM crypto_predictions 
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%'
UNION ALL
-- How many BTC queries?
SELECT 'BTC/USDT Queries', COUNT(*) FROM crypto_predictions 
WHERE LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%'
UNION ALL
-- How many SOL queries?
SELECT 'SOL/USDT Queries', COUNT(*) FROM crypto_predictions 
WHERE LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%'
UNION ALL
-- Total across all networks
SELECT 'Total All Networks (V2)', COUNT(*) FROM all_v2_requests;


-- ============================================================================
-- CLEANUP (Optional)
-- ============================================================================
-- Drop tables if you want to re-run from scratch
-- DROP TABLE IF EXISTS crypto_predictions;
-- DROP TABLE IF EXISTS all_v2_requests;
-- DROP TABLE IF EXISTS polygon_new;
-- DROP TABLE IF EXISTS polygon_old;
-- DROP TABLE IF EXISTS blast;
-- DROP TABLE IF EXISTS base;
-- ============================================================================

