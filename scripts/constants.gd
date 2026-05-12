## constants.gd — Global constants and enums for Domination
## Autoloaded as "Constants"
extends Node

# ---------------------------------------------------------------------------
# Calibration Cores  (box variants chosen at run start)
# ---------------------------------------------------------------------------
const CORE_COUNT: int = 10
const CORE_NAMES: Array[String] = [
	"Standard Core", "Resonant Core", "Dense Array", "Void Lattice",
	"Slimline", "Specialist Core",
	"The Arsenal", "The Runner", "Obsidian Core",
	"Blank Slate",
]
const CORE_RARITIES: Array[int] = [0, 1, 1, 2, 1, 2, 1, 2, 3, 2]
const CORE_DESCS: Array[String] = [
	"Full double-9 set — 110 tiles.\nBalanced and well-understood.",
	"Doubles only (0-0 through 9-9) — 50 tiles.\nEvery tile resonates. Multipliers run wild.",
	"Double-6 set — 84 tiles.\nLower pip ceiling, but chains form freely.",
	"Standard set + 10 Wild tiles — 120 tiles.\nUnstable flux. The Wilds connect to anything.",
	"One copy of each tile — 55 tiles.\nBox drains fast. Make every placement count.",
	"Only tiles with a face ≥ 6, ×2 — 68 tiles.\nFewer matching faces, but every tile is heavy.",
	"Standard set + 2 Bone modules pre-equipped.\nHit the ground running.",
	"Standard set, +4 starting Coins, +1 directive slot.\nContract specialist build.",
	"Standard set + 1 Obsidian module pre-equipped.\nShop prices +2. Power has its cost.",
	"Blank-heavy box (130 tiles) + Null Recoder pre-equipped.\nZeroes become your strongest signal.",
]
const CORE_LORES: Array[String] = [
	"\"Standard field array. Recommended for initial calibration.\"",
	"\"All harmonics collapsed to pure resonance. The signal sings itself.\"",
	"\"A tighter grid. The Chronometer breathes easier at reduced amplitude.\"",
	"\"Something has contaminated the array. The Wilds answer to nothing—and everything.\"",
	"\"Reduced redundancy. The simulation runs lean, fast, and unforgiving.\"",
	"\"Only the loud frequencies. The faint signals have been filtered out.\"",
	"\"Pre-loaded with field gear. The Operator does not improvise.\"",
	"\"A backchannel kit. The Copper Guild knows your name.\"",
	"\"The Renegade Mechanic's signature. The Archiver would disapprove.\"",
	"\"The Chronometer found signal in the silence first.\"",
]
## Score target scale (applied as target × scale / 100).
const CORE_TARGET_SCALE: Array[int] = [100, 160, 65, 90, 85, 130, 110, 100, 110, 95]

## Unlock gates per core. Index 0 is the starter — always unlocked, the
## description is just for completeness. The other entries say what the
## player must accomplish (across any prior run) to unlock the core.
##
## Format: { "type": "best_round" | "wins", "value": int, "label": String }
## Checked against SaveManager.get_lifetime_stats() at the start screen.
const CORE_UNLOCKS: Array[Dictionary] = [
	{ "type": "always", "value": 0,  "label": "Available from the first run." },
	{ "type": "best_round", "value": 5,  "label": "Clear the first Entropy Failure (round 5)." },
	{ "type": "best_round", "value": 10, "label": "Clear the second Entropy Failure (round 10)." },
	{ "type": "wins",       "value": 1,  "label": "Recalibrate the Chronometer at least once." },
	{ "type": "best_round", "value": 5,  "label": "Clear the first Entropy Failure (round 5)." },
	{ "type": "best_round", "value": 10, "label": "Clear the second Entropy Failure (round 10)." },
	{ "type": "best_round", "value": 5,  "label": "Clear the first Entropy Failure (round 5)." },
	{ "type": "best_round", "value": 10, "label": "Clear the second Entropy Failure (round 10)." },
	{ "type": "wins",       "value": 1,  "label": "Recalibrate the Chronometer at least once." },
	{ "type": "best_round", "value": 10, "label": "Clear the second Entropy Failure (round 10)." },
]

