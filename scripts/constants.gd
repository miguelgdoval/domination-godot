## constants.gd — Global constants and enums for Domination
## Autoloaded as "Constants"
extends Node

# ---------------------------------------------------------------------------
# Calibration Cores  (box variants chosen at run start)
# ---------------------------------------------------------------------------
const CORE_COUNT: int = 4
const CORE_NAMES: Array[String] = [
	"Standard Core", "Resonant Core", "Dense Array", "Void Lattice",
]
const CORE_RARITIES: Array[int] = [0, 1, 1, 2]  # Bone, Carved, Carved, Ivory
const CORE_DESCS: Array[String] = [
	"Full double-9 set — 110 tiles.\nBalanced and well-understood.",
	"Doubles only (0-0 through 9-9) — 50 tiles.\nEvery tile resonates. Multipliers run wild.",
	"Double-6 set — 84 tiles.\nLower pip ceiling, but chains form freely.",
	"Standard set + 10 Wild tiles — 120 tiles.\nUnstable flux. The Wilds connect to anything.",
]
const CORE_LORES: Array[String] = [
	"\"Standard field array. Recommended for initial calibration.\"",
	"\"All harmonics collapsed to pure resonance. The signal sings itself.\"",
	"\"A tighter grid. The Chronometer breathes easier at reduced amplitude.\"",
	"\"Something has contaminated the array. The Wilds answer to nothing—and everything.\"",
]
## Score target scale (applied as target × scale / 100).
## Resonant Core: all-doubles → massive multipliers → harder targets.
## Dense Array: max pip 6 → lower chips → easier targets.
## Void Lattice: wilds help chaining but don't score → slight reduction.
const CORE_TARGET_SCALE: Array[int] = [100, 160, 65, 90]

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
	"Hand 5 | Plays 6 | Discards 0\n+5 starting Monedas. No safety net.",
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
# Scoring thresholds for chain length bonus
# ---------------------------------------------------------------------------
const CHAIN_BONUS_SMALL:    int = 4   # chain >= 4 tiles → +1 mult
const CHAIN_BONUS_LARGE:    int = 7   # chain >= 7 tiles → +2 mult
const DOUBLE_MULT_BONUS:    int = 1   # each double  → +1 mult

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
const SCORE_TARGETS: Array[int] = [
	# Etapa 1 — The Mahogany Trial (rounds 1-4 + boss)
	100, 200, 340, 520, 750,
	# Etapa 2 — The Industrial Load (rounds 5-8 + boss)
	1050, 1550, 2300, 3400, 5000,
	# Etapa 3 — The Cold Singularity (rounds 9-12 + boss)
	7200, 10500, 15000, 21000, 30000,
	# Etapa 4 — The Archiver's Core — Hard mode only (rounds 13-16 + boss)
	43000, 62000, 88000, 125000, 175000,
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
	"SIGNAL DECAY",
	"RESONANCE LOCK",
	"TOTAL ENTROPY",
]
const BOSS_DESCS: Array[String] = [
	"Your Isolation Chamber is compressed.\nHand size –1 for this round.",
	"Discharge relays compromised.\nMaximum discards –2 for this round.",
	"The signal stutters under load.\nMaximum plays –1 for this round.",
	"All systems failing at once.\nHand size –1 and plays –1 for this round.",
]
## Delta applied to hand_size on boss rounds.
const BOSS_HAND_DELTA:    Array[int] = [-1,  0,  0, -1]
## Delta applied to max_discards on boss rounds (clamped to min 0).
const BOSS_DISCARD_DELTA: Array[int] = [ 0, -2,  0,  0]
## Delta applied to max_hands on boss rounds (clamped to min 1).
const BOSS_HANDS_DELTA:   Array[int] = [ 0,  0, -1, -1]
