## save_manager.gd — Persistence layer: run state, settings, best scores.
## Autoloaded as "SaveManager".
##
## Save file location: user://save.json
## (on Android: /data/data/<package>/files/save.json)
extends Node

const SAVE_PATH := "user://save.json"

# ---------------------------------------------------------------------------
# Default structures
# ---------------------------------------------------------------------------
const DEFAULT_SETTINGS := {
	"sfx_volume":   1.0,
	"music_volume": 0.70,
	"muted":        false,
}

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

# ---------------------------------------------------------------------------
# Run persistence
# ---------------------------------------------------------------------------

## Serialise the current GameState run into the save file.
## Call after every shop exit and at the end of every scored hand.
func save_run() -> void:
	if not _is_run_active():
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
# Tutorial flag
# ---------------------------------------------------------------------------
func set_tutorial_seen(b: bool) -> void:
	_data["tutorial_seen"] = b
	_save_to_disk()

func is_tutorial_seen() -> bool:
	return _data.get("tutorial_seen", false)

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
		_data = parsed
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
