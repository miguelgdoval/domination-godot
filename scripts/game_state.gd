## game_state.gd — Global run state for a Trial Cycle.
## Autoloaded as "GameState". Persists across rounds within a single run.
extends Node

# ---------------------------------------------------------------------------
# Run state
# ---------------------------------------------------------------------------
var round_index:    int = 0   # 0-based current round
var monedas:        int = 0
var difficulty:     int = Constants.Difficulty.NORMAL
var box:            Box       # the Operator's tile supply
var modules:        Array     # equipped Calibration Modules (Artifacts)
var directives:     Array     # active Contracts
var module_slots:   int = Constants.BASE_MODULE_SLOTS

# ---------------------------------------------------------------------------
# Initialise / reset
# ---------------------------------------------------------------------------
func start_run(p_difficulty: int = Constants.Difficulty.NORMAL) -> void:
	round_index  = 0
	monedas      = 0
	difficulty   = p_difficulty
	box          = Box.create_standard()
	modules      = []
	directives   = []
	module_slots = Constants.BASE_MODULE_SLOTS

# ---------------------------------------------------------------------------
# Round progression
# ---------------------------------------------------------------------------
func advance_round() -> void:
	round_index += 1

## Award Monedas after a successful round.
## Returns the amount awarded.
func award_monedas(unused_hands: int) -> int:
	var earned: int = Constants.MONEDAS_PER_ROUND
	earned += unused_hands * Constants.MONEDAS_PER_UNUSED_HAND
	if Constants.is_boss_round(round_index):
		earned += Constants.BOSS_MONEDAS_BONUS
	monedas += earned
	return earned

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func is_boss_round() -> bool:
	return Constants.is_boss_round(round_index)

func current_etapa() -> int:
	return Constants.etapa_for_round(round_index)

func etapa_name() -> String:
	var e: int = current_etapa()
	if e < Constants.ETAPA_NAMES.size():
		return Constants.ETAPA_NAMES[e]
	return "Unknown"

func total_rounds() -> int:
	return Constants.total_rounds(difficulty)

func is_run_complete() -> bool:
	return round_index >= total_rounds()

func round_display() -> String:
	return "Round %d / %d" % [round_index + 1, total_rounds()]
