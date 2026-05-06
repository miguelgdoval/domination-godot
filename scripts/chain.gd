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

## Branching at doubles: each double placed in the chain adds an extra
## valid match value here. Future tiles can connect via left_end, right_end,
## OR any value in extra_ends. When a tile lands via an extra_end, that
## end is consumed and the tile's other face becomes a new extra_end —
## the chain effectively forks. Visualisation stays linear (the branched
## tile is appended on the right) but the gameplay flexibility is real.
var extra_ends: Array[int] = []

# Each history entry: {tile, side, prev_left, prev_right, prev_extra}
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
	if domino.is_double() and _has_doubles_connect_any():
		return true
	if domino.left  == left_end  or domino.right == left_end or \
			domino.left  == right_end or domino.right == right_end:
		return true
	# Branching: any extra open end created by a previously-placed double.
	for v in extra_ends:
		if v == WILD or domino.left == v or domino.right == v:
			return true
	return false

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
		"prev_extra": extra_ends.duplicate(),
		"side":       ""
	}

	if is_empty():
		snap["side"] = "first"
		_history.append(snap)
		tiles.append(domino)
		tile_displays.append(Vector2i(domino.left, domino.right))
		left_end  = WILD if domino.is_wild else domino.left
		right_end = WILD if domino.is_wild else domino.right
	elif _fits_right(domino):
		snap["side"] = "right"
		_history.append(snap)
		_append_right(domino)
	elif _fits_left(domino):
		snap["side"] = "left"
		_history.append(snap)
		_prepend_left(domino)
	elif _fits_extra(domino):
		snap["side"] = "extra"
		_history.append(snap)
		_append_via_extra(domino)
	else:
		return false

	# Branching: doubles add a new open-end value the chain can match later.
	# (Wild doubles don't add a specific value — they're already universal.)
	if not domino.is_wild and domino.is_double():
		extra_ends.append(domino.left)

	return true

## Remove the last-placed tile, restoring the previous chain state exactly.
## Returns the tile so the caller can return it to the hand, or null if empty.
func undo() -> Domino:
	if _history.is_empty():
		return null

	var snap: Dictionary = _history.pop_back()
	left_end  = snap["prev_left"]
	right_end = snap["prev_right"]
	# Restore extra_ends snapshot (empty-list default for legacy entries).
	var prev_extra: Array = snap.get("prev_extra", [])
	extra_ends.clear()
	for v in prev_extra:
		extra_ends.append(int(v))

	# "extra"-side placements are appended to the right of the visual chain
	# (same as right adds), so removal is also from the back.
	match snap["side"]:
		"first", "right", "extra":
			tiles.pop_back()
			tile_displays.pop_back()
		"left":
			tiles.remove_at(0)
			tile_displays.remove_at(0)

	return snap["tile"]

func clear() -> void:
	tiles.clear()
	tile_displays.clear()
	extra_ends.clear()
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
## True if the tile matches a branching open end (created by a double
## already in the chain). Only consulted after `_fits_right`/`_fits_left`
## have failed, so this is the fallback path.
func _fits_extra(domino: Domino) -> bool:
	if extra_ends.is_empty():
		return false
	if domino.is_wild:
		return true
	for v in extra_ends:
		if v == WILD or domino.left == v or domino.right == v:
			return true
	return false

## Append a tile that matched via an extra (branch) open end. The matched
## extra is consumed; the tile's other face becomes a NEW extra so the
## chain can keep growing along that branch later. Visually the tile is
## appended on the right (same as `_append_right`); the renderer doesn't
## currently draw branches as a tree.
func _append_via_extra(domino: Domino) -> void:
	# Find the first matching extra_end.
	var idx: int = -1
	var matched_v: int = 0
	for i in range(extra_ends.size()):
		var v: int = extra_ends[i]
		if domino.is_wild or v == WILD or v == Domino.WILD \
				or domino.left == v or domino.right == v:
			idx = i
			matched_v = v
			break
	if idx < 0:
		return
	extra_ends.remove_at(idx)

	var connecting: int
	var exposed:    int
	if domino.is_wild:
		connecting = matched_v
		exposed    = matched_v
	elif matched_v == WILD or matched_v == Domino.WILD:
		connecting = domino.left
		exposed    = domino.right
	elif domino.left == matched_v:
		connecting = domino.left
		exposed    = domino.right
	else:
		connecting = domino.right
		exposed    = domino.left

	# The branch keeps growing — push the exposed face back onto extra_ends
	# so the next tile can land on this branch too.
	if not domino.is_wild:
		extra_ends.append(exposed)

	tiles.append(domino)
	# Render with connecting face oriented "left" so the tile looks like a
	# right-side append visually. Pure cosmetic — not connected to anything
	# in the visible chain (the branch is logical, not drawn).
	if connecting == domino.left:
		tile_displays.append(Vector2i(domino.left, domino.right))
	else:
		tile_displays.append(Vector2i(domino.right, domino.left))

func _fits_right(domino: Domino) -> bool:
	if domino.is_wild or right_end == WILD:
		return true
	if domino.left == right_end or domino.right == right_end:
		return true
	# DOUBLES_CONNECT_ANY: doubles attach to any open end
	if domino.is_double() and _has_doubles_connect_any():
		return true
	return false

func _fits_left(domino: Domino) -> bool:
	if domino.is_wild or left_end == WILD:
		return true
	if domino.left == left_end or domino.right == left_end:
		return true
	# DOUBLES_CONNECT_ANY: doubles attach to any open end
	if domino.is_double() and _has_doubles_connect_any():
		return true
	return false

## Returns true if any equipped module grants DOUBLES_CONNECT_ANY.
func _has_doubles_connect_any() -> bool:
	for m in GameState.modules:
		if m.effect_type == Module.EffectType.DOUBLES_CONNECT_ANY:
			return true
	return false

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
	elif domino.right == right_end:
		# Right side connects → flip: display as [right | left], expose left
		disp      = Vector2i(domino.right, domino.left)
		right_end = domino.left
	else:
		# DOUBLES_CONNECT_ANY: no face matches — display naturally, expose right face
		disp      = Vector2i(domino.left, domino.right)
		right_end = domino.right
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
	elif domino.left == left_end:
		# Left side connects to chain → flip: display as [right | left], expose right
		disp     = Vector2i(domino.right, domino.left)
		left_end = domino.right
	else:
		# DOUBLES_CONNECT_ANY: no face matches — display naturally, expose left face
		disp     = Vector2i(domino.left, domino.right)
		left_end = domino.left
	tile_displays.insert(0, disp)
