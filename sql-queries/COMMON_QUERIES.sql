-- ============================================================================
-- COMMON ANALYSIS QUERIES - UMA Oracle September 2025
-- ============================================================================
-- Run these queries in DuckDB to analyze filtered crypto prediction data
-- 
-- Usage:
--   duckdb
--   .read sql-queries/COMMON_QUERIES.sql
-- ============================================================================

-- Load all crypto predictions from all networks
CREATE OR REPLACE TABLE crypto_predictions AS 
SELECT * FROM read_csv_auto('data-dumps/*/september_2025/crypto_predictions.csv');


-- ============================================================================
-- QUERY 1: Total Overview
-- ============================================================================
-- Get total count of crypto price predictions across all networks

SELECT 
    COUNT(*) as total_crypto_predictions,
    COUNT(DISTINCT identifier) as unique_identifiers
FROM crypto_predictions;


-- ============================================================================
-- QUERY 2: How many ETH/USDT queries?
-- ============================================================================
-- Answer: Simple price queries for Ethereum

SELECT 
    COUNT(*) as eth_usdt_queries,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM crypto_predictions), 1) as percentage
FROM crypto_predictions
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' 
   OR LOWER(ancillaryData_text) LIKE '%eth/usdt%'
   OR LOWER(ancillaryData_text) LIKE '%eth/usd%';


-- ============================================================================
-- QUERY 3: Breakdown by Asset
-- ============================================================================
-- Count queries for each major crypto asset

SELECT 
    CASE 
        WHEN LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%' THEN 'Solana (SOL)'
        WHEN LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%' THEN 'Bitcoin (BTC)'
        WHEN LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%' THEN 'Ethereum (ETH)'
        WHEN LOWER(ancillaryData_text) LIKE '%xrp%' THEN 'XRP'
        ELSE 'Other'
    END as asset,
    COUNT(*) as queries,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM crypto_predictions), 1) as percentage
FROM crypto_predictions
GROUP BY asset
ORDER BY queries DESC;


-- ============================================================================
-- QUERY 4: All Assets Breakdown
-- ============================================================================
-- Detailed breakdown with all four major assets separately

WITH asset_counts AS (
    SELECT 
        SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%bitcoin%' OR LOWER(ancillaryData_text) LIKE '%btc/%' THEN 1 ELSE 0 END) as btc,
        SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%ethereum%' OR LOWER(ancillaryData_text) LIKE '%eth/%' THEN 1 ELSE 0 END) as eth,
        SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%solana%' OR LOWER(ancillaryData_text) LIKE '%sol/%' THEN 1 ELSE 0 END) as sol,
        SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%xrp%' THEN 1 ELSE 0 END) as xrp,
        COUNT(*) as total
    FROM crypto_predictions
)
SELECT 
    'Bitcoin (BTC/USDT, BTC/USD)' as asset,
    btc as queries,
    ROUND(100.0 * btc / total, 1) as percentage
FROM asset_counts
UNION ALL
SELECT 
    'Ethereum (ETH/USDT, ETH/USD)',
    eth,
    ROUND(100.0 * eth / total, 1)
FROM asset_counts
UNION ALL
SELECT 
    'Solana (SOL/USDT, SOL/USD)',
    sol,
    ROUND(100.0 * sol / total, 1)
FROM asset_counts
UNION ALL
SELECT 
    'XRP',
    xrp,
    ROUND(100.0 * xrp / total, 1)
FROM asset_counts
ORDER BY queries DESC;


-- ============================================================================
-- QUERY 5: Sample ETH Queries
-- ============================================================================
-- Show first 10 Ethereum price queries

SELECT 
    SUBSTRING(ancillaryData_text, POSITION('title:' IN ancillaryData_text) + 7, 100) as query_title
FROM crypto_predictions
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' 
   OR LOWER(ancillaryData_text) LIKE '%eth/%'
LIMIT 10;


-- ============================================================================
-- QUERY 6: Query Pattern Analysis
-- ============================================================================
-- Count different types of price queries