## Per-core "profile": a small dict describing extra starting state that
## the standard `start_run` flow doesn't cover (preloaded modules, extra
## starting monedas / directives, shop pricing modifier, etc.). Indexed
## the same as CORE_NAMES; an empty dict means "no extras".
##
## Recognised keys:
##   start_modules     : Array[String]  — module IDs equipped at run start.
##   start_monedas     : int            — added to the protocol bonus.
##   start_directives  : int            — overrides the default 2 active.
##   shop_price_delta  : int            — added to every shop item's cost.
const CORE_PROFILES: Array[Dictionary] = [
	{},                                                          # Standard
	{},                                                          # Resonant
	{},                                                          # Dense
	{},                                                          # Void
	{},                                                          # Slimline
	{},                                                          # Specialist
	{"start_modules": ["brass_gear", "copper_coil"]},            # Arsenal
	{"start_monedas": 4, "start_directives": 3},                 # Runner
	{"start_modules": ["the_dominator"], "shop_price_delta": 2}, # Obsidian
	{"start_modules": ["null_recoder"]},                         # Blank Slate
]

# ---------------------------------------------------------------------------
# Etapa visual themes  (index 0-3, one per etapa)
# ---------------------------------------------------------------------------
const ETAPA_BG: Array = [
	Color(0.08, 0.07, 0.05),   # Mahogany — warm dark brown
	Color(0.07, 0.08, 0.09),   # Industrial — cold steel
	Color(0.04, 0.05, 0.10),   # Singularity — deep blue-black
	Color(0.07, 0.04, 0.10),   # Archiver — deep purple
]
const ETAPA_TABLE: Array = [
	Color(0.07, 0.09, 0.06),
	Color(0.06, 0.07, 0.09),
	Color(0.03, 0.05, 0.10),
	Color(0.06, 0.03, 0.09),
]
const ETAPA_TABLE_BORDER: Array = [
	Color(0.28, 0.24, 0.14),
	Color(0.28, 0.30, 0.18),
	Color(0.14, 0.22, 0.44),
	Color(0.34, 0.14, 0.44),
]
const ETAPA_PANEL: Array = [
	Color(0.13, 0.11, 0.08, 0.95),
	Color(0.10, 0.11, 0.14, 0.95),
	Color(0.07, 0.08, 0.15, 0.95),
	Color(0.11, 0.07, 0.16, 0.95),
]
const ETAPA_ACCENT: Array = [
	Color(0.85, 0.70, 0.30),   # amber gold
	Color(0.95, 0.58, 0.20),   # industrial orange
	Color(0.28, 0.88, 0.95),   # cold cyan
	Color(0.88, 0.72, 0.95),   # archiver violet
]

# ---------------------------------------------------------------------------
# Protocols  (operational modifiers chosen at run start)
# ---------------------------------------------------------------------------
const PROTOCOL_COUNT: int = 4
const PROTOCOL_NAMES: Array[String] = [
	"Equilibrium Protocol",
	"Compression Protocol",
	"Overload Protocol",
	"Cascade Protocol",
]
const PROTOCOL_RARITIES: Array[int] = [0, 1, 1, 2]
const PROTOCOL_DESCS: Array[String] = [
	"Hand 5 | Plays 4 | Discards 2\nThe balanced operational parameter set.",
	"Hand 4 | Plays 4 | Discards 4\nSmaller hand, far more flexibility.",
	"Hand 6 | Plays 5 | Discards 1\nMaximum throughput. Minimal fallback.",
	"Hand 5 | Plays 6 | Discards 0\n+5 starting Coins. No safety net.",
]
const PROTOCOL_LORES: Array[String] = [
	"\"Operational parameters nominal. Proceed as calibrated.\"",
	"\"Compress the intake. Route excess energy to the discharge relay.\"",
	"\"Maximum throughput engaged. Hesitation is entropy.\"",
	"\"All discharge ports sealed. Find the flow—or fail the Chronometer.\"",
]
const PROTOCOL_HAND_SIZES:    Array[int] = [5, 4, 6, 5]
const PROTOCOL_HANDS:         Array[int] = [4, 4, 5, 6]
const PROTOCOL_DISCARDS:      Array[int] = [2, 4, 1, 0]
const PROTOCOL_BONUS_MONEDAS: Array[int] = [0, 0, 0, 5]

