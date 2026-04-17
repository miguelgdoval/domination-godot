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
	var double_pip_mult: int = 1   # DOUBLE_PIP_BOOST: highest value wins
	var double_mult_per: int = 1   # DOUBLE_MULT_BOOST: highest value wins
	for m in modules:
		match m.effect_type:
			Module.EffectType.DOUBLE_PIP_BOOST:
				double_pip_mult = maxi(double_pip_mult, m.effect_value)
			Module.EffectType.DOUBLE_MULT_BOOST:
				double_mult_per = maxi(double_mult_per, m.effect_value)

	# --- Chip accumulation ---
	for tile in chain.tiles:
		var pips: int = tile.total_pips()
		# double_weight: -1 = auto (1 if double, 0 otherwise), else explicit
		var dw: int = tile.double_weight if tile.double_weight >= 0 \
			else (1 if tile.is_double() else 0)
		if dw > 0:
			doubles += dw
			chips += pips * double_pip_mult
		else:
			chips += pips
		chips += tile.bonus_chips

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

	return {
		"chips":   chips,
		"mult":    mult,
		"total":   chips * mult,
		"length":  length,
		"doubles": doubles,
	}
