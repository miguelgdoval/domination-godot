## directive_db.gd — Pool of all available Directives.
class_name DirectiveDB
extends RefCounted

static func all() -> Array[Directive]:
	# Rewards bumped from the 2-7 range to 3-12. With base round
	# reward at +3 coins, contracts now feel like real bonuses (an
	# extra "good round" of income) rather than rounding errors.
	# Hardest contracts (CHAIN_LENGTH_16, MULT_10, TOTAL_1000) sit
	# at the top end to motivate stretch plays.
	return [
		_make(Directive.Type.CHAIN_DOUBLES_3,  "Play a chain containing 3+ doubles",          4),
		_make(Directive.Type.CHAIN_LENGTH_5,   "Play a chain of 5 or more tiles",             3),
		_make(Directive.Type.CHAIN_LENGTH_7,   "Play a chain of 7 or more tiles",             6),
		_make(Directive.Type.CHIPS_60,         "Score 60+ chips in a single Pulse",           3),
		_make(Directive.Type.TOTAL_250,        "Score 250+ Chronos in a single Pulse",        4),
		_make(Directive.Type.TOTAL_500,        "Score 500+ Chronos in a single Pulse",        6),
		_make(Directive.Type.MULT_5,           "Achieve a ×5 or higher multiplier",           4),
		_make(Directive.Type.NO_DOUBLES,       "Play a chain of 3+ tiles with no doubles",    4),
		_make(Directive.Type.WIN_HANDS_LEFT_2, "Win the round with 2+ plays remaining",       5),
		_make(Directive.Type.NO_DISCARDS_USED, "Win the round without discarding",            4),
		# ── Persistent-chain era directives ─────────────────────────────────
		_make(Directive.Type.CHAIN_LENGTH_11,  "Reach Resonance tier (chain of 11+)",         8),
		_make(Directive.Type.CHAIN_LENGTH_16,  "Reach Harmonic tier (chain of 16+)",         12),
		_make(Directive.Type.TOTAL_1000,       "Score 1000+ Chronos in a single Pulse",       8),
		_make(Directive.Type.MULT_10,          "Achieve a ×10 or higher multiplier",          9),
		_make(Directive.Type.NO_DOUBLES_LONG,  "Play a chain of 7+ tiles with no doubles",    8),
		_make(Directive.Type.HIGH_PIP_CHAIN,   "Chain of 5+ tiles, avg ≥6 pips per tile",     6),
		_make(Directive.Type.WILD_USED,        "Use a wild tile in a chain",                  4),
	]

static func _make(t: Directive.Type, text: String, reward: int) -> Directive:
	var d := Directive.new()
	d.type    = t
	d.text    = text
	d.reward  = reward
	return d