## Unlock gates per protocol. Same format as CORE_UNLOCKS.
const PROTOCOL_UNLOCKS: Array[Dictionary] = [
	{ "type": "always", "value": 0,  "label": "Available from the first run." },
	{ "type": "best_round", "value": 5,  "label": "Clear the first Entropy Failure (round 5)." },
	{ "type": "best_round", "value": 10, "label": "Clear the second Entropy Failure (round 10)." },
	{ "type": "wins",       "value": 1,  "label": "Recalibrate the Chronometer at least once." },
]

## Returns true if the unlock requirement in `gate` is met by the given
## lifetime-stats dict (from SaveManager.get_lifetime_stats()). The
## "always" type is the starter gate (everyone has it).
static func unlock_met(gate: Dictionary, lifetime: Dictionary) -> bool:
	match gate.get("type", "always"):
		"always":     return true
		"best_round": return int(lifetime.get("best_round", 0)) >= int(gate["value"])
		"wins":       return int(lifetime.get("wins",       0)) >= int(gate["value"])
		_: return true

## Convenience wrapper: is core index `i` currently unlocked?
static func is_core_unlocked(i: int, lifetime: Dictionary) -> bool:
	if i < 0 or i >= CORE_UNLOCKS.size():
		return false
	return unlock_met(CORE_UNLOCKS[i], lifetime)

static func is_protocol_unlocked(i: int, lifetime: Dictionary) -> bool:
	if i < 0 or i >= PROTOCOL_UNLOCKS.size():
		return false
	return unlock_met(PROTOCOL_UNLOCKS[i], lifetime)

