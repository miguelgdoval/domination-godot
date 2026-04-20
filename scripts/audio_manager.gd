## audio_manager.gd — Centralised audio controller.
## Autoloaded as "AudioManager".
##
## Drop .ogg files into:
##   res://assets/audio/sfx/    (one-shot sound effects)
##   res://assets/audio/music/  (looping background tracks)
## then call play_sfx("tile_click") or play_music("game_ambient").
## Missing files are silently ignored — safe in editor and stub builds.
extends Node

# ---------------------------------------------------------------------------
# Bus names (set up in Project > Audio)
# ---------------------------------------------------------------------------
const BUS_MASTER := "Master"
const BUS_SFX    := "SFX"
const BUS_MUSIC  := "Music"

# ---------------------------------------------------------------------------
# File paths
# ---------------------------------------------------------------------------
const SFX_PATH   := "res://assets/audio/sfx/"
const MUSIC_PATH := "res://assets/audio/music/"

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------
var _music_player_a: AudioStreamPlayer   # crossfade double-buffer
var _music_player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer    # whichever is currently audible

var _sfx_volume:   float = 1.0
var _music_volume: float = 0.70
var _muted:        bool  = false

var _current_track: String = ""

# Pre-loaded SFX cache (loaded on first play)
var _sfx_cache: Dictionary = {}

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func _ready() -> void:
	_ensure_buses()
	_music_player_a = _make_music_player()
	_music_player_b = _make_music_player()
	_active_player  = _music_player_a

func _make_music_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = BUS_MUSIC
	p.volume_db = linear_to_db(_music_volume)
	add_child(p)
	return p

# ---------------------------------------------------------------------------
# Public — SFX
# ---------------------------------------------------------------------------

## Play a one-shot sound effect by name (no extension).
## e.g. AudioManager.play_sfx("tile_click")
func play_sfx(sfx_name: String, pitch: float = 1.0) -> void:
	if _muted:
		return
	var stream := _get_sfx(sfx_name)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream    = stream
	p.bus       = BUS_SFX
	p.volume_db = linear_to_db(_sfx_volume)
	p.pitch_scale = pitch
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

## Play a UI click sound (convenience alias).
func play_ui_click() -> void:
	play_sfx("ui_click")

## Play a UI hover sound at reduced volume.
func play_ui_hover() -> void:
	play_sfx("ui_hover", 1.0)

# ---------------------------------------------------------------------------
# Public — Music
# ---------------------------------------------------------------------------

## Crossfade to a new music track. Safe to call even if track is already playing.
func play_music(track_name: String, fade_time: float = 0.50) -> void:
	if track_name == _current_track:
		return
	var stream := _load_music(track_name)
	if stream == null:
		return  # file missing — stay silent
	_current_track = track_name

	var incoming := _music_player_b if _active_player == _music_player_a else _music_player_a
	incoming.stream      = stream
	incoming.volume_db   = linear_to_db(0.0)
	incoming.play()

	# Fade out outgoing, fade in incoming
	var t := create_tween().set_parallel(true)
	t.tween_property(_active_player, "volume_db",
		linear_to_db(0.0), fade_time).set_trans(Tween.TRANS_LINEAR)
	t.tween_property(incoming, "volume_db",
		linear_to_db(_music_volume if not _muted else 0.0), fade_time) \
		.set_trans(Tween.TRANS_LINEAR)
	var prev := _active_player
	t.chain().tween_callback(func(): prev.stop())

	_active_player = incoming

## Fade out and stop the current music track.
func stop_music(fade_time: float = 0.60) -> void:
	if not _active_player.playing:
		return
	_current_track = ""
	var t := create_tween()
	t.tween_property(_active_player, "volume_db",
		linear_to_db(0.0), fade_time).set_trans(Tween.TRANS_LINEAR)
	var p := _active_player
	t.tween_callback(func(): p.stop())

# ---------------------------------------------------------------------------
# Public — Volume & Mute
# ---------------------------------------------------------------------------

func set_sfx_volume(v: float) -> void:
	_sfx_volume = clampf(v, 0.0, 1.0)
	_update_music_bus_volume()

func set_music_volume(v: float) -> void:
	_music_volume = clampf(v, 0.0, 1.0)
	_update_music_bus_volume()

func get_sfx_volume() -> float:
	return _sfx_volume

func get_music_volume() -> float:
	return _music_volume

func set_mute(b: bool) -> void:
	_muted = b
	_update_music_bus_volume()

func is_muted() -> bool:
	return _muted

func toggle_mute() -> void:
	set_mute(not _muted)

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _update_music_bus_volume() -> void:
	var vol := _music_volume if not _muted else 0.0
	_music_player_a.volume_db = linear_to_db(vol)
	_music_player_b.volume_db = linear_to_db(vol)

func _get_sfx(sfx_name: String) -> AudioStream:
	if sfx_name in _sfx_cache:
		return _sfx_cache[sfx_name] as AudioStream
	for ext in ["ogg", "mp3", "wav"]:
		var path := SFX_PATH + sfx_name + "." + ext
		if ResourceLoader.exists(path):
			var s := load(path) as AudioStream
			_sfx_cache[sfx_name] = s
			return s
	# File not found — return null silently
	_sfx_cache[sfx_name] = null
	return null

func _load_music(track_name: String) -> AudioStream:
	for ext in ["ogg", "mp3", "wav"]:
		var path := MUSIC_PATH + track_name + "." + ext
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return null

func _ensure_buses() -> void:
	# Create SFX and Music buses if they don't exist
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_SFX)
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_MUSIC)
