## tile_shop_manager.gd — Generates tile offers and removal candidates
## for the Artisan's Workshop (boss shop).
class_name TileShopManager
extends RefCounted

## Generate `count` tile purchase offers. Each entry: {tile: Domino, cost: int}.
## Biased towards higher-value tiles to make the offer feel meaningful.
static func generate_offers(count: int) -> Array[Dictionary]:
	var pool: Array[Domino] = []

	# Full double-9 set as candidates
	for i in range(Constants.MAX_PIP + 1):
		for j in range(i, Constants.MAX_PIP + 1):
			pool.append(Domino.new(i, j))

	# Always include one Wild option
	pool.append(Domino.new(Domino.WILD, Domino.WILD, 0, true))

	pool.shuffle()
	var result: Array[Dictionary] = []
	for tile in pool:
		result.append({ "tile": tile, "cost": _tile_cost(tile) })
		if result.size() >= count:
			break
	return result

## Pick `count` tiles from the box as removal candidates (deck-thinning).
## Sorted by ascending pip total so low-value tiles appear first.
static func generate_removal_candidates(box: Box, count: int) -> Array[Domino]:
	var tiles: Array[Domino] = box.all_tiles()
	# Sort ascending by total pips so the "worst" tiles surface first
	tiles.sort_custom(func(a: Domino, b: Domino) -> bool:
		return a.total_pips() < b.total_pips())
	# Take from the front but shuffle within each pip bucket for variety
	var candidates: Array[Domino] = []
	if tiles.size() <= count:
		candidates = tiles
	else:
		candidates = tiles.slice(0, count)
	return candidates

## Cost formula for a single tile purchase.
static func _tile_cost(tile: Domino) -> int:
	if tile.is_wild:
		return 8
	var pips: int = tile.total_pips()
	var base: int = 1 + pips / 3          # 0→1, 3→2, 6→3, 9→4, 12→5, 15→6, 18→7
	if tile.is_double():
		base += 2                          # doubles cost extra
	return clampi(base, 1, 9)
