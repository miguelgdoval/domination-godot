## save_manager.gd — Persistence layer: run state, settings, best scores.
## Autoloaded as "SaveManager".
##
## Save file location: user://save.json
## (on Android: /data/data/<package>/files/save.json)
extends Node

# Fired when a codex entry is newly unlocked (not on no-op re-unlocks).
# main.gd connects this to a toast notification so the player sees
# discoveries surface mid-run instead of having to dig into the codex.
signal codex_unlocked(id: String)

# Fired when an achievement crosses its earned threshold for the first
# time. Migration on first call after this feature exists silently seeds
# `seen_achievements` so legacy progress doesn't flood the player with
# retroactive toasts.
signal achievement_unlocked(idx: int)

const SAVE_PATH := "user://save.json"

# ---------------------------------------------------------------------------
# Default structures
# ---------------------------------------------------------------------------
const DEFAULT_SETTINGS := {
	"sfx_volume":      1.0,
	"music_volume":    0.70,
	"muted":           false,
	"anim_speed":      1.0,
	"text_scale":      1.0,
	"pip_numerals":    false,
	"colorblind_mode": false,
}

# Allowed animation-speed presets. Settings overlay cycles through these.
const ANIM_SPEED_PRESETS: Array[float] = [1.0, 2.0, 4.0]
const ANIM_SPEED_LABELS:  Array[String] = ["NORMAL", "FAST", "FASTER"]

# Text-scale presets. Applied multiplicatively to every label / button
# font size at construction time — takes effect on the next UI rebuild
# (round start, shop visit, etc.), not retroactively on live widgets.
const TEXT_SCALE_PRESETS: Array[float]  = [1.0, 1.15, 1.30]
const TEXT_SCALE_LABELS:  Array[String] = ["100%", "115%", "130%"]

const DEFAULT_SCORES := {
	# key: "difficulty_N" → { round_reached, total_chronos, modules_count }
}

# ---------------------------------------------------------------------------
# In-memory cache
# ---------------------------------------------------------------------------
var _data: Dictionary = {}

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func _ready() -> void:
	_load_from_disk()
	# Seed the seen-achievements list on first run after this feature
	# was added — otherwise a returning player would get a flood of
	# retroactive toasts the next time stats change.
	check_and_emit_achievements()

# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------
func save_settings(sfx_vol: float, music_vol: float, muted: bool) -> void:
	_data["settings"] = {
		"sfx_volume":   sfx_vol,
		"music_volume": music_vol,
		"muted":        muted,
	}
	_save_to_disk()

func load_settings() -> Dictionary:
	return _data.get("settings", DEFAULT_SETTINGS.duplicate())

## Animation-speed multiplier applied to long cinematics (boss warning,
## scoring cascade, run-end reveal). 1.0 = baseline, 2.0/4.0 for players
## who'd rather skim the eye candy. Stored per-installation, not per-run.
func get_anim_speed() -> float:
	var s: Dictionary = _data.get("settings", {})
	return float(s.get("anim_speed", DEFAULT_SETTINGS["anim_speed"]))

func set_anim_speed(v: float) -> void:
	var s: Dictionary = _data.get("settings", DEFAULT_SETTINGS.duplicate())
	s["anim_speed"] = v
	_data["settings"] = s
	_save_to_disk()

## Text-scale multiplier applied to every label / button at creation
## time. Persists across sessions, so a player who needs larger text
## doesn't have to dig into Settings every run.
func get_text_scale() -> float:
	var s: Dictionary = _data.get("settings", {})
	return float(s.get("text_scale", DEFAULT_SETTINGS["text_scale"]))

func set_text_scale(v: float) -> void:
	var s: Dictionary = _data.get("settings", DEFAULT_SETTINGS.duplicate())
	s["text_scale"] = v
	_data["settings"] = s
	_save_to_disk()

