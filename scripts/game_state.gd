## game_state.gd — Global run state for a Trial Cycle.
## Autoloaded as "GameState".
extends Node

var round_index:     int = 0
var monedas:         int = 0
var difficulty:      int = Constants.Difficulty.NORMAL
var chosen_core:     int = 0   # index into Constants.CORE_*
var chosen_protocol: int = 0   # index into Constants.PROTOCOL_*
var box:             Box
var modules:         Array = []   # Array[Module] — equipped Calibration Modules
var module_slots:    int = Constants.BASE_MODULE_SLOTS
# Consumables
var reinforcements:  Array = []   # Array[Reinforcement] — up to MAX_REINFORCEMENTS
const MAX_REINFORCEMENTS: int = 3
# Mastery contracts
var active_contracts:    Array = []   # Array[MasteryContract]
var completed_contracts: Array = []   # Array[String] (ids)
# Run stats (reset each run)
var total_chronos:   int = 0   # cumulative Chronos across all rounds
var best_hand:       int = 0   # highest single-hand Chronos this run
var hands_played:    int = 0   # total hands played this run
var doubles_played:  int = 0   # total doubles placed this run (for contracts)
var longest_chain:   int = 0   # max chain length reached in any round this run
var best_tier:       int = -1  # max tier index reached in any round this run (-1 = none)
var is_daily_run:    bool = false   # set by start_daily_run; controls run-end recording

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
	modules             = []
	module_slots        = Constants.BASE_MODULE_SLOTS
	reinforcements      = []
	active_contracts    = []
	completed_contracts = []
	total_chronos       = 0
	best_hand           = 0
	hands_played        = 0
	doubles_played      = 0
	longest_chain       = 0
	best_tier           = -1
	is_daily_run        = false
	# Protocol starting bonus
	monedas += Constants.PROTOCOL_BONUS_MONEDAS[p_protocol]
	# Core profile — preloaded modules, extra monedas, etc. for cores that
	# define more than just a custom box. Empty dict for cores that don't.
	_apply_core_profile(p_core)

## Apply the per-core profile (preloaded modules, starting monedas bump,
## etc.) declared in `Constants.CORE_PROFILES`. Called from start_run
## after the baseline state has been set up.
func _apply_core_profile(p_core: int) -> void:
	if p_core < 0 or p_core >= Constants.CORE_PROFILES.size():
		return
	var profile: Dictionary = Constants.CORE_PROFILES[p_core]
	if profile.is_empty():
		return
	monedas += int(profile.get("start_monedas", 0))
	for mid in profile.get("start_modules", []):
		for m in ModuleDB.all():
			if m.id == String(mid):
				modules.append(m)
				module_slots += m.extra_slots
				# Codex: preloaded modules count as discovered too —
				# the Operator equips them at the Window before play
				# begins, same encounter trigger as a shop purchase.
				SaveManager.unlock_codex("module_" + m.id)
				break

## Begin a daily-trial run. Reseeds Godot's RNG with today's deterministic
## seed so every player faces the same box order, shop offers, etc., then
## kicks off a normal run on the Standard core / Equilibrium protocol so
## the playing field stays uniform. Sets `is_daily_run` so the run-end
## screen can tell the difference and record the attempt.
func start_daily_run() -> void:
	seed(SaveManager.today_daily_seed())
	start_run(0, 0, Constants.Difficulty.NORMAL)
	is_daily_run = true

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
	# COIN_PER_ROUND modules — included in the displayed total
	for m in modules:
		if m.effect_type == Module.EffectType.COIN_PER_ROUND:
			earned += m.effect_value
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

## Returns the active boss-effect kind for the current round, or
## STAT_CUT (= no special hook) for non-boss rounds. Scoring and the
## renderer call this to honour effects like RESONANCE_INVERSION.
func active_boss_effect() -> int:
	if not is_boss_round():
		return Constants.BossEffect.STAT_CUT
	var e: int = current_etapa()
	if e < 0 or e >= Constants.BOSS_EFFECT_TYPE.size():
		return Constants.BossEffect.STAT_CUT
	return Constants.BOSS_EFFECT_TYPE[e]

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

func record_hand(score: int, chain_doubles: int = 0) -> void:
	total_chronos  += score
	hands_played   += 1
	doubles_played += chain_doubles
	if score > best_hand:
		best_hand = score

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

func module_hand_size_bonus() -> int:
	var b := 0
	for m in modules:
		if m.effect_type == Module.EffectType.HAND_SIZE_BONUS:
			b += m.effect_value
	return b

func module_hands_bonus() -> int:
	var b := 0
	for m in modules:
		if m.effect_type == Module.EffectType.EXTRA_HAND:
			b += m.effect_value
	return b

func module_discard_bonus() -> int:
	var b := 0
	for m in modules:
		if m.effect_type == Module.EffectType.DISCARD_BONUS:
			b += m.effect_value
	return b

# ---------------------------------------------------------------------------
# Adjusted target (core scales difficulty)
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Module economy helpers
# ---------------------------------------------------------------------------
func shop_discount_pct() -> int:
	var total := 0
	for m in modules:
		if m.effect_type == Module.EffectType.SHOP_DISCOUNT:
			total += m.effect_value
	return clampi(total, 0, 80)

## Per-core shop price modifier — added flat to every shop item's cost
## AFTER any percentage discount. Used by the Obsidian Core (+2) to
## offset its preloaded Obsidian module.
func core_shop_price_delta() -> int:
	if chosen_core < 0 or chosen_core >= Constants.CORE_PROFILES.size():
		return 0
	return int(Constants.CORE_PROFILES[chosen_core].get("shop_price_delta", 0))

func chain_coin_bonus(chain_length: int) -> int:
	var total := 0
	for m in modules:
		if m.effect_type == Module.EffectType.CHAIN_COIN_BONUS:
			if chain_length >= m.effect_param:
				total += m.effect_value
	return total

## Persistent-chain variant: only awards a module's bonus if its threshold
## was crossed by THIS play (prev < threshold ≤ new). Prevents the chain
## from re-triggering coin rewards on every subsequent play of the round.
func chain_coin_bonus_crossed(prev_length: int, new_length: int) -> int:
	var total := 0
	for m in modules:
		if m.effect_type == Module.EffectType.CHAIN_COIN_BONUS:
			if prev_length < m.effect_param and new_length >= m.effect_param:
				total += m.effect_value
	return total

# ---------------------------------------------------------------------------
# Reinforcement helpers
# ---------------------------------------------------------------------------
func has_reinforcement_slot() -> bool:
	return reinforcements.size() < MAX_REINFORCEMENTS

func add_reinforcement(r: Reinforcement) -> bool:
	if not has_reinforcement_slot():
		return false
	reinforcements.append(r)
	return true

func use_reinforcement(r: Reinforcement) -> bool:
	if not reinforcements.has(r):
		return false
	reinforcements.erase(r)
	return true

# ---------------------------------------------------------------------------
# Mastery contract helpers
# ---------------------------------------------------------------------------
func add_contract(c: MasteryContract) -> void:
	active_contracts.append(c)

func complete_contract(c: MasteryContract) -> void:
	active_contracts.erase(c)
	completed_contracts.append(c.id)
	monedas += c.reward_monedas

# ---------------------------------------------------------------------------
# Adjusted target (core scales difficulty)
# ---------------------------------------------------------------------------
func adjusted_target(p_round_index: int) -> int:
	var base: int = Constants.score_target(p_round_index)
	return int(base * Constants.CORE_TARGET_SCALE[chosen_core] / 100.0)
