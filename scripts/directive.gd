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
	# ── Persistent-chain expansion ─────────────────────────────────────
	CHAIN_LENGTH_11,    # reach Resonance tier (chain ≥ 11)
	CHAIN_LENGTH_16,    # reach Harmonic tier (chain ≥ 16)
	TOTAL_1000,         # score 1000+ Chronos in a single Pulse
	MULT_10,            # achieve ×10 or higher multiplier
	NO_DOUBLES_LONG,    # play a chain of 7+ tiles with no doubles
	HIGH_PIP_CHAIN,     # chain ≥ 5 tiles, average pip per tile ≥ 6
	WILD_USED,          # play a chain that contains a wild tile
	BRANCH_USED,        # play a chain that uses a branch (extra_end)
}

var type:      Type
var text:      String
var reward:    int
var completed: bool = false
