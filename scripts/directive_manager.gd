## directive_manager.gd — Manages the active Directives for one round.
## Checks completion after each Pulse and at round end.
class_name DirectiveManager
extends RefCounted

signal directive_completed(directive: Directive, earned: int)

var active: Array[Directive] = []
var _rm: RoundManager   # set via setup(); used for round-end checks

func setup(rm: RoundManager, count: int = 2) -> void:
	_rm = rm
	var pool: Array[Directive] = DirectiveDB.all()
	pool.shuffle()
	active.clear()
	for i in range(mini(count, pool.size())):
		active.append(pool[i])

## Call after play_chain() resolves. Returns Monedas earned.
func check_play(result: Dictionary) -> int:
	var earned: int = 0
	for d in active:
		if d.completed:
			continue
		if _eval_play(d, result):
			d.completed = true
			earned += d.reward
			directive_completed.emit(d, d.reward)
	return earned

## Call when the round is won. Returns Monedas earned.
func check_round_win() -> int:
	var earned: int = 0
	for d in active:
		if d.completed:
			continue
		if _eval_end(d):
			d.completed = true
			earned += d.reward
			directive_completed.emit(d, d.reward)
	return earned

func all_completed() -> bool:
	for d in active:
		if not d.completed:
			return false
	return true

# ---------------------------------------------------------------------------
# Evaluation
# ---------------------------------------------------------------------------
func _eval_play(d: Directive, r: Dictionary) -> bool:
	match d.type:
		Directive.Type.CHAIN_DOUBLES_3:  return r["doubles"] >= 3
		Directive.Type.CHAIN_LENGTH_5:   return r["length"]  >= 5
		Directive.Type.CHAIN_LENGTH_7:   return r["length"]  >= 7
		Directive.Type.CHAIN_LENGTH_11:  return r["length"]  >= 11
		Directive.Type.CHAIN_LENGTH_16:  return r["length"]  >= 16
		Directive.Type.CHIPS_60:         return r["chips"]   >= 60
		Directive.Type.TOTAL_250:        return r["total"]   >= 250
		Directive.Type.TOTAL_500:        return r["total"]   >= 500
		Directive.Type.TOTAL_1000:       return r["total"]   >= 1000
		Directive.Type.MULT_5:           return r["mult"]    >= 5
		Directive.Type.MULT_10:          return r["mult"]    >= 10
		Directive.Type.NO_DOUBLES:       return r["doubles"] == 0 and r["length"] >= 3
		Directive.Type.NO_DOUBLES_LONG:  return r["doubles"] == 0 and r["length"] >= 7
		Directive.Type.HIGH_PIP_CHAIN:   return _high_pip_chain_check(r)
		Directive.Type.WILD_USED:        return _chain_has_wild()
		_: return false

## True if the chain is at least 5 tiles AND its average non-wild pip
## total per tile is ≥ 6. Reads the live current_chain rather than the
## scoring result so we can inspect tile pips directly.
func _high_pip_chain_check(r: Dictionary) -> bool:
	if r["length"] < 5:
		return false
	if _rm == null or _rm.current_chain == null:
		return false
	var sum_pips: int = 0
	var count:    int = 0
	for tile in _rm.current_chain.tiles:
		if tile.is_wild:
			continue
		sum_pips += tile.total_pips()
		count    += 1
	if count == 0:
		return false
	return sum_pips >= count * 6

func _chain_has_wild() -> bool:
	if _rm == null or _rm.current_chain == null:
		return false
	for tile in _rm.current_chain.tiles:
		if tile.is_wild:
			return true
	return false

func _eval_end(d: Directive) -> bool:
	match d.type:
		Directive.Type.WIN_HANDS_LEFT_2: return _rm.hands_remaining >= 2
		Directive.Type.NO_DISCARDS_USED: return _rm.discards_remaining == _rm.max_discards
		_: return false
