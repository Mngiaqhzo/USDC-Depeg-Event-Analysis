-- 03 · Curve 3pool imbalance: reconstructed USDC / USDT / DAI balances
-- Reconstructs token balances from ERC-20 Transfer events involving Curve 3pool.
--
-- Important methodological point:
-- The query scans transfers before the display window so the cumulative balances
-- represent actual pool balances, not merely balance changes during the event week.

WITH base_flows AS (
  SELECT
    evt_block_time AS ts,
    evt_block_number,
    evt_index,
    contract_address AS token,
    CASE
      WHEN "to" = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
        THEN  CAST(value AS double)
      ELSE -CAST(value AS double)
    END
    / power(
        10,
        CASE
          WHEN contract_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F THEN 18 -- DAI
          ELSE 6 -- USDC / USDT
        END
      ) AS delta
  FROM erc20_ethereum.evt_Transfer
  WHERE contract_address IN (
      0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, -- USDC
      0xdAC17F958D2ee523a2206206994597C13D831ec7, -- USDT
      0x6B175474E89094C44Da98b954EedeAC495271d0F  -- DAI
    )
    AND (
      "to"   = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
      OR
      "from" = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
    )
    AND evt_block_time < TIMESTAMP '2023-03-16'
),

running_balances AS (
  SELECT
    ts,
    SUM(
      CASE
        WHEN token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 THEN delta
        ELSE 0
      END
    ) OVER (
      ORDER BY ts, evt_block_number, evt_index
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS usdc_balance,

    SUM(
      CASE
        WHEN token = 0xdAC17F958D2ee523a2206206994597C13D831ec7 THEN delta
        ELSE 0
      END
    ) OVER (
      ORDER BY ts, evt_block_number, evt_index
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS usdt_balance,

    SUM(
      CASE
        WHEN token = 0x6B175474E89094C44Da98b954EedeAC495271d0F THEN delta
        ELSE 0
      END
    ) OVER (
      ORDER BY ts, evt_block_number, evt_index
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS dai_balance
  FROM base_flows
)

SELECT
  date_trunc('hour', ts) AS hour,
  approx_percentile(usdc_balance, 0.5) AS usdc_balance,
  approx_percentile(usdt_balance, 0.5) AS usdt_balance,
  approx_percentile(dai_balance, 0.5) AS dai_balance,
  approx_percentile(
    usdc_balance / NULLIF(usdc_balance + usdt_balance + dai_balance, 0),
    0.5
  ) AS usdc_share
FROM running_balances
WHERE ts >= TIMESTAMP '2023-03-09'
  AND ts <  TIMESTAMP '2023-03-16'
GROUP BY 1
ORDER BY 1;
