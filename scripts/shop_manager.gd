## shop_manager.gd — Generates shop inventories for the Emporium and Artisan's Workshop.
class_name ShopManager
extends RefCounted

## Generate `count` unique random module items for the Brass Emporium.
## Excludes modules the player already owns.
static func generate_emporium(count: int, owned_ids: Array) -> Array[Dictionary]:
	var pool: Array[Module] = ModuleDB.all()
	pool.shuffle()
	var result: Array[Dictionary] = []
	for m in pool:
		if m.id not in owned_ids:
			result.append(_entry(m))
		if result.size() >= count:
			break
	# If pool exhausted before count reached, allow owned modules to fill gaps
	if result.size() < count:
		for m in pool:
			if not result.any(func(e): return e["item"].id == m.id):
				result.append(_entry(m))
			if result.size() >= count:
				break
	return result

## Generate the Artisan's Workshop: 1 guaranteed Ivory + 1 guaranteed Obsidian.
static func generate_artisan(owned_ids: Array) -> Array[Dictionary]:
	var ivory_pool    := ModuleDB.get_by_rarity(Constants.Rarity.IVORY)
	var obsidian_pool := ModuleDB.get_by_rarity(Constants.Rarity.OBSIDIAN)
	ivory_pool.shuffle()
	obsidian_pool.shuffle()

	var result: Array[Dictionary] = []

	# Prefer unowned; fall back to owned if necessary
	var ivory := _pick_preferred(ivory_pool, owned_ids)
	if ivory != null:
		result.append(_entry(ivory))

	var obsidian := _pick_preferred(obsidian_pool, owned_ids)
	if obsidian != null:
		result.append(_entry(obsidian))

	return result

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
static func _entry(m: Module) -> Dictionary:
	return { "item": m, "cost": Constants.RARITY_COSTS[m.rarity] }

static func _pick_preferred(pool: Array[Module], owned_ids: Array) -> Module:
	for m in pool:
		if m.id not in owned_ids:
			return m
	return pool[0] if not pool.is_empty() else null
