# Domination — Game Design Document

> A domino-based roguelike inspired by Balatro. Build chains, score Chronos, survive the Entropy, and Recalibrate the Perpetual Chronometer.

---

## Table of Contents

1. [World & Lore](#world--lore)
2. [Lore Glossary](#lore-glossary)
3. [Core Concept](#core-concept)
4. [Core Loop](#core-loop)
5. [Etapas (Stages)](#etapas-stages)
6. [Domino Tiles](#domino-tiles)
7. [Scoring System](#scoring-system)
8. [Round Structure](#round-structure)
9. [Progression & Difficulty](#progression--difficulty)
10. [Scoring Targets](#scoring-targets)
11. [Item Types](#item-types)
12. [Rarity System](#rarity-system)
13. [Shop System](#shop-system)
14. [Economy](#economy)
15. [Artifact Slots](#artifact-slots)
16. [Contracts](#contracts)
17. [Calibration Cores (Starting Boxes)](#calibration-cores-starting-boxes)
18. [Protocols](#protocols)
19. [Boss Fights — Entropy Failures](#boss-fights--entropy-failures)
20. [Event Terminal — The Archiver](#event-terminal--the-archiver)
21. [Seed Content — Examples](#seed-content--examples)
22. [Open Questions / Future Scope](#open-questions--future-scope)

---

## World & Lore

### The Universe: The Perpetual Chronometer

The universe is the **Perpetual Chronometer** (*El Cronómetro Perpétuo*) — a vast, impossibly complex clockwork machine that holds the very fabric of reality together. Time is not abstract here; it is a geared substance that flows in ordered cycles. The Chronometer maintains this order.

The Machine is perfect. It is also dying.

### The Player: The Trial Operator

You are not a hero. You are **The Trial Operator** (*El Operario de Ensayo*) — a highly qualified engineer recruited into the **Society of Time Architects**, a secret organization responsible for maintaining the Chronometer.

Your task is precise and critical: take a seat at the **Observation Window** (*La Ventana de Observación del Tiempo*) — the play table — and run timeline simulations. Each simulation tests the Machine's resistance to structural failure. If the simulation holds, the Machine learns. If it collapses, the data is preserved and the simulation resets.

You are not unique. You are indispensable.

When a run fails, the game does not say "Game Over." It says:

> **SIMULATION FAILURE. REINITIALIZING PROTOCOL. OPERATOR REMAINS AVAILABLE.**

### The Conflict: Entropy

The Machine suffers from chronic **Entropy** — a structural decay that cannot be stopped, only managed. The Entropy manifests in the simulations as increasing resistance, impossible targets, and corrupted flow states.

The **Entropy Failures** (*Fallas de Entropía*) — the Bosses — are physical manifestations of the Machine's worst paradoxes. You do not destroy them. You **isolate** them, extracting a Mastery that strengthens future simulations.

The ultimate goal, across many runs, is to **Recalibrate the Perpetual Chronometer** and prevent the universe from collapsing into chaos.

### Key NPCs

| Name | Role | Personality |
|---|---|---|
| **The Archiver** (*El Archivero*) | Custodian of the Machine's knowledge. Lives outside normal time flow. Appears during the Event Terminal to offer powerful bargains. | Cold, methodical, obsessed with symmetry. Speaks in clean formal text. Represented by a single crystal optical eye on a brass panel. |
| **The Voice of the Emporium** (*La Voz del Emporio*) | AI commercial system of the Brass Emporium. Facilitates all in-run purchases. | Neutral, efficient, slightly uncanny. |
| **The Renegade Mechanic** (*El Mecánico Renegado*) | Sells illegal Calibration Modules — powerful items that bend the rules of the simulation. | Chaotic, irreverent, knows more than he admits. |
| **The Master of the Forge** (*El Maestro de la Forja*) | Runs the Artisan's Workshop. The one who teaches the Operator to build better modules. | Precise, demanding, respectful of craft. |
| **The Copper Guild** (*El Gremio del Cobre*) | Controls the temporal economy — the flow of Monedas. Background faction, appears in event lore. | Institutional, transactional, amoral. |

---

## Lore Glossary

| Game Term | Lore Name | Description |
|---|---|---|
| Run | **Trial Cycle** (*Ciclo de Ensayo*) | A single complete simulation of a timeline |
| Antes / Stages | **Etapas** | Grouped phases of a Trial Cycle, each with distinct table aesthetics |
| Round | **Ronda** | The smallest unit of play — one scoring attempt |
| Score | **Chronos** | The temporal energy extracted from a stable chain |
| Coins | **Monedas** | Stable byproducts of Chronos — spendable at shops |
| Domino tiles | **Temporal Flow Components** (*Componentes de Flujo Temporal*) | Each tile represents a logic gear in the Machine's processing core |
| Hand | **Isolation Chamber** (*Cámara de Aislamiento*) | Where flow components are held before insertion |
| Play area | **Processing Core** (*Núcleo de Procesamiento*) | The active simulation zone |
| Chain | **Cohesion Pulse** (*Pulso de Cohesión*) | A stable sequence of aligned temporal flows |
| Artifacts | **Calibration Modules** (*Módulos de Calibración*) | Technological hacks inserted into the simulation to bend its rules |
| Contracts | **Directives** (*Directivas*) | Assigned objectives with rewards upon completion |
| Starting Box | **Calibration Core** (*Núcleo de Calibración*) | The configuration defining the Operator's starting state |
| Difficulty modifier | **Protocol** (*Protocolo de Ensayo*) | A fundamental rule distorting the simulation |
| Normal Shop | **The Brass Emporium** (*El Emporio de Latón*) | The automated commercial terminal |
| Artisan Shop | **The Artisan's Workshop** (*El Taller del Artesano*) | The Forge — appears after every Entropy Failure (Boss) |
| Boss | **Entropy Failure** (*Falla de Entropía*) | A structural paradox manifesting in the simulation |
| Death / Fail | **Simulation Failure** | The simulation collapses; data preserved, Operator redeployed |
| Victory | **Recalibration** | The Chronometer stabilizes — the run is a success |

---

## Core Concept

Domination is a single-player roguelike where the player runs timeline simulations inside the Perpetual Chronometer. Each simulation (*Trial Cycle*) is played as a series of domino chain-building rounds. Build Cohesion Pulses from Temporal Flow Components, generate Chronos, and hit the target to survive each Ronda.

Between rounds, visit shops to upgrade your configuration. Every 4 rounds face an Entropy Failure — a Boss with a special negative effect. Fail to hit a target and the simulation collapses. Survive all rounds and the Chronometer is Recalibrated.

The player is a blank slate — anonymous, purposeful, defined by their function. The story is told through item descriptions, cryptic NPC dialogue, and the Machine itself.

---

## Core Loop

```
Start Trial Cycle → Choose Calibration Core → (Choose Protocol)
  └─ Ronda
       ├─ Build Cohesion Pulses from Isolation Chamber tiles
       ├─ Generate Chronos across all hands
       ├─ Hit Chronos target → survive, earn Monedas, visit Emporium
       ├─ Miss target → Simulation Failure (Game Over)
       └─ Every 4 rounds: Entropy Failure (Boss)
			└─ After boss: Artisan's Workshop (replaces Emporium)
				  └─ (Optional) Event Terminal — The Archiver appears
```

---

## Etapas (Stages)

A Trial Cycle is divided into **Etapas** — grouped phases each with distinct visual identity. The table itself changes aesthetics with each Etapa.

| Etapa | Name | Table Aesthetic | Difficulty |
|---|---|---|---|
| 1 | **The Mahogany Trial** (*El Ensayo de la Caoba*) | Polished mahogany, brass fittings, warm candlelight | Entry — basic mechanics, low Chronos targets |
| 2 | **The Industrial Load** (*La Carga Industrial*) | Steel and steam, copper pipes, industrial lamps | Mid — risk/reward mechanics introduced |
| 3 | **The Cold Singularity** (*La Singularidad Fría*) | Black obsidian, neon green accents, cold white light | Advanced — Entropy at maximum, high targets |
| 4 | **The Archiver's Core** (*El Núcleo del Archivero*) | Ancient paper, brass, encrypted glyphs | Hard mode only — final Entropy Failure |

Normal difficulty (3 Etapas): Mahogany → Industrial → Cold Singularity
Hard difficulty (4 Etapas): adds The Archiver's Core

---

## Domino Tiles

### The Tiles in Lore

Domino tiles are **Temporal Flow Components** — logic gears encoding a fragment of a timeline. The pip value on each side (e.g. a 6) represents the **Chronos Charge** — the stability value of that temporal data stream. The pip value is not decorative; it is the raw energy of that flow.

Your **Isolation Chamber** (hand) holds these components ready for insertion into the **Processing Core** (the play area). When you place a tile, you are not playing a game piece — you are routing a temporal data stream into the Machine's active simulation.

### Technical Specs

- **Set:** Double-9 (tiles 0|0 through 9|9 — 55 unique tiles)
- **Default Calibration Core:** All 55 tiles × 2 = 110 tiles total
- **Isolation Chamber size:** 5 tiles (can be modified)
- **Box replenishes:** Fully at the start of each Trial Cycle round (not each hand)
- **Unplayed tiles:** Stay in hand between hands within the same round
- **Drawing:** After each hand, draw from the box until hand is full

### The Blank (0) Tile

The blank side encodes **zero Chronos** (0 chips) but acts as a **Universal Connector** — it can link to any numbered flow in the chain. Blank-heavy tiles are useful for keeping chains alive at the cost of scoring nothing on that side. In lore: a dormant flow node that accepts any input signal.

---

## Scoring System

Each hand you build a Cohesion Pulse — a chain of dominoes connected classic-style (matching edges must share the same pip value). The Chronos generated by a hand is:

```
Chronos = Total Pips × Multiplier
```

### Chips (Total Pips — Raw Chronos)
Sum of **all pip values** on every tile in the chain.
- Example: `2|3 — 3|5 — 5|4` = 2+3+3+5+5+4 = **22 chips**

### Multiplier Bonuses (additive, then applied as ×)
| Condition | Bonus | Lore Explanation |
|---|---|---|
| Base | ×1 | Baseline signal coherence |
| Each **double** in the chain | +1 mult | Resonance loop — a self-referential flow amplifies the signal |
| Chain length ≥ 4 tiles | +1 mult | Extended cohesion — a sustained pulse stabilizes the output |
| Chain length ≥ 7 tiles | +2 mult (replaces ≥4) | Maximum coherence — a perfect temporal alignment |

### Example
Chain: `2|3 — 3|4 — 4|4 — 4|1`
- Pips: 2+3+3+4+4+4+4+1 = **25 chips**
- 1 double (4|4) = +1 mult → **×2**
- Hand Chronos: 25 × 2 = **50 Chronos**

### Chronos Accumulation
Chronos from **all hands in a round** is summed and compared against the round target. You do not need to reach the target in a single hand.

---

## Round Structure

- **Hands per round:** 4 (baseline — modifiable by Calibration Core or Modules)
- **Discards per round:** 2 (baseline)
- **Minimum chain length:** 1 (a single tile can be played if no connections exist)
- **Chain shape:** Single line only (no branching)
- **Discard mechanic:** Return tiles to the box, draw replacements immediately

---

## Progression & Difficulty

| Difficulty | Etapas | Rounds per Etapa | Total Rounds | Entropy Failures |
|---|---|---|---|---|
| Normal | 3 | 4 rounds + 1 Boss | 15 | 3 |
| Hard | 4 | 4 rounds + 1 Boss | 20 | 4 |

A Trial Cycle ends in **Recalibration** when the final Entropy Failure of the final Etapa is survived.

---

## Scoring Targets

### Normal (3 Etapas)

| Round | Target | Etapa |
|---|---|---|
| 1 | 150 | Mahogany |
| 2 | 250 | Mahogany |
| 3 | 400 | Mahogany |
| 4 | 600 | Mahogany |
| **Boss 1** | **900** | **Mahogany** |
| 5 | 1,400 | Industrial |
| 6 | 2,000 | Industrial |
| 7 | 3,000 | Industrial |
| 8 | 4,500 | Industrial |
| **Boss 2** | **6,500** | **Industrial** |
| 9 | 9,000 | Cold Singularity |
| 10 | 13,000 | Cold Singularity |
| 11 | 19,000 | Cold Singularity |
| 12 | 27,000 | Cold Singularity |
| **Boss 3** | **40,000** | **Cold Singularity** |

### Hard adds Etapa 4 (Archiver's Core)

| Round | Target |
|---|---|
| 13 | 58,000 |
| 14 | 82,000 |
| 15 | 120,000 |
| 16 | 170,000 |
| **Boss 4** | **250,000** |

---

## Item Types

### 1. Temporal Flow Components (Tiles)
Domino tiles added permanently to your box. Standard tiles are base double-9 pieces. Rare tiles have special properties — wild connectors, amplified scoring, or unique chain effects.

### 2. Calibration Modules (Artifacts)
Passive items that modify scoring, economy, or simulation rules. Equipped to Module slots — persist for the full Trial Cycle. Acquired at the Brass Emporium or Artisan's Workshop.

### 3. Directives (Contracts)
Assigned objectives with rewards. Purchased at the Emporium or granted via event/module effects. You hold a maximum of 2 Directives at once (expandable). They expire after a set number of rounds.

---

## Rarity System

Four tiers of item quality — named for the materials of antique clockwork:

| Rarity | Material | Shop Cost | Sell Value |
|---|---|---|---|
| **Bone** | Common — basic carved bone fittings | 2 Monedas | 1 Moneda |
| **Carved** | Uncommon — detailed engraved brass | 4 Monedas | 2 Monedas |
| **Ivory** | Rare — polished ivory inlay | 6 Monedas | 3 Monedas |
| **Obsidian** | Legendary — volcanic glass, unstable chronite veins | 8 Monedas | 4 Monedas |

Applies to all item types: tiles, Calibration Modules, and Directives.

---

## Shop System

### The Brass Emporium (*El Emporio de Latón*)
The automated commercial terminal. Present after every non-boss round.
- **3 item slots** — random items, any type, any rarity
- Refreshes fully between rounds
- Items purchased with in-run **Monedas**
- Sell any owned item back at any point during the shop phase

*In lore: not a physical store. A temporal intersection point — a window into a different part of the Machine where the Operator can exchange resources.*

### The Artisan's Workshop (*El Taller del Artesano*)
The Forge. Appears after every Entropy Failure (Boss) — **replaces** the Emporium that round.
- **2 item slots only**
- Slot 1: guaranteed **Ivory** (Rare) item
- Slot 2: guaranteed **Obsidian** (Legendary) item
- No Bone or Carved items ever appear here
- Purchased with in-run **Monedas**

---

## Economy

- **Currency:** Monedas (stable Chronos byproducts — the residual energy of a successful simulation)
- **Starting Monedas:** 0
- **Earning Monedas:**
  - Complete a round: **+3 Monedas** base
  - Unused hands: **+1 Moneda** per hand not used (efficiency reward)
  - Entropy Failure completion bonus: **+2 Monedas** extra
- **Spending:** Buy items at the Emporium or Workshop
- **Selling:** Sell owned items during shop phase for their sell value

---

## Artifact Slots (Module Slots)

- **Base slots:** 4
- **Maximum slots:** 6 (unlocked via specific Obsidian Module or certain Calibration Cores)
- Modules fill slots in order. When full, a Module must be sold to buy a new one.

---

## Contracts (Directives)

- **Hold limit:** 2 at a time (expandable via Module)
- **Expiry:** 2 or 3 rounds from acquisition (stated on the Directive)
- **Rewards:** Random — Monedas, tiles, Modules, or additional Directives
- **Acquisition:** Purchased at the Emporium, or granted by Module effects or Archiver events
- **Failure:** Expired Directive disappears with no penalty beyond the lost opportunity and cost

---

## Calibration Cores (Starting Boxes)

A **Calibration Core** is the configuration the Operator inserts at the start of each Trial Cycle. It defines the starting tile composition, advantages, and any special rules for that run. 8 Cores are planned; one is available from the start.

| Core | Starting Configuration | Strategy |
|---|---|---|
| **Standard Core** | All 55 double-9 tiles × 2. No modules. 4 hands, 2 discards. | The baseline — learn the Machine. |
| **Specialist Core** | Only tiles containing 6, 7, 8, or 9. Fewer tiles, higher average pips. Starts with 1 Carved module boosting high-pip chains. | High-roll, high-risk. |
| **The Arsenal** | Normal tile set but starts with 2 Bone modules already equipped. | Module-driven from round 1. |
| **The Runner** | Normal tile set, starts with 3 Directives and 4 extra Monedas. Directive hold limit starts at 3. | Contract specialist. |
| **Slimline** | Half the tiles (one copy of each, 55 total). +1 hand per round, +1 discard per round. | Speed and flexibility over depth. |
| **Blank Slate** | Box heavily weighted toward blank (0) tiles. Starts with a module that makes blanks score based on chain length. | Unusual flow — hard to master. |
| **The Double** | Only double tiles (10 tiles × 4 copies). Chains are harder to form but every tile is a double (+1 mult each). | Pure multiplier build. |
| **Obsidian Core** | Normal tile set, starts with 1 Obsidian module, but Emporium prices are +2 Monedas for the whole run. | Power at a cost. |

---

## Protocols

A **Protocol** (*Protocolo de Ensayo*) is a fundamental rule distortion selected at the start of a Trial Cycle alongside the Calibration Core. Protocols are unlocked sequentially by completing previous ones, and add a narrative layer to the simulation's instability.

Protocols provide no starting advantage — they modify the fundamental rules of play, making each run feel mechanically distinct.

### Standard Protocols (Unlocked Sequentially)

| Protocol | Rule | Lore |
|---|---|---|
| **P-0: Nominal** | No modifications. The standard simulation. | "Baseline stability. Nominal temporal conditions." |
| **P-1: Flux** | At the start of each round, one random tile in your hand has its pip values swapped. | "Minor flux in the processing core. Data values oscillating." |
| **P-2: Erosion** | Each round, the first tile you play disappears from your box permanently after the round. | "Entropy erosion detected. Flow components degrading with each use." |
| **P-3: Unstable** | After each hand, one random tile in your box is destroyed. | "Critical instability. Temporal flows disintegrating mid-simulation." |
| **P-4: Asymmetric** | Hand size is reduced by 1, but scoring targets are reduced by 15%. | "Spatial distortion in the processing core. Configuration misaligned." |

### Challenge Protocols (Unlocked by Achievement)

Extreme isolated simulations that test the Operator's mastery. First completion rewards a permanent Mastery or a powerful Calibration Core.

| Protocol | Restriction | Lore |
|---|---|---|
| **P-D1: Chain Fusion** | Only one Cohesion Pulse per round. It must be ≥ 5 tiles. | "The Chronometer cannot handle discrete flows. It demands a single, perfect Cohesion Pulse." |
| **P-D2: Chronos Debt** | Start with -20 Monedas. End any round with negative Monedas and fail. | "The simulated timeline is in energy deficit. Begin repaying the Copper Guild immediately." |
| **P-D3: Silent Paradox** | Global multiplier is fixed at ×1. All Chronos gain must come from base pip values or fixed-bonus Modules. | "Entropy noise is too high. All amplifiers are damaged. Precision only." |
| **P-D4: The Archiver's Test** | Tile pip values are hidden until played. | "The Archiver has encrypted all flow data. Learn the truth of each component through trial and consequence." |

---

## Boss Fights — Entropy Failures

Every 5th round (*the boss round of each Etapa*) is an **Entropy Failure** — a structural paradox manifesting in the simulation. Mechanically it is a normal round with a higher Chronos target and one **special effect** revealed at the start.

Entropy Failure effects are negative, random, or mixed:

| Effect | Description | Lore |
|---|---|---|
| **The Mute** | Doubles score 0 pips this round (double mult bonus still applies) | "Self-referential flows are being suppressed. Resonance loops neutralized." |
| **Short Chain** | Hand size reduced to 3 tiles | "Isolation Chamber partially corrupted. Reduced capacity." |
| **The Tax** | Lose 2 Monedas regardless of outcome | "The Copper Guild is extracting a toll from this unstable node." |
| **The Fog** | Tile pip values are hidden until played | "Sensor array offline. Flow values unreadable until insertion." |
| **Scramble** | Box reshuffled, current hand discarded (no discard charge) | "Full memory wipe of active flows. Re-initializing from archive." |
| **Heavy Target** | Round target ×1.5 | "Entropy spike detected. Recalibration threshold elevated." |
| **Lockout** | Discards disabled this round | "Isolation Chamber sealed. No ejection possible." |
| **The Inversion** | High and low pips inverted (9 scores as 1, 1 scores as 9, etc.) | "Signal polarity reversed. All Chronos values have been mirrored." |

*Future direction: reactive Entropy Failures where the boss actively intervenes — removing tiles from the Isolation Chamber before each hand.*

---

## Event Terminal — The Archiver

*Full design is future scope — architecture should support it from the start.*

After certain rounds, there is a chance that the **Event Terminal** activates. The Archiver contacts the Operator with a binary or ternary choice — a narrative dilemma with meaningful risk/reward tradeoffs.

**Design principles:**
- Events are not random gifts. They always involve a cost or a risk.
- The Archiver does not explain himself. His offers are stated, not argued.
- Event text is cold, formal, minimal — matching the Archiver's personality.

**Example Event:**

> **TRANSMISSION INCOMING — SOURCE: THE ARCHIVER**
>
> *"I have observed your current flow configuration. One of your components contains an anomaly that interests me. I will compensate you."*
>
> **[A] Transfer the anomalous tile to the Archive.** → Lose 1 random Module tile from your box. Gain 1 Ivory Module.
>
> **[B] Refuse the transaction.** → Nothing happens. The Archiver notes the refusal.
>
> **[C] Counter-offer: sell him information instead.** → Reveal your current Chronos total. Gain 3 Monedas.

---

## Seed Content — Examples

### Example Calibration Modules (Artifacts)

**Bone — The Linker**
> *"Module CB-1. A basic signal bridge. Routes any isolated flow node to the active chain."*
> At the start of each hand, one random tile in your Isolation Chamber becomes a Universal Connector (wild) for that hand only.

**Carved — The Accumulator**
> *"Module CB-7. A Chronos retention coil. Residual signal bleeds forward across hands."*
> After each completed hand, carry +1 mult bonus into the next hand. Resets at the start of each round.

**Ivory — Chain Reaction**
> *"Module CI-4. Resonance amplifier. Detects extended cohesion events and boosts output."*
> Every Cohesion Pulse of 5 or more tiles grants +3 mult instead of the standard chain length bonus.

**Obsidian — The Dominator**
> *"Module CO-9. Illegal. The Renegade Mechanic built this himself. The Archiver would disapprove."*
> Doubles score double their pip value (e.g. 6|6 counts as 24 chips instead of 12). +1 Module slot.

---

### Example Rare Tiles

**Ivory Tile — The Ghost (0|0)**
> *"A dormant node with no intrinsic value — until it finds a signal to mirror."*
> When played, copies the pip value of the tile it connects to on both sides for scoring. Scores 0 if played alone.

**Obsidian Tile — The Crown (9|9)**
> *"Maximum chronos charge. Unstable. Handle with extreme care."*
> Counts as any number for connection purposes. Scores 18 chips. If played as a double, grants +3 mult instead of +1.

---

### Example Directives (Contracts)

**Bone — Long Road** *(2 rounds)*
> Build a Cohesion Pulse of 5 or more tiles in a single hand.
> Reward: 4 Monedas

**Carved — Double Down** *(2 rounds)*
> Include 3 or more doubles in Cohesion Pulses across a single round.
> Reward: 1 random Ivory item

**Ivory — The Blank Run** *(3 rounds)*
> Complete a full round using at least one blank tile in every hand.
> Reward: 1 random Obsidian item or 8 Monedas (random)

---

### Example Entropy Failure Effects (Boss)

See [Boss Fights — Entropy Failures](#boss-fights--entropy-failures) section for full list.

---

## Open Questions / Future Scope

### ✅ Confirmed Decisions

- **Dual startup choice:** Confirmed — player selects both a Calibration Core AND a Protocol at run start
- **Artisan's Workshop currency:** Uses in-run Monedas (simple, no meta-currency layer)
- **Stage aesthetics:** Confirmed — Mahogany → Industrial → Cold Singularity → Archiver's Core (Hard only)

### Future Scope
- Event Terminal full design (The Archiver system)
- Branching path choices between rounds (risk/reward routes)
- Reactive Entropy Failure bosses (boss plays against you)
- Full catalogue of Modules, tiles, and Directives per rarity
- Challenge Protocol unlock achievements
- Full NPC roster and event writing
- Sound design and visual identity (Bone/Ivory/Obsidian/Brass aesthetic)
- Unlockable Calibration Cores progression