## Toggle for showing numeric pip values alongside the dot pattern on
## every domino. Helps players who can't quickly count 8-9 dots, plus
## anyone scanning a long chain at a glance.
func get_pip_numerals() -> bool:
	var s: Dictionary = _data.get("settings", {})
	return bool(s.get("pip_numerals", DEFAULT_SETTINGS["pip_numerals"]))

func set_pip_numerals(b: bool) -> void:
	var s: Dictionary = _data.get("settings", DEFAULT_SETTINGS.duplicate())
	s["pip_numerals"] = b
	_data["settings"] = s
	_save_to_disk()

## Colorblind-friendly palette toggle. Swaps the green/red signals
## (chronos progress, win/loss states, affordable shop items) to a
## deuteranopia-safe cyan/orange pair on key UI surfaces. Symbol-only
## reads stay readable; gold/amber accents are unchanged.
func is_colorblind_mode() -> bool:
	var s: Dictionary = _data.get("settings", {})
	return bool(s.get("colorblind_mode", DEFAULT_SETTINGS["colorblind_mode"]))

func set_colorblind_mode(b: bool) -> void:
	var s: Dictionary = _data.get("settings", DEFAULT_SETTINGS.duplicate())
	s["colorblind_mode"] = b
	_data["settings"] = s
	_save_to_disk()

# ---------------------------------------------------------------------------
# Run persistence
# ---------------------------------------------------------------------------

## Serialise the current GameState run into the save file.
## Call after every shop exit and at the end of every scored hand.
##
## Daily-trial runs are intentionally NOT auto-saved: the determinism of
## the seed only holds if the run is played in one session, and persisting
## the in-progress state would let the player effectively restart by
## crashing at a bad point.
func save_run() -> void:
	if not _is_run_active():
		return
	if GameState.is_daily_run:
		return
	_data["run"] = {
		"active":           true,
		"round_index":      GameState.round_index,
		"monedas":          GameState.monedas,
		"difficulty":       GameState.difficulty,
		"chosen_core":      GameState.chosen_core,
		"chosen_protocol":  GameState.chosen_protocol,
		"total_chronos":    GameState.total_chronos,
		"best_hand":        GameState.best_hand,
		"hands_played":     GameState.hands_played,
		"doubles_played":   GameState.doubles_played,
		"module_slots":     GameState.module_slots,
		"modules":          _serialise_modules(),
		"reinforcements":   _serialise_reinforcements(),
	}
	_save_to_disk()

## Returns true if a saved mid-run exists.
func has_saved_run() -> bool:
	return _data.get("run", {}).get("active", false)

## Load a previously saved run back into GameState.
## Returns false if no save exists.
func load_run() -> bool:
	var run: Dictionary = _data.get("run", {})
	if not run.get("active", false):
		return false

	GameState.round_index     = run.get("round_index",     0)
	GameState.monedas         = run.get("monedas",         0)
	GameState.difficulty      = run.get("difficulty",      Constants.Difficulty.NORMAL)
	GameState.chosen_core     = run.get("chosen_core",     0)
	GameState.chosen_protocol = run.get("chosen_protocol", 0)
	GameState.total_chronos   = run.get("total_chronos",   0)
	GameState.best_hand       = run.get("best_hand",       0)
	GameState.hands_played    = run.get("hands_played",    0)
	GameState.doubles_played  = run.get("doubles_played",  0)
	GameState.module_slots    = run.get("module_slots",    Constants.BASE_MODULE_SLOTS)
	GameState.box             = Box.create_for_core(GameState.chosen_core)
	GameState.modules         = _deserialise_modules(run.get("modules", []))
	GameState.reinforcements  = _deserialise_reinforcements(run.get("reinforcements", []))
	GameState.active_contracts    = []
	GameState.completed_contracts = []
	return true

## Clear the active run save (call on game over, victory, or new game).
func clear_run() -> void:
	_data.erase("run")
	_save_to_disk()

# ---------------------------------------------------------------------------
# Best scores
# ---------------------------------------------------------------------------