# ---------------------------------------------------------------------------
# Achievements — visual progression markers, independent of core/protocol
# unlock gates. Earned by hitting lifetime-stat thresholds. No additional
# tracking required: derived from SaveManager.get_lifetime_stats().
# ---------------------------------------------------------------------------
## Each entry:
##   id   — stable string for save persistence
##   name — short display title
##   icon — single-glyph badge symbol
##   desc — short unlock condition shown on the badge card
##   type — stat key in lifetime stats: best_tier / best_round / wins /
##          daily_streak / hands_played / modules_seen / doubles_played
##   value — threshold the stat must meet
const ACHIEVEMENTS: Array[Dictionary] = [
	{"id": "tier_pulse",      "name": "First Pulse",       "icon": "▷",
	 "desc": "Reach the Pulse tier (4-tile chain).",
	 "type": "best_tier",      "value": 0},
	{"id": "tier_cohesion",   "name": "Cohesion Achieved", "icon": "◇",
	 "desc": "Reach the Cohesion tier (7-tile chain).",
	 "type": "best_tier",      "value": 1},
	{"id": "tier_resonance",  "name": "Resonance Master",  "icon": "◆",
	 "desc": "Reach the Resonance tier (11-tile chain).",
	 "type": "best_tier",      "value": 2},
	{"id": "tier_harmonic",   "name": "Harmonic Pulse",    "icon": "❖",
	 "desc": "Reach the Harmonic tier (16-tile chain).",
	 "type": "best_tier",      "value": 3},
	{"id": "tier_singularity","name": "The Singularity",   "icon": "✦",
	 "desc": "Reach the Singularity tier (21+ chain).",
	 "type": "best_tier",      "value": 4},
	{"id": "boss1",           "name": "First Failure",     "icon": "I",
	 "desc": "Clear the first Entropy Failure.",
	 "type": "best_round",     "value": 5},
	{"id": "boss2",           "name": "Second Failure",    "icon": "II",
	 "desc": "Clear the second Entropy Failure.",
	 "type": "best_round",     "value": 10},
	{"id": "recalibrator",    "name": "Recalibrator",      "icon": "⬡",
	 "desc": "Recalibrate the Chronometer (win a run).",
	 "type": "wins",           "value": 1},
	{"id": "streak3",         "name": "Three-Day Pulse",   "icon": "✺",
	 "desc": "Win 3 daily trials in a row.",
	 "type": "daily_streak",   "value": 3},
	{"id": "streak7",         "name": "Week of Order",     "icon": "✺✺",
	 "desc": "Win 7 daily trials in a row.",
	 "type": "daily_streak",   "value": 7},
	{"id": "centurion",       "name": "Centurion",         "icon": "✱",
	 "desc": "Play 100 hands across all runs.",
	 "type": "hands_played",   "value": 100},
	{"id": "collector",       "name": "Module Collector",  "icon": "▢",
	 "desc": "See 20 unique modules across all runs.",
	 "type": "modules_seen",   "value": 20},
	{"id": "hard_recal",      "name": "Hard Recalibrator", "icon": "⬢",
	 "desc": "Recalibrate the Chronometer on Hard difficulty.",
	 "type": "hard_wins",      "value": 1},
	{"id": "veteran",         "name": "Veteran",           "icon": "✱✱",
	 "desc": "Play 500 hands across all runs.",
	 "type": "hands_played",   "value": 500},
	{"id": "doubles_specialist","name": "Doubles Specialist","icon": "⊕",
	 "desc": "Place 100 doubles across all runs.",
	 "type": "doubles_played", "value": 100},
	{"id": "chronos_hoarder", "name": "Chronos Hoarder",   "icon": "♔",
	 "desc": "Earn 1,000,000 total Chronos across all runs.",
	 "type": "chronos",        "value": 1000000},
	{"id": "connoisseur",     "name": "Module Connoisseur","icon": "▣",
	 "desc": "See 30 unique modules across all runs.",
	 "type": "modules_seen",   "value": 30},
]

## Returns true if the achievement at `idx` is earned given a lifetime
## stats dict (from SaveManager.get_lifetime_stats() or daily helpers).
## `daily_streak` is passed in via the `extra` arg since it's computed
## by the SaveManager rather than a flat key on lifetime_stats.
static func achievement_earned(idx: int, lifetime: Dictionary,
		daily_streak: int = 0) -> bool:
	if idx < 0 or idx >= ACHIEVEMENTS.size():
		return false
	var a: Dictionary = ACHIEVEMENTS[idx]
	var t: String = a.get("type", "")
	var v: int    = int(a.get("value", 0))
	match t:
		"best_tier":      return int(lifetime.get("best_tier", -1)) >= v
		"best_round":     return int(lifetime.get("best_round", 0)) >= v
		"wins":           return int(lifetime.get("wins", 0)) >= v
		"hard_wins":      return int(lifetime.get("hard_wins", 0)) >= v
		"chronos":        return int(lifetime.get("chronos", 0)) >= v
		"hands_played":   return int(lifetime.get("hands_played", 0)) >= v
		"doubles_played": return int(lifetime.get("doubles_played", 0)) >= v
		"modules_seen":   return int(Array(lifetime.get("modules_seen", [])).size()) >= v
		"daily_streak":   return daily_streak >= v
		_: return false

# ---------------------------------------------------------------------------
# Rarity
# ---------------------------------------------------------------------------
enum Rarity { BONE = 0, CARVED = 1, IVORY = 2, OBSIDIAN = 3 }
const RARITY_NAMES: Array[String] = ["Bone", "Carved", "Ivory", "Obsidian"]
const RARITY_COSTS: Array[int]    = [2, 4, 6, 8]
const RARITY_SELL:  Array[int]    = [1, 2, 3, 4]

