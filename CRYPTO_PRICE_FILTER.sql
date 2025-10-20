-- ============================================================================
-- CRYPTO PRICE PREDICTION FILTER - SQL VERSION
-- ============================================================================
-- These queries replicate the Python filtering logic in pure SQL
-- Used to identify crypto price predictions from UMA oracle proposals
--
-- Logic:
-- 1. Must contain crypto asset keyword (bitcoin, ethereum, xrp, btc, eth, etc.)
-- 2. Must match price pattern ("will the price of", "price between $", etc.)
-- ============================================================================

-- QUERY 1: Count total proposals vs price predictions
-- ============================================================================
SELECT 
    (SELECT COUNT(*) FROM proposals) as total_proposals,
    (SELECT COUNT(*) FROM proposals 
     WHERE LOWER(ancillaryData) LIKE '%will the price of%' 
     AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
          OR LOWER(ancillaryData) LIKE '%ethereum%'
          OR LOWER(ancillaryData) LIKE '%xrp%'
          OR LOWER(ancillaryData) LIKE '%solana%'
          OR LOWER(ancillaryData) LIKE '%btc%'
          OR LOWER(ancillaryData) LIKE '%eth%'
          OR LOWER(ancillaryData) LIKE '%sol%')) as crypto_price_predictions;


-- QUERY 2: Filter and extract crypto price predictions with details
-- ============================================================================
SELECT 
    id,
    time,
    state,
    requester,
    proposer,
    disputer,
    bond,
    reward,
    CASE 
        WHEN LOWER(ancillaryData) LIKE '%bitcoin%' OR LOWER(ancillaryData) LIKE '%btc%' THEN 'BTC'
        WHEN LOWER(ancillaryData) LIKE '%ethereum%' OR LOWER(ancillaryData) LIKE '%eth%' THEN 'ETH'
        WHEN LOWER(ancillaryData) LIKE '%xrp%' THEN 'XRP'
        WHEN LOWER(ancillaryData) LIKE '%solana%' OR LOWER(ancillaryData) LIKE '%sol%' THEN 'SOL'
        ELSE 'OTHER'
    END as crypto_asset,
    ancillaryData
FROM proposals
WHERE 
    -- Must have price pattern
    LOWER(ancillaryData) LIKE '%will the price of%'
    -- Must have crypto keyword
    AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
         OR LOWER(ancillaryData) LIKE '%ethereum%'
         OR LOWER(ancillaryData) LIKE '%xrp%'
         OR LOWER(ancillaryData) LIKE '%solana%'
         OR LOWER(ancillaryData) LIKE '%btc%'
         OR LOWER(ancillaryData) LIKE '%eth%'
         OR LOWER(ancillaryData) LIKE '%sol%'
         OR LOWER(ancillaryData) LIKE '%cardano%'
         OR LOWER(ancillaryData) LIKE '%ada%'
         OR LOWER(ancillaryData) LIKE '%litecoin%'
         OR LOWER(ancillaryData) LIKE '%ltc%'
         OR LOWER(ancillaryData) LIKE '%dogecoin%'
         OR LOWER(ancillaryData) LIKE '%doge%')
LIMIT 10;  -- Show first 10


-- QUERY 3: Count by crypto asset (after filtering)
-- ============================================================================
SELECT 
    CASE 
        WHEN LOWER(ancillaryData) LIKE '%bitcoin%' OR LOWER(ancillaryData) LIKE '%btc%' THEN 'BTC'
        WHEN LOWER(ancillaryData) LIKE '%ethereum%' OR LOWER(ancillaryData) LIKE '%eth%' THEN 'ETH'
        WHEN LOWER(ancillaryData) LIKE '%xrp%' THEN 'XRP'
        WHEN LOWER(ancillaryData) LIKE '%solana%' OR LOWER(ancillaryData) LIKE '%sol%' THEN 'SOL'
        ELSE 'OTHER'
    END as asset,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (
        SELECT COUNT(*) FROM proposals 
        WHERE LOWER(ancillaryData) LIKE '%will the price of%'
    ), 2) as percentage