## Record a completed or failed run result.
func record_run_result(difficulty: int, round_reached: int,
		total_chronos: int, modules_count: int) -> bool:
	var key: String = "best_%d" % difficulty
	var prev: Dictionary = _data.get(key, {})
	var improved: bool = false

	# A run is "better" if it reached a higher round, or same round with more Chronos
	var prev_round: int = prev.get("round_reached", -1)
	var prev_chronos: int = prev.get("total_chronos", 0)

	if round_reached > prev_round or \
			(round_reached == prev_round and total_chronos > prev_chronos):
		_data[key] = {
			"round_reached":  round_reached,
			"total_chronos":  total_chronos,
			"modules_count":  modules_count,
		}
		improved = true
		_save_to_disk()

	return improved

## Returns best run data for a difficulty, or empty dict if none.
func get_best_run(difficulty: int) -> Dictionary:
	return _data.get("best_%d" % difficulty, {})

# ---------------------------------------------------------------------------
# Lifetime stats (persistent across all runs)
# ---------------------------------------------------------------------------

## Update cumulative-across-all-runs stats. Called from the run-end recap
## with the metrics from the run that just finished. Each new run only
## ever increases the stored maxima.
##
## Also stores a `last_run` snapshot used by `get_last_run()` — feeds the
## "prior cycle" hint shown at the start of the next run.
func accumulate_run_stats(stats: Dictionary) -> void:
	var s: Dictionary = _data.get("lifetime_stats", {})
	s["runs"]            = s.get("runs",            0) + 1
	if stats.get("won", false):
		s["wins"]        = s.get("wins",            0) + 1
		# Track hard-mode wins separately so an achievement can gate on
		# "win on hard difficulty" without needing per-run win records.
		if int(stats.get("difficulty", -1)) == Constants.Difficulty.HARD:
			s["hard_wins"] = s.get("hard_wins",     0) + 1
	s["chronos"]         = s.get("chronos",         0) + int(stats.get("total_chronos", 0))
	s["hands_played"]    = s.get("hands_played",    0) + int(stats.get("hands_played", 0))
	s["doubles_played"]  = s.get("doubles_played",  0) + int(stats.get("doubles_played", 0))
	s["longest_chain"]   = maxi(s.get("longest_chain", 0), int(stats.get("longest_chain", 0)))
	s["best_tier"]       = maxi(s.get("best_tier",     -1), int(stats.get("best_tier", -1)))
	s["best_round"]      = maxi(s.get("best_round",    0), int(stats.get("round_reached", 0)))
	# Track unique modules ever collected — useful for "you've seen N of M
	# modules" style achievements down the line.
	var seen: Array = s.get("modules_seen", [])
	for mid in stats.get("module_ids", []):
		if mid not in seen:
			seen.append(mid)
	s["modules_seen"] = seen
	# Snapshot of the run that just ended. Read by `get_last_run()` to
	# render the "prior cycle" hint at the start of the next run.
	s["last_run"] = {
		"won":           bool(stats.get("won", false)),
		"round_reached": int(stats.get("round_reached", 0)),
		"total_chronos": int(stats.get("total_chronos", 0)),
		"etapa":         int(stats.get("etapa", 0)),
		"boss_round":    bool(stats.get("boss_round", false)),
		"core":          int(stats.get("core", 0)),
		"difficulty":    int(stats.get("difficulty", 0)),
		"is_daily":      bool(stats.get("is_daily", false)),
	}
	_data["lifetime_stats"] = s
	_save_to_disk()
	check_and_emit_achievements()

## Returns the snapshot of the most recent completed run (win or loss),
## or {} if no run has ended yet. Powers the prior-cycle hint shown at
## the start of every non-first run.
func get_last_run() -> Dictionary:
	return _data.get("lifetime_stats", {}).get("last_run", {})

# ---------------------------------------------------------------------------
# Daily Trial
# ---------------------------------------------------------------------------

## Today's calendar key (YYYY-MM-DD), used as the daily-history dict key.
func today_date_key() -> String:
	var d: Dictionary = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]

