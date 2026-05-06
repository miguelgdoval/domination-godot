## module.gd — A Calibration Module (Artifact).
## Passive items equipped by the Operator that modify scoring and gameplay.
class_name Module
extends RefCounted

## Archetype tags drive shop bias: when generating new offers, the shop
## weights each candidate module by how many modules of its archetype the
## player already owns. Synergy builds form naturally instead of needing
## the player to luck into matching effects.
##
## Mapping is derived from `effect_type` via `Module.archetype_of()` so we
## don't have to tag every entry in module_db.gd by hand.
enum Archetype {
	GENERIC,    # FLAT_MULT, FLAT_CHIPS — useful in any build, never biased
	DOUBLES,    # rewards doubles in chain
	LONG_CHAIN, # rewards chain length / tile count
	HIGH_PIP,   # rewards high pip values per tile
	BLANKS,     # rewards blank pips / wild tiles
	SACRIFICE,  # converts low-pip tiles into mult
	ECONOMY,    # monedas / shop pricing
	UTILITY,    # stats: hand size, extra plays, discards, slots
}

enum EffectType {
	FLAT_MULT,          # +effect_value mult every hand
	FLAT_CHIPS,         # +effect_value chips every hand
	DOUBLE_MULT_BOOST,  # each double gives +effect_value mult (replaces the base +1)
	DOUBLE_PIP_BOOST,   # doubles score effect_value × their pip value (replaces ×1)
	LONG_CHAIN_BOOST,   # chain >= effect_param tiles → +effect_value mult (additive)
	EXTRA_SLOT,         # grants +effect_value module slots on equip (passive)
	HAND_SIZE_BONUS,    # +effect_value to hand size each round
	EXTRA_HAND,         # +effect_value to max plays each round
	DISCARD_BONUS,      # +effect_value to max discards each round
	CHIPS_PER_TILE,     # +effect_value chips for every tile in the chain
	# ── New archetypes ────────────────────────────────────────────────────────
	HIGH_PIP_BONUS,     # if max(left,right) >= effect_param: +effect_value chips per tile
	WILD_PIP_VALUE,     # wild tiles score as if each face shows effect_value pips
	CLOSING_TILE_BONUS, # chain 3+ tiles: +effect_value flat chips (rewards finishing)
	ERA_SCALING_MULT,   # mult += effect_value × (current_etapa + 1) — grows each era
	# ── Milestone 5 archetypes ───────────────────────────────────────────────
	LOW_PIP_TO_MULT,    # tiles with total_pips <= effect_param: 0 chips, +effect_value mult each (sacrifice)
	BLANK_TO_CHIPS,     # each 0-pip face in chain: +effect_value chips (conversion)
	ROUND_SCALING_MULT, # mult += effect_value × rounds_completed — compounds per round (scaling)
	# ── Economy & utility ────────────────────────────────────────────────────
	COIN_PER_ROUND,     # +effect_value Monedas added to round-end award
	SHOP_DISCOUNT,      # shop item costs reduced by effect_value % (stacks, capped 80%)
	DOUBLES_CONNECT_ANY,# double tiles can connect to any open pip value
	CHAIN_COIN_BONUS,   # chain >= effect_param tiles: +effect_value Monedas per play
}

var id:           String
var display_name: String
var rarity:       int          # Constants.Rarity value
var effect_type:  EffectType
var effect_value: int
var effect_param: int = 0      # secondary parameter (e.g. chain length threshold)
var extra_slots:  int = 0      # additional module slots granted on equip
var description:  String
var lore_text:    String = ""
var icon_path:    String = ""   # res://assets/modules/{id}.png — swap when art arrives

## Archetype derived from `effect_type`. Used for shop bias.
func archetype() -> Archetype:
	return Module.archetype_of(effect_type)

static func archetype_of(eff: EffectType) -> Archetype:
	match eff:
		EffectType.DOUBLE_MULT_BOOST, EffectType.DOUBLE_PIP_BOOST, \
		EffectType.DOUBLES_CONNECT_ANY:
			return Archetype.DOUBLES
		EffectType.LONG_CHAIN_BOOST, EffectType.CHIPS_PER_TILE, \
		EffectType.CLOSING_TILE_BONUS, EffectType.ROUND_SCALING_MULT, \
		EffectType.CHAIN_COIN_BONUS:
			return Archetype.LONG_CHAIN
		EffectType.HIGH_PIP_BONUS, EffectType.ERA_SCALING_MULT:
			return Archetype.HIGH_PIP
		EffectType.BLANK_TO_CHIPS, EffectType.WILD_PIP_VALUE:
			return Archetype.BLANKS
		EffectType.LOW_PIP_TO_MULT:
			return Archetype.SACRIFICE
		EffectType.COIN_PER_ROUND, EffectType.SHOP_DISCOUNT:
			return Archetype.ECONOMY
		EffectType.HAND_SIZE_BONUS, EffectType.EXTRA_HAND, \
		EffectType.DISCARD_BONUS, EffectType.EXTRA_SLOT:
			return Archetype.UTILITY
		_:
			return Archetype.GENERIC
