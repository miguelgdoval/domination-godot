## chain.gd — A Cohesion Pulse: the active chain being built this hand.
## Tracks tile order, open endpoints, display orientation, and full undo history.
class_name Chain
extends RefCounted

const EMPTY: int = -2  # sentinel — chain has no tiles yet
const WILD:  int = Domino.WILD  # = -1

var tiles:         Array[Domino]   = []
## Parallel to `tiles`. Each Vector2i stores (display_left_pip, display_right_pip)
## — the orientation in which the tile is visually rendered in the chain.
## The right pip of tile[i] always matches the left pip of tile[i+1].
var tile_displays: Array[Vector2i] = []
var left_end:  int = EMPTY
var right_end: int = EMPTY

# Each history entry: {tile, side ("first"|"right"|"left"), prev_left, prev_right}
var _history: Array[Dictionary] = []

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func is_empty() -> bool:
	return tiles.is_empty()

func length() -> int:
	return tiles.size()

func can_add(domino: Domino) -> bool:
	if is_empty():
		return true
	if domino.is_wild:
		return true
	if left_end == WILD or right_end == WILD:
		return true
	return (domino.left  == left_end  or domino.right == left_end or
			domino.left  == right_end or domino.right == right_end)

# ---------------------------------------------------------------------------
# Mutation
# ---------------------------------------------------------------------------
func add(domino: Domino) -> bool:
	if not can_add(domino):
		return false

	var snap := {
		"tile":       domino,
		"prev_left":  left_end,
		"prev_right": right_end,
		"side":       ""
	}

	if is_empty():
		snap["side"] = "first"
		_history.append(snap)
		tiles.append(domino)
		tile_displays.append(Vector2i(domino.left, domino.right))
		left_end  = WILD if domino.is_wild else domino.left
		right_end = WILD if domino.is_wild else domino.right
		return true

	if _fits_right(domino):
		snap["side"] = "right"
		_history.append(snap)
		_append_right(domino)
	elif _fits_left(domino):
		snap["side"] = "left"
		_history.append(snap)
		_prepend_left(domino)
	else:
		return false

	return true

## Remove the last-placed tile, restoring the previous chain state exactly.
## Returns the tile so the caller can return it to the hand, or null if empty.
func undo() -> Domino:
	if _history.is_empty():
		return null

	var snap: Dictionary = _history.pop_back()
	left_end  = snap["prev_left"]
	right_end = snap["prev_right"]

	match snap["side"]:
		"first", "right":
			tiles.pop_back()
			tile_displays.pop_back()
		"left":
			tiles.remove_at(0)
			tile_displays.remove_at(0)

	return snap["tile"]

func clear() -> void:
	tiles.clear()
	tile_displays.clear()
	_history.clear()
	left_end  = EMPTY
	right_end = EMPTY

# ---------------------------------------------------------------------------
# Display (text fallback — main UI uses tile_displays directly)
# ---------------------------------------------------------------------------
func display() -> String:
	if is_empty():
		return "(empty)"
	var parts: Array[String] = []
	for d in tile_displays:
		var l: String = str(d.x) if d.x >= 0 else "★"
		var r: String = str(d.y) if d.y >= 0 else "★"
		parts.append("%s|%s" % [l, r])
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

## Append to the RIGHT end. Also records display orientation:
## the connecting side faces LEFT (into chain), the exposed side faces RIGHT.
func _append_right(domino: Domino) -> void:
	tiles.append(domino)
	var disp: Vector2i
	if domino.is_wild:
		disp      = Vector2i(domino.left, domino.right)
		right_end = WILD
	elif right_end == WILD:
		# Wild end — orient tile naturally
		disp      = Vector2i(domino.left, domino.right)
		right_end = domino.right
	elif domino.left == right_end:
		# Left side connects → normal: display as [left | right], expose right
		disp      = Vector2i(domino.left, domino.right)
		right_end = domino.right
	else:
		# Right side connects → flip: display as [right | left], expose left
		disp      = Vector2i(domino.right, domino.left)
		right_end = domino.left
	tile_displays.append(disp)

## Prepend to the LEFT end. Also records display orientation:
## the exposed side faces LEFT (new open end), the connecting side faces RIGHT.
func _prepend_left(domino: Domino) -> void:
	tiles.insert(0, domino)
	var disp: Vector2i
	if domino.is_wild:
		disp     = Vector2i(domino.left, domino.right)
		left_end = WILD
	elif left_end == WILD:
		disp     = Vector2i(domino.left, domino.right)
		left_end = domino.left
	elif domino.right == left_end:
		# Right side connects to chain → display as [left | right], expose left
		disp     = Vector2i(domino.left, domino.right)
		left_end = domino.left
	else:
		# Left side connects to chain → flip: display as [right | left], expose right
		disp     = Vector2i(domino.right, domino.left)
		left_end = domino.right
	tile_displays.insert(0, disp)
