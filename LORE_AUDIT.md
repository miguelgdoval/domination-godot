# Lore Audit — Domination
*Written 2026-05-14. Every piece of canon in the game read against `STORY_BIBLE.md`. Categorised as CONSISTENT / OPPORTUNITY / CONTRADICTION / REMOVAL. Specific text fixes proposed for everything that needs touching.*

---

## §1. Methodology

Source: `LORE_INVENTORY.md` (the full canon catalogue). Reference: `STORY_BIBLE.md` (the foundation). For each item:

- **CONSISTENT** — matches the bible as-is. No action.
- **OPPORTUNITY** — matches the bible but could be sharpened to point more directly at a now-known truth. Optional small rewrites.
- **CONTRADICTION** — directly conflicts with the bible. Must change.
- **REMOVAL** — contradicts so deeply it shouldn't be in the game. None found.

The bulk of canon was written before the bible existed, in the same tonal register the bible later locked in. So most of it passes. The cases where it doesn't are concentrated in early Codex entries that asserted things the bible has now refined.

---

## §2. Summary

| Category | Count |
|---|---|
| CONSISTENT | ~140 items |
| OPPORTUNITY | 8 items (small text changes) |
| CONTRADICTION | 2 items (must fix) |
| REMOVAL | 0 |

The bible covers what's there. The world is internally healthy. **Two true contradictions, both fixable in one line each.**

---

## §3. Contradictions

### C1 — Codex: "The Perpetual Chronometer"

**Current text** ([scripts/codex.gd:230-231](scripts/codex.gd)):

> "Nobody — not the Architects, not the Archiver, not the Renegade — knows what the Chronometer was for, before it began to fail."

**Conflict**: The bible commits clearly that the Renegade *does* know. He was there. The Society's institutional knowledge has lapsed; the Renegade's hasn't. He is the only living person who remembers.

**Proposed fix** — drop "not the Renegade" from the list:

> "Nobody — not the Architects, not the Archive in its current state — admits to knowing what the Chronometer was for, before it began to fail. **The Renegade Mechanic does not answer questions of this kind.**"

