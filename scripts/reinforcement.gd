## reinforcement.gd — A Reinforcement Tile (one-use consumable item).
## The player carries up to MAX_REINFORCEMENTS at a time.
## Each fires a discrete in-run effect when activated.
class_name Reinforcement
extends RefCounted

enum EffectType {
	BOMB,           # Remove one tile from hand permanently
	RECYCLER,       # Return one tile to the box, draw a new one
	WILDCARD,       # Next tile placed connects to any value (one-shot wild)
	HOURGLASS,      # Gain +1 extra hand this round (one-shot)
	FORTUNE_ESSENCE,# Next chain played earns double Monedas
	COPY_MIRROR,    # Duplicate one hand tile (add a copy to hand)
	FUSION_HAMMER,  # Combine two low-value tiles into a higher-value double
	GOLD_TALISMAN,  # Transform next placed tile into a bonus-chip tile (+10 chips)
	COMPASS,        # Peek the next 3 tiles in the box and reorder them
}

var id:           String
var display_name: String
var effect_type:  EffectType
var effect_value: int = 0       # secondary numeric param (e.g. chip bonus)
var description:  String
var lore_text:    String = ""
var icon_path:    String = ""   # res://assets/reinforcements/{id}.png — swap when art arrives
