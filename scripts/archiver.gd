## archiver.gd — Dialogue bank for the Archiver's intermittent transmissions.
##
## The Archiver speaks at specific round indices, with line variants
## conditioned on lifetime stats so a repeat player hears different
## things from a first-timer. Returns "" when the round shouldn't have
## a transmission, so the caller can skip cleanly.
##
## Pure static data. No autoload. Caller (main.gd) invokes
## `Archiver.line_for_round(round_index, lifetime)` and either shows
## the line or does nothing.
class_name Archiver
extends RefCounted

## Line bank indexed by 0-based round_index. Each entry is an Array of
## variants; the right variant is picked from the player's lifetime
## stats. The first variant is the always-available default.
##
## Variant format: Dictionary with optional gates —
##     "min_failures":   int — only choose if lifetime failures >= this
##     "min_wins":       int — only choose if lifetime wins >= this
##     "min_familiarity": int — only choose if archiver_familiarity >= this
##                              (counts transmissions heard + Archiver
##                              event encounters across all runs)
##     "text":           String — the actual line
##
## The selector picks the most specific variant available — for each
## round, it walks variants from last (most-gated) to first (default)
## and returns the first whose gates are all met. So familiarity gates
## should be ordered AFTER the wins/failures variants for the same
## thematic level if you want them to take priority at high counts.
##
## Missing round entries → no transmission.
const LINES: Dictionary = {
	# Round 1 — opening of every run
	0: [
		{"text": "Trial Cycle initialised. Operator, you have the Window."},
		{"min_failures": 25, "text":
			"Cycle %s. Take the Window. Try not to bring me back here too soon." % "{cycle}"},
		{"min_failures": 100, "text":
			"Welcome back, Operator. You have always been welcome back."},
		{"min_wins": 25, "text":
			"Operator. The Architects are watching this run with interest."},
		# Familiarity-gated lines — the Archiver drops the formal register
		# as he hears himself addressed by the Operator more often.
		{"min_familiarity": 40, "text":
			"You are here again. I do not mind. I do not mind anymore."},
		{"min_familiarity": 100, "text":
			"Operator. The transmissions cost less when you stay."},
	],
	# Round 3 — mid-Mahogany observation
	2: [
		{"text": "Mahogany holds. The Machine learns nothing yet."},
		{"min_failures": 50, "text":
			"You have seen this chamber many times. The Machine has not noticed."},
		{"min_familiarity": 60, "text":
			"The Mahogany Trial. You and I have crossed it together more often than the records show."},
	],
	# Round 5 — entering Industrial Load (etapa transition)
	5: [
		{"text": "Etapa II. The steam rises to meet you."},
		{"min_wins": 10, "text":
			"Industrial Load. You know its temperaments."},
		{"min_familiarity": 50, "text":
			"The pressure. You have grown into it. I have noticed."},
	],
	# Round 7 — mid-Industrial
	7: [
		{"text": "The pressure builds. Stay above it."},
		{"min_familiarity": 80, "text":
			"Stay above it. You know how. I will not lecture."},
	],
	# Round 9 — pre-boss for Etapa II
	8: [
		{"text": "The Mirror approaches. Trust your low signals."},
		{"min_failures": 10, "text":
			"You know what comes next. The pips invert; the small become large."},
		{"min_familiarity": 70, "text":
			"The Mirror. You and I disagree about it. I am the one keeping score."},
	],
	# Round 11 — entering Cold Singularity
	10: [
		{"text": "The Singularity. Even the Machine breathes slower here."},
		{"min_wins": 10, "text":
			"You have crossed the Singularity before. You remember the cold."},
		{"min_familiarity": 60, "text":
			"The cold is for both of us. It is not personal. It is simply the Singularity."},
	],
	# Round 13 — mid-Singularity
	12: [
		{"text": "Doubles are about to betray you. Adapt or be lost."},
		{"min_familiarity": 80, "text":
			"Doubles. You know the trick by now. I am only saying it for the record."},
	],
	# Round 16 — Hard mode only, entering Archiver's Core
	15: [
		{"text": "You are inside the Archive. Some of you, at least."},
		{"min_wins": 25, "text":
			"You insist on returning to this chamber. I respect that."},
		{"min_familiarity": 90, "text":
			"The Archive holds you, Operator. The Archive does not hold many things twice."},
	],
	# Round 18 — mid-Archive
	17: [
		{"text": "The Ghost Chain remembers you, even when you forget yourself."},
		{"min_familiarity": 100, "text":
			"Operator. I remember what the Archive forgets. You may rely on this."},
	],
}

## Returns the best line for the given round, or "" if the round has
## no dialogue. The selector picks the highest-gate variant the player
## meets, so repeat players naturally see different lines than first-
## timers without per-round duplication.
##
## `round_index` is 0-based (round 1 == 0).
## `lifetime` is the SaveManager.get_lifetime_stats() dict.
## `familiarity` (optional) is SaveManager.get_archiver_familiarity() —
##   gates the tone-shift variants that mark deepening relationship.
static func line_for_round(round_index: int, lifetime: Dictionary,
		familiarity: int = 0) -> String:
	if not LINES.has(round_index):
		return ""
	var variants: Array = LINES[round_index]
	if variants.is_empty():
		return ""

	var fails: int = maxi(0, int(lifetime.get("runs", 0)) -
		int(lifetime.get("wins", 0)))
	var wins:  int = int(lifetime.get("wins", 0))

	# Walk from last (most-specific gate) to first (default), pick the
	# first one whose gates the player meets.
	for i in range(variants.size() - 1, -1, -1):
		var v: Dictionary = variants[i]
		if int(v.get("min_failures", 0)) > fails:
			continue
		if int(v.get("min_wins", 0)) > wins:
			continue
		if int(v.get("min_familiarity", 0)) > familiarity:
			continue
		var text: String = String(v.get("text", ""))
		# Cycle substitution — only used for the run-counter variant on
		# round 0. Computed from runs+1 to reflect the current run.
		return text.replace("{cycle}", str(int(lifetime.get("runs", 0)) + 1))
	return ""
