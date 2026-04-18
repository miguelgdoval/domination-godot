## scoring.gd — Chronos (score) calculation.
## Pass active modules to apply Calibration Module bonuses.
class_name Scoring
extends RefCounted

## Full calculation including Calibration Module effects.
## Pass an empty array (default) for the base calculation.
static func calculate(chain: Chain, modules: Array = []) -> Dictionary:
	if chain.is_empty():
		return { "chips": 0, "mult": 1, "total": 0, "length": 0, "doubles": 0 }

	var chips:   int = 0
	var mult:    int = 1
	var doubles: int = 0
	var length:  int = chain.length()

	# --- Pre-scan modules for per-tile modifiers ---
	var double_pip_mult:  int   = 1   # DOUBLE_PIP_BOOST: highest value wins
	var double_mult_per:  int   = 1   # DOUBLE_MULT_BOOST: highest value wins
	var wild_pip_chips:   int   = 0   # WILD_PIP_VALUE: chips per wild tile (2 × face value)
	var high_pip_bonuses: Array = []  # HIGH_PIP_BONUS: [{t: threshold, v: value}]
	var sacrifice_specs:  Array = []  # LOW_PIP_TO_MULT: [{t: pip_threshold, v: mult_per}]
	var blank_pip_value:  int   = 0   # BLANK_TO_CHIPS: highest value wins
	for m in modules:
		match m.effect_type:
			Module.EffectType.DOUBLE_PIP_BOOST:
				double_pip_mult = maxi(double_pip_mult, m.effect_value)
			Module.EffectType.DOUBLE_MULT_BOOST:
				double_mult_per = maxi(double_mult_per, m.effect_value)
			Module.EffectType.WILD_PIP_VALUE:
				# Module stores face value; chip contribution = 2 faces × value
				wild_pip_chips = maxi(wild_pip_chips, m.effect_value * 2)
			Module.EffectType.HIGH_PIP_BONUS:
				high_pip_bonuses.append({"t": m.effect_param, "v": m.effect_value})
			Module.EffectType.LOW_PIP_TO_MULT:
				sacrifice_specs.append({"t": m.effect_param, "v": m.effect_value})
			Module.EffectType.BLANK_TO_CHIPS:
				blank_pip_value = maxi(blank_pip_value, m.effect_value)

	# --- Chip accumulation ---
	for tile in chain.tiles:
		var pips: int = tile.total_pips()

		# LOW_PIP_TO_MULT (sacrifice): non-wild tiles with pips ≤ threshold contribute
		# 0 chips and instead grant mult. Each qualifying spec adds its own mult bonus.
		if not tile.is_wild and not sacrifice_specs.is_empty():
			var sacrificed: bool = false
			for spec in sacrifice_specs:
				if pips <= spec["t"]:
					mult      += spec["v"]
					sacrificed = true
			if sacrificed:
				continue   # this tile is fully consumed — no chips, no doubles count

		# double_weight: -1 = auto (1 if double, 0 otherwise), else explicit
		var dw: int = tile.double_weight if tile.double_weight >= 0 \
			else (1 if tile.is_double() else 0)
		if dw > 0:
			doubles += dw
			if tile.is_wild and wild_pip_chips > 0:
				# Wild tile with WILD_PIP_VALUE: score face-value chips instead of 0
				chips += wild_pip_chips
			else:
				chips += pips * double_pip_mult
		else:
			chips += pips
		chips += tile.bonus_chips

		# BLANK_TO_CHIPS: each 0-pip face on a non-wild tile adds flat chips
		if blank_pip_value > 0 and not tile.is_wild:
			if tile.left  == 0: chips += blank_pip_value
			if tile.right == 0: chips += blank_pip_value

		# HIGH_PIP_BONUS: per-tile face threshold check
		var max_face: int = max(tile.left, tile.right)
		for hpb in high_pip_bonuses:
			if max_face >= hpb["t"]:
				chips += hpb["v"]

	# --- Base multiplier bonuses ---
	# Double resonance
	mult += doubles * double_mult_per

	# Chain length (cohesion) bonus
	if length >= Constants.CHAIN_BONUS_LARGE:
		mult += 2
	elif length >= Constants.CHAIN_BONUS_SMALL:
		mult += 1

	# --- Module flat bonuses ---
	for m in modules:
		match m.effect_type:
			Module.EffectType.FLAT_MULT:
				mult += m.effect_value
			Module.EffectType.FLAT_CHIPS:
				chips += m.effect_value
			Module.EffectType.LONG_CHAIN_BOOST:
				if length >= m.effect_param:
					mult += m.effect_value
			Module.EffectType.CHIPS_PER_TILE:
				chips += length * m.effect_value
			Module.EffectType.CLOSING_TILE_BONUS:
				# Rewards finishing a proper chain (3+ tiles)
				if length >= 3:
					chips += m.effect_value
			Module.EffectType.ERA_SCALING_MULT:
				# Grows stronger each era — weak start, strong finish
				mult += m.effect_value * (GameState.current_etapa() + 1)
			Module.EffectType.ROUND_SCALING_MULT:
				# Compounds per round completed — weak early, very strong late
				mult += m.effect_value * GameState.round_index

	return {
		"chips":   chips,
		"mult":    mult,
		"total":   chips * mult,
		"length":  length,
		"doubles": doubles,
	}