## Deterministic seed for today's daily trial. Same value for every player
## on the same calendar day (UTC drift aside) so leaderboards / shared
## attempts compare apples to apples.
func today_daily_seed() -> int:
	var d: Dictionary = Time.get_date_dict_from_system()
	return int(d.year) * 10000 + int(d.month) * 100 + int(d.day)

## Operator number for a given date — derived deterministically from
## the date key so every player sees the same Operator-N for the same
## calendar day. Lore: each daily seed is a memorial for a fallen
## Operator from the Society's records, replayed across the timelines.
##
## Range 1-999. The collision risk over the lifetime of the game is
## acceptable — the lore intentionally implies many Operators have
## fallen and some numbers may recur.
func daily_operator_number(date_key: String = "") -> int:
	var key: String = date_key if not date_key.is_empty() else today_date_key()
	# Stable hash from the YYYY-MM-DD string. Sum of digits and char codes
	# is good enough for a 1-999 spread per day.
	var h: int = 0
	for i in range(key.length()):
		h = (h * 31 + key.unicode_at(i)) % 1000
	return (h % 999) + 1

## Returns "Operator-N" string for the given date (defaults to today).
func daily_operator_name(date_key: String = "") -> String:
	return "Operator-%d" % daily_operator_number(date_key)

## Curated epitaph pool — one-sentence fragments describing how a fallen
## Operator's final Cycle ended. Picked deterministically from the date
## hash so every player sees the same epitaph for the same calendar day.
## Kept under ~12 words each so they fit on the daily-memorial caption
## line without wrapping.
const _DAILY_EPITAPHS: Array[String] = [
	"Held the Window for 9 Cycles. Lost to the Mirror.",
	"Refused the Renegade's bargain. Reached Etapa III.",
	"First to chain a Singularity. Never returned from it.",
	"Lost in the Cold Singularity. The cold did not lift.",
	"Cleared the Archiver's Core twice. Could not clear it a third time.",
	"Trusted the high pips. The Mirror disagreed.",
	"Built only Obsidian modules. The Archive logged the choice.",
	"Refused to Stand. Extended into the Ghost Chain. Did not return.",
	"Cleared the Frequency Drain eleven times. Failed on the twelfth.",
	"The Voice of the Emporium refused her last transaction.",
	"Lost mid-Pulse in Etapa II. The Resonance held without him.",
	"Cleared Etapa IV on Hard. The Archiver did not congratulate her.",
	"Last seen building blanks. The cascade arrived too late.",
	"The Copper Guild closed his account before the run ended.",
	"Stood at the Window for forty-three Cycles. The forty-fourth was different.",
	"Lost to the Mute. Doubles were her whole strategy.",
	"Crossed the Singularity threshold. The crossing was one-way.",
	"Caught between the Architects' caution and the Renegade's haste.",
	"Cleared three Failures in one Cycle. The fourth did not arrive.",
	"The Archive notes only: 'attempted Singularity. did not arrive.'",
	"Final Pulse: 14 tiles. Final Chronos: insufficient.",
	"Did not adapt. Doubles, then doubles, then nothing.",
	"Held one of the original Obsidian modules. Returned it.",
	"Lost the Pinnacle in his final hand. The Pinnacle does not return.",
	"Master of the Forge spoke at her closing. He has not spoken since.",
	"Five Pulses, five rounds, five Cycles. The sixth was a Failure.",
	"The Ghost Chain remembered him. He did not remember it back.",
	"Reached the Archiver's Core. Was not heard from again.",
	"Routed every flow herself. The Machine accepted them all but one.",
	"Cleared the Industrial Load eight times consecutively. Then nothing.",
	"The Renegade Mechanic salvaged his final module. He kept it.",
	"Asked the Voice a question. The Voice did not answer.",
	"Last logged Cycle: a Cohesion of 19. One tile short of Harmonic.",
	"Operator-prime. The Archive's records start with her.",
	"Built a Wild-only chain. The Archive marked it 'experimental.'",
	"Lost on round 1. The Architects did not bother to record why.",
	"Cleared 200 Cycles. The 201st was the last.",
	"Spoke to the Archiver directly. The Archiver responded.",
	"Discarded every double he ever drew. He cleared three Etapas anyway.",
	"The Copper Guild still holds her unspent Coins.",
]

