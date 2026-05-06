## shop_manager.gd — Generates shop inventories for the Emporium and Artisan's Workshop.
class_name ShopManager
extends RefCounted

## Each owned module of an archetype adds this much weight to candidates of
## the same archetype when rolling shop offers. With base weight 1.0:
##   • 0 owned of archetype → weight 1.0
##   • 1 owned             → weight 1.5
##   • 3 owned             → weight 2.5
## High enough to make builds form, low enough that off-archetype rolls
## still appear regularly (no degenerate guaranteed-synergy spirals).
const ARCHETYPE_WEIGHT_PER_OWNED: float = 0.5

## Generate `count` unique random module items for the Brass Emporium.
## Excludes modules the player already owns and biases toward archetypes
## the player has invested in (see ARCHETYPE_WEIGHT_PER_OWNED).
##
## `owned_modules` is optional for backward compatibility; if omitted the
## shop falls back to uniform random.
static func generate_emporium(count: int, owned_ids: Array,
		owned_modules: Array = []) -> Array[Dictionary]:
	var pool: Array[Module] = ModuleDB.all()
	# Filter to unowned candidates first.
	var candidates: Array[Module] = []
	for m in pool:
		if m.id not in owned_ids:
			candidates.append(m)

	var arch_weights: Dictionary = _archetype_weights(owned_modules)
	var result: Array[Dictionary] = []
	while result.size() < count and not candidates.is_empty():
		var picked: Module = _weighted_pick(candidates, arch_weights)
		if picked == null:
			break
		result.append(_entry(picked))
		candidates.erase(picked)

	# If pool exhausted before count reached, allow owned modules to fill gaps.
	if result.size() < count:
		var fallback: Array[Module] = []
		for m in pool:
			if not result.any(func(e): return e["item"].id == m.id):
				fallback.append(m)
		fallback.shuffle()
		for m in fallback:
			result.append(_entry(m))
			if result.size() >= count:
				break
	return result

## Generate the Artisan's Workshop: 1 guaranteed Ivory + 1 guaranteed Obsidian.
## Same archetype-bias logic applied within each rarity bucket.
static func generate_artisan(owned_ids: Array,
		owned_modules: Array = []) -> Array[Dictionary]:
	var ivory_pool    := ModuleDB.get_by_rarity(Constants.Rarity.IVORY)
	var obsidian_pool := ModuleDB.get_by_rarity(Constants.Rarity.OBSIDIAN)
	var arch_weights: Dictionary = _archetype_weights(owned_modules)

	var result: Array[Dictionary] = []
	var ivory := _pick_preferred(ivory_pool, owned_ids, arch_weights)
	if ivory != null:
		result.append(_entry(ivory))
	var obsidian := _pick_preferred(obsidian_pool, owned_ids, arch_weights)
	if obsidian != null:
		result.append(_entry(obsidian))
	return result

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
static func _entry(m: Module) -> Dictionary:
	return { "item": m, "cost": Constants.RARITY_COSTS[m.rarity] }

## Build a {Archetype: count} dict from the player's currently-owned modules.
## GENERIC counts as zero — those modules don't bias future rolls because
## they fit any build.
static func _archetype_weights(owned_modules: Array) -> Dictionary:
	var counts: Dictionary = {}
	for m in owned_modules:
		var a: int = m.archetype()
		if a == Module.Archetype.GENERIC:
			continue
		counts[a] = counts.get(a, 0) + 1
	return counts

## Weighted pick: each candidate's weight = 1 + ARCHETYPE_WEIGHT_PER_OWNED
## × count of its archetype already owned. GENERIC modules always sit at
## base weight 1, so they don't get squeezed out of biased shops.
static func _weighted_pick(candidates: Array[Module], arch_counts: Dictionary) -> Module:
	if candidates.is_empty():
		return null
	var total: float = 0.0
	var weights: Array[float] = []
	for m in candidates:
		var w: float = 1.0
		var a: int   = m.archetype()
		if a != Module.Archetype.GENERIC:
			w += ARCHETYPE_WEIGHT_PER_OWNED * float(arch_counts.get(a, 0))
		weights.append(w)
		total += w
	if total <= 0.0:
		return candidates[0]
	var roll: float = randf() * total
	var acc:  float = 0.0
	for i in range(candidates.size()):
		acc += weights[i]
		if roll <= acc:
			return candidates[i]
	return candidates[-1]

static func _pick_preferred(pool: Array[Module], owned_ids: Array,
		arch_counts: Dictionary = {}) -> Module:
	# Filter to unowned, weighted-pick if any remain.
	var unowned: Array[Module] = []
	for m in pool:
		if m.id not in owned_ids:
			unowned.append(m)
	if not unowned.is_empty():
		return _weighted_pick(unowned, arch_counts)
	return pool[0] if not pool.is_empty() else null
