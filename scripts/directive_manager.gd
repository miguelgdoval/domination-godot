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
		Directive.Type.CHIPS_60:         return r["chips"]   >= 60
		Directive.Type.TOTAL_250:        return r["total"]   >= 250
		Directive.Type.TOTAL_500:        return r["total"]   >= 500
		Directive.Type.MULT_5:           return r["mult"]    >= 5
		Directive.Type.NO_DOUBLES:       return r["doubles"] == 0 and r["length"] >= 3
		_: return false

func _eval_end(d: Directive) -> bool:
	match d.type:
		Directive.Type.WIN_HANDS_LEFT_2: return _rm.hands_remaining >= 2
		Directive.Type.NO_DISCARDS_USED: return _rm.discards_remaining == _rm.max_discards
		_: return false
