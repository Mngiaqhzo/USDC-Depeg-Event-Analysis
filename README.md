# USDC Depeg Event Analysis

**On-chain analysis of the March 2023 USDC/SVB depeg using DuneSQL**

This repository is a portfolio-style on-chain analytics case study. It analyzes the March 2023 USDC depeg after the Silicon Valley Bank failure and asks a specific question:

> Was the USDC depeg primarily a reserve-solvency crisis, or was it a temporary failure of redemption and settlement-rail availability?

The core thesis of this project is:

> The USDC depeg was not mainly a smart-contract failure or a simple reserve-impairment story. It was a temporary **redeemability / settlement-rail availability crisis**. When primary redemption through banking rails became impaired over the weekend, the secondary market temporarily lost its normal $1 arbitrage backstop.

This project connects stablecoin mechanics, DEX market structure, Curve pool imbalance, and TradFi settlement constraints.

The dashboard reconstructs DEX-implied prices, Curve 3pool imbalance, and DAI contagion to show how fiat-backed stablecoin pegs depend on arbitrage channels.

---

## What this project demonstrates

This case study demonstrates the ability to translate an economic mechanism into observable on-chain evidence.

It uses DuneSQL to analyze:

1. **USDC market price reconstruction**
   Reconstructs USDC's hourly market-implied price from raw DEX trade ratios instead of relying only on USD oracle-style feeds.

2. **Flight-to-safety behavior**
   Tracks which assets users bought when they sold USDC during the depeg window.

3. **Curve 3pool imbalance**
   Reconstructs USDC / USDT / DAI balances in Curve 3pool from ERC-20 transfer events and calculates USDC's pool share.

4. **DAI contagion**
   Compares DAI and USDC market prices to show second-order stablecoin contagion.

5. **Redemption-rail framing**
   Interprets the event as a failure of arbitrage availability: if the primary redemption path is temporarily unavailable, the secondary market loses its normal $1 backstop.

---

## Repository structure

```text
.
├── README.md
├── sql/
│   ├── 01_usdc_market_price.sql
│   ├── 02_usdc_sell_destination.sql
│   ├── 03_curve_3pool_imbalance.sql
│   ├── 04_dai_market_price.sql
│   └── 05_usdc_dai_depeg_comparison.sql
├── docs/
│   ├── case-study.md
│   ├── methodology.md
│   ├── publishing-checklist.md
├── screenshots/
│   └── README.md
├── data/
│   └── README.md
├── .gitignore
└── LICENSE
```

---

## Key contracts and addresses

| Asset / Contract | Ethereum address                             |
| ---------------- | -------------------------------------------- |
| USDC             | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| USDT             | `0xdAC17F958D2ee523a2206206994597C13D831ec7` |
| DAI              | `0x6B175474E89094C44Da98b954EedeAC495271d0F` |
| Curve 3pool      | `0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7` |

---

## Event window

The analysis uses the following window:

```text
2023-03-09 00:00 UTC to 2023-03-16 00:00 UTC
```

This captures:

* the pre-event baseline,
* the SVB failure shock,
* the weekend depeg,
* the policy response,
* and the early recovery period.

---

## Queries

| SQL file                               | Chart type              | Purpose                                          |
| -------------------------------------- | ----------------------- | ------------------------------------------------ |
| `sql/01_usdc_market_price.sql`         | Line chart              | Reconstruct USDC's market-implied depeg timeline |
| `sql/02_usdc_sell_destination.sql`     | Stacked bar chart       | Show what assets USDC sellers bought             |
| `sql/03_curve_3pool_imbalance.sql`     | Line chart              | Reconstruct USDC share in Curve 3pool            |
| `sql/04_dai_market_price.sql`          | Line chart              | Reconstruct DAI's market-implied price           |
| `sql/05_usdc_dai_depeg_comparison.sql` | Multi-series line chart | Compare USDC and DAI depeg behavior              |

---

## Minimum viable dashboard

The project can tell a complete story with only two charts:

1. **USDC market price timeline**
   Shows when the peg broke, how deep the depeg was, and when the market recovered.

2. **Curve 3pool USDC share**
   Shows the mechanism: users pushed USDC into the pool while withdrawing USDT / DAI, leaving the pool increasingly overweight USDC.

Together, these two charts support the central argument:

> The market was not merely reacting to reserve headlines. It was reacting to the temporary absence of a reliable $1 redemption backstop.

---

## Methodology summary

### Price reconstruction

The USDC and DAI price queries use `dex.trades` and calculate price directly from swap legs:

```text
price = quote token amount / target token amount
```

For USDC/USDT:

```text
USDC price = USDT amount / USDC amount
```

Because USDC can appear on either side of a swap, the query uses a `CASE` statement to normalize both directions into one consistent convention:

```text
1 USDC = X USDT
```

### Why not rely only on `amount_usd`?

During a depeg event, generic USD-denominated fields can be affected by price feeds that lag or smooth actual market stress. For this reason, the key price charts derive market-implied prices directly from token ratios in DEX trades.

### Robust aggregation

The price queries use:

```sql
approx_percentile(price, 0.5)
```

This returns an approximate median price per hour. Median is used instead of average because DEX trades can include thin-liquidity outliers, abnormal fills, or noisy trades during stress periods.

### Curve 3pool reconstruction

The Curve 3pool query uses ERC-20 `Transfer` events:

```text
inflow to 3pool   = positive balance delta
outflow from pool = negative balance delta
running sum       = reconstructed token balance
```

Then it computes:

```text
USDC share = USDC balance / (USDC + USDT + DAI balance)
```

The query intentionally scans transfer history before the display window and filters the output window only after cumulative balances are computed. Otherwise, the result would show only balance changes during the week, not actual pool composition.

---

## Limitations

* These are starter DuneSQL queries. Dune schemas can evolve, so small column or table-name adjustments may be needed.
* `amount_usd` may rely on price feeds that do not fully reflect market-implied depeg prices during stress periods.
* Curve 3pool reconstruction from ERC-20 transfers is an approximation of token balances. A production-grade version should cross-check against pool-specific state or audited community queries.
* This project is an on-chain analytics case study, not investment advice.

---

## Portfolio positioning

Suggested resume line:

> Built a DuneSQL-based case study on the March 2023 USDC depeg, reconstructing DEX-implied USDC pricing, Curve 3pool imbalance, and DAI contagion to analyze how redemption-rail availability affects fiat-backed stablecoin peg stability.

Suggested GitHub description:

> DuneSQL case study analyzing the March 2023 USDC/SVB depeg through DEX prices, Curve 3pool imbalance, and stablecoin contagion.

---

## Original source materials

The `docs/original-claude/` folder preserves the visible source conversation and planning material behind this project.

The polished files in the main `sql/` and `docs/` folders are cleaned-up GitHub versions of those materials.
