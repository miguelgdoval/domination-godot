## chain.gd — A Cohesion Pulse: the active chain being built this hand.
## Tracks tile order and the two open endpoints.
class_name Chain
extends RefCounted

const EMPTY: int = -2  # sentinel — chain has no tiles yet
const WILD:  int = Domino.WILD  # = -1

var tiles: Array[Domino] = []
var left_end:  int = EMPTY
var right_end: int = EMPTY

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func is_empty() -> bool:
	return tiles.is_empty()

func length() -> int:
	return tiles.size()

## Returns true if `domino` can legally be added to either end of the chain.
func can_add(domino: Domino) -> bool:
	if is_empty():
		return true
	if domino.is_wild:
		return true
	# A WILD end accepts any pip value
	if left_end == WILD or right_end == WILD:
		return true
	return (domino.left  == left_end  or domino.right == left_end or
			domino.left  == right_end or domino.right == right_end)

# ---------------------------------------------------------------------------
# Mutation
# ---------------------------------------------------------------------------

## Add `domino` to the chain. Returns false if the tile cannot connect.
## Prefers appending to the right end; falls back to the left.
func add(domino: Domino) -> bool:
	if not can_add(domino):
		return false

	if is_empty():
		tiles.append(domino)
		left_end  = WILD if domino.is_wild else domino.left
		right_end = WILD if domino.is_wild else domino.right
		return true

	var fits_right: bool = _fits_right(domino)
	var fits_left:  bool = _fits_left(domino)

	if fits_right:
		_append_right(domino)
	elif fits_left:
		_prepend_left(domino)
	else:
		return false  # should never reach here given can_add check

	return true

func clear() -> void:
	tiles.clear()
	left_end  = EMPTY
	right_end = EMPTY

# ---------------------------------------------------------------------------
# Display
# ---------------------------------------------------------------------------
func display() -> String:
	if is_empty():
		return "(empty)"
	var parts: Array[String] = []
	for t in tiles:
		parts.append(t.display_name())
	return " → ".join(parts)

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------
func _fits_right(domino: Domino) -> bool:
	if domino.is_wild or right_end == WILD:
		return true
	return domino.left == right_end or domino.right == right_end

func _fits_left(domino: Domino) -> bool:
	if domino.is_wild or left_end == WILD:
		return true
	return domino.left == left_end or domino.right == left_end

func _append_right(domino: Domino) -> void:
	tiles.append(domino)
	if domino.is_wild:
		right_end = WILD
		return
	if right_end == WILD:
		# Wild end accepts either orientation; expose the tile's right side
		right_end = domino.right
	elif domino.left == right_end:
		right_end = domino.right
	else:  # domino.right == right_end
		right_end = domino.left

func _prepend_left(domino: Domino) -> void:
	tiles.insert(0, domino)
	if domino.is_wild:
		left_end = WILD
		return
	if left_end == WILD:
		left_end = domino.left
	elif domino.right == left_end:
		left_end = domino.left
	else:  # domino.left == left_end
		left_end = domino.right
