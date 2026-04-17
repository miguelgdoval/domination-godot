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

		# ------------------------------------------------------------------
		# BONE — additional
		# ------------------------------------------------------------------
		_make("flux_capacitor", "Flux Capacitor", Constants.Rarity.BONE,
			Module.EffectType.FLAT_CHIPS, 3, 0, 0,
			"+3 Chips every hand.",
			"Salvaged from the first collapse. Still holds a charge."),

		_make("timing_chain", "Timing Chain", Constants.Rarity.BONE,
			Module.EffectType.LONG_CHAIN_BOOST, 1, 3, 0,
			"Chain 3+ tiles: +1 Mult.",
			"Even small coherence deserves recognition."),

		# ------------------------------------------------------------------
		# CARVED — additional
		# ------------------------------------------------------------------
		_make("resonant_loop", "Resonant Loop", Constants.Rarity.CARVED,
			Module.EffectType.HAND_SIZE_BONUS, 1, 0, 0,
			"+1 tile drawn each round.",
			"More data, more signal. More signal, more control."),

		_make("echo_chamber_mod", "Echo Chamber", Constants.Rarity.CARVED,
			Module.EffectType.EXTRA_HAND, 1, 0, 0,
			"+1 play per round.",
			"The signal echoes once. Use it."),

		_make("discharge_relay", "Discharge Relay", Constants.Rarity.CARVED,
			Module.EffectType.DISCARD_BONUS, 1, 0, 0,
			"+1 discard per round.",
			"Release what does not serve the Chronometer."),

		_make("harmonic_filter", "Harmonic Filter", Constants.Rarity.CARVED,
			Module.EffectType.LONG_CHAIN_BOOST, 2, 6, 0,
			"Chain 6+ tiles: +2 Mult.",
			"At six nodes the filter locks in. The signal clarifies."),

		# ------------------------------------------------------------------
		# IVORY — additional
		# ------------------------------------------------------------------
		_make("chronos_lens", "Chronos Lens", Constants.Rarity.IVORY,
			Module.EffectType.CHIPS_PER_TILE, 1, 0, 0,
			"+1 Chip per tile in chain.",
			"Each node in the array contributes its measure."),

		_make("overclock_array", "Overclock Array", Constants.Rarity.IVORY,
			Module.EffectType.DOUBLE_PIP_BOOST, 3, 0, 0,
			"Doubles score 3× their pips.",
			"Push the resonance past its rated frequency."),

		_make("cascade_lens", "Cascade Lens", Constants.Rarity.IVORY,
			Module.EffectType.LONG_CHAIN_BOOST, 5, 8, 0,
			"Chain 8+ tiles: +5 Mult.",
			"A full eight-node array approaches the resonance threshold."),

		# ------------------------------------------------------------------
		# OBSIDIAN — additional
		# ------------------------------------------------------------------
		_make_extra("the_singularity", "The Singularity", Constants.Rarity.OBSIDIAN,
			Module.EffectType.FLAT_MULT, 8, 0, 1,
			"+8 Mult every hand. +1 Module slot.",
			"\"When entropy reaches zero, all multipliers converge.\""),

		_make_extra("void_amplifier", "Void Amplifier", Constants.Rarity.OBSIDIAN,
			Module.EffectType.CHIPS_PER_TILE, 3, 0, 1,
			"+3 Chips per tile in chain. +1 Module slot.",
			"\"The Void does not merely connect. It amplifies.\""),
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
