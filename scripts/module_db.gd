## module_db.gd — Catalogue of all Calibration Modules.
## Pure static data — no autoload needed.
class_name ModuleDB
extends RefCounted

static func all() -> Array[Module]:
	return [
		# ------------------------------------------------------------------
		# BONE (common)
		# ------------------------------------------------------------------
		_make("brass_gear", "Brass Gear", Constants.Rarity.BONE,
			Module.EffectType.FLAT_MULT, 1, 0, 0,
			"+1 Mult every hand.",
			"A simple gear salvaged from a broken chronometer."),

		_make("copper_coil", "Copper Coil", Constants.Rarity.BONE,
			Module.EffectType.FLAT_CHIPS, 5, 0, 0,
			"+5 Chips every hand.",
			"Stores a residual Chronos charge between insertions."),

		_make("worn_sprocket", "Worn Sprocket", Constants.Rarity.BONE,
			Module.EffectType.FLAT_MULT, 1, 0, 0,
			"+1 Mult every hand.",
			"Still functional. Barely."),

		# ------------------------------------------------------------------
		# CARVED (uncommon)
		# ------------------------------------------------------------------
		_make("signal_amp", "Signal Amp", Constants.Rarity.CARVED,
			Module.EffectType.FLAT_MULT, 2, 0, 0,
			"+2 Mult every hand.",
			"Amplifies the coherence signal of every flow insertion."),

		_make("resonance_chamber", "Resonance Chamber", Constants.Rarity.CARVED,
			Module.EffectType.DOUBLE_MULT_BOOST, 2, 0, 0,
			"Each double gives +2 Mult instead of +1.",
			"Self-referential loops double their resonance output."),

		_make("data_shard", "Data Shard", Constants.Rarity.CARVED,
			Module.EffectType.FLAT_CHIPS, 12, 0, 0,
			"+12 Chips every hand.",
			"A fragment of encoded temporal data, still warm."),

		# ------------------------------------------------------------------
		# IVORY (rare)
		# ------------------------------------------------------------------
		_make("chain_reaction", "Chain Reaction", Constants.Rarity.IVORY,
			Module.EffectType.LONG_CHAIN_BOOST, 3, 5, 0,
			"Chain ≥5 tiles: +3 Mult (in addition to standard).",
			"Extended cohesion triggers a cascade of amplified energy."),

		_make("precision_lens", "Precision Lens", Constants.Rarity.IVORY,
			Module.EffectType.FLAT_MULT, 3, 0, 0,
			"+3 Mult every hand.",
			"Ground from crystallised chronite. Perfectly aligned."),

		_make("entropy_sink", "Entropy Sink", Constants.Rarity.IVORY,
			Module.EffectType.FLAT_CHIPS, 20, 0, 0,
			"+20 Chips every hand.",
			"Captures wasted Chronos bleed and feeds it back to the pulse."),

		# ------------------------------------------------------------------
		# OBSIDIAN (legendary)
		# ------------------------------------------------------------------
		_make_extra("the_dominator", "The Dominator", Constants.Rarity.OBSIDIAN,
			Module.EffectType.DOUBLE_PIP_BOOST, 2, 0, 1,
			"Doubles score ×2 pip value. +1 Module slot.",
			"\"This modification is illegal. The Archiver would disapprove.\""),

		_make_extra("chronos_amp", "Chronos Amplifier", Constants.Rarity.OBSIDIAN,
			Module.EffectType.FLAT_MULT, 5, 0, 1,
			"+5 Mult every hand. +1 Module slot.",
			"Maximum coherence output. Unstable in the wrong hands."),
	]

static func get_by_rarity(rarity: int) -> Array[Module]:
	var result: Array[Module] = []
	for m in all():
		if m.rarity == rarity:
			result.append(m)
	return result

# ---------------------------------------------------------------------------
# Internal factories
# ---------------------------------------------------------------------------
static func _make(id: String, name: String, rarity: int,
		eff: Module.EffectType, val: int, param: int, slots: int,
		desc: String, lore: String) -> Module:
	var m := Module.new()
	m.id           = id
	m.display_name = name
	m.rarity       = rarity
	m.effect_type  = eff
	m.effect_value = val
	m.effect_param = param
	m.extra_slots  = slots
	m.description  = desc
	m.lore_text    = lore
	return m

static func _make_extra(id: String, name: String, rarity: int,
		eff: Module.EffectType, val: int, param: int, slots: int,
		desc: String, lore: String) -> Module:
	return _make(id, name, rarity, eff, val, param, slots, desc, lore)
