## notebook_db.gd — Found notes from previous Operators.
##
## Once per run (~65% of runs), one of these fragments appears in a
## random shop visit as a short italicised note attributed to a fallen
## Operator. The fragments mix:
##
##   • accurate hints      — real strategic advice
##   • lore-only flavour   — atmosphere, no mechanical content
##   • unreliable advice   — wrong on purpose. The Operator before you
##                            was learning too. Half the fun is figuring
##                            out which is which.
##
## Each entry carries an `operator_n` so different fragments feel like
## different voices. Some Operator numbers repeat across multiple notes
## to suggest a few specific Operators left several pages behind.
##
## Pure static data — no autoload needed.
class_name NotebookDB
extends RefCounted

## Tag values — surfaced in code for filtering / weighting if we ever
## want to bias toward "accurate" notes for new players, etc. Not used
## in v1; included for future tuning.
const TAG_ACCURATE:   String = "accurate"
const TAG_LORE:       String = "lore"
const TAG_UNRELIABLE: String = "unreliable"

static func all() -> Array[Dictionary]:
	return [
		# ── ACCURATE — real strategic advice ────────────────────────────────
		{
			"operator_n": 11,
			"text":       "The Mirror eats high pips. Blanks survive it. Build a backup chain in Etapa II.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 11,
			"text":       "Doubles betray you in the Singularity. Don't lean on what you've been building.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 11,
			"text":       "Tier bonuses don't stack. The highest applies. Don't be a hero past Singularity.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 47,
			"text":       "Stand only when extending the chain wouldn't cross the next tier. Otherwise: push.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 47,
			"text":       "Wild tiles without the Void Channeler are tax. With it, they're scoring engines.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 88,
			"text":       "The Workshop sells one Ivory and one Obsidian. Save your Coins for it, not for Bone gear.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 88,
			"text":       "Ghost Chain hides the tiles, not the pip values. The connections still exist.",
			"tag":        TAG_ACCURATE,
		},
		{
			"operator_n": 152,
			"text":       "Unused hands at round-end pay one Coin each. Don't burn plays you don't need.",
			"tag":        TAG_ACCURATE,
		},

		# ── LORE — atmosphere, no mechanical content ────────────────────────
		{
			"operator_n": 7,
			"text":       "I have seen the Archiver appear twice in one Cycle. The second time was a mercy. The third would not be.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 7,
			"text":       "The Renegade isn't lying about the Modules. He's selling something the Society wants kept off the catalogue.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 7,
			"text":       "The Master speaks rarely. When he does, listen — even if his hint is silence.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 203,
			"text":       "The Guild's records show every Operator who has stood at the Window. The list does not always read forward.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 203,
			"text":       "Operator-prime used only the Standard Core. The Archive does not record what she was running from.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 419,
			"text":       "Three Cycles of Recalibration and I still don't trust the Mirror. The Mirror does not require my trust.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 419,
			"text":       "The Society teaches you to hesitate. The Renegade teaches you not to. I have not decided who is right.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 612,
			"text":       "I died at the Pinnacle. I do not blame the Pinnacle. The Pinnacle does what the Pinnacle was built for.",
			"tag":        TAG_LORE,
		},

		# ── UNRELIABLE — subtly wrong on purpose ────────────────────────────
		{
			"operator_n": 31,
			"text":       "Always Stand at tier 2. Tier 3 isn't worth the risk and the Machine punishes ambition.",
			"tag":        TAG_UNRELIABLE,
		},
		{
			"operator_n": 31,
			"text":       "Blanks score zero. Don't draw them. Discard every blank you see, immediately.",
			"tag":        TAG_UNRELIABLE,
		},
		{
			"operator_n": 31,
			"text":       "The Frequency Drain is the hardest Failure. The others are easier. Build to survive the first.",
			"tag":        TAG_UNRELIABLE,
		},
		{
			"operator_n": 31,
			"text":       "Doubles always give +1 mult. Stack as many as you can, the Machine has no upper limit.",
			"tag":        TAG_UNRELIABLE,
		},
		{
			"operator_n": 31,
			"text":       "Obsidian modules are illegal. The Archiver will void your run if you equip more than one.",
			"tag":        TAG_UNRELIABLE,
		},

		# ── OPINIONATED — strong views, debatable correctness ───────────────
		{
			"operator_n": 244,
			"text":       "Build wide, not deep. The Machine respects breadth. Twelve tiles beats six high-pip ones.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 244,
			"text":       "The Society teaches you to hesitate. Don't. Play the Pulse you have, not the one you wanted.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 506,
			"text":       "If you reach the Archiver's Core, do not Stand on Round 16. Push. The Cycle is over either way.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 506,
			"text":       "The Archiver speaks differently to those who have failed often. Failure has its uses.",
			"tag":        TAG_LORE,
		},

		# ── FIRST HOUR — operators who heard the term and recorded it ───────
		# The First Hour is the Society's name for the period before its
		# founding. Past Operators caught the term in passing and wrote it
		# down. None of them learned what it meant. They are not the only
		# ones who didn't learn.
		{
			"operator_n": 203,
			"text":       "The Renegade once told me a name. He said it was from the First Hour. I have forgotten it. Of course I have.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 419,
			"text":       "The Master, drunk once, said the First Hour was \"shorter than they will tell you.\" He did not elaborate. He does not drink anymore.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 612,
			"text":       "I think the First Hour ended on a Tuesday. I have nothing to base this on.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 7,
			"text":       "Asked the Archiver about the First Hour. He answered. I have written down what he answered. The paper is blank.",
			"tag":        TAG_LORE,
		},

		# ── DEEP CAREER — late-Cycle fragments ──────────────────────────────
		# Voices reaching the end of their tenure at the Window. Not
		# advice. The texture of becoming part of the Machine. The bible
		# (§7) says Operators who survive long enough are absorbed into
		# the Chambers — these fragments are the last writing from before
		# that absorption was complete.
		{
			"operator_n": 244,
			"text":       "I do not remember which Cycle I am on. The Archive does. I have stopped asking. The information is no longer useful to me.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 419,
			"text":       "I dreamt of an outside last Cycle. Or I dreamt of a place I called the outside. The Master, when I described it, did not recognise any of it. Neither did I, on waking.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 506,
			"text":       "I reached the Archiver's Core on my hundredth Recalibration. The Archiver said something I have lost. I do not blame him. He is going. So am I.",
			"tag":        TAG_LORE,
		},
		{
			"operator_n": 203,
			"text":       "They said Operator-prime never spoke at the Window. I doubt this. She would have spoken. I think we have just forgotten what she said.",
			"tag":        TAG_LORE,
		},
	]

## Pick a random fragment. Uses the project RNG, so daily-mode runs are
## deterministic when the seed is fixed at run start.
static func pick_random() -> Dictionary:
	var pool: Array[Dictionary] = all()
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]