FROM proposals
WHERE 
    LOWER(ancillaryData) LIKE '%will the price of%'
    AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
         OR LOWER(ancillaryData) LIKE '%ethereum%'
         OR LOWER(ancillaryData) LIKE '%xrp%'
         OR LOWER(ancillaryData) LIKE '%solana%'
         OR LOWER(ancillaryData) LIKE '%btc%'
         OR LOWER(ancillaryData) LIKE '%eth%'
         OR LOWER(ancillaryData) LIKE '%sol%'
         OR LOWER(ancillaryData) LIKE '%cardano%'
         OR LOWER(ancillaryData) LIKE '%ada%'
         OR LOWER(ancillaryData) LIKE '%litecoin%'
         OR LOWER(ancillaryData) LIKE '%ltc%'
         OR LOWER(ancillaryData) LIKE '%dogecoin%'
         OR LOWER(ancillaryData) LIKE '%doge%')
GROUP BY asset
ORDER BY count DESC;


-- QUERY 4: Financial metrics for crypto price predictions
-- ============================================================================
SELECT 
    COUNT(*) as total_price_predictions,
    SUM(CAST(bond AS BIGINT)) as total_bond_smallest_unit,
    SUM(CAST(reward AS BIGINT)) as total_reward_smallest_unit,
    ROUND(AVG(CAST(bond AS BIGINT)), 0) as avg_bond_smallest_unit,
    ROUND(AVG(CAST(reward AS BIGINT)), 0) as avg_reward_smallest_unit,
    SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) as disputes,
    ROUND(100.0 * SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as dispute_rate_pct
FROM proposals
WHERE 
    LOWER(ancillaryData) LIKE '%will the price of%'
    AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
         OR LOWER(ancillaryData) LIKE '%ethereum%'
         OR LOWER(ancillaryData) LIKE '%xrp%'
         OR LOWER(ancillaryData) LIKE '%solana%'
         OR LOWER(ancillaryData) LIKE '%btc%'
         OR LOWER(ancillaryData) LIKE '%eth%'
         OR LOWER(ancillaryData) LIKE '%sol%'
         OR LOWER(ancillaryData) LIKE '%cardano%'
         OR LOWER(ancillaryData) LIKE '%ada%'
         OR LOWER(ancillaryData) LIKE '%litecoin%'
         OR LOWER(ancillaryData) LIKE '%ltc%'
         OR LOWER(ancillaryData) LIKE '%dogecoin%'
         OR LOWER(ancillaryData) LIKE '%doge%');


-- QUERY 5: Top proposers (price predictions only)
-- ============================================================================
SELECT 
    proposer,
    COUNT(*) as proposals,
    ROUND(100.0 * COUNT(*) / (
        SELECT COUNT(*) FROM proposals 
        WHERE LOWER(ancillaryData) LIKE '%will the price of%'
    ), 2) as market_share_pct,
    SUM(CAST(bond AS BIGINT)) as total_bond,
    SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) as disputes
FROM proposals
WHERE 
    LOWER(ancillaryData) LIKE '%will the price of%'
    AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
         OR LOWER(ancillaryData) LIKE '%ethereum%'
         OR LOWER(ancillaryData) LIKE '%xrp%'
         OR LOWER(ancillaryData) LIKE '%solana%'
         OR LOWER(ancillaryData) LIKE '%btc%'
         OR LOWER(ancillaryData) LIKE '%eth%'
         OR LOWER(ancillaryData) LIKE '%sol%'
         OR LOWER(ancillaryData) LIKE '%cardano%'
         OR LOWER(ancillaryData) LIKE '%ada%'
         OR LOWER(ancillaryData) LIKE '%litecoin%'
         OR LOWER(ancillaryData) LIKE '%ltc%'
         OR LOWER(ancillaryData) LIKE '%dogecoin%'
         OR LOWER(ancillaryData) LIKE '%doge%')
