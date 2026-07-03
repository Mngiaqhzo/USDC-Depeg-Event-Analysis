-- 05 · USDC and DAI depeg comparison
-- Combines USDC/USDT and DAI/USDT trades into one multi-series query.
-- Recommended visualization: line chart
--   X axis: hour
--   Y axis: median_price
--   Series: token

WITH trades AS (
  SELECT
    date_trunc('hour', block_time) AS hour,
    'USDC' AS token,
    CASE
      WHEN token_sold_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        THEN token_bought_amount / token_sold_amount
      ELSE token_sold_amount / token_bought_amount
    END AS price
  FROM dex.trades
  WHERE blockchain = 'ethereum'
    AND block_time >= TIMESTAMP '2023-03-09'
    AND block_time <  TIMESTAMP '2023-03-16'
    AND (
      (
        token_sold_address   = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        AND token_bought_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7
      )
      OR
      (
        token_bought_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        AND token_sold_address   = 0xdAC17F958D2ee523a2206206994597C13D831ec7
      )
    )

  UNION ALL

  SELECT
    date_trunc('hour', block_time) AS hour,
    'DAI' AS token,
    CASE
      WHEN token_sold_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F
        THEN token_bought_amount / token_sold_amount
      ELSE token_sold_amount / token_bought_amount
    END AS price
  FROM dex.trades
  WHERE blockchain = 'ethereum'
    AND block_time >= TIMESTAMP '2023-03-09'
    AND block_time <  TIMESTAMP '2023-03-16'
    AND (
      (
        token_sold_address   = 0x6B175474E89094C44Da98b954EedeAC495271d0F
        AND token_bought_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7
      )
      OR
      (
        token_bought_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F
        AND token_sold_address   = 0xdAC17F958D2ee523a2206206994597C13D831ec7
      )
    )
)

SELECT
  hour,
  token,
  approx_percentile(price, 0.5) AS median_price
FROM trades
WHERE price BETWEEN 0.5 AND 1.5
GROUP BY 1, 2
ORDER BY 1, 2;
