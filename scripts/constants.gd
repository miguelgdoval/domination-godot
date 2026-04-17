## constants.gd — Global constants and enums for Domination
## Autoloaded as "Constants"
extends Node

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
	150, 250, 400, 600, 900,
	# Etapa 2 — The Industrial Load (rounds 5-8 + boss)
	1400, 2000, 3000, 4500, 6500,
	# Etapa 3 — The Cold Singularity (rounds 9-12 + boss)
	9000, 13000, 19000, 27000, 40000,
	# Etapa 4 — The Archiver's Core — Hard mode only (rounds 13-16 + boss)
	58000, 82000, 120000, 170000, 250000,
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
