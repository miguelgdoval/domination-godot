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

## Modules with restricted availability. Keep the DB pure and filter
## here so the shop-side rules can evolve without touching catalogue data.
const FACTION_LOCKED_IDS: Array[String] = ["module_co_13"]

## True if `m` is available to appear in the current shop context.
## CO-13 is filtered out everywhere except a Renegade-swap Artisan visit
## with the faction unlock earned.
static func _module_available(m: Module, renegade_here: bool) -> bool:
	if not (m.id in FACTION_LOCKED_IDS):
		return true
	if m.id == "module_co_13":
		return renegade_here and SaveManager.is_faction_unlocked("renegade")
	return false

## Generate `count` unique random module items for the Brass Emporium.
## Excludes modules the player already owns and biases toward archetypes
## the player has invested in (see ARCHETYPE_WEIGHT_PER_OWNED).
##
## `owned_modules` is optional for backward compatibility; if omitted the
## shop falls back to uniform random.
static func generate_emporium(count: int, owned_ids: Array,
		owned_modules: Array = []) -> Array[Dictionary]:
	var pool: Array[Module] = ModuleDB.all()
	# Filter to unowned candidates first. Emporium never sees the
	# Renegade — CO-13 and anything else in FACTION_LOCKED_IDS is excluded.
	var candidates: Array[Module] = []
	for m in pool:
		if m.id in owned_ids:
			continue
		if not _module_available(m, false):
			continue
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

## Generate `count` random tool offers for the Emporium / Workshop. No
## ownership filter — tools are consumable, so duplicates are fine.
## Cheap (BONE / CARVED) rarities are weighted higher so the typical
## shop has at least one affordable tool option.
static func generate_tools(count: int) -> Array[Dictionary]:
	var pool: Array[Reinforcement] = ReinforcementDB.all()
	if pool.is_empty() or count <= 0:
		return []
	# Rarity weights — cheap tiers dominate so the player isn't stuck
	# with only legendary tools they can't afford.
	var weights: Array[float] = []
	var total: float = 0.0
	for r in pool:
		var w: float = 3.0  # BONE default
		match r.rarity:
			Constants.Rarity.BONE:     w = 3.0
			Constants.Rarity.CARVED:   w = 2.0
			Constants.Rarity.IVORY:    w = 1.0
			Constants.Rarity.OBSIDIAN: w = 0.4
		weights.append(w)
		total += w

	var result: Array[Dictionary] = []
	# Sample with replacement allowed (consumables), but try to avoid
	# the same tool appearing twice in a single shop offer by tracking
	# which ids we've already picked.
	var picked_ids: Array = []
	for _i in range(count):
		var roll: float = randf() * total
		var acc:  float = 0.0
		var chosen: Reinforcement = pool[0]
		for j in range(pool.size()):
			acc += weights[j]
			if roll <= acc:
				chosen = pool[j]
				break
		# Re-roll once if we've already shown this tool — keeps offers
		# varied without forcing strict uniqueness.
		if chosen.id in picked_ids and pool.size() > picked_ids.size():
			var roll2: float = randf() * total
			var acc2:  float = 0.0
			for j in range(pool.size()):
				acc2 += weights[j]
				if roll2 <= acc2:
					chosen = pool[j]
					break
		picked_ids.append(chosen.id)
		result.append({
			"item": chosen,
			"cost": Constants.RARITY_COSTS[chosen.rarity],
		})
	return result

## Generate the Artisan's Workshop: 1 guaranteed Ivory + 1 guaranteed Obsidian.
## Same archetype-bias logic applied within each rarity bucket. The
## `renegade_here` flag controls whether faction-locked Modules (CO-13)
## are eligible for the Obsidian slot, and forces CO-13 in when the
## Operator has earned the Renegade's trust.
static func generate_artisan(owned_ids: Array,
		owned_modules: Array = [],
		renegade_here: bool = false) -> Array[Dictionary]:
	var ivory_pool: Array[Module] = _filter_available(
		ModuleDB.get_by_rarity(Constants.Rarity.IVORY), renegade_here)
	var obsidian_pool: Array[Module] = _filter_available(
		ModuleDB.get_by_rarity(Constants.Rarity.OBSIDIAN), renegade_here)
	var arch_weights: Dictionary = _archetype_weights(owned_modules)

	var result: Array[Dictionary] = []
	var ivory := _pick_preferred(ivory_pool, owned_ids, arch_weights)
	if ivory != null:
		result.append(_entry(ivory))
	# Renegade-with-unlock: force CO-13 into the Obsidian slot so the
	# faction reward is visible the moment it's earned.
	var obsidian: Module = null
	if renegade_here and SaveManager.is_faction_unlocked("renegade"):
		for m in obsidian_pool:
			if m.id == "module_co_13" and not (m.id in owned_ids):
				obsidian = m
				break
	if obsidian == null:
		obsidian = _pick_preferred(obsidian_pool, owned_ids, arch_weights)
	if obsidian != null:
		result.append(_entry(obsidian))
	return result

## Filter a Module pool down to modules available in the current context
## (mainly: drop faction-locked entries unless the visit qualifies).
static func _filter_available(pool: Array[Module],
		renegade_here: bool) -> Array[Module]:
	var out: Array[Module] = []
	for m in pool:
		if _module_available(m, renegade_here):
			out.append(m)
	return out

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
