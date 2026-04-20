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

		# ------------------------------------------------------------------
		# NEW ARCHETYPES — high pip, wild conversion, closing, era scaling
		# ------------------------------------------------------------------
		_make("resonant_threshold", "Resonant Threshold", Constants.Rarity.CARVED,
			Module.EffectType.HIGH_PIP_BONUS, 6, 7, 0,
			"Tiles with 7+ pips on either face: +6 Chips.",
			"The heaviest Nodes resonate at a higher frequency."),

		_make("void_channeler", "Void Channeler", Constants.Rarity.IVORY,
			Module.EffectType.WILD_PIP_VALUE, 5, 0, 0,
			"Wild tiles score as if each face shows 5 pips (+10 Chips).",
			"The Void is not empty. It hums with potential energy."),

		_make("finisher_protocol", "Finisher Protocol", Constants.Rarity.CARVED,
			Module.EffectType.CLOSING_TILE_BONUS, 20, 0, 0,
			"Chain 3+ tiles: +20 Chips.",
			"A closed circuit releases all stored energy at once."),

		_make("temporal_accumulator", "Temporal Accumulator", Constants.Rarity.BONE,
			Module.EffectType.ERA_SCALING_MULT, 1, 0, 0,
			"+1 Mult per Era entered. (×1 / ×2 / ×3 / ×4 over the run)",
			"Patience is a form of power. The mechanism remembers."),

		_make_extra("entropy_harvester", "Entropy Harvester", Constants.Rarity.OBSIDIAN,
			Module.EffectType.ERA_SCALING_MULT, 3, 0, 1,
			"+3 Mult per Era entered. Grows with the run. +1 slot.",
			"\"It does not fight entropy. It feeds on it.\""),

		_make("harmonic_apex", "Harmonic Apex", Constants.Rarity.IVORY,
			Module.EffectType.HIGH_PIP_BONUS, 12, 8, 0,
			"Tiles with 8+ pips on either face: +12 Chips.",
			"At maximum resonance, the signal becomes self-sustaining."),

		# ------------------------------------------------------------------
		# SACRIFICE (LOW_PIP_TO_MULT) — trade weak tile chips for mult
		# ------------------------------------------------------------------
		_make("void_tribute", "Void Tribute", Constants.Rarity.CARVED,
			Module.EffectType.LOW_PIP_TO_MULT, 2, 2, 0,
			"Tiles with ≤2 total pips: 0 Chips, +2 Mult each.",
			"What the Void takes, it returns as signal."),

		_make("entropy_pact", "Entropy Pact", Constants.Rarity.IVORY,
			Module.EffectType.LOW_PIP_TO_MULT, 3, 3, 0,
			"Tiles with ≤3 total pips: 0 Chips, +3 Mult each.",
			"The weak become leverage. Every sacrifice strengthens the pulse."),

		_make_extra("obsidian_sacrifice", "Obsidian Sacrifice", Constants.Rarity.OBSIDIAN,
			Module.EffectType.LOW_PIP_TO_MULT, 5, 4, 1,
			"Tiles with ≤4 total pips: 0 Chips, +5 Mult each. +1 Module slot.",
			"\"Feed it the small ones. It will give you the cascade.\""),

		# ------------------------------------------------------------------
		# CONVERSION (BLANK_TO_CHIPS) — turn blank faces into chip value
		# ------------------------------------------------------------------
		_make("null_recoder", "Null Recoder", Constants.Rarity.BONE,
			Module.EffectType.BLANK_TO_CHIPS, 3, 0, 0,
			"+3 Chips per blank (0-pip) face in chain.",
			"Blank faces carry no pips, but they hold latent potential."),

		_make("zero_point_array", "Zero-Point Array", Constants.Rarity.CARVED,
			Module.EffectType.BLANK_TO_CHIPS, 7, 0, 0,
			"+7 Chips per blank face in chain.",
			"Empty nodes resonate louder than you would expect."),

		_make("resonant_null", "Resonant Null", Constants.Rarity.IVORY,
			Module.EffectType.BLANK_TO_CHIPS, 14, 0, 0,
			"+14 Chips per blank face in chain.",
			"The Chronometer found signal in the silence first."),

		# ------------------------------------------------------------------
		# SCALING (ROUND_SCALING_MULT) — compounds per round cleared
		# ------------------------------------------------------------------
		_make("momentum_coil", "Momentum Coil", Constants.Rarity.BONE,
			Module.EffectType.ROUND_SCALING_MULT, 1, 0, 0,
			"+1 Mult per round cleared. Grows throughout the run.",
			"Patience compounds. Round by round, the coil tightens."),

		_make("temporal_spiral", "Temporal Spiral", Constants.Rarity.CARVED,
			Module.EffectType.ROUND_SCALING_MULT, 2, 0, 0,
			"+2 Mult per round cleared. Stronger with every cycle.",
			"The spiral has no end. Only acceleration."),

		# ------------------------------------------------------------------
		# ECONOMY & UTILITY — new archetypes
		# ------------------------------------------------------------------
		_make("coin_magnet", "Coin Magnet", Constants.Rarity.BONE,
			Module.EffectType.COIN_PER_ROUND, 2, 0, 0,
			"+2 Monedas at the end of every round.",
			"Residual Chronos bleeds into the stipend. Small, but reliable."),

		_make("accelerator_gem", "Accelerator Gem", Constants.Rarity.CARVED,
			Module.EffectType.SHOP_DISCOUNT, 15, 0, 0,
			"All shop items cost 15% less.",
			"The market bends for those who know the right frequencies."),

		_make("transmutation_amulet", "Transmutation Amulet", Constants.Rarity.IVORY,
			Module.EffectType.DOUBLES_CONNECT_ANY, 0, 0, 0,
			"Double tiles connect to any open pip value.",
			"When both faces echo the same signal, the chain accepts them without question."),

		_make("fortune_gauntlet", "Fortune Gauntlet", Constants.Rarity.CARVED,
			Module.EffectType.CHAIN_COIN_BONUS, 1, 3, 0,
			"Chains of 3+ tiles award +1 Moneda on play.",
			"The longer the pulse, the greater the dividend."),
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
	m.icon_path    = "res://assets/modules/%s.png" % id
	return m

static func _make_extra(id: String, name: String, rarity: int,
		eff: Module.EffectType, val: int, param: int, slots: int,
		desc: String, lore: String) -> Module:
	return _make(id, name, rarity, eff, val, param, slots, desc, lore)
