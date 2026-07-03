# Case Study: USDC Depeg Event Analysis

## Core thesis

The March 2023 USDC depeg is best understood as a temporary failure of **redeemability**, not a pure reserve-solvency failure.

USDC normally holds its peg through a primary-market arbitrage loop:

1. Buy USDC below $1 in the secondary market.
2. Redeem USDC with Circle at $1 through the primary redemption channel.
3. Earn the spread.
4. The buying pressure pushes the secondary price back toward $1.

During the SVB weekend, that arbitrage loop became impaired because the redemption leg depends on banking rails. Once the primary redemption backstop is impaired, the secondary market no longer has a reliable $1 buyer of last resort.

That is the mechanism this project tries to visualize.

---

## Event window

The dashboard uses:

```text
2023-03-09 00:00 UTC to 2023-03-16 00:00 UTC
```

This captures the pre-event baseline, the Friday/Saturday depeg, the Sunday policy response, and the Monday recovery.

---

## Narrative arc

### 1. The peg breaks

The first chart reconstructs USDC's hourly market price from DEX trade ratios.

This is better than relying only on a generic USD price feed because depeg events are exactly when feed-based prices can lag, smooth, or obscure the true secondary-market price.

**Claim supported by chart:** the market priced USDC below par during the crisis window.

---

### 2. Holders search for exits

The second chart groups trades where users sold USDC and records what they bought.

This converts raw swaps into user behavior:

```text
Did users flee into USDT?
Did they buy DAI?
Did they rotate into ETH?
Did they move into other assets?
```

**Claim supported by chart:** the sell pressure was not random; it had a clear flight-to-safety pattern.

---

### 3. Curve 3pool becomes the mechanism chart

Curve 3pool holds USDC, USDT, and DAI. In normal conditions, these three stablecoins should stay relatively balanced because they are treated as close substitutes.

During the depeg, users pushed USDC into the pool and pulled out USDT / DAI. The pool composition therefore becomes a direct on-chain footprint of one-sided panic.

**Claim supported by chart:** the market was not simply repricing USDC; it was using Curve as an exit venue, leaving the pool increasingly overweight USDC.

---

### 4. DAI contagion

DAI was affected because of its USDC exposure and stablecoin liquidity relationships. Comparing DAI/USDT with USDC/USDT shows whether the stress transmitted to another major stablecoin.

**Claim supported by chart:** stablecoin risk can propagate through collateral and liquidity relationships, not just through issuer-specific reserve headlines.

---

### 5. Recovery is tied to redemption availability

The central interpretive point is that USDC's recovery was not only about reassessing the reserve pool. It was about restoring the credibility and availability of the redemption path.

**Claim supported by the full dashboard:** a fiat-backed stablecoin's peg is a function of arbitrage availability. When redemption rails are unavailable, the peg can become a secondary-market liquidity problem.

---

## Why this belongs in a security / audit portfolio

This is not a smart-contract exploit report. It is a **stablecoin risk analysis** case study.

It shows that stablecoin safety is not only about contract code. It also depends on:

* reserve custody,
* redemption design,
* banking rail availability,
* market-maker behavior,
* DEX liquidity structure,
* and contagion through collateral links.

For stablecoin auditors, risk analysts, and protocol reviewers, this is exactly the bridge between smart contract controls and real-world financial infrastructure.

---

## Final takeaway

A stablecoin peg is not a magic constant. It is a mechanism.

For USDC, the mechanism is backed by reserves, but enforced in the market through arbitrage. The March 2023 event showed that when the arbitrage path depends on off-chain settlement rails, the peg can fail temporarily even when the asset is not fundamentally insolvent.