## Returns a one-sentence epitaph for the Operator named for the given
## date. Deterministic — every player sees the same epitaph for the same
## date. Used in the Daily Memorial caption and history rows.
func daily_operator_epitaph(date_key: String = "") -> String:
	var key: String = date_key if not date_key.is_empty() else today_date_key()
	# Independent hash from `daily_operator_number` so the operator-N and
	# the epitaph don't track each other (would feel formulaic if they did).
	var h: int = 0
	for i in range(key.length()):
		h = (h * 41 + key.unicode_at(i)) % 9973
	return _DAILY_EPITAPHS[h % _DAILY_EPITAPHS.size()]

## Has the player already used their one attempt at today's daily?
func daily_attempted_today() -> bool:
	var hist: Dictionary = _data.get("daily_history", {})
	return hist.has(today_date_key())

## Returns today's daily attempt entry, or {} if not yet attempted.
## Shape: { won: bool, score: int, round_reached: int }
func get_daily_today() -> Dictionary:
	var hist: Dictionary = _data.get("daily_history", {})
	return hist.get(today_date_key(), {})

## Record the result of today's daily run. One attempt per day — the
## title-screen button locks once this is set.
func record_daily_attempt(won: bool, score: int, round_reached: int) -> void:
	var hist: Dictionary = _data.get("daily_history", {})
	hist[today_date_key()] = {
		"won":           won,
		"score":         score,
		"round_reached": round_reached,
	}
	_data["daily_history"] = hist
	_save_to_disk()
	# Daily streak feeds the streak-N achievements, so recompute after
	# each daily attempt — wins extend the streak, losses reset it.
	check_and_emit_achievements()

## Number of consecutive daily wins ending at today (or yesterday if today
## hasn't been attempted yet — you don't break a streak by not playing
## yet today). Walks back day-by-day; stops at the first loss or gap.
func daily_streak() -> int:
	var hist: Dictionary = _data.get("daily_history", {})
	if hist.is_empty():
		return 0
	# Start from today; if not attempted, slide back one day so a player
	# who hasn't played YET today can still see their existing streak.
	var d: Dictionary = Time.get_date_dict_from_system()
	var unix: int = int(Time.get_unix_time_from_datetime_dict(d))
	if not hist.has(_date_key_from_dict(d)):
		unix -= 86400
	var streak: int = 0
	while true:
		var dt: Dictionary = Time.get_date_dict_from_unix_time(unix)
		var key: String = _date_key_from_dict(dt)
		var entry: Dictionary = hist.get(key, {})
		if entry.is_empty() or not entry.get("won", false):
			break
		streak += 1
		unix -= 86400
	return streak

## Aggregate counts across the entire daily history. Cheap — runs through
## the whole dict once, used by the history overlay's header strip.
func daily_summary() -> Dictionary:
	var hist: Dictionary = _data.get("daily_history", {})
	var attempts: int = hist.size()
	var wins: int     = 0
	for key in hist.keys():
		if hist[key].get("won", false):
			wins += 1
	return {
		"attempts": attempts,
		"wins":     wins,
		"streak":   daily_streak(),
	}

## All daily attempts as a date-sorted Array (newest first).
## Each entry: { date: "YYYY-MM-DD", won, score, round_reached }
func daily_history_sorted() -> Array:
	var hist: Dictionary = _data.get("daily_history", {})
	var out: Array = []
	for key in hist.keys():
		var e: Dictionary = hist[key].duplicate()
		e["date"] = key
		out.append(e)
	out.sort_custom(func(a, b): return a["date"] > b["date"])
	return out

func _date_key_from_dict(d: Dictionary) -> String:
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]

# ---------------------------------------------------------------------------
# Codex — lore entries unlocked across runs
# ---------------------------------------------------------------------------

