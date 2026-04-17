## directive.gd — A single bonus objective for a round.
## Directives are generated fresh each round and award Monedas on completion.
class_name Directive
extends RefCounted

enum Type {
	CHAIN_DOUBLES_3,    # play a chain with 3+ doubles
	CHAIN_LENGTH_5,     # play a chain of 5+ tiles
	CHAIN_LENGTH_7,     # play a chain of 7+ tiles
	CHIPS_60,           # score 60+ chips in one Pulse
	TOTAL_250,          # score 250+ Chronos in one Pulse
	TOTAL_500,          # score 500+ Chronos in one Pulse
	MULT_5,             # achieve ×5 or higher multiplier
	NO_DOUBLES,         # play a chain of 3+ tiles with no doubles
	WIN_HANDS_LEFT_2,   # win the round with 2+ plays remaining
	NO_DISCARDS_USED,   # win the round without discarding
}

var type:      Type
var text:      String
var reward:    int
var completed: bool = false
