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