# ---------------------------------------------------------------------------
# Tile set
# ---------------------------------------------------------------------------
const MAX_PIP: int = 9  # Double-9 set

# ---------------------------------------------------------------------------
# Round defaults (overridable by Calibration Core / Modules)
# ---------------------------------------------------------------------------
const DEFAULT_HAND_SIZE:     int = 5
const DEFAULT_HANDS_PER_ROUND: int = 4
const DEFAULT_DISCARDS:      int = 2

# ---------------------------------------------------------------------------
# Module slots
# ---------------------------------------------------------------------------
const BASE_MODULE_SLOTS: int = 4
const MAX_MODULE_SLOTS:  int = 6

# ---------------------------------------------------------------------------
# Scoring thresholds for chain length bonus (persistent-chain tiers)
# Highest tier whose threshold the chain meets is applied (not stacked).
# Tiers in ascending order — names are surfaced to UX.
# ---------------------------------------------------------------------------
const CHAIN_TIER_MIN:    Array[int]    = [4,       7,          11,          16,         21          ]
const CHAIN_TIER_BONUS:  Array[int]    = [1,       2,          4,           7,          12          ]
const CHAIN_TIER_NAMES:  Array[String] = ["Pulse", "Cohesion", "Resonance", "Harmonic", "Singularity"]

# Legacy aliases — kept so existing UI references still resolve.
const CHAIN_BONUS_SMALL:    int = 4   # chain >= 4 tiles → +1 mult
const CHAIN_BONUS_LARGE:    int = 7   # chain >= 7 tiles → +2 mult
const DOUBLE_MULT_BONUS:    int = 1   # each double  → +1 mult
## Doubles past this threshold contribute half the per-double mult bonus.
## Keeps doubles strong without letting all-doubles chains exponentially
## outscale every other build under the persistent-chain mechanic.
const DOUBLES_FULL_THRESHOLD: int = 5

## Default chip contribution for a Wild tile per scored placement. Used to
## be 0 (wilds were tax tiles unless a WILD_PIP_VALUE module saved them);
## now they always pull their weight at base 10 chips, and modules still
## upgrade them above that. Roughly equivalent to a 5|5 tile.
const WILD_BASE_CHIPS: int = 10

# ---------------------------------------------------------------------------
# Economy
# ---------------------------------------------------------------------------
const MONEDAS_PER_ROUND:       int = 3
const MONEDAS_PER_UNUSED_HAND: int = 1
const BOSS_MONEDAS_BONUS:      int = 2

# ---------------------------------------------------------------------------
# Chronos (score) targets — indexed from 0 (round 1 = index 0)
# Normal: indices 0-14 (15 rounds)  Hard: indices 0-19 (20 rounds)
# ---------------------------------------------------------------------------
## Targets are calibrated for the persistent-chain mechanic: a single chain
## grows across all hands of a round and is scored as one final structure.
## Curve is roughly 2× the previous per-hand-scoring values, with steeper
## late scaling because module compounding lands harder on a long chain.
const SCORE_TARGETS: Array[int] = [
	# Etapa 1 — The Mahogany Trial (rounds 1-4 + boss)
	200, 350, 550, 900, 1400,
	# Etapa 2 — The Industrial Load (rounds 5-8 + boss)
	2200, 3300, 5000, 8000, 12000,
	# Etapa 3 — The Cold Singularity (rounds 9-12 + boss)
	18000, 28000, 45000, 70000, 110000,
	# Etapa 4 — The Archiver's Core — Hard mode only (rounds 13-16 + boss)
	160000, 240000, 360000, 540000, 800000,
]

# Boss rounds are index 4, 9, 14, 19 (every 5th, 0-indexed)
const ROUNDS_PER_ETAPA: int = 5  # 4 regular + 1 boss

