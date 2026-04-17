## box.gd — The tile supply for a Trial Cycle (the "deck")
## Holds all Temporal Flow Components available to the Operator.
class_name Box
extends RefCounted

var _draw_pile:    Array[Domino] = []
var _all_tiles:    Array[Domino] = []  # master copy for replenishment

# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------

## Creates the Standard Calibration Core box:
## all 55 double-9 tiles, duplicated once = 110 tiles total.
static func create_standard() -> Box:
	var box := Box.new()
	for i in range(Constants.MAX_PIP + 1):       # 0..9
		for j in range(i, Constants.MAX_PIP + 1): # i..9
			box._all_tiles.append(Domino.new(i, j))
			box._all_tiles.append(Domino.new(i, j))
	box.replenish()
	return box

## Creates the correct box for a Calibration Core index (see Constants.CORE_*).
static func create_for_core(core_index: int) -> Box:
	match core_index:
		1: return _create_resonant()
		2: return _create_dense()
		3: return _create_void()
		_: return create_standard()

## Resonant Core: only double tiles (0-0 through 9-9), 5 copies each = 50 tiles.
static func _create_resonant() -> Box:
	var box := Box.new()
	for i in range(Constants.MAX_PIP + 1):
		for _k in range(5):
			box._all_tiles.append(Domino.new(i, i))
	box.replenish()
	return box

## Dense Array: double-6 set (28 unique tiles), 3 copies each = 84 tiles.
static func _create_dense() -> Box:
	var box := Box.new()
	const MAX_DENSE: int = 6
	for i in range(MAX_DENSE + 1):
		for j in range(i, MAX_DENSE + 1):
			for _k in range(3):
				box._all_tiles.append(Domino.new(i, j))
	box.replenish()
	return box

## Void Lattice: standard double-9 set ×2 + 10 Wild tiles = 120 tiles.
static func _create_void() -> Box:
	var box := Box.new()
	for i in range(Constants.MAX_PIP + 1):
		for j in range(i, Constants.MAX_PIP + 1):
			box._all_tiles.append(Domino.new(i, j))
			box._all_tiles.append(Domino.new(i, j))
	for _k in range(10):
		box._all_tiles.append(Domino.new(Domino.WILD, Domino.WILD, 0, true))
	box.replenish()
	return box

# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------

## Restores the draw pile to a full shuffled copy of all tiles.
## Called at the start of each round.
func replenish() -> void:
	_draw_pile = _all_tiles.duplicate()
	_draw_pile.shuffle()

## Draw up to `count` tiles from the pile.
## Returns fewer if the pile is exhausted.
func draw(count: int) -> Array[Domino]:
	var drawn: Array[Domino] = []
	var to_draw: int = mini(count, _draw_pile.size())
	for _i in range(to_draw):
		drawn.append(_draw_pile.pop_back())
	return drawn

## Permanently add a tile to this box (shop purchase).
func add_tile(domino: Domino) -> void:
	_all_tiles.append(domino)
	_draw_pile.append(domino)

## Permanently remove a tile from this box (sold / consumed).
## Removes the first matching instance.
func remove_tile(domino: Domino) -> bool:
	for i in range(_all_tiles.size()):
		if _all_tiles[i] == domino:
			_all_tiles.remove_at(i)
			break
	for i in range(_draw_pile.size()):
		if _draw_pile[i] == domino:
			_draw_pile.remove_at(i)
			return true
	return false

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func draw_pile_size() -> int:
	return _draw_pile.size()

func total_tiles() -> int:
	return _all_tiles.size()

func is_empty() -> bool:
	return _draw_pile.is_empty()

## Returns a shallow copy of all tiles in the box (for display / shop use).
func all_tiles() -> Array[Domino]:
	var copy: Array[Domino] = []
	copy.append_array(_all_tiles)
	return copy
