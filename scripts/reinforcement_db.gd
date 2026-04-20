## reinforcement_db.gd — Catalogue of all Reinforcement Tiles (consumables).
## Pure static data — no autoload needed.
class_name ReinforcementDB
extends RefCounted

static func all() -> Array[Reinforcement]:
	return [
		_make("bomb", "Bomba",
			Reinforcement.EffectType.BOMB, 0,
			"Permanently destroy one tile from your hand.",
			"\"Some nodes are too corrupted to reclaim. Burn them.\""),

		_make("recycler", "Reciclador",
			Reinforcement.EffectType.RECYCLER, 0,
			"Return one hand tile to the box. Draw a new tile.",
			"\"The Chronometer wastes nothing. Reshape what does not fit.\""),

		_make("wildcard", "Comodín",
			Reinforcement.EffectType.WILDCARD, 0,
			"Your next placed tile connects to any pip value.",
			"\"The Void has no preferences. Neither should you.\""),

		_make("hourglass", "Reloj de Arena",
			Reinforcement.EffectType.HOURGLASS, 1,
			"Gain +1 hand this round.",
			"\"One more rotation. Use it well.\""),

		_make("fortune_essence", "Esencia de la Fortuna",
			Reinforcement.EffectType.FORTUNE_ESSENCE, 2,
			"Your next chain awards double Monedas.",
			"\"Temporal residue crystallised into pure potential.\""),

		_make("copy_mirror", "Espejo de Copia",
			Reinforcement.EffectType.COPY_MIRROR, 0,
			"Duplicate one tile in your hand. Keep both copies.",
			"\"The reflection is identical. Even the resonance signature.\""),

		_make("fusion_hammer", "Martillo de la Fusión",
			Reinforcement.EffectType.FUSION_HAMMER, 0,
			"Merge two tiles with the same pip value into a double of that value.",
			"\"Two imperfect signals, collapsed into one perfect resonance.\""),

		_make("gold_talisman", "Talismán de Oro",
			Reinforcement.EffectType.GOLD_TALISMAN, 10,
			"The next tile you place gains +10 bonus chips.",
			"\"Transmutation is illegal. This talisman does not exist.\""),

		_make("compass", "Brújula",
			Reinforcement.EffectType.COMPASS, 3,
			"See the next 3 tiles in your box. Reorder them freely.",
			"\"The signal is not random. You just needed to look ahead.\""),
	]

static func get_by_id(id: String) -> Reinforcement:
	for r in all():
		if r.id == id:
			return r
	return null

static func _make(id: String, name: String,
		eff: Reinforcement.EffectType, val: int,
		desc: String, lore: String) -> Reinforcement:
	var r := Reinforcement.new()
	r.id           = id
	r.display_name = name
	r.effect_type  = eff
	r.effect_value = val
	r.description  = desc
	r.lore_text    = lore
	r.icon_path    = "res://assets/reinforcements/%s.png" % id
	return r
