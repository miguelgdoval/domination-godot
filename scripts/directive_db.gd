## directive_db.gd — Pool of all available Directives.
class_name DirectiveDB
extends RefCounted

static func all() -> Array[Directive]:
	return [
		_make(Directive.Type.CHAIN_DOUBLES_3,  "Play a chain containing 3+ doubles",          2),
		_make(Directive.Type.CHAIN_LENGTH_5,   "Play a chain of 5 or more tiles",             2),
		_make(Directive.Type.CHAIN_LENGTH_7,   "Play a chain of 7 or more tiles",             4),
		_make(Directive.Type.CHIPS_60,         "Score 60+ chips in a single Pulse",           2),
		_make(Directive.Type.TOTAL_250,        "Score 250+ Chronos in a single Pulse",        3),
		_make(Directive.Type.TOTAL_500,        "Score 500+ Chronos in a single Pulse",        4),
		_make(Directive.Type.MULT_5,           "Achieve a ×5 or higher multiplier",           2),
		_make(Directive.Type.NO_DOUBLES,       "Play a chain of 3+ tiles with no doubles",    2),
		_make(Directive.Type.WIN_HANDS_LEFT_2, "Win the round with 2+ plays remaining",       3),
		_make(Directive.Type.NO_DISCARDS_USED, "Win the round without discarding",            2),
	]

static func _make(t: Directive.Type, text: String, reward: int) -> Directive:
	var d := Directive.new()
	d.type    = t
	d.text    = text
	d.reward  = reward
	return d
