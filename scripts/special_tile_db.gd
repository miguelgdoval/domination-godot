## special_tile_db.gd — Named tiles with unique scoring properties.
## These appear exclusively in the Artisan's Workshop tile shop.
class_name SpecialTileDB
extends RefCounted

## Returns the full pool of acquirable special tiles.
static func all() -> Array[Domino]:
	return [
		_anchor(),
		_echo(),
		_gilded_shard(),
		_prism(),
		_void_eye(),
	]

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