# Etapa names and aesthetics
const ETAPA_NAMES: Array[String] = [
	"The Mahogany Trial",
	"The Industrial Load",
	"The Cold Singularity",
	"The Archiver's Core",
]

# ---------------------------------------------------------------------------
# Difficulty
# ---------------------------------------------------------------------------
enum Difficulty { NORMAL = 0, HARD = 1 }
const ETAPAS_NORMAL: int = 3
const ETAPAS_HARD:   int = 4

func total_rounds(difficulty: Difficulty) -> int:
	var etapas = ETAPAS_HARD if difficulty == Difficulty.HARD else ETAPAS_NORMAL
	return etapas * ROUNDS_PER_ETAPA

func is_boss_round(round_index: int) -> bool:
	# round_index is 0-based; boss rounds are at positions 4, 9, 14, 19
	return (round_index + 1) % ROUNDS_PER_ETAPA == 0

func etapa_for_round(round_index: int) -> int:
	return round_index / ROUNDS_PER_ETAPA

func score_target(round_index: int) -> int:
	if round_index < SCORE_TARGETS.size():
		return SCORE_TARGETS[round_index]
	return SCORE_TARGETS[-1]

# ---------------------------------------------------------------------------
# Boss effects — one per etapa (index 0-3)
# ---------------------------------------------------------------------------
const BOSS_NAMES: Array[String] = [
	"FREQUENCY DRAIN",
	"MIRROR DECAY",
	"RESONANCE INVERSION",
	"GHOST CHAIN",
]
const BOSS_DESCS: Array[String] = [
	"Your Isolation Chamber is compressed.\nHand size –1 for this round.",
	"Pip values mirror across the threshold.\nEach pip scores as (9 – pip).\nLow tiles are now your strongest.",
	"Self-referential flows have inverted polarity.\nEach double SUBTRACTS from your multiplier\ninstead of adding to it.",
	"The Archive forgets what it has seen.\nA third of your placed tiles fade from view.\nTrust your memory.",
]
## Boss arc:
##   • Boss 1 — STAT_CUT. The gentle intro: small hand, normal everything.
##   • Boss 2 — MIRROR_DECAY. Pip-chip contribution inverted. The doubles
##     and high-pip stacks the player has been building suddenly underperform;
##     low-pip tiles (especially blanks) become valuable.
##   • Boss 3 — RESONANCE_INVERSION. Doubles flip sign in the mult math,
##     so the doubles-stack build becomes a liability for one round.
##   • Boss 4 — GHOST_CHAIN. Hard-mode final boss: a third of the chain's
##     placed tiles render near-invisible, forcing the player to remember
##     pip values for connection planning. No stat cuts.
##
## Delta applied to hand_size on boss rounds.
const BOSS_HAND_DELTA:    Array[int] = [-1,  0,  0,  0]
## Delta applied to max_discards on boss rounds (clamped to min 0).
const BOSS_DISCARD_DELTA: Array[int] = [ 0,  0,  0,  0]
## Delta applied to max_hands on boss rounds (clamped to min 1).
const BOSS_HANDS_DELTA:   Array[int] = [ 0,  0,  0,  0]

## Boss effect "kind" — drives scoring overrides and render-time tweaks.
## STAT_CUT bosses just lean on the deltas above; special effects need
## scoring or display logic to honour them.
enum BossEffect {
	STAT_CUT,            # No special hook; uses the stat deltas only.
	MIRROR_DECAY,        # Each pip's chip contribution is (9 - pip).
	RESONANCE_INVERSION, # Doubles count NEGATIVELY toward mult.
	GHOST_CHAIN,         # ~1/3 of chain tiles render at low opacity.
}
const BOSS_EFFECT_TYPE: Array[int] = [
	BossEffect.STAT_CUT,
	BossEffect.MIRROR_DECAY,
	BossEffect.RESONANCE_INVERSION,
	BossEffect.GHOST_CHAIN,
]