GROUP BY proposer
ORDER BY proposals DESC
LIMIT 10;


-- QUERY 6: State distribution (price predictions only)
-- ============================================================================
SELECT 
    state,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (
        SELECT COUNT(*) FROM proposals 
        WHERE LOWER(ancillaryData) LIKE '%will the price of%'
    ), 2) as percentage
FROM proposals
WHERE 
    LOWER(ancillaryData) LIKE '%will the price of%'
    AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
         OR LOWER(ancillaryData) LIKE '%ethereum%'
         OR LOWER(ancillaryData) LIKE '%xrp%'
         OR LOWER(ancillaryData) LIKE '%solana%'
         OR LOWER(ancillaryData) LIKE '%btc%'
         OR LOWER(ancillaryData) LIKE '%eth%'
         OR LOWER(ancillaryData) LIKE '%sol%'
         OR LOWER(ancillaryData) LIKE '%cardano%'
         OR LOWER(ancillaryData) LIKE '%ada%'
         OR LOWER(ancillaryData) LIKE '%litecoin%'
         OR LOWER(ancillaryData) LIKE '%ltc%'
         OR LOWER(ancillaryData) LIKE '%dogecoin%'
         OR LOWER(ancillaryData) LIKE '%doge%')
GROUP BY state
ORDER BY count DESC;


-- QUERY 7: CTE Version (Cleaner - Recommended)
-- ============================================================================
-- This is the cleanest version using a Common Table Expression
-- Run this in DuckDB for best results

WITH crypto_price_predictions AS (
    SELECT 
        id,
        time,
        state,
        requester,
        proposer,
        disputer,
        bond,
        reward,
        ancillaryData,
        CASE 
            WHEN LOWER(ancillaryData) LIKE '%bitcoin%' OR LOWER(ancillaryData) LIKE '%btc%' THEN 'BTC'
            WHEN LOWER(ancillaryData) LIKE '%ethereum%' OR LOWER(ancillaryData) LIKE '%eth%' THEN 'ETH'
            WHEN LOWER(ancillaryData) LIKE '%xrp%' THEN 'XRP'
            WHEN LOWER(ancillaryData) LIKE '%solana%' OR LOWER(ancillaryData) LIKE '%sol%' THEN 'SOL'
            ELSE 'OTHER'
        END as crypto_asset
    FROM proposals
    WHERE 
        LOWER(ancillaryData) LIKE '%will the price of%'
        AND (LOWER(ancillaryData) LIKE '%bitcoin%' 
             OR LOWER(ancillaryData) LIKE '%ethereum%'
             OR LOWER(ancillaryData) LIKE '%xrp%'
             OR LOWER(ancillaryData) LIKE '%solana%'
             OR LOWER(ancillaryData) LIKE '%btc%'
             OR LOWER(ancillaryData) LIKE '%eth%'
             OR LOWER(ancillaryData) LIKE '%sol%'
             OR LOWER(ancillaryData) LIKE '%cardano%'
             OR LOWER(ancillaryData) LIKE '%ada%'
             OR LOWER(ancillaryData) LIKE '%litecoin%'
             OR LOWER(ancillaryData) LIKE '%ltc%'
             OR LOWER(ancillaryData) LIKE '%dogecoin%'
             OR LOWER(ancillaryData) LIKE '%doge%')
)
SELECT 
    COUNT(*) as total_predictions,
    COUNT(DISTINCT crypto_asset) as unique_assets,
    COUNT(DISTINCT proposer) as unique_proposers,
    COUNT(DISTINCT requester) as unique_requesters,
    SUM(CASE WHEN state = 'Settled' THEN 1 ELSE 0 END) as settled,
    SUM(CASE WHEN disputer IS NOT NULL THEN 1 ELSE 0 END) as disputed,
    SUM(CAST(bond AS BIGINT)) as total_bond_smallest_unit,
    SUM(CAST(reward AS BIGINT)) as total_reward_smallest_unit
FROM crypto_price_predictions;
