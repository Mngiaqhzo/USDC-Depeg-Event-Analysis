-- 01 · USDC market price in USDT, hourly
-- Derives the USDC market price from raw DEX trade ratios.
-- Price convention: 1 USDC = X USDT.

WITH usdc_usdt_trades AS (
  SELECT
    date_trunc('hour', block_time) AS hour,
    CASE
      -- User sold USDC and bought USDT:
      -- price = USDT amount / USDC amount
      WHEN token_sold_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        THEN token_bought_amount / token_sold_amount

      -- User sold USDT and bought USDC:
      -- price = USDT amount / USDC amount
      ELSE token_sold_amount / token_bought_amount
    END AS usdc_price
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
)

SELECT
  hour,
  approx_percentile(usdc_price, 0.5) AS median_usdc_price
FROM usdc_usdt_trades
WHERE usdc_price BETWEEN 0.5 AND 1.5
GROUP BY 1
ORDER BY 1;