SELECT 
    CASE
        WHEN LOWER(ancillaryData_text) LIKE '%price above%' OR LOWER(ancillaryData_text) LIKE '%be above%' THEN 'Price Above Threshold'
        WHEN LOWER(ancillaryData_text) LIKE '%price below%' OR LOWER(ancillaryData_text) LIKE '%be below%' THEN 'Price Below Threshold'
        WHEN LOWER(ancillaryData_text) LIKE '%price between%' THEN 'Price Between Range'
        ELSE 'Other Format'
    END as query_type,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM crypto_predictions), 1) as percentage
FROM crypto_predictions
GROUP BY query_type
ORDER BY count DESC;


-- ============================================================================
-- QUERY 7: Trading Pair Detection
-- ============================================================================
-- Identify which trading pairs are mentioned

SELECT 
    COUNT(*) as queries_with_trading_pairs,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%/usdt%' THEN 1 ELSE 0 END) as usdt_pairs,
    SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%/usd%' THEN 1 ELSE 0 END) as usd_pairs,
    ROUND(100.0 * SUM(CASE WHEN LOWER(ancillaryData_text) LIKE '%/usdt%' OR LOWER(ancillaryData_text) LIKE '%/usd%' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_with_pairs
FROM crypto_predictions;


-- ============================================================================
-- QUERY 8: ETH Queries with Sample Text
-- ============================================================================
-- Detailed view of Ethereum queries

SELECT 
    SUBSTRING(ancillaryData_text, 1, 150) as query_preview
FROM crypto_predictions
WHERE LOWER(ancillaryData_text) LIKE '%ethereum%' 
   OR LOWER(ancillaryData_text) LIKE '%eth/%'
LIMIT 5;


-- ============================================================================
-- QUICK REFERENCE
-- ============================================================================
-- Common questions and their queries:
--
-- Q: How many ETH/USDT queries?
--    A: Run QUERY 2
--
-- Q: Breakdown by asset?
--    A: Run QUERY 3 or QUERY 4
--
-- Q: What do ETH queries look like?
--    A: Run QUERY 5 or QUERY 8
--
-- Q: What query patterns exist?
--    A: Run QUERY 6
--
-- Q: How many mention trading pairs?
--    A: Run QUERY 7
--
-- Q: How many simple identifier-only queries (like DEXTFUSD, ETHUSDT)?
--    A: Run QUERY 11
-- ============================================================================


-- ============================================================================
-- QUERY 11: Simple Identifier-Only Queries
-- ============================================================================
-- Leadership Question: "How many requests were only simple price queries (e.g., ETH/USDT)?"
-- 
-- Definition: 
--   - Identifier IS the query itself (ETHUSDT, BTCUSD, DEXTFUSD)
--   - ancillaryData is empty or minimal
--   - NOT full text format like "Will the price of Ethereum be above..."

-- Note: This query requires loading all V2 requests, not just crypto_predictions
-- Run MULTI_NETWORK_ANALYSIS.sql first to create all_v2_requests table

-- Count simple identifier-only queries
SELECT 
    'Simple identifier-only queries (like DEXTFUSD)' as query_type,
    COUNT(*) as count,
    'Examples: ETHUSDT, BTCUSD, DEXTFUSD, SOLUSD' as format
FROM all_v2_requests
WHERE (identifier LIKE '%USD' OR identifier LIKE '%USDT' OR identifier LIKE '%BTC' OR identifier LIKE '%ETH')
  AND identifier != 'YES_OR_NO_QUERY'
  AND LENGTH(ancillaryData_text) < 50;

-- Show identifier distribution
SELECT 
    identifier,
    COUNT(*) as count,
    CASE 
        WHEN identifier = 'YES_OR_NO_QUERY' THEN 'Modern format (full text)'
        WHEN identifier LIKE '%USD' OR identifier LIKE '%USDT' THEN 'Simple identifier-only'
        ELSE 'Other'
    END as format_type
FROM all_v2_requests
GROUP BY identifier, format_type
ORDER BY count DESC;

-- Expected result for September 2025: 0 simple queries
-- All 29,942 requests use YES_OR_NO_QUERY format
-- Simple format was common in 2021-2022 (DEXTFUSD era)
-- ============================================================================