## Returns the set of Codex entry IDs the player has unlocked through
## explicit events (visiting shops, beating bosses, etc.). Stat-gated
## unlocks aren't stored here — they're derived from lifetime_stats.
func codex_seen() -> Array:
	return _data.get("codex_seen", [])

## Mark a Codex entry as unlocked. Used for "event"-type gates that
## fire on specific in-game moments (first shop visit, first round
## clear, encountering a specific boss). Idempotent — duplicate calls
## with the same id are no-ops.
func unlock_codex(id: String) -> bool:
	if id.is_empty():
		return false
	var seen: Array = _data.get("codex_seen", [])
	if id in seen:
		return false
	seen.append(id)
	_data["codex_seen"] = seen
	_save_to_disk()
	codex_unlocked.emit(id)
	return true

## Re-evaluate every achievement against current lifetime stats and emit
## `achievement_unlocked` for any that crossed their threshold since the
## last check. First call after this feature exists silently seeds the
## seen-list with whatever's already earned so historical progress
## doesn't fire a flood of retroactive toasts.
func check_and_emit_achievements() -> void:
	var lifetime: Dictionary = get_lifetime_stats()
	var streak: int = daily_streak()
	var fresh_install: bool = not _data.has("seen_achievements")
	var seen: Array = _data.get("seen_achievements", [])
	var changed: bool = false
	for idx in range(Constants.ACHIEVEMENTS.size()):
		var id: String = String(Constants.ACHIEVEMENTS[idx].get("id", ""))
		if id.is_empty():
			continue
		if not Constants.achievement_earned(idx, lifetime, streak):
			continue
		if id in seen:
			continue
		seen.append(id)
		changed = true
		if not fresh_install:
			achievement_unlocked.emit(idx)
	if changed or fresh_install:
		_data["seen_achievements"] = seen
		_save_to_disk()

## Returns lifetime stats dict. Always has the standard keys (defaulted to
## 0 if the player has never finished a run).
func get_lifetime_stats() -> Dictionary:
	var s: Dictionary = _data.get("lifetime_stats", {})
	return {
		"runs":           s.get("runs",            0),
		"wins":           s.get("wins",            0),
		"hard_wins":      s.get("hard_wins",       0),
		"chronos":        s.get("chronos",         0),
		"hands_played":   s.get("hands_played",    0),
		"doubles_played": s.get("doubles_played",  0),
		"longest_chain":  s.get("longest_chain",   0),
		"best_tier":      s.get("best_tier",      -1),
		"best_round":     s.get("best_round",      0),
		"modules_seen":   s.get("modules_seen",   []),
	}

# ---------------------------------------------------------------------------
# Faction reputation — silent meters tracked across runs
# ---------------------------------------------------------------------------
# Three invisible meters track the Operator's behavioural alignment with
# the cast factions: the Society of Time Architects, the Copper Guild,
# and the Renegade Mechanic. The player never sees a number; instead
# crossing a threshold (FACTION_UNLOCK_AT, default 10) permanently
# unlocks one effect per faction:
#   • society   → "The Architect's Mark" tile enters the Artisan pool
#   • guild     → +2 starting Coins on every subsequent run
#   • renegade  → "Module CO-13" appears at Renegade-swap shop visits
#
# Crossing the threshold once is permanent — `*_unlocked` flags don't
# clear if the rep later drops. Rep itself can drop (bribing the auditor
# costs society), so the player can still pursue all three factions.

# Fired once when a faction's threshold is first crossed. Hooks the
# codex unlock + toast for the matching faction-recognition entry.
signal faction_unlocked(faction: String)

const FACTION_UNLOCK_AT: int = 10
const FACTION_NAMES: Array[String] = ["society", "guild", "renegade"]

