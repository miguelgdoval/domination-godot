## mastery_db.gd — Catalogue of all Mastery Contracts.
## Pure static data — no autoload needed.
class_name MasteryDB
extends RefCounted

static func all() -> Array[MasteryContract]:
	return [
		_make("fortune_mastery", "Fortune Mastery",
			MasteryContract.ObjectiveType.EARN_MONEDAS_IN_ROUND, 25, 0, 30,
			"Earn 25 Monedas in a single round.",
			"\"Show the Archival Authority what efficiency looks like.\""),

		_make("collector_mastery", "Collector's Mastery",
			MasteryContract.ObjectiveType.USE_REINFORCEMENTS, 3, 0, 25,
			"Activate 3 Reinforcement tiles in one round.",
			"\"A well-stocked Operator is an unstoppable Operator.\""),

		_make("investor_mastery", "Investor's Mastery",
			MasteryContract.ObjectiveType.BUY_SHOP_ITEM, 1, 0, 20,
			"Purchase any item from the shop.",
			"\"Capital circulating is capital working.\""),

		_make("expert_mastery", "Expert's Mastery",
			MasteryContract.ObjectiveType.SCORE_CHAIN, 50, 0, 35,
			"Score a single chain of 50+ Chronos.",
			"\"The threshold is not arbitrary. It is the minimum the Chronometer respects.\""),

		_make("doubler_mastery", "Doubler's Mastery",
			MasteryContract.ObjectiveType.PLAY_DOUBLES, 4, 0, 30,
			"Place 4 double tiles across the run.",
			"\"Self-resonance is the purest form of coherence.\""),

		_make("void_mastery", "Void Mastery",
			MasteryContract.ObjectiveType.EMPTY_HAND, 1, 0, 40,
			"Empty your hand completely — 0 tiles remaining.",
			"\"The Operator who holds nothing holds everything.\""),

		_make("multiplier_mastery", "Multiplier's Mastery",
			MasteryContract.ObjectiveType.REACH_SCORE_BEFORE_ROUND, 500, 10, 50,
			"Accumulate 500 total Chronos before round 10.",
			"\"Early acceleration compounds. The Chronometer never forgets momentum.\""),
	]

static func get_by_id(id: String) -> MasteryContract:
	for c in all():
		if c.id == id:
			return c
	return null

static func _make(id: String, name: String,
		obj: MasteryContract.ObjectiveType, target: int, param: int,
		reward: int, desc: String, lore: String) -> MasteryContract:
	var c := MasteryContract.new()
	c.id             = id
	c.display_name   = name
	c.objective_type = obj
	c.target         = target
	c.target_param   = param
	c.reward_monedas = reward
	c.description    = desc
	c.lore_text      = lore
	c.icon_path      = "res://assets/contracts/%s.png" % id
	return c
