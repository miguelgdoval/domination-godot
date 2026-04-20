# DOMINATION — UI/UX Design Document
*Domino roguelike. Balatro DNA. Retrofuturist aesthetic — "The Perpetual Chronometer."*
*Built in Godot 4. All UI is procedural GDScript — no scene files.*

---

## Table of Contents

1. [Design Pillars](#1-design-pillars)
2. [Inspirations & References](#2-inspirations--references)
3. [Current UI Structure](#3-current-ui-structure)
4. [Color Palette & Visual Language](#4-color-palette--visual-language)
5. [Tile Design](#5-tile-design)
6. [Animation Stack](#6-animation-stack)
7. [Scoring Sequence](#7-scoring-sequence)
8. [Information Architecture](#8-information-architecture)
9. [Shop UI Design](#9-shop-ui-design)
10. [Reinforcement Tray](#10-reinforcement-tray)
11. [Contract Bar](#11-contract-bar)
12. [Layout Principles](#12-layout-principles)
13. [Etapa Visual Progression](#13-etapa-visual-progression)
14. [Pending & Future Design Work](#14-pending--future-design-work)

---

## 1. Design Pillars

These four pillars are the lens through which every UI/UX decision is evaluated. When in doubt, return here.

### Every tile placed is a decision, not a move
Hold for chain length bonus or cash out now? That tension must be legible at a glance — never requiring mental math. The UI must surface the cost/benefit of each tile before the player commits. Connection arrows (← → ↔ ·), live score preview, and milestone markers all exist to serve this pillar.

### The scoring moment is the payoff
Chips accumulate tile-by-tile, mult slams, total bursts. The player must *watch* their decisions pay off. The scoring sequence is not a loading screen — it is the climax of each hand. Every sub-animation in the sequence exists to make the payoff feel earned and legible.

### The run tells a story
Etapa 1 feels different from Etapa 4 — not just palette swaps, but mood, stakes, and narrative pressure. The UI should reflect The Chronometer's deteriorating state. A player in Etapa 4 should *feel* the machine failing.

### Information is a design material
What you show, when you show it, and how large you show it shapes how the player *feels* about the game state, not just how they understand it. Size = importance. Position = frequency of reference. Timing = moment of relevance.

---

## 2. Inspirations & References

### Balatro
The primary DNA reference for feel and feedback.

| Element | What to Take |
|---------|-------------|
| Card lift on select | Physical weight, deliberate selection — tiles lift Y -9px + scale 1.04× |
| Scoring sequence | Per-card stagger, chip pop from card position, mult slam, counter tick-up |
| Joker activation pulses | Module rack icons glow when their effect fires during scoring |
| Chip counter | Starts at base chips, increments per tile, slams to final value |
| Mult slam | "× N" appears large, orange, bounce-in — the pivot moment in the scoring sequence |
| Shop card hover lift | Module cards lift on hover, rarity border brightens |

### Slay the Spire
- Persistent UI clarity — always know your HP, energy, hand count, discard size
- Monster intent system — player always knows what the threat is before they act (analogous to showing chain end pips and score preview before committing)
- Upgrade paths — visual distinction between base and upgraded cards (analogous to rarity tiers on tiles and modules)

### Monster Train
- Layered board with vertical information density — multiple active regions without clutter
- Each zone has a clear visual owner (floor = zone, unit = element) — applied here as HUD / Table / Hand zones with distinct visual weight
- Persistent state (units on floors) is always visible alongside active decisions

### Cobalt Core
- Clean small-game polish — every interaction has feedback, nothing feels inert
- Compact UI with high information density that still reads as simple
- Every button state (normal / hovered / active / disabled) is visually distinct without being noisy

---

## 3. Current UI Structure

Three main zones, top to bottom. The table zone is dominant.

```
┌─────────────────────────────────────────────────────────┐
│  HUD BAR (top, fixed height)                            │
│  [Round/Etapa] | [====CHRONOS BAR 312/520====] | [●●●○] | [Monedas: 47] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  TABLE (center, dominant — takes remaining height)      │
│  [CONTRACT BAR — ◈ CONTRACT: Name — 2/5]                │
│                                                         │
│       [←3]  [tile]→[tile]→[tile]  [6→]                 │
│              22 chips × 3 = 66                          │
│         ○ ○ ○ ● ● ● ● ← milestone dots                 │
│                                                         │
│  Last hand result (dim, bottom of table)                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  HAND ZONE (bottom, fixed height)                       │
│  [Directives bar]                                       │
│  [Module rack] [Isolation Chamber]                      │
│  [Reinforcement tray]                                   │
│    [ ← ]  [ ↔ ]  [ ↔ ]  [ → ]  [ · ]  [ ↔ ]           │
│  [Undo] [Discard (2)] [Play Pulse ▶]                    │
└─────────────────────────────────────────────────────────┘
```

### HUD Bar (top)
- **Round / Etapa label** — small, top-left, least important info. Format: `CYCLE 3 / ERA I`
- **Chronos progress bar** — dominant center element. Fills toward target. Label shows `312 / 520`. Ghost projection overlays when tiles are selected (`312 + 66 → 378 / 520`).
- **Hands/Discards dots** — filled/empty circles. Hands turn red when 1 remaining. Two separate dot rows in distinct colors.
- **Monedas display** — gold coin icon + number, top-right. Animates "+N" pop on earn.

### Table (center, dominant)
- **Contract bar** — thin strip below table title, hidden when no active contract
- **Chain display** — horizontally centered. End-pip indicators flank the chain on both sides (glowing connection ports). Chain tiles arranged left-to-right with spacing.
- **Score preview equation** — sits below chain. Two-line hierarchy: `22 chips × 3` (dim, 14px) above `= 66` (bright green, 26px bold). Total line dominates.
- **Chain milestone markers** — dot row below score preview. Shows progress toward +1 Mult (tile 4) and +2 Mult (tile 7) thresholds, colored by progress.
- **Last hand result** — dim text at table bottom. Fades in after scoring, replaced by next result.

### Hand Zone (bottom)
- **Directives bar** — horizontal row of active directive cards at the very top of the hand zone
- **Module rack** — left side, module icons that pulse during scoring when activated
- **Isolation Chamber** — special tile staging area within hand zone
- **Hand tiles** — the main 7 tile row with connection arrows (← → ↔ ·) beneath each tile
- **Reinforcement tray** — 3 slots above the action buttons
- **Action buttons** — `[Undo]` `[Discard (N)]` `[Play Pulse ▶]`

---

## 4. Color Palette & Visual Language

### Core Colors

| Token | Usage | RGB (normalized) | Hex approx |
|-------|-------|-----------------|-----------|
| `C_BG` | Background | (0.08, 0.07, 0.05) | `#141209` |
| `C_TILE_BODY` | Outer tile frame | (0.21, 0.17, 0.11) | `#362B1C` |
| `C_TILE_FACE` | Pip half panels, ivory | (0.89, 0.85, 0.74) | `#E3D9BD` |
| `C_TILE_FACE_SEL` | Selected tile panels | (0.96, 0.88, 0.52) | `#F5E085` |
| `C_TILE_BORDER` | Normal tile border | (0.60, 0.48, 0.26) | `#997A42` |
| `C_TILE_BORDER_SEL` | Selected tile border | (0.96, 0.80, 0.28) | `#F5CC47` |
| `C_TILE_DIVIDER` | Spinner rivet divider | (0.52, 0.42, 0.22) | `#856B38` |
| `C_TARGETING` | Reinforcement targeting | (0.30, 0.90, 0.85) | `#4CE6D9` |
| `C_CHRONOS` | Chronos bar fill | (0.40, 0.92, 0.40) | `#66EB66` |
| `C_TARGET` | Score target, orange UI | (1.00, 0.52, 0.30) | `#FF854D` |
| `C_MONEDAS` | Coin/currency gold | (1.00, 0.86, 0.20) | `#FFDB33` |
| `C_WIN` | Win state, score total | (0.40, 1.00, 0.40) | `#66FF66` |
| `C_TITLE_GLOW` | Ambient title, wild tiles | (0.85, 0.70, 0.30) | `#D9B24D` |

### Rarity Colors

| Rarity | Description | Tint |
|--------|-------------|------|
| BONE | Common | Grey-brass — muted, desaturated |
| CARVED | Uncommon | Green-brass — oxidized copper |
| IVORY | Rare | Gold-brass — polished |
| OBSIDIAN | Epic | Purple-brass — void-touched |

Rarity tint is applied to tile borders and module card borders. Not to the tile face/pips — those remain ivory. The border carries the rarity signal.

### Etapa Palettes

| Etapa | Name | Primary Tones | Atmosphere |
|-------|------|--------------|-----------|
| 1 | Mahogany | Warm browns, deep amber | Stable. Chronometer hums warmly. |
| 2 | Brass | Cold steel, sharp orange | Strain. Amber frequencies rising. |
| 3 | Obsidian | Deep blue-black, cyan edge | Deteriorating. Visual crackle begins. |
| 4 | Void | Deep purple, sickly green | Critical. Machine is dying. |

Etapa palette changes apply to: HUD bar tint, table panel background, milestone marker colors, Chronos bar fill color, and ambient glow effects.

---

## 5. Tile Design

### Proportions

Real 2:1 domino ratio maintained throughout. Two sizes depending on context:

| Context | Width | Height |
|---------|-------|--------|
| Hand tiles | 98px | 196px |
| Chain tiles | 88px | 176px |

Chain tiles are slightly smaller to allow the full chain to display comfortably in the table area.

### Construction (layers, outside in)

```
┌─────────────────┐  ← C_TILE_BODY frame (dark ebony)
│  ┌───────────┐  │  ← 4px C_TILE_BORDER (rich brass)
│  │  FACE TOP │  │  ← Ivory pip-half panel (StyleBoxTexture, parchment)
│  │   • • •   │  │  ← Pips: 3×3 grid, circular dots, 3px separation
│  │           │  │
│  ├─────┬─────┤  │  ← Divider: 10px spine bar (brass)
│  │  ●  │     │  │    + 10×10 centered spinner rivet (brass, lightened)
│  ├─────┴─────┤  │
│  │  FACE BOT │  │  ← Second ivory pip-half panel
│  │     •     │  │
│  └───────────┘  │
└─────────────────┘
```

- **Outer frame**: `C_TILE_BODY`, 12px corner radius, 6px drop shadow
- **Border**: 4px `C_TILE_BORDER`, corner radius matches outer frame
- **Inner inset**: 11px inset from border edge
- **Pip panels**: `C_TILE_FACE` (ivory), StyleBoxTexture for parchment feel
- **Selected state**: panels shift to `C_TILE_FACE_SEL` (amber-gold), border shifts to `C_TILE_BORDER_SEL` (bright gold)
- **Divider**: horizontal spine bar + circular rivet at center — references actual domino spinner hardware

### Pip Rendering

- Layout: 3×3 grid per half
- Pip style: circular dots (not squares)
- Spacing: 3px separation between pips
- Pip color: dark (`C_TILE_BODY`-ish) against ivory face

### Rarity-Tinted Borders

- CARVED: green-brass tint on border
- IVORY: gold-brass tint on border
- OBSIDIAN: purple-brass tint on border
- BONE: default brass, no tint

### Special Tile Variants

- **Wild tiles**: ★ glyph in `C_TITLE_GLOW` (amber) rendered in the pip area instead of dots
- **Sacrifice tiles** (LOW_PIP_TO_MULT): void-purple tint on face panels during scoring flash
- **Double tiles**: gold flash during scoring sequence (both halves have identical pip count)

---

## 6. Animation Stack

Organized by priority tier. Tier 1 is implemented. Tiers 2–4 are queued.

---

### Tier 1 — Core Feel (implemented)

These animations define whether the game *feels* like a game worth playing.

#### a. Tile Lift on Select
- **Trigger**: player clicks a hand tile to add it to chain selection
- **In**: translate Y −9px + scale 1.04× over 0.12s — `TRANS_BACK`, `EASE_OUT`
- **Out**: spring back to Y 0, scale 1.0 over 0.10s — `TRANS_SPRING`
- **Guard**: state-checked before tween starts — no stacking tweens on rapid click
- **Why**: communicates physical weight; player *feels* the pick-up

#### b. Tile Draw Slide-In
- **Trigger**: hand refilled after playing or discarding
- **Effect**: each tile fades in (alpha 0→1) + scale pops (0.88→1.0) over 0.20s — `TRANS_BACK`
- **Stagger**: 0.055s per tile left-to-right
- **Why**: hand replenishment should feel like receiving something, not teleporting

#### c. Play Button Glow Pulse
- **Trigger**: valid chain selected (at least 1 tile, valid connections)
- **Effect**: looping amber modulate oscillation — 1.0 → 1.18 → 1.0 brightness, 0.65s per half-cycle
- **Stop**: immediately on chain clearing or on play
- **Why**: draws eye to the action; communicates "this is ready to fire"

#### d. Monedas "+N" Pop
- **Trigger**: coins increase during play (round clear, sell, interest)
- **Effect**: floating gold label spawns at Monedas display position, rises 40px, fades out over 0.80s
- **Color**: `C_MONEDAS`
- **Why**: coin feedback must be immediate and celebratory, not just a number change

#### e. Score Preview Visual Hierarchy
- **Equation line**: `22 chips × 3` — dim white, 14px — small, secondary
- **Total line**: `= 66` — `C_WIN` green, 26px bold — dominant, primary
- **Rule**: the total must always be visually larger than the equation
- **Why**: player's eye should land on "what will I score" not "how did I get there"

#### f. Chronos Ghost Projection
- **Trigger**: any tiles selected in current chain
- **Effect**: Chronos bar label updates from `312 / 520` to `312 + 66 → 378 / 520`
- **Color**: ghost portion in dimmer `C_CHRONOS` tint
- **Why**: player needs to know "will this be enough?" before committing

#### g. Chain Milestone Visual Markers
- **Effect**: dot row below score preview. 9px circles, one per position up to max chain length
- **Threshold flags**: visual accent at position 4 (+1 Mult) and position 7 (+2 Mult)
- **Coloring**: filled = current chain length (bright), empty = remaining (dim), past threshold = brightened
- **Why**: player can see at a glance whether they're two tiles away from a bonus

---

### Tier 2 — Information Clarity (next to implement)

These animations make the state changes legible, not just pretty.

#### Hand Dot Break Animation
- **Trigger**: hand consumed after playing
- **Effect**: consumed dot shrinks + fades over 0.18s, then row rebuilds with new count
- **Why**: raw number change doesn't communicate "I spent something"

#### Scoring Tile Scale Pulse
- **Trigger**: each tile during its scoring flash step
- **Effect**: tile scales to 1.06× during flash, returns to 1.0 immediately after
- **Why**: reinforces which tile is currently contributing to the running total

#### Chip Counter Tick-Up
- **Trigger**: chip total updating during scoring sequence
- **Effect**: `tween_method` increments displayed number from previous to new value over 0.15s per tile
- **Why**: Balatro's most satisfying moment — the number *accumulating*, not jumping

#### Deferred Effect Indicators
- **Trigger**: Fortune Essence / Talisman / delayed-trigger modules are active
- **Effect**: affected reinforcement slots show a faint pulsing glow (dim amber, 1.0s cycle)
- **Why**: player needs to know "this will fire later" without tooltip

---

### Tier 3 — Mood & Atmosphere (requires art/polish pass)

These animations serve the narrative pillar: "the run tells a story."

#### Etapa Ambient Degradation
- **Etapa 3**: subtle scanline overlay at low opacity across full screen
- **Etapa 4**: chromatic aberration shader at screen edges (RGB channel offset ±2px at corners)
- **Implementation**: ShaderMaterial on a CanvasLayer above game layer

#### Boss Round Warning
- **Trigger**: 2 rounds before a boss round
- **Effect**: round label pulses amber → red on a 1.2s cycle
- **Why**: builds dread without breaking gameplay

#### Chain Lock-In Flash
- **Trigger**: Play button pressed
- **Effect**: all selected tiles do simultaneous white flash (modulate to white, 0.08s, return 0.12s)
- **Why**: the moment of commitment — tiles "lock" into the chain

#### Idle Tile Breathing
- **Trigger**: hand tiles not selected, idle for >3s
- **Effect**: very subtle glow oscillation on hand tiles — low opacity amber outline, 2.5s cycle
- **Amplitude**: barely perceptible — should feel alive, not distracting

#### Module Equip Animation
- **Trigger**: module purchased in shop
- **Effect**: module icon ghost flies from shop card position to target rack slot (parabolic arc, 0.45s)
- **Why**: physical continuity — the item *moves* from shop to inventory

---

### Tier 4 — Polish (needs sound/art assets)

These animations require sound design or art assets to be meaningful.

#### Sound Design Pass
Priority order for implementation:
1. Tile click (tile added to chain)
2. Chain snap (Play pressed, lock-in moment)
3. Chip pop (per-tile during scoring)
4. Mult slam (× N moment)
5. Coin clink (Monedas earned)
6. Win jingle (Chronos target reached)
7. Boss sting (boss round intro)

#### Reinforcement Use SFX + VFX
- Each reinforcement type has a distinct activation visual
- Color-coded particle burst from reinforcement slot on use

#### Victory / Defeat Cinematics
- Basic version exists; needs polish pass
- Victory: screen clears, Chronometer stabilization visual metaphor
- Defeat: screen degrades, `REINITIALIZING PROTOCOL` replaces `GAME OVER`

#### Corruption Shader
- Etapa 4 tiles get visual glitch/corruption effect
- Possible implementation: UV displacement shader on tile panels

#### Module Icons
- `assets/modules/{id}.png` — user-provided art drops in here
- Fallback: initials in a rarity-tinted box (already implemented)

---

## 7. Scoring Sequence

**The most important animation in the game.** This is the Balatro payoff moment — where the player's decisions are validated. Every frame of this sequence must feel earned.

### Full Sequence Spec

```
STATE: input locked throughout
```

**Step 1 — Setup (immediate on play)**
- All chain tiles dim to 70% opacity
- Score preview total clears / goes blank
- Play button glow pulse stops
- Input locked

**Step 2 — Per-tile chip phase (100ms stagger per tile)**

For each tile in the chain (left to right):
- Tile border flashes bright:
  - Normal tile: `C_WIN` green
  - Double tile: `C_TILE_BORDER_SEL` gold (distinct moment — larger pop, will have distinct sound)
  - Sacrifice tile (LOW_PIP_TO_MULT): void-purple tint, pop shows `+N Mult` not `+N chips`
- `+N chips` floating label rises 75px from tile center, fades over 0.80s
- Running chip counter increments with `tween_method` (tick-up, not jump)
- Tile returns to full opacity after its flash

**Step 3 — Module pulses**
- Any module whose effect fired during this chain: rack icon glows (rarity color, 0.3s pulse)
- Fires as effects are applied, interleaved with chip phase if needed

**Step 4 — Mult slam**
- `× N` appears at chain center
- Style: 34px, `C_TARGET` orange, bounce-in (scale 0→1.2→1.0, 0.25s)
- Chip counter display pivots to show: `N chips × M`

**Step 5 — Total burst**
- `+N Chronos` appears at chain center above mult label
- Style: 38px, `C_WIN` green, rises 75px over 0.80s while fading
- Chip counter shows full equation: `N chips × M = Total`

**Step 6 — Bar fill**
- Chronos bar fills from old value to new value over 0.55s tween
- If score ≥ 80: table shakes (subtle, ±3px offset, 3 cycles, 0.30s)
- If Chronos bar reaches/exceeds target: bar flashes `C_WIN`, win-state activates

**Step 7 — Unlock**
- Input unlocked
- Score display restores to preview mode for next chain selection
- Tile states reset (lifted tiles return to baseline)

### Double Tile Protocol
- Flash color: gold (`C_TILE_BORDER_SEL`) instead of green
- Pop label: larger font (18px vs 14px)
- Chip contribution: standard chips + the extra double-bonus chips shown separately
- Future: distinct sound cue

### Sacrifice Tile Protocol (LOW_PIP_TO_MULT)
- Flash color: void-purple (matches OBSIDIAN rarity)
- Pop label: `+N Mult` in purple instead of `+N chips` in green
- Counter: mult value ticks up during this tile's step instead of chip value

---

## 8. Information Architecture

### Always Visible During Play

These elements are never hidden, never behind a tooltip, never in a submenu.

| Element | Where | Why |
|---------|-------|-----|
| Chronos progress | HUD bar, center | Primary win condition — must dominate |
| Chronos ghost projection | HUD bar, overlay | Decision support — "will this be enough?" |
| Hands remaining | HUD bar, right | Scarcity signal — how many attempts left |
| Discards remaining | HUD bar, right | Resource signal — emergency option count |
| Chain end connectors | Table, flanking chain | Tile compatibility — eliminates mental math |
| Score preview equation | Table, below chain | Current chain value — live decision feedback |
| Score preview total | Table, below chain | Dominant number — player's eye target |
| Chain milestone dots | Table, below preview | Chain length incentive — "N more for +1 Mult" |
| Hand tile arrows | Hand zone, per tile | Connection validity — ← → ↔ · |
| Active directives | Hand zone, top strip | Objective awareness — what am I optimizing for? |
| Monedas | HUD bar, far right | Resource budget — what can I afford in shop? |

### Connection Arrow System

Each hand tile displays one of four symbols:

| Symbol | Meaning | Visual |
|--------|---------|--------|
| `←` | Fits left end only | Arrow pointing left |
| `→` | Fits right end only | Arrow pointing right |
| `↔` | Fits either end | Bidirectional arrow |
| `·` | No match | Dim dot (tile is not playable) |

Tiles with `·` are visually dimmed. This eliminates all mental calculation about playability.

### On-Demand (Future)

These elements are accessed on request, not persistent:

- **Box Viewer** — tap to see all tiles in current box, sorted by pip value
- **Module tooltip** — hover over rack icon to see full effect description
- **Run history** — post-run screen showing round-by-round scores and decisions
- **Stats screen** — in-run stats (tiles played, doubles hit, highest chain, etc.)

---

## 9. Shop UI Design

The Artisan's Workshop. Tone shifts per etapa — the UI should reflect the narrative context.

### Module Card Anatomy

```
┌───────────────────────────────┐  ← rarity-colored border (4px)
│ [CARVED]           UNCOMMON   │  ← rarity label, small, accent color
│                               │
│  ┌────────┐                   │
│  │  64×64 │  MODULE NAME      │  ← icon area + name (large)
│  │  icon  │  ──────────────   │
│  └────────┘                   │
│                               │
│  Effect description that      │  ← wrapped text, readable size
│  wraps across multiple lines  │
│  when needed.                 │
│                               │
│  "Lore flavor text here,      │  ← dim, small — world flavor
│   in italics, brief."         │
│                               │
│  Cost: ◈ 5     (-15%)        │  ← cost + discount badge inline
│  ┌──────────────────────────┐ │
│  │        BUY               │ │  ← action button
│  └──────────────────────────┘ │
└───────────────────────────────┘
      width: 260px
```

### Module Card States

| State | Visual |
|-------|--------|
| Normal | Base rarity border at full opacity |
| Hovered | Lifts Y −4px, border brightens, slight scale (1.02×) |
| Purchased | "OWNED" stamp replaces buy button, card dims to 60% |
| Unaffordable | Buy button dims, cost label turns red |
| Discounted | "(-15%)" badge appears inline with cost (SHOP_DISCOUNT module active) |

### Icon Fallback

When `assets/modules/{id}.png` is not present:
- Box sized 64×64, filled with rarity color at 40% opacity
- Module initials (first 2 characters of name) centered, rarity color at full opacity, 20px bold

### Shop Layout

- Module cards: horizontal row, 3 per page (or scrollable)
- Card spacing: 16px gap
- Artisan dialogue: text panel above cards, changes per etapa
- "Leave Workshop" button: bottom-right, restrained styling (not competing with module cards)

---

## 10. Reinforcement Tray

Three slots in the hand zone, above the action button row. Reinforcements are single-use consumables.

### Slot States

| State | Visual |
|-------|--------|
| Empty | 52×52 button, dimmed to 35% alpha, center dot placeholder |
| Filled | Full opacity, icon from `assets/reinforcements/{id}.png` or initials fallback |
| Hovered | Slight brightness increase, tooltip appears |
| Targeting mode | All hand tiles switch to teal (`C_TARGETING`) highlight; selected tile shows ✓, invalid targets show ? |
| Disabled | During scoring animation — slots locked, pointer changes to indicate disabled |

### Targeting Mode Flow

1. Player clicks a filled reinforcement slot
2. Tray slot highlights (selected state)
3. All hand tiles switch to teal highlight
4. Tiles that are valid targets show `✓`, invalid show `?`
5. Player clicks a target tile
6. Effect applies, targeting mode ends, tile returns to normal highlight
7. Reinforcement slot clears (consumed)
8. Cancel: right-click or Escape exits targeting mode without consuming

### Tooltip Content

On hover over a filled slot:
- **Name** (bold)
- **Description** (effect text)
- **Cost to use**: 0 Monedas (already purchased) — reminder that it's free to use now

---

## 11. Contract Bar

A thin contextual bar in the table zone, visible only when an active contract exists.

### Layout

```
◈  CONTRACT: Resonance Surge  —  2 / 5 chains of 6+
```

- `◈` — glowing contract icon in `C_TITLE_GLOW` amber
- `CONTRACT:` — label, dim, small caps
- Contract name — normal weight, readable
- Progress — `current / target` in `C_CHRONOS` green when progressing, normal when waiting
- Hidden completely (zero height, no space reserved) when no contract is active

### Update Behavior

- Updates on every hand scored — progress fraction animates (counter tick-up)
- On contract complete: brief green flash, "COMPLETE" stamp, then bar hides after 1.5s
- Mastery contract (full tracking): progress bar variant instead of fraction — fills left to right

---

## 12. Layout Principles

These principles govern every layout decision. Reference them when adding new elements.

### Hierarchy Rules

1. **Chronos bar is the dominant element** — must be the widest, most visually prominent thing in the HUD. Player should be able to read progress at a glance from across the room.
2. **Score total is larger than the equation** — `= 66` must always be visually larger than `22 chips × 3`. Player's eye goes to the answer, not the math.
3. **Chain is vertically centered in the table** — always. Not top-aligned, not bottom-aligned. The chain *owns* the table space.
4. **Information density increases toward center** — chain and score in center (high density), etapa label at corner (low density). The eye lands where the decisions are.

### Physical Feel Rules

- **Tiles feel physical** — lift, weight, shadow. Never feel like flat UI elements.
- **Selections feel deliberate** — the lift animation communicates "I picked this up." Deselection springs back, not snaps.
- **Scoring feels mechanical** — per-tile stagger, tick-up counter. The machine is *processing* the chain.

### Whitespace Rules

- The table zone background should have enough empty space around the chain that the chain reads as isolated, focused, important.
- Hand zone is denser — tiles are packed — but still breathable (gap between tiles).
- HUD bar items should not crowd each other. Each element needs its visual lane.

### Procedural UI Constraints

Since all UI is GDScript with no scene files:
- All sizes are defined as constants at the top of each script
- Colors reference the palette constants (never hardcoded hex)
- Layout is computed on `_ready()` and on window resize
- New elements must fit into the three-zone structure without creating a fourth zone

---

## 13. Etapa Visual Progression

Each etapa is a chapter in the machine's decline. The UI reflects this.

| Etapa | Name | Palette | Atmosphere | UI Changes |
|-------|------|---------|------------|-----------|
| 1 | Mahogany | Warm browns, deep amber | Stable. The Chronometer hums. | Base palette. Clean, warm. |
| 2 | Brass | Cold steel, orange accents | First signs of strain. Amber rising. | Slight cooler tint on backgrounds. Orange accents sharpen. |
| 3 | Obsidian | Deep blue-black, cyan edges | Deteriorating. Visual crackle. | Scanline overlay (low opacity). Blue-black table background. |
| 4 | Void | Deep purple, sickly green | Critical failure imminent. | Chromatic aberration at screen edges. Purple ambient glow. Tile corruption shader. |

### Etapa Transition Sequence (implemented)

When moving to a new etapa:
1. Screen fades to black
2. Roman numeral + etapa name scales in (large, centered)
3. Atmosphere tagline appears below
4. Brief hold (1.5s)
5. Scale out, fade to new etapa palette
6. Round begins

### Artisan Dialogue Per Etapa

The shop NPC reflects the world state:

| Etapa | Artisan Tone | Sample Line |
|-------|-------------|-------------|
| 1 | Calm, professional | *"Calibration nominal. What will strengthen the pulse today?"* |
| 2 | Measured concern | *"Slight turbulence in the flow. Best to fortify while you can."* |
| 3 | Strained urgency | *"The Chronometer strains. I've set aside my strongest work."* |
| 4 | Desperate | *"Operator. Listen carefully. This may be our last transaction."* |

### Boss Round Protocol

- **2 rounds before boss**: round label begins amber-red pulse cycle (1.2s)
- **Boss round intro**: blackout → corrupted name text (glitch typewriter) → one line of menace → round begins
- Boss mechanic should be *implied by lore text*, not stated mechanically in the intro

---

## 14. Pending & Future Design Work

Ordered roughly by impact-to-effort ratio.

### High Priority (highest non-visual impact)

- [ ] **Sound design pass** — tile click, chain snap, chip pop, mult slam, coin clink, win jingle, boss sting. Sound is 50% of feel. This should happen before any more visual polish.
- [ ] **Module icons** (`assets/modules/{id}.png`) — user-provided art. Fallback initials already implemented.
- [ ] **Reinforcement icons** (`assets/reinforcements/{id}.png`) — same pattern as modules.
- [ ] **Contract icons** — visual identity for each contract type.

### Medium Priority (Tier 2 animations)

- [ ] Hand dot break animation (consumed dot shrinks/fades, 0.18s)
- [ ] Scoring tile scale pulse (1.06× during flash step)
- [ ] Chip counter tick-up (tween_method, not jump)
- [ ] Deferred effect indicators (Fortune Essence / Talisman pulsing glow)

### Feature Design Work

- [ ] **Reinforcements in shop** — how are reinforcements sold? Priced? Displayed alongside modules or in a separate section? Design TBD.
- [ ] **Box Viewer** — full tile composition viewer. Tap to see all tiles in current box, sorted by value. Layout: modal overlay, grid of tiles, filterable by pip value.
- [ ] **Mastery contract progress animation** — progress bar variant of contract bar, fills on each qualifying hand.
- [ ] **Run history screen** — post-run breakdown. Round-by-round scores, modules acquired, key decisions. Should feel like a log entry, not a stats screen.
- [ ] **Difficulty selector polish** — currently functional, needs visual identity matching the retrofuturist aesthetic.

### Atmospheric Polish (Tier 3–4)

- [ ] Etapa 3 scanline overlay shader
- [ ] Etapa 4 chromatic aberration shader
- [ ] Chain lock-in flash (simultaneous white flash on Play)
- [ ] Idle tile breathing (hand tiles, very subtle)
- [ ] Module equip fly animation (icon arc from shop to rack)
- [ ] Corruption shader for Etapa 4 tiles
- [ ] Victory/defeat cinematic polish pass

### Open Design Questions

- **Reinforcement shop display**: separate section in the Artisan's Workshop, or interspersed with modules? Price point for reinforcements vs modules?
- **Box Viewer access**: dedicated button in HUD, or tap on tile count display? Should it be available during opponent's "turn" equivalent?
- **Run history depth**: how many runs are stored? Is there a "best run" highlight? Is there per-run replay?
- **Difficulty modes**: does difficulty affect visual intensity (more degradation at lower difficulties played harder)? Or purely mechanical?

---

*Last updated: 2026-04-20*
*This is a living document — update when significant UI/UX decisions are made or changed.*
