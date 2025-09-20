# BitArena – Competitive Gaming Protocol

## Overview

**BitArena** is a competitive gaming protocol built on **Bitcoin Layer 2 via Stacks**. It introduces decentralized, skill-based tournaments where players can:

* Compete in structured games with **verifiable scoring**.
* Earn and trade **unique NFT-based game assets**.
* Participate in **BTC-backed prize pools** with automated distribution.

The protocol ensures **fair play, transparent leaderboards, secure asset ownership**, and **trustless reward distribution**, powered by Clarity smart contracts.

---

## System Overview

The protocol is designed around three pillars:

1. **Skill-Based Gaming:**
   Players register, pay entry fees, and compete in tournaments. Scores are updated on-chain by authorized game admins.

2. **Game Asset Economy:**

   * Assets are represented as **non-fungible tokens (NFTs)**.
   * Each NFT has metadata: name, description, rarity, and power-level.
   * Assets can be **minted, owned, and transferred** securely.

3. **BTC Prize Pools:**

   * Player entry fees accumulate into the prize pool.
   * Rewards are distributed automatically based on leaderboard rankings.
   * Scoring and payout logic is **fully transparent**.

---

## Contract Architecture

### Error Constants

Predefined error codes standardize failure cases (`ERR-NOT-AUTHORIZED`, `ERR-INVALID-INPUT`, etc.), ensuring predictable outcomes.

### Protocol Configuration

* **Game Fee (`game-fee`)**: Entry fee for players.
* **Max Leaderboard Entries (`max-leaderboard-entries`)**: Caps leaderboard size.
* **Prize Pool (`total-prize-pool`)**: Tracks cumulative rewards.
* **Game Assets (`total-game-assets`)**: Tracks NFT issuance.

### NFTs

* `game-asset`: Core NFT standard.
* `game-asset-metadata`: Metadata registry for each asset.

### Leaderboard

* Maps players to stats: `score`, `games-played`, `total-rewards`.
* Used for ranking and distributing rewards.

### Admin Whitelist

* Controlled by `game-admin-whitelist`.
* Admins manage games, assets, and player scores.

---

## Key Functions

### Administration

* `add-game-admin`: Adds new admin (whitelisted).
* `initialize-game`: Sets entry fees and max leaderboard entries.

### Assets

* `mint-game-asset`: Issues NFTs with metadata.
* `transfer-game-asset`: Transfers ownership securely.

### Players

* `register-player`: Registers new players, deducts entry fees.
* `update-player-score`: Updates leaderboard stats (admin-only).

### Rewards

* `distribute-bitcoin-rewards`: Iterates through valid candidates, allocates rewards based on performance.
* `calculate-reward`: Proportional payout logic based on score.

---

## Data Flow

1. **Registration:**

   * Player registers → Pays entry fee → Added to leaderboard with baseline stats.

2. **Gameplay:**

   * Admin updates player scores via `update-player-score`.
   * Stats evolve with each participation (score + games played).

3. **NFT Asset Economy:**

   * Admins mint assets → Players hold or trade assets.
   * NFTs may influence gameplay (e.g., power-level).

4. **Reward Distribution:**

   * Admin triggers `distribute-bitcoin-rewards`.
   * Protocol checks top performers → Calculates rewards → Updates player totals.

---

## Security Considerations

* **Admin Whitelisting:** Prevents unauthorized control over scoring and asset issuance.
* **Safe Principals:** Validates principals before transfers or admin actions.
* **Transparent Prize Logic:** Prize distribution logic is fully on-chain.
* **Immutable Assets:** NFTs follow standard Clarity non-fungible-token semantics.

---

## Deployment Notes

* Upon deployment, **contract deployer is set as initial admin**.
* Additional admins may be added via `add-game-admin`.
* Ensure correct initialization with `initialize-game` before onboarding players.

---

## Future Extensions

* Support for **multi-tier tournaments** with varied prize pools.
* Integration with **oracles** for off-chain score verification.
* Expanded NFT utility (skins, power-ups, rarity multipliers).
* Decentralized governance for community-driven rule updates.
