# DOMINATION — Production Design Document
*Domino roguelike. Balatro DNA. Retrofuturist entropy-management setting.*

---

## Design Pillars

1. **Every tile placed is a decision, not a move.** Hold for chain length bonus or cash out now? That tension must be legible at a glance, never requiring mental math.
2. **The scoring moment is the payoff.** Chips accumulate tile-by-tile, mult slams, total bursts. The player must *watch* their decisions pay off.
3. **The run tells a story.** Etapa 1 feels different from Etapa 4 — not just palette swaps, but mood, stakes, and narrative pressure.
4. **Information is a design material.** What you show, when, and how large shapes how the player *feels* about the game state, not just understands it.

---

## Setting — The Perpetual Chronometer

The Chronometer is a vast mechanical construct that sustains temporal order. It is failing.
You are **The Operator** — recruited (or conscripted) to run **Trial Cycles**, calibration runs
through simulated entropy to keep the Chronometer stable.

**The World:**
- Tiles are **Resonance Nodes** — fragments of quantised time that carry Chronos energy.
- Chains are **Cohesion Pulses** — sequences of resonance that release accumulated Chronos.
- Modules are **Calibration Modules** — salvaged or crafted upgrades attached to your resonance rig.
- Monedas are the **Operator's stipend** — issued by the Archival Authority per successful round.
- Rounds are **Calibration Cycles**. Etapas are **Eras of Stability** (or instability).

---

## Etapas — Narrative Chapters

Each etapa has a distinct visual identity, ambient character, and narrative pressure.

| Etapa | Name | Tone | Boss Type |
|-------|------|------|-----------|
| 1 | Mahogany | Stable, warm. The Chronometer hums. | Minor disruption — routine anomaly. |
| 2 | Brass | First signs of strain. Amber glows. | Moderate corruption — escalating pattern. |
| 3 | Obsidian | Deteriorating. Visual crackle. | Severe corruption — cascade threat. |
| 4 | Void | Critical failure imminent. | Entropy cascade — all constraints maxed. |

**Artisan dialogue changes per etapa.** In Etapa 1: calm and professional. Etapa 4: urgent, almost desperate.
Boss intros should be cinematic: black screen, corrupted text, one line of genuine menace.

---

## UI Architecture

### The HUD (top bar)
Four sections, left to right:

```
[Round / Etapa] | [=====CHRONOS BAR 312/520=====] | [Hands ●●●○  Disc ●●○] | [Monedas: 47]
```

- **Chronos bar** is the dominant element — fills toward target. Color: deep green → bright green → gold (≥75%) → win-green (≥100%).
- **Hands remaining** shown as filled/empty dots. Turns red when 1 hand left.
- **Discards remaining** as dots in a different color.
- Round and Etapa small, top-left — least important info.

### The Table (center, dominant)
```
COHESION PULSE                    Round 3/15

         [←3]  [tile]→[tile]→[tile]  [6→]
                 22 chips × 3 = 66

    (spacer — chain always vertically centered)

    last hand result
```

- Chain is **vertically centered** in the table at all times.
- **Chain end indicators** flank the chain: glowing pip displays showing left_end and right_end values. These are the "connection ports" — matching these connects your next tile.
- Score preview sits just below the chain, always visible as tiles are added.

### The Hand Zone (bottom, fixed)
```
[Directives bar]
[ISOLATION CHAMBER — tiles — tiles — tiles]
    [ ← ] [ ↔ ] [ ↔ ] [ → ] [ · ] [ ↔ ]
[Undo] [Discard(2)] [Play Pulse]
```

- Each hand tile shows a connection arrow: **←** (fits left end), **→** (fits right end), **↔** (fits both), **·** (no match).
- Arrows eliminate ALL mental calculation about which tiles are playable and where.
- Tiles that cannot connect are visually dimmed.

---

## Scoring Sequence (Balatro-style)

When a hand is played, input is locked and the sequence runs:

1. **Tile 1 highlights** (golden border) — "+N chips" pops upward from it (100ms stagger per tile)
2. **Tile 2 highlights** — "+N chips" pop (doubles show gold pop, normal tiles white pop)
3. … (repeat for each tile in chain)
4. **Mult slam**: "× N MULT" appears large in the chain center — orange, scale-in animation
5. **Total burst**: "+N Chronos" in green, larger, rises and fades
6. **Chronos bar** fills with animation
7. Input unlocked

