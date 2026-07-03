-- 04 · DAI market price in USDT, hourly
-- Price convention: 1 DAI = X USDT.

WITH dai_usdt_trades AS (
  SELECT
    date_trunc('hour', block_time) AS hour,
    CASE
      WHEN token_sold_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F
        THEN token_bought_amount / token_sold_amount
      ELSE token_sold_amount / token_bought_amount
    END AS dai_price
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
  approx_percentile(dai_price, 0.5) AS median_dai_price
FROM dai_usdt_trades
WHERE dai_price BETWEEN 0.5 AND 1.5
GROUP BY 1
ORDER BY 1;
