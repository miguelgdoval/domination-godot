## module.gd — A Calibration Module (Artifact).
## Passive items equipped by the Operator that modify scoring and gameplay.
class_name Module
extends RefCounted

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