Doubles get a visually distinct moment: gold highlight color, larger pop, different sound (future).

---

## Information Architecture

### Always visible during play
- Chronos progress (bar + number)
- Target
- Hands + discards remaining (dots)
- Chain end connectors (which pip values are free)
- Current chain score preview (chips × mult = total)
- Hand tile connection arrows
- Directives

### On-demand (future)
- Full box composition ("Box Viewer")
- Module full effect descriptions (tooltip on hover)
- Run history / stats

---

## Animation Priority Stack

### Tier 1 — Core loop feedback (implement first)
- [x] Per-tile chip pop from tile position with stagger
- [ ] Tile highlight during scoring (golden border)
- [ ] Accumulating chip counter in scoring display
- [ ] Mult slam animation
- [ ] Chronos bar fill animation
- [x] Score total burst pop

### Tier 2 — Reads + Information
- [x] Chain end pip indicators
- [x] Hand tile connection arrows (← → ↔ ·)
- [x] Chronos progress bar
- [x] Hands/discards as dot indicators
- [x] Chain length milestone markers ("3 more for +1 Mult")
- [x] Module activation pulses (icon glows when effect fires)

### Tier 3 — Mood + World
- [x] Etapa transition sweep (not just color change)
- [x] Boss intro sequence (cinematic)
- [ ] Artisan shop enter/exit transitions
- [ ] Tile placement particle spark on valid connection
- [ ] Etapa ambient effects (late etapa visual degradation)

### Tier 4 — Polish + Juice
- [ ] Idle animations (chain tiles breathe, slight glow)
- [ ] Camera shake on very high scoring moments
- [ ] Corruption visual effects on Etapa 4
- [ ] Victory/defeat cinematics
- [ ] Sound design (tile click, chain snap, score burst, mult slam)

---

## Module System — Design Intent

Modules should create **radically different strategies**, not just flat stat boosts.
Current palette (22 modules) is good. Future additions should target missing archetypes:

- **No "chain cost" module yet** — e.g. "burn N tiles from chain for +X mult" (sacrifice)
- **No "draw manipulation" module yet** — e.g. "see top 3 tiles, keep 2" (information)
- **No "conversion" module yet** — e.g. "all 0-pip tiles treated as wild" (transformation)
- **No "scaling" module yet** — e.g. "+1 mult per round survived" (compounding)

Module activation should be **visually distinct** — icon pulses when effect fires in scoring sequence.

---

## Lore Integration

### The Artisan (shop NPC)
A recurring character, not just a shop menu. Per-etapa greetings:
- Etapa 1: *"Calibration nominal. What will strengthen the pulse today?"*
- Etapa 2: *"Slight turbulence in the flow. Best to fortify while you can."*
- Etapa 3: *"The Chronometer strains. I've set aside my strongest work."*
- Etapa 4: *"Operator. Listen carefully. This may be our last transaction."*

### Boss Intros
Format: blackout → corrupted name text → one line of menace → round begins.
The boss mechanic description should be *implied by the lore text*, not stated mechanically.

### Win / Lose Screens
- **Victory**: The Chronometer stabilizes. Visual metaphor of order restored. Stats secondary.
- **Defeat**: Corruption spreads. Screen degrades. "REINITIALIZING PROTOCOL" not "GAME OVER."
- Both screens should feel like part of the world, not UI dialogs.

---

## Build-Order Priorities

1. ✅ Chronos progress bar (fills toward target, color-coded)
2. ✅ Chain end pip indicators (glowing connector ports)
3. ✅ Hand tile connection arrows (← → ↔ ·)
4. ✅ Scoring overlay animation (tile highlights, chip pops, mult slam)
5. ✅ Input lock during scoring
6. ✅ Animated chronos bar fill on score
7. ✅ Module rack visible during play (icons pulse on activation)
8. ✅ Chain length milestone text
9. ✅ Artisan dialogue per etapa
10. ✅ Boss intro cinematic (glitch → typewriter name reveal, staged lore/desc/button)
11. ✅ Etapa transition sweep effect (Roman numeral + name + atmosphere, scale-in/out)
12. 🔜 Sound design pass
