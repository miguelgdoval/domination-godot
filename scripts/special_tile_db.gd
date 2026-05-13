## special_tile_db.gd — Named tiles with unique scoring properties.
## These appear exclusively in the Artisan's Workshop tile shop.
class_name SpecialTileDB
extends RefCounted

## Returns the full pool of acquirable special tiles. The Architect's
## Mark is faction-gated and only joins the pool when the Society
## reputation has been crossed (see SaveManager.is_faction_unlocked).
static func all() -> Array[Domino]:
	var pool: Array[Domino] = [
		_anchor(),
		_echo(),
		_gilded_shard(),
		_prism(),
		_void_eye(),
		_spark(),
		_hollow(),
		_bridge(),
		_pinnacle(),
		_crown(),
	]
	if SaveManager != null and SaveManager.is_faction_unlocked("society"):
		pool.append(_architects_mark())
	return pool

## The Anchor — a 0|0 that refuses to be worthless.
## Scores 15 bonus chips when played.
static func _anchor() -> Domino:
	var d := Domino.new(0, 0, Constants.Rarity.IVORY)
	d.custom_name  = "The Anchor"
	d.bonus_chips  = 15
	d.lore_text    = "\"Even entropy has a floor.\""
	return d

## The Echo — a 5|5 that resonates twice.
## Counts as 2 doubles for multiplier purposes.
static func _echo() -> Domino:
	var d := Domino.new(5, 5, Constants.Rarity.IVORY)
	d.custom_name  = "The Echo"
	d.double_weight = 2
	d.lore_text    = "\"Its frequency rings across two signal layers simultaneously.\""
	return d

## The Gilded Shard — a 4|6 coated in chronometric alloy.
## +8 bonus chips when scored.
static func _gilded_shard() -> Domino:
	var d := Domino.new(4, 6, Constants.Rarity.CARVED)
	d.custom_name  = "The Gilded Shard"
	d.bonus_chips  = 8
	d.lore_text    = "\"Salvaged from the third calibration collapse.\""
	return d

## The Prism — a 3|9 that refracts the signal.
## +6 bonus chips and counts as 1 double regardless of its pips.
static func _prism() -> Domino:
	var d := Domino.new(3, 9, Constants.Rarity.CARVED)
	d.custom_name    = "The Prism"
	d.bonus_chips    = 6
	d.double_weight  = 1
	d.lore_text      = "\"Light entering becomes light multiplied.\""
	return d

## The Void Eye — a Wild tile that also contributes 5 bonus chips.
static func _void_eye() -> Domino:
	var d := Domino.new(Domino.WILD, Domino.WILD, Constants.Rarity.OBSIDIAN, true)
	d.custom_name  = "The Void Eye"
	d.bonus_chips  = 5
	d.lore_text    = "\"It sees all connections and makes them real.\""
	return d

## The Spark — a 1|1 with +5 bonus chips. Bone-tier entry to the
## special-tile shop so the player has an affordable upgrade option
## even on a tight monedas budget.
static func _spark() -> Domino:
	var d := Domino.new(1, 1, Constants.Rarity.BONE)
	d.custom_name = "The Spark"
	d.bonus_chips = 5
	d.lore_text   = "\"Small. But the cascade has to start somewhere.\""
	return d

## The Hollow — Bone-tier 0|0 with +6 bonus chips. Cheaper Anchor variant
## for early-run blank-friendly builds (especially on the Blank Slate core).
static func _hollow() -> Domino:
	var d := Domino.new(0, 0, Constants.Rarity.BONE)
	d.custom_name = "The Hollow"
	d.bonus_chips = 6
	d.lore_text   = "\"An empty channel still carries a tone.\""
	return d

## The Bridge — a 3|6, both pips common across the standard set, with
## +6 bonus chips and double_weight=1 so the tile contributes a double's
## mult bonus despite being a non-double. Designed as a connector tile
## that fits anywhere AND scores like a real double.
static func _bridge() -> Domino:
	var d := Domino.new(3, 6, Constants.Rarity.CARVED)
	d.custom_name    = "The Bridge"
	d.bonus_chips    = 6
	d.double_weight  = 1
	d.lore_text      = "\"Two flows, one channel. The Bridge does not choose sides.\""
	return d

## The Pinnacle — a 9|9 that counts as 3 doubles for multiplier purposes
## and adds 8 bonus chips. Massive on a doubles-stack build, terrible
## under Resonance Inversion (Boss 3) — a real strategic acquisition.
static func _pinnacle() -> Domino:
	var d := Domino.new(9, 9, Constants.Rarity.OBSIDIAN)
	d.custom_name    = "The Pinnacle"
	d.bonus_chips    = 8
	d.double_weight  = 3
	d.lore_text      = "\"The peak of resonance. Three signals from one source.\""
	return d

## The Crown — Obsidian Wild with double_weight=3 and +8 bonus chips.
## Connects to anything (Wild) AND triples its mult contribution. Total
## chip output: WILD_BASE_CHIPS (10) + bonus (8) = 18, with +3 mult from
## the triple-resonance. The Archiver-tier centerpiece of any Wild build.
static func _crown() -> Domino:
	var d := Domino.new(Domino.WILD, Domino.WILD, Constants.Rarity.OBSIDIAN, true)
	d.custom_name    = "The Crown"
	d.bonus_chips    = 8
	d.double_weight  = 3
	d.lore_text      = "\"It does not need to match. The chain matches it.\""
	return d

## The Architect's Mark — society-faction reward. A 7|7 with +12 bonus
## chips, Ivory rarity. Only enters the Artisan tile pool after the
## Operator has earned the Society's recognition (10+ society rep).
## Heavy double on a Society-issue tile — the Architects don't waste
## their seal on small gear.
static func _architects_mark() -> Domino:
	var d := Domino.new(7, 7, Constants.Rarity.IVORY)
	d.custom_name    = "The Architect's Mark"
	d.bonus_chips    = 12
	d.lore_text      = "\"Awarded only to Operators who have demonstrated alignment with the Society's calibration philosophy.\""
	return d
