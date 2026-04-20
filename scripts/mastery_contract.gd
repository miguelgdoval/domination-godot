## mastery_contract.gd — A Mastery Contract (run objective with reward).
## Active contracts track progress; completing one awards Monedas + lore text.
class_name MasteryContract
extends RefCounted

enum ObjectiveType {
	EARN_MONEDAS_IN_ROUND,   # earn >= target monedas in a single round
	USE_REINFORCEMENTS,      # use >= target reinforcements in one round
	BUY_SHOP_ITEM,           # buy any item from the shop (any rarity)
	SCORE_CHAIN,             # score a single chain >= target Chronos
	PLAY_DOUBLES,            # place >= target doubles across the entire run
	EMPTY_HAND,              # play until hand is completely empty (0 tiles)
	REACH_SCORE_BEFORE_ROUND,# reach total Chronos >= target before round N
}

var id:             String
var display_name:   String
var objective_type: ObjectiveType
var target:         int    # quantity the player must hit
var target_param:   int    # secondary param (e.g. round cap for REACH_SCORE)
var reward_monedas: int    # Monedas awarded on completion
var description:    String # shown during gameplay ("Score 500 Chronos before round 10")
var lore_text:      String = ""
var icon_path:      String = ""   # res://assets/contracts/{id}.png

# ---------------------------------------------------------------------------
# Runtime tracking (not saved to disk — resets each run)
# ---------------------------------------------------------------------------
var progress:   int  = 0
var completed:  bool = false

func check_progress(value: int) -> bool:
	if completed:
		return false
	progress = value
	if progress >= target:
		completed = true
		return true
	return false

func progress_text() -> String:
	return "%d / %d" % [mini(progress, target), target]