The new closing line is bible-true (he could speak, he won't) and reads as the Archive's quiet acknowledgment that the silence is itself a kind of data.

---

### C2 — Codex: "The Renegade Mechanic"

**Current text** ([scripts/codex.gd:92-94](scripts/codex.gd)):

> "He runs no shop with a sign. He appears at the Artisan's Workshop after **every** Entropy Failure, the Master of the Forge stepping aside with the deliberate silence of someone who has seen this before."

**Conflict**: The implementation has the Renegade swap firing at most *once per run* (~60% of runs, deterministic in daily mode). The Codex says "every Entropy Failure." Player who reads the Codex then plays the game notices the gap.

**Proposed fix** — soften "every" to match implementation, preserve the lore beat:

> "He runs no shop with a sign. He appears at the Artisan's Workshop **after certain Entropy Failures, on schedules the Society has not deciphered**, the Master of the Forge stepping aside with the deliberate silence of someone who has seen this before."

The new clause ("on schedules the Society has not deciphered") is bible-true — the Renegade visits when he chooses, and the Society does not understand his pattern. Player observation matches Codex.

---

## §4. Opportunities

Eight places where existing canon is bible-compatible but could be sharpened to point at a now-known truth. None are required. All are small.

### O1 — Codex: "The Master of the Forge"

**Current** ([codex.gd:108-110](scripts/codex.gd)):

> "When the Operator selects a tile for removal, the Master simply nods. When the Operator selects a special tile to add, the Master examines them — not the tile."

**Bible** (§5, The Master): *"When the Master examines the Operator, he is checking how much you have forgotten."*

**Opportunity** — append one sentence to cash out the "examines them, not the tile" beat:

> "When the Operator selects a tile for removal, the Master simply nods. When the Operator selects a special tile to add, the Master examines them — not the tile. **He is checking how much wear the Operator has taken since the last visit.**"

---

### O2 — Codex: "The Voice of the Emporium"

**Current** ([codex.gd:82-83](scripts/codex.gd)):

> "Some Operators have tried to reach what is behind it. None have reported what they found."

**Bible** (§5, The Voice): an empty intercom office; a chair pushed back from a desk; the Operator at the other end has been dead a very long time. A few Operators stopped leaving.

**Opportunity** — replace the unspecific last line with a concrete detail:

> "Some Operators have tried to reach what is behind it. They find a small office. A chair, pushed back from a desk. **The terminal on the desk is the other side of the Voice, and it is silent. A few of those Operators did not leave.**"

Concrete object (chair), confirmed absence (the other terminal is silent), implication of fate (didn't leave). Doesn't spoil anything; deepens.

---

### O3 — Codex: "The Wild"

**Current** ([codex.gd:393-394](scripts/codex.gd)):

> "The Renegade Mechanic disagrees. He says the Wilds are intentional. He has not said by whom."

**Bible** (§10, point 7): the Renegade built them as connection-tools for the original world; they were doors, technically; now they go nowhere.

**Opportunity** — preserve the "has not said by whom" beat but add one line of architecture:

> "The Renegade Mechanic disagrees. He says the Wilds are intentional. He has not said by whom. **A sketch recovered from the Workshop floor — unsigned, in the Renegade's hand — depicts a Wild as a door. The door, in the sketch, is open. The page does not show what is on the other side.**"

Adds a specific in-fiction artefact (the sketch) and leaves the question deliciously open.

---

### O4 — Codex: "The Renegade Mechanic"

**Current** ([codex.gd:98-99](scripts/codex.gd)):

> "The Archiver has filed a request for his arrest in every Trial Cycle for as long as the records go back. The request is never executed."

**Bible** (§5, The Renegade): the Society *has no procedure* for arresting someone older than itself. The Archiver files them out of protocol; the warrants go to administrators who do not know what to do with them.

**Opportunity** — sharpen the WHY without confirming the bible-truth:

> "The Archiver has filed a request for his arrest in every Trial Cycle for as long as the records go back. **The requests reach the Society's administrative offices and are accepted, stamped, and filed.** The request is never executed."

The new middle sentence depicts the bureaucracy receiving the warrant and doing nothing with it — exactly the bible's institution-too-depleted-to-act framing.

---

### O5 — Codex: "The Mahogany Trial"

**Current** ([codex.gd:163-165](scripts/codex.gd)):

> "The Architects refer to the Mahogany Trial as 'the cradle.' The Archiver does not."

**Bible** (§6, Mahogany Trial): the Archiver does not, because he knows how many Operators have died in their first Cycle, and "cradle" implies safety.

**Opportunity** — give the Archiver's silence its specific weight:

> "The Architects refer to the Mahogany Trial as 'the cradle.' The Archiver does not. **The Archive has a complete record of how many Operators have not survived their first Cycle. The Archive considers 'cradle' inaccurate.**"

The new sentences read as Archive prose — formal, withholding, knowing.

---

### O6 — Codex: "The Copper Guild"

**Current** ([codex.gd:124-130](scripts/codex.gd)):

> "The Copper Guild is institutional, transactional, amoral. They do not appear in person at the Observation Window. They are everywhere else. Coins — the stable byproducts of successful Trial Cycles — are minted, valued, and accepted only by Guild contract. The Society of Time Architects tolerates the Guild because the Guild's bookkeeping is the only thing preventing the Chronometer's economy from collapsing alongside the Machine."

**Bible** (§5, The Copper Guild): they have a longer view than the Society. Their plan is not the Society's plan. The bible deliberately doesn't reveal the plan, but does hint that the Guild may outlast even the Chronometer.

**Opportunity** — add one bible-consistent line at the end:

> "[existing text]. **The Guild's books extend forward through margins of expected losses that imply a horizon longer than the Society's. The Guild does not advertise the horizon.**"

Hints at the longer plan without naming it.

---

### O7 — Codex: "Transmission #1"

**Current** body asserts: *"You have not been told that the Chronometer is dying because something is killing it. This is also correct."*

**Bible** (§11, hard constraint #3): no antagonist. Just entropy. *Any "something is killing it" reading must remain the Archiver's interpretation, not a confirmed fact.*

**Assessment**: The transmission is bible-compatible *if read as the Archiver's interpretation, not a confirmed external fact.* The Archiver doesn't lie — he's allowed to ascribe intentionality to entropy the way a grief-stricken function might. But future writing must NOT confirm an antagonist anywhere else.

**No fix needed.** Flag for the bible to enforce in future content.

---

### O8 — Codex: "Resonant Null" (module)

**Current** ([codex.gd:778-781](scripts/codex.gd)):

> "The Null was the Mechanism's second discovery. The rest of the Mechanism followed. The Architects have not been able to identify the first discovery; the Chronometer's earliest records are damaged."

**Bible** (§2): The First Mechanism Discovery is *the principle that a single perfectly-preserved moment slows the universe's drift around itself.* The Architects don't know this because they don't know what's being preserved.

**Opportunity** — the existing entry is bible-consistent, but could be sharpened to imply the missing first-discovery is recoverable, not lost:

> "The Null was the Mechanism's second discovery. The rest of the Mechanism followed. The Architects have not been able to identify the first discovery; **the Chronometer's earliest records are damaged. The Renegade has not been asked.**"

The closing sentence functions as both atmospheric and as a load-bearing hint that the answer exists, just isn't accessible to the Society.

---

## §5. New Content Opportunities

The bible opens five new categories of writing the canon doesn't currently cover. None are required for consistency — they're places we *could* push the lore deeper.

### N1 — New Codex concept: "The First Hour"

The bible names this period explicitly. The Codex currently doesn't have an entry for it. Adding one — even a deliberately spare entry — would let the player encounter the name and know it matters.

Proposed body (~60 words):

> "The Chronometer's reference period. The Society's records use this term without elaborating. The Architects have no consistent definition; the Archive's earliest indices reference 'the First Hour' as a fixed unit, but the unit's length, calendar, and conditions are not recoverable. The Renegade has not been asked.\n\nThe First Hour ended. The Society is what came after."

Unlock gate: `wins ≥ 5` (alongside Transmission #1, so the player meets the term and the first transmission roughly together).

### N2 — New Codex entry: "The Brass Lever"

The lever is one of the three preserved-moment fragments. The bible says it's somewhere in the Cold Singularity, still half-pulled. A Codex entry would let the player who's seen Transmission #5 cross-reference what they saw.

Unlock gate: `wins ≥ 50` (same as Transmission #5).

Proposed body (~80 words):

> "A brass lever, half-pulled, fixed in its half-position for the duration of the Memorial. Located somewhere in the Cold Singularity, behind the chamber's primary processing manifold. The Architects' inventory marks the position with the note 'do not adjust.' The note has been re-stamped many times. The lever has not been adjusted.\n\nIt is the lever the founder pulled to start the preservation. It has been half-pulled since."

### N3 — A new event involving the Master noticing the Operator's forgetting

The Master's diegetic role is now clearly defined (he examines you, not the tile, checking how much you've forgotten). One event could surface this directly. The Master speaks rarely — when he does, the player should feel it.

Sketch:

> Title: **THE MASTER PAUSES**
> Speaker: THE MASTER OF THE FORGE
> Body: *"Operator. You may not remember this, but we have had this conversation before. I am asking again because the Catalogue is paid for; the answer is not. Are you well?"*
> Choices:
> A. "Tell him you are well." — outcome: *"He nods once. 'I will write it down. For when you forget.'"* (no mechanical effect; codex unlocks "Master's Question")
> B. "Tell him you are not." — outcome: *"He gives you a Bone Module. No comment."* (+1 Bone module if slot, else 3 coins)
> C. "Ask him what he remembers."  — outcome: *"He looks at you a long moment. He does not answer. The Workshop is quiet for the rest of your visit."* (rep: +1 society)

Bible-consistent on every beat. Adds emotional weight to the Master.

### N4 — New notebook fragments referencing the First Hour

The bible commits to the First Hour as a real historical period. None of the current 25 notebook fragments name it. Adding 3-4 fragments where past Operators reference it (always in passing, never explaining) would seed the term across the world.

Examples:

- **Op-203**: "The Renegade once told me a name. He said it was from the First Hour. I have forgotten it. Of course I have."
- **Op-419**: "The Master, drunk once, said the First Hour was 'shorter than they will tell you.' He did not elaborate. He does not drink anymore."
- **Op-612**: "I think the First Hour ended on a Tuesday. I have nothing to base this on."

### N5 — A new event involving the Voice

The Voice is now clearly an empty intercom. One event could let the player encounter the empty office on the other side. Bible-compatible because the bible says some Operators have done this; the event is the player having the option.

Sketch:

> Title: **YOU HAVE BEEN OFFERED A SIDE DOOR**
> Speaker: (unattributed; the prompt appears between rounds)
> Body: *"A door near the Emporium has opened. It was not there last Cycle. Whatever is past it is not catalogued. The Operator may, optionally, look."*
> Choices:
> A. "Look." — outcome: *"A small office. A chair pushed back from a desk. The terminal on the desk is the other side of the Voice. It is silent."* (–1 Coin "for the time," gain 1 random Carved Module — the office had supplies someone forgot to retrieve)
> B. "Walk past." — outcome: *"The door is gone the next time you check. It was not catalogued."* (no effect)

---

## §6. Mechanical Opportunity (separate scope)

### M1 — Surface Sacrifice's memory cost in-game

The bible commits to "each Sacrifice Module equipped consumes a piece of the Operator's outside life." Currently this is **lore only** — no mechanical signal.

A minimal in-game beat would be devastating: when the player equips a Sacrifice Module, a small label fades up briefly:

> *You forgot —*

with the dash trailing into empty space. No mechanical penalty. No tracking. Just a one-line confirmation that the lore is *literal*.

Tonally cruel in the right way. Easy to implement (the acquisition-flash system from earlier batches is the right template). Would also retroactively recolor every existing Sacrifice purchase for veteran players.

**Scope**: ~30 minutes of work. Touches `main.gd` only.

---

## §7. Incorporation Plan

Prioritized list. Each item has scope.

### TIER 1 — Required for consistency (must do)

- **C1** — Reword "The Perpetual Chronometer" Codex entry (1-line text change)
- **C2** — Reword "The Renegade Mechanic" Codex entry to match implementation (1-line text change)

Total: ~5 minutes. Two edits to `codex.gd`.

### TIER 2 — Polish opportunities (should do; small)

- **O1** — Master examination line
- **O2** — Voice's empty office detail
- **O3** — Wild's unsigned sketch
- **O4** — Warrant filing bureaucracy
- **O5** — Mahogany Trial's not-a-cradle
- **O6** — Copper Guild's longer horizon
- **O8** — Resonant Null's recoverable knowledge

Total: ~20 minutes. All edits to `codex.gd`. Adds emotional precision throughout.

### TIER 3 — New content (could do; medium)

- **N1** — New Codex concept "The First Hour"
- **N2** — New Codex entry "The Brass Lever"
- **N4** — 3-4 new notebook fragments referencing the First Hour
- **N3** — New event "The Master Pauses"
- **N5** — New event "You Have Been Offered a Side Door"

Total: ~2 hours. Adds Codex depth + 2 new events. Recommendable as a single batch, "First Hour pass."

### TIER 4 — Mechanical change (could do; isolated)

- **M1** — Sacrifice memory-cost beat ("You forgot —")

Total: ~30 minutes. Cruel and small. Big tonal payoff.

---

## §8. What the audit confirms

Three things worth saying explicitly:

1. **The world is internally healthy.** Two genuine contradictions, both one-line fixes. Everything else is either consistent or sharpenable. The pre-bible writing already had the bible's tone; the bible just made the tone explicit.

2. **The bible's hard constraints are not retroactively threatened.** Nothing in current canon names Operator-prime, specifies the First Hour's end, brings her back, or contradicts the no-antagonist rule. The Codex's "something is killing it" reading from Transmission #1 is the only edge case, and it's bible-compatible *as the Archiver's interpretation.*

3. **The bible's deliberate ambiguities are all preserved by current canon.** The catastrophe is never named. Operator-prime's name appears nowhere. The Renegade's relationship to her is undefined. The Guild's plan is unspecified. The corridors are walked but never described. We have not accidentally closed any door the bible wanted open.

The lore foundation is sound. The fixes are small. The new content opportunities are concrete and gated.

---

*End of audit. Recommended next: ship Tier 1 + Tier 2 together as a single "audit pass" commit, then decide on Tier 3 / Tier 4 separately.*
