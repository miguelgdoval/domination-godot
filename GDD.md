# Domination — Game Design Document

> A domino-based roguelike inspired by Balatro. Build chains, score points, survive rounds, and craft a build that multiplies your way to victory.

---

## Table of Contents

1. [Core Concept](#core-concept)
2. [Core Loop](#core-loop)
3. [Domino Tiles](#domino-tiles)
4. [Scoring System](#scoring-system)
5. [Round Structure](#round-structure)
6. [Progression & Difficulty](#progression--difficulty)
7. [Scoring Targets](#scoring-targets)
8. [Item Types](#item-types)
9. [Rarity System](#rarity-system)
10. [Shop System](#shop-system)
11. [Economy](#economy)
12. [Artifact Slots](#artifact-slots)
13. [Contracts](#contracts)
14. [Starting Boxes](#starting-boxes)
15. [Boss Fights](#boss-fights)
16. [Seed Content — Examples](#seed-content--examples)

---

## Core Concept

Domination is a single-player roguelike where you play chains of domino tiles to hit a score target each round. Between rounds you visit a shop to buy tiles, artifacts, and contracts that upgrade your build. Every 4 rounds you face a boss with a special negative effect. Die if you miss a target. Win if you survive all antes.

---

## Core Loop

```
Start run → Choose starting box
  └─ Round
       ├─ Play hands (chains of tiles) to accumulate points
       ├─ Hit the target → survive, earn coins, visit shop
       ├─ Miss the target → game over
       └─ Every 4 rounds: Boss round (modified effects)
            └─ After boss: Artisan Shop (instead of normal shop)
```

---

## Domino Tiles

- **Set:** Double-9 (tiles 0|0 through 9|9 — 55 unique tiles)
- **Default box:** All 55 tiles × 2 = 110 tiles total
- **Hand size:** 5 tiles (can be modified by artifacts or starting box)
- **Box replenishes:** Fully at the start of each round (not each hand)
- **Unplayed tiles:** Stay in hand between hands within the same round
- **Drawing:** After each hand, draw from the box until hand is full (5 tiles)

### The Blank (0) Tile
The blank side counts as 0 pips (no chip contribution) but acts as a **wild connector** — it can connect to any number. This makes blank-heavy tiles useful for keeping chains alive at the cost of scoring nothing on that side.

---

## Scoring System

Each hand you play a chain of dominoes (classic style: matching edges must share the same number). The score for a hand is:

```
Score = Total Pips × Multiplier
```

### Chips (Total Pips)
- Sum of **all pip values** on every tile in the chain
- Example: `2|3 — 3|5 — 5|4` = 2+3+3+5+5+4 = **22 chips**

### Multiplier Bonuses (stack additively, then apply as ×)
| Condition | Bonus |
|---|---|
| Base | ×1 |
| Each **double** in the chain | +1 mult |
| Chain length ≥ 4 tiles | +1 mult |
| Chain length ≥ 7 tiles | +2 mult total (replaces the ≥4 bonus) |

### Example
Chain: `2|3 — 3|4 — 4|4 — 4|1`
- Pips: 2+3+3+4+4+4+4+1 = **25 chips**
- Bonuses: 1 double (4|4) = +1 mult → **×2**
- Hand score: 25 × 2 = **50 points**

### Score Accumulation
Points from **all hands in a round** are summed together and compared against the round target. You do not need to hit the target in a single hand.

---

## Round Structure

- **Hands per round:** 4 (baseline — can be modified by starting box or artifacts)
- **Discards per round:** 2 (baseline — discard any tiles from your hand back to the box, draw replacements)
- **Minimum chain length:** 1 (you can play a single tile if you cannot connect)
- **Chain shape:** Single line only (no branching)

---

## Progression & Difficulty

| Difficulty | Antes | Rounds per Ante | Total Rounds | Bosses |
|---|---|---|---|---|
| Normal | 3 | 4 rounds + 1 boss | 15 | 3 |
| Hard | 4 | 4 rounds + 1 boss | 20 | 4 |

A run ends in victory when you survive the final boss of the final ante.

---

## Scoring Targets

### Normal (3 Antes)

| Round | Target |
|---|---|
| **Ante 1** | |
| 1 | 150 |
| 2 | 250 |
| 3 | 400 |
| 4 | 600 |
| Boss 1 | 900 |
| **Ante 2** | |
| 5 | 1,400 |
| 6 | 2,000 |
| 7 | 3,000 |
| 8 | 4,500 |
| Boss 2 | 6,500 |
| **Ante 3** | |
| 9 | 9,000 |
| 10 | 13,000 |
| 11 | 19,000 |
| 12 | 27,000 |
| Boss 3 | 40,000 |

### Hard (4 Antes) — adds Ante 4

| Round | Target |
|---|---|
| 13 | 58,000 |
| 14 | 82,000 |
| 15 | 120,000 |
| 16 | 170,000 |
| Boss 4 | 250,000 |

---

## Item Types

### 1. Tiles
Domino tiles added permanently to your box. Common tiles are standard double-9 pieces. Rare tiles have special properties (see Rarity System and Seed Content).

### 2. Artifacts
Passive items that modify your scoring, economy, or gameplay rules. Equipped to artifact slots — they persist for the whole run once equipped. Inspired by Balatro's jokers.

### 3. Contracts
Objectives that reward you upon completion. You pick them from a pool in the shop (or via artifact effects). They expire after a fixed number of rounds whether completed or not. You can hold a maximum of **2 contracts** at once (expandable by artifact).

---

## Rarity System

Four rarities, themed to domino materials:

| Rarity | Theme | Shop Cost | Sell Value |
|---|---|---|---|
| **Bone** | Common | 2 chains | 1 chain |
| **Carved** | Uncommon | 4 chains | 2 chains |
| **Ivory** | Rare | 6 chains | 3 chains |
| **Obsidian** | Legendary | 8 chains | 4 chains |

Rarity applies to all item types: tiles, artifacts, and contracts.

---

## Shop System

### Normal Shop
- Appears after every non-boss round
- **3 item slots** — random items from any type and any rarity
- Refreshes fully between rounds (not mid-round)
- You can sell items (tiles, artifacts, contracts) back at any point during the shop phase

### Artisan Shop
- Appears after every boss round — **replaces** the normal shop
- **2 item slots only**
- Slot 1: guaranteed **Ivory** (rare) item
- Slot 2: guaranteed **Obsidian** (legendary) item
- No Bone or Carved items ever appear here

---

## Economy

- **Currency:** Chains (thematic coin)
- **Starting coins:** 0
- **Earning coins:**
  - Complete a round: **+3 chains** base
  - Unused hands: **+1 chain** per hand not used (reward for efficiency)
  - Boss round completion bonus: **+2 chains** extra
- **Spending:** Buy items in the shop
- **Selling:** Sell any owned item back during shop phase for its sell value

---

## Artifact Slots

- **Base slots:** 4
- **Maximum slots:** 6 (unlocked via specific Obsidian artifact or certain starting boxes)
- Artifacts fill slots in order. If all slots are full you must sell one to buy another.

---

## Contracts

- **Hold limit:** 2 at a time (can be increased by artifact)
- **Expiry:** Each contract states its duration — 2 or 3 rounds from when it was acquired
- **Rewards:** Anything — coins, tiles, artifacts, or additional contracts. Kept random and varied deliberately
- **Acquisition:** Bought in the shop like any other item, or granted by artifact effects
- **Failure:** If a contract expires unfinished, it disappears with no penalty beyond the lost opportunity and original cost

---

## Starting Boxes

8 starting boxes planned. The default box is available from the start; others are unlocked through play.

| Box | Description |
|---|---|
| **Standard** | All 55 double-9 tiles × 2. No artifacts. 4 hands, 2 discards. The baseline. |
| **Specialist** | Only tiles containing 6, 7, 8, or 9. Fewer tiles but higher average pips. Starts with 1 Carved artifact that boosts scoring for high-pip chains. |
| **The Arsenal** | Normal tile set but starts with 2 Bone artifacts already equipped. |
| **The Runner** | Normal tile set but starts with 3 contracts and 4 extra chains. Contract hold limit starts at 3. |
| **Slimline** | Half the tiles (one copy of each, 55 total) but +1 hand per round and +1 discard per round. |
| **Blank Slate** | Box is heavily weighted toward blank (0) tiles. Starts with an artifact that makes blanks score based on chain length instead of pips. |
| **The Double** | Only double tiles (0|0 through 9|9 = 10 tiles × 4 copies). Chains are harder to form but every tile is a double. |
| **Obsidian Box** | Normal tile set, starts with 1 Obsidian artifact, but shop prices are +2 chains for the whole run. |

---

## Boss Fights

Boss rounds use the normal round mechanics but add one **special effect** that lasts only for that round. The effect is revealed at the start of the round.

Effects are negative, random, or mixed. Examples:

| Boss Effect | Description |
|---|---|
| **The Mute** | Doubles score 0 pips this round (the double bonus mult still applies) |
| **Short Chain** | Hand size reduced to 3 tiles |
| **Tax Collector** | You lose 2 chains regardless of outcome |
| **The Fog** | Tile pip values are hidden until played |
| **Scramble** | Your box is reshuffled and you draw a new random hand (existing hand discarded, no discard charge) |
| **Heavy Target** | The round target is ×1.5 |
| **Lockout** | Discards are disabled this round |
| **The Swap** | High and low pips are inverted (9 scores as 1, 1 scores as 9, etc.) |

Future direction: reactive boss mechanics where the boss "plays against you" — e.g. the boss removes one tile from your hand before each hand you play.

---

## Seed Content — Examples

### Example Artifacts

**Bone — The Linker**
> At the start of each hand, one random tile in your hand becomes a wild tile (connects to any number) for that hand only.

**Carved — The Accumulator**
> After each completed hand, carry over +1 mult bonus to the next hand. Resets at the start of each round.

**Ivory — Chain Reaction**
> Every chain of 5 or more tiles gives +3 mult instead of the standard length bonus.

**Obsidian — The Dominator**
> Doubles score double their pip value (e.g. 6|6 counts as 24 chips instead of 12). +1 artifact slot.

---

### Example Rare Tiles

**Ivory Tile — The Ghost (0|0)**
> When played, The Ghost copies the pip value of the tile it connects to on both sides for scoring purposes. Still scores 0 if played alone.

**Obsidian Tile — The Crown (9|9)**
> Counts as any number for connection purposes. Scores 9+9 = 18 chips. If played as a double, grants +3 mult instead of +1.

---

### Example Contracts

**Bone Contract — Long Road** (2 rounds)
> Play a chain of 5 or more tiles in a single hand.
> Reward: 4 chains

**Carved Contract — Double Down** (2 rounds)
> Include 3 or more doubles in chains across a single round.
> Reward: 1 random Ivory item

**Ivory Contract — The Blank Run** (3 rounds)
> Complete a full round using at least one blank tile in every hand.
> Reward: 1 random Obsidian item or 8 chains (random choice)

---

## Open Questions / Future Scope

- Branching paths between rounds (risk/reward route choices)
- Interactive boss mechanics (reactive decisions)
- Unlockable starting boxes (progression meta-layer)
- Achievements / run challenges
- Full catalogue of artifacts, tiles, and contracts per rarity
- Sound design and visual identity (Bone/Ivory/Obsidian aesthetic)
