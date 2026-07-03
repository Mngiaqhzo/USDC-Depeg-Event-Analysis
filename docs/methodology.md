# Methodology

## Data sources

This project uses Dune tables commonly used for Ethereum on-chain analysis.

| Table                         | Use in this project                                                                |
| ----------------------------- | ---------------------------------------------------------------------------------- |
| `dex.trades`                  | DEX swap records, used to reconstruct market-implied prices and trade destinations |
| `erc20_ethereum.evt_Transfer` | ERC-20 transfer events, used to reconstruct Curve 3pool token balances             |

---

## Why derive price from trade ratios?

During a depeg event, a generic USD price feed may not fully capture the actual market price at each venue and timestamp.

For that reason, this project calculates price from the swap itself.

For USDC/USDT:

```text
USDC price = USDT amount / USDC amount
```

The `CASE` statement is needed because USDC can appear on either side of the trade.

| Trade direction     | Formula                                   |
| ------------------- | ----------------------------------------- |
| Sell USDC, buy USDT | `token_bought_amount / token_sold_amount` |
| Sell USDT, buy USDC | `token_sold_amount / token_bought_amount` |

Both branches return the same price convention:

```text
1 USDC = X USDT
```

---

## Why use median?

The queries use:

```sql
approx_percentile(price, 0.5)
```

This gives an approximate median.

Median is more robust than average when the dataset contains:

* very small trades,
* thin-liquidity pools,
* temporary outliers,
* abnormal fills during stress,
* or venue-specific noise.

---

## Curve 3pool balance reconstruction

Curve 3pool is a pool contract, but each token balance is recorded in the individual ERC-20 token contract ledger.

Therefore, to reconstruct pool balances, the query searches all transfers where:

```text
contract_address IN (USDC, USDT, DAI)
AND ("to" = 3pool OR "from" = 3pool)
```

Then:

```text
inflow to 3pool   = positive delta
outflow from pool = negative delta
running sum       = reconstructed balance
```

Decimals must be normalized:

| Token | Decimals |
| ----- | -------: |
| USDC  |        6 |
| USDT  |        6 |
| DAI   |       18 |

---

## Main charts

### Chart 1: USDC market price

File:

```text
sql/01_usdc_market_price.sql
```

Purpose:

```text
Show the timing and depth of the USDC depeg.
```

---

### Chart 2: USDC sell destination

File:

```text
sql/02_usdc_sell_destination.sql
```

Purpose:

```text
Show where capital moved when users sold USDC.
```

---

### Chart 3: Curve 3pool imbalance

File:

```text
sql/03_curve_3pool_imbalance.sql
```

Purpose:

```text
Show that Curve 3pool became overweight USDC, indicating one-sided exit pressure.
```

---

### Chart 4: DAI price

File:

```text
sql/04_dai_market_price.sql
```

Purpose:

```text
Show whether stress transmitted from USDC to DAI.
```

---

### Chart 5: USDC vs DAI comparison

File:

```text
sql/05_usdc_dai_depeg_comparison.sql
```

Purpose:

```text
Show contagion in a single multi-series chart.
```

---

## Validation checklist

Before publishing, verify:

* each query runs on Dune without schema errors,
* chart time zone is clear,
* chart range covers `2023-03-09` to `2023-03-15`,
* labels explain what each metric proves,
* the README links to the live Dune dashboard,
* screenshots are committed under `screenshots/`,
* all placeholder values are replaced with real query outputs.
