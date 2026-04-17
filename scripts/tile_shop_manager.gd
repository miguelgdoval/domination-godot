## tile_shop_manager.gd — Generates tile offers and removal candidates
## for the Artisan's Workshop (boss shop).
class_name TileShopManager
extends RefCounted

## Generate `count` tile purchase offers. Each entry: {tile: Domino, cost: int}.
## Always includes one special tile; the rest are from the regular pool.
static func generate_offers(count: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	# One special tile (random from the pool)
	var specials: Array[Domino] = SpecialTileDB.all()
	specials.shuffle()
	result.append({ "tile": specials[0], "cost": _special_cost(specials[0]) })

	# Fill the rest with regular tiles
	var pool: Array[Domino] = []
	for i in range(Constants.MAX_PIP + 1):
		for j in range(i, Constants.MAX_PIP + 1):
			pool.append(Domino.new(i, j))
	pool.shuffle()
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

## Cost formula for a regular tile purchase.
static func _tile_cost(tile: Domino) -> int:
	if tile.is_wild:
		return 8
	var pips: int = tile.total_pips()
	var base: int = 1 + pips / 3          # 0→1, 3→2, 6→3, 9→4, 12→5, 15→6, 18→7
	if tile.is_double():
		base += 2                          # doubles cost extra
	return clampi(base, 1, 9)

## Cost formula for a special named tile.
static func _special_cost(tile: Domino) -> int:
	var base: int = Constants.RARITY_COSTS[tile.rarity]
	base += tile.bonus_chips / 3
	if tile.double_weight > 1:
		base += 2
	return clampi(base, 4, 12)
