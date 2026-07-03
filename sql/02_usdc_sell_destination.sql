-- 02 · USDC sell destination / flight-to-safety analysis
-- Tracks which assets users bought when they sold USDC during the depeg window.
-- Recommended visualization: stacked bar chart
--   X axis: day
--   Y axis: usdc_sold_amount
--   Series: bought_asset

WITH usdc_sells AS (
  SELECT
    date_trunc('day', block_time) AS day,
    CASE
      WHEN token_bought_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7 THEN 'USDT'
      WHEN token_bought_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F THEN 'DAI'
      WHEN token_bought_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 THEN 'WETH'
      WHEN token_bought_address = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 THEN 'WBTC'
      ELSE 'Other'
    END AS bought_asset,
    token_sold_amount AS usdc_sold_amount,
    amount_usd
  FROM dex.trades
  WHERE blockchain = 'ethereum'
    AND block_time >= TIMESTAMP '2023-03-09'
    AND block_time <  TIMESTAMP '2023-03-16'
    AND token_sold_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
)

SELECT
  day,
  bought_asset,
  SUM(usdc_sold_amount) AS usdc_sold_amount,
  SUM(amount_usd) AS approximate_usd_volume,
  COUNT(*) AS trade_count
FROM usdc_sells
GROUP BY 1, 2
ORDER BY 1, usdc_sold_amount DESC;