## Add `delta` to a faction's rep counter. `name` ∈ {"society","guild",
## "renegade"}. Negative deltas allowed (the Guild-audit bribe costs
## society rep). Emits `faction_unlocked` the first time the threshold
## is crossed, then sets the permanent `*_unlocked` flag.
func add_faction_rep(faction: String, delta: int) -> void:
	if delta == 0 or not (faction in FACTION_NAMES):
		return
	var data: Dictionary = _data.get("faction_rep", {})
	var current: int = int(data.get(faction, 0))
	var new_val: int = current + delta
	data[faction] = new_val
	# Threshold-crossing check — once-only emit.
	var unlocked_key: String = faction + "_unlocked"
	if not bool(data.get(unlocked_key, false)) and new_val >= FACTION_UNLOCK_AT:
		data[unlocked_key] = true
		_data["faction_rep"] = data
		_save_to_disk()
		faction_unlocked.emit(faction)
		return
	_data["faction_rep"] = data
	_save_to_disk()

## True if the faction's threshold has ever been crossed (permanent).
func is_faction_unlocked(faction: String) -> bool:
	var data: Dictionary = _data.get("faction_rep", {})
	return bool(data.get(faction + "_unlocked", false))

## Returns the current rep value for a faction (for telemetry / debug).
func get_faction_rep(faction: String) -> int:
	var data: Dictionary = _data.get("faction_rep", {})
	return int(data.get(faction, 0))

# ---------------------------------------------------------------------------
# Tutorial flag
# ---------------------------------------------------------------------------
func set_tutorial_seen(b: bool) -> void:
	_data["tutorial_seen"] = b
	_save_to_disk()

func is_tutorial_seen() -> bool:
	return _data.get("tutorial_seen", false)

## One-shot intro for the Tools tray — fires the first time the player
## ever acquires a tool. Persisted across runs so a returning player
## doesn't see the explanation toast again.
func is_tool_intro_seen() -> bool:
	return _data.get("tool_intro_seen", false)

func mark_tool_intro_seen() -> void:
	_data["tool_intro_seen"] = true
	_save_to_disk()

# ---------------------------------------------------------------------------
# Interstitial ad counter
# ---------------------------------------------------------------------------
func increment_shop_visits() -> int:
	var n: int = _data.get("shop_visits", 0) + 1
	_data["shop_visits"] = n
	_save_to_disk()
	return n

func reset_shop_visits() -> void:
	_data["shop_visits"] = 0
	_save_to_disk()

func get_shop_visits() -> int:
	return _data.get("shop_visits", 0)

# ---------------------------------------------------------------------------
# "Remove ads" IAP flag
# ---------------------------------------------------------------------------
func set_ads_removed(b: bool) -> void:
	_data["ads_removed"] = b
	_save_to_disk()

func is_ads_removed() -> bool:
	return _data.get("ads_removed", false)

# ---------------------------------------------------------------------------
# Disk I/O
# ---------------------------------------------------------------------------
func _save_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open save file for writing")
		return
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()

func _load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = {}
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_data = {}
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		_data = parsed as Dictionary
	else:
		push_warning("SaveManager: corrupt save file — resetting")
		_data = {}

# ---------------------------------------------------------------------------
# Serialisation helpers (modules / reinforcements → plain Dictionaries)
# ---------------------------------------------------------------------------
func _serialise_modules() -> Array:
	var out: Array = []
	for m in GameState.modules:
		out.append({ "id": m.id })
	return out

func _deserialise_modules(arr: Array) -> Array:
	var out: Array = []
	for entry in arr:
		var id: String = entry.get("id", "")
		if id.is_empty():
			continue
		for m in ModuleDB.all():
			if m.id == id:
				out.append(m)
				break
	return out

func _serialise_reinforcements() -> Array:
	var out: Array = []
	for r in GameState.reinforcements:
		out.append({ "id": r.id })
	return out

func _deserialise_reinforcements(arr: Array) -> Array:
	var out: Array = []
	for entry in arr:
		var id: String = entry.get("id", "")
		if id.is_empty():
			continue
		for r in ReinforcementDB.all():
			if r.id == id:
				out.append(r)
				break
	return out

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _is_run_active() -> bool:
	return GameState.box != null
