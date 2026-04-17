## domino.gd — A single Temporal Flow Component (domino tile)
class_name Domino
extends RefCounted

# Sentinel value for a wild/universal end in the chain
const WILD: int = -1

var left:  int  # pip value 0-9 (or WILD for a universal-connector tile)
var right: int
var rarity: int = 0        # Constants.Rarity value
var is_wild: bool = false  # True only for special rare tiles (e.g. The Crown)
var custom_name: String = ""
var lore_text: String = ""

func _init(p_left: int, p_right: int,
		p_rarity: int = 0, p_wild: bool = false) -> void:
	left = p_left
	right = p_right
	rarity = p_rarity
	is_wild = p_wild

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func is_double() -> bool:
	return left == right

func total_pips() -> int:
	# Wild tiles with negative pip values score 0
	var l: int = max(0, left)
	var r: int = max(0, right)
	return l + r

## Returns the open-end pip value this tile will expose when connected
## via the given connected_value.
func exposed_end(connected_value: int) -> int:
	if is_wild:
		return WILD
	if left == connected_value:
		return right
	return left  # right == connected_value (or wild end)

# ---------------------------------------------------------------------------
# Display
# ---------------------------------------------------------------------------
func display_name() -> String:
	if custom_name != "":
		return custom_name
	var l_str: String = str(left)  if left  >= 0 else "★"
	var r_str: String = str(right) if right >= 0 else "★"
	return "%s|%s" % [l_str, r_str]
