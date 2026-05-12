## reinforcement_db.gd — Catalogue of all Reinforcement Tiles (consumables).
## Pure static data — no autoload needed.
class_name ReinforcementDB
extends RefCounted

static func all() -> Array[Reinforcement]:
	return [
		_make("bomb", "Bomb",
			Reinforcement.EffectType.BOMB, 0,
			"Permanently destroy one tile from your hand.",
			"\"Some nodes are too corrupted to reclaim. Burn them.\"",
			Constants.Rarity.BONE),

		_make("recycler", "Recycler",
			Reinforcement.EffectType.RECYCLER, 0,
			"Return one hand tile to the box. Draw a new tile.",
			"\"The Chronometer wastes nothing. Reshape what does not fit.\"",
			Constants.Rarity.BONE),

		_make("wildcard", "Wildcard",
			Reinforcement.EffectType.WILDCARD, 0,
			"Your next placed tile connects to any pip value.",
			"\"The Void has no preferences. Neither should you.\"",
			Constants.Rarity.CARVED),

		_make("hourglass", "Hourglass",
			Reinforcement.EffectType.HOURGLASS, 1,
			"Gain +1 hand this round.",
			"\"One more rotation. Use it well.\"",
			Constants.Rarity.CARVED),

		_make("fortune_essence", "Fortune Essence",
			Reinforcement.EffectType.FORTUNE_ESSENCE, 2,
			"Your next chain awards double Coins.",
			"\"Temporal residue crystallised into pure potential.\"",
			Constants.Rarity.IVORY),

		_make("copy_mirror", "Copy Mirror",
			Reinforcement.EffectType.COPY_MIRROR, 0,
			"Duplicate one tile in your hand. Keep both copies.",
			"\"The reflection is identical. Even the resonance signature.\"",
			Constants.Rarity.IVORY),

		_make("fusion_hammer", "Fusion Hammer",
			Reinforcement.EffectType.FUSION_HAMMER, 0,
			"Merge two tiles with the same pip value into a double of that value.",
			"\"Two imperfect signals, collapsed into one perfect resonance.\"",
			Constants.Rarity.OBSIDIAN),

		_make("gold_talisman", "Gold Talisman",
			Reinforcement.EffectType.GOLD_TALISMAN, 10,
			"The next tile you place gains +10 bonus chips.",
			"\"Transmutation is illegal. This talisman does not exist.\"",
			Constants.Rarity.CARVED),

		_make("compass", "Compass",
			Reinforcement.EffectType.COMPASS, 3,
			"See the next 3 tiles in your box. Reorder them freely.",
			"\"The signal is not random. You just needed to look ahead.\"",
			Constants.Rarity.IVORY),
	]

static func get_by_id(id: String) -> Reinforcement:
	for r in all():
		if r.id == id:
			return r
	return null

static func _make(id: String, name: String,
		eff: Reinforcement.EffectType, val: int,
		desc: String, lore: String,
		rarity: int = Constants.Rarity.BONE) -> Reinforcement:
	var r := Reinforcement.new()
	r.id           = id
	r.display_name = name
	r.effect_type  = eff
	r.effect_value = val
	r.description  = desc
	r.lore_text    = lore
	r.rarity       = rarity
	r.icon_path    = "res://assets/reinforcements/%s.png" % id
	return r
