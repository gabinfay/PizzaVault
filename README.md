# YIELDERITA
<img width="3000" height="1000" alt="banner" src="https://github.com/user-attachments/assets/161d2898-2de5-4923-a6b4-3bca20f80862" />

A **pizza-aware DeFi vault** that routes user deposits into [Lazy Summer Protocol](https://summer.fi) strategies, flipping between **ETH Higher Risk** and **USDC Lower Risk** vaults based on the [Pentagon Pizza Index](https://pizzint.watch) (PizzINT) signals.

[Demo App]() | [MockUp/UI-UX](https://github.com/gabinfay/PizzaVault/blob/main/UI-UX-MockUp.md) | [Slide Deck](https://github.com/gabinfay/PizzaVault/blob/main/SLIDEDECK.md) | [Taikai](https://taikai.network/ethtokyo/hackathons/hackathon-2025/projects/cmfk8u72a04lm9gzupebp3i29/idea)

---

## Overview

- **ETH deposit** supported only.
- **Risk-On / Risk-Off** strategy allocation triggered by live PizzINT signals.
- Visual dashboard shows allocation as pizza slices.
- Demo-ready using PizzINT watch feed for signals.
- Signals are utilized for automatic strategy rebalancing.

![Yielderitaanim-ezgif com-resize](https://github.com/user-attachments/assets/8c02296b-4553-45c1-af3b-bb8da1fcb48b)


---

## Architecture

1. **PizzaVault Contract**
   - Accepts deposits.
   - Allocates funds to **Lazy Summer Protocol** vaults based on `pizzaSignal`.
   - Rebalances automatically when pizza index changes.

2. **Signal Adapter**
   - Fetches pizza index level from [PizzINT](https://www.pizzint.watch/).
   - Updates on-chain `pizzaSignal` variable via a simple oracle.

3. **Frontend Dashboard**
   - React/Next.js app.
   - Pizza-slice visualization for vault allocation.
   - Shows live pizza index and portfolio breakdown.
  
---

## User Flow
<img width="1512" height="982" alt="user flow" src="https://github.com/user-attachments/assets/2294d3ce-ad19-4597-b944-8c5258f718d7" />

---

## Tech Stack

- `Solidity` (custom PizzaVault smart contract)
- `Lazy Summer Protocol` vaults
- `Chainlink` Functions
- `Next.js` + `Tailwind` CSS frontend
- `Ethers.js` for contract interactions

---

### Smart Contracts List

| Contract | Address | Network |
|----------|---------|---------|
| `PizzaVault.sol` | [0xXXX]() | Base |

---

## Built for ETHTokyo 2025 and PizzaDAO x Ethreactor Mini Hackathon

Baked with Fresh Data, Served Hot with DeFi Yield.
