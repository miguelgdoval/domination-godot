## game_state.gd — Global run state for a Trial Cycle.
## Autoloaded as "GameState".
extends Node

var round_index:    int = 0
var monedas:        int = 0
var difficulty:     int = Constants.Difficulty.NORMAL
var chosen_core:    int = 0   # index into Constants.CORE_*
var chosen_protocol: int = 0  # index into Constants.PROTOCOL_*
var box:            Box
var modules:        Array = []   # Array[Module] — equipped Calibration Modules
var module_slots:   int = Constants.BASE_MODULE_SLOTS

# ---------------------------------------------------------------------------
# Run initialisation
# ---------------------------------------------------------------------------
func start_run(p_core: int = 0, p_protocol: int = 0,
		p_difficulty: int = Constants.Difficulty.NORMAL) -> void:
	round_index     = 0
	monedas         = 0
	difficulty      = p_difficulty
	chosen_core     = p_core
	chosen_protocol = p_protocol
	box             = Box.create_for_core(p_core)
	modules         = []
	module_slots    = Constants.BASE_MODULE_SLOTS
	# Protocol starting bonus
	monedas += Constants.PROTOCOL_BONUS_MONEDAS[p_protocol]

# ---------------------------------------------------------------------------
# Round progression
# ---------------------------------------------------------------------------
func advance_round() -> void:
	round_index += 1

func award_monedas(unused_hands: int) -> int:
	var earned: int = Constants.MONEDAS_PER_ROUND
	earned += unused_hands * Constants.MONEDAS_PER_UNUSED_HAND
	if Constants.is_boss_round(round_index):
		earned += Constants.BOSS_MONEDAS_BONUS
	monedas += earned
	return earned

# ---------------------------------------------------------------------------
# Economy
# ---------------------------------------------------------------------------
func spend_monedas(amount: int) -> bool:
	if monedas < amount:
		return false
	monedas -= amount
	return true

# ---------------------------------------------------------------------------
# Module (Artifact) management
# ---------------------------------------------------------------------------

## Returns true if there is a free module slot.
func has_free_slot() -> bool:
	return modules.size() < module_slots

## Returns true if the player already owns a module with this id.
func owns_module(id: String) -> bool:
	for m in modules:
		if m.id == id:
			return true
	return false

## Equip a module. Returns false if no slot is available.
func add_module(m: Module) -> bool:
	if not has_free_slot():
		return false
	modules.append(m)
	if m.extra_slots > 0:
		module_slots += m.extra_slots
	return true

## Sell (remove) a module. Returns false if it would leave more modules than slots.
func remove_module(m: Module) -> bool:
	if not modules.has(m):
		return false
	# Selling a slot-giver would reduce capacity — ensure no overflow
	var new_slots: int = module_slots - m.extra_slots
	if new_slots < modules.size() - 1:
		return false   # would overflow; player must sell something else first
	modules.erase(m)
	module_slots -= m.extra_slots
	return true

func sell_module(m: Module) -> bool:
	if not remove_module(m):
		return false
	monedas += Constants.RARITY_SELL[m.rarity]
	return true

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

# ---------------------------------------------------------------------------
# Protocol helpers
# ---------------------------------------------------------------------------
func protocol_hand_size() -> int:
	return Constants.PROTOCOL_HAND_SIZES[chosen_protocol]

func protocol_hands() -> int:
	return Constants.PROTOCOL_HANDS[chosen_protocol]

func protocol_discards() -> int:
	return Constants.PROTOCOL_DISCARDS[chosen_protocol]

# ---------------------------------------------------------------------------
# Adjusted target (core scales difficulty)
# ---------------------------------------------------------------------------
func adjusted_target(p_round_index: int) -> int:
	var base: int = Constants.score_target(p_round_index)
	return int(base * Constants.CORE_TARGET_SCALE[chosen_core] / 100.0)
