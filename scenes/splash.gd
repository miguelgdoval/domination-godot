## splash.gd — Intro splash screen.
## Shows logo, tagline, and lore line, then transitions to main.tscn.
## Tap / click anywhere to skip to the end of the animation immediately.
extends Node

# ---------------------------------------------------------------------------
# Palette (matching main.gd)
# ---------------------------------------------------------------------------
const C_BG     := Color(0.05, 0.04, 0.03)
const C_TEXT   := Color(0.90, 0.88, 0.82)
const C_DIM    := Color(0.45, 0.43, 0.40)
const C_ACCENT := Color(0.85, 0.70, 0.30)   # amber gold

const NEXT_SCENE := "res://scenes/main.tscn"

# ---------------------------------------------------------------------------
# References built in _ready
# ---------------------------------------------------------------------------
var _bg:         ColorRect
var _lbl_title:  Label
var _lbl_tag:    Label
var _lbl_lore:   Label
var _lbl_tap:    Label

var _seq:        Tween = null
var _done:       bool  = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	_build_ui()
	_run_sequence()

func _input(event: InputEvent) -> void:
	if _done:
		return
	if event is InputEventMouseButton and event.pressed:
		_skip()
	elif event is InputEventScreenTouch and event.pressed:
		_skip()
	elif event is InputEventKey and event.pressed and not event.echo:
		_skip()

# ---------------------------------------------------------------------------
# UI construction (procedural, no .tscn dependency)
# ---------------------------------------------------------------------------
func _build_ui() -> void:
	# Full-screen black background
	_bg = ColorRect.new()
	_bg.color = C_BG
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	# Title: "DOMINATION"
	_lbl_title = Label.new()
	_lbl_title.text = "DOMINATION"
	_lbl_title.add_theme_font_size_override("font_size", 72)
	_lbl_title.add_theme_color_override("font_color", C_ACCENT)
	_lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_title.modulate.a = 0.0
	FontManager.apply_display(_lbl_title)
	vbox.add_child(_lbl_title)

	# Separator line
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(320, 1)
	sep.color = C_ACCENT.darkened(0.3)
	sep.modulate.a = 0.0
	vbox.add_child(sep)

	# Tagline
	_lbl_tag = Label.new()
	_lbl_tag.text = "Recalibrate the Perpetual Chronometer"
	_lbl_tag.add_theme_font_size_override("font_size", 18)
	_lbl_tag.add_theme_color_override("font_color", C_DIM)
	_lbl_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_tag.modulate.a = 0.0
	FontManager.apply_body(_lbl_tag)
	vbox.add_child(_lbl_tag)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(spacer)

	# Lore quote
	_lbl_lore = Label.new()
	_lbl_lore.text = "\"The signal does not forgive hesitation.\""
	_lbl_lore.add_theme_font_size_override("font_size", 14)
	_lbl_lore.add_theme_color_override("font_color", C_DIM.darkened(0.2))
	_lbl_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_lore.modulate.a = 0.0
	FontManager.apply_body(_lbl_lore)
	vbox.add_child(_lbl_lore)

	# "Tap to continue" hint (appears last)
	_lbl_tap = Label.new()
	_lbl_tap.text = "tap to continue"
	_lbl_tap.add_theme_font_size_override("font_size", 11)
	_lbl_tap.add_theme_color_override("font_color", C_DIM.darkened(0.4))
	_lbl_tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_tap.modulate.a = 0.0
	FontManager.apply_body(_lbl_tap)
	# Anchor bottom-centre
	_lbl_tap.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_lbl_tap.offset_bottom = -28
	add_child(_lbl_tap)

	# Store sep reference for the tween
	_bg.set_meta("sep", sep)

func _run_sequence() -> void:
	_seq = create_tween()

	# Beat 1 — black silence (0.4s)
	_seq.tween_interval(0.40)

	# Beat 2 — title fades in (0.7s)
	_seq.tween_property(_lbl_title, "modulate:a", 1.0, 0.70) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_seq.tween_interval(0.20)

	# Beat 3 — separator + tagline
	_seq.tween_property(_bg.get_meta("sep"), "modulate:a", 1.0, 0.35)
	_seq.tween_property(_lbl_tag, "modulate:a", 1.0, 0.50) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_seq.tween_interval(0.30)

	# Beat 4 — lore line
	_seq.tween_property(_lbl_lore, "modulate:a", 0.55, 0.60) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_seq.tween_interval(0.60)

	# Beat 5 — "tap to continue" pulses in
	_seq.tween_property(_lbl_tap, "modulate:a", 0.50, 0.40)
	_seq.tween_interval(0.80)

	# Beat 6 — auto-advance (total ≈ 3.8s on screen before this fires)
	_seq.tween_callback(_transition)

func _skip() -> void:
	if _seq != null and is_instance_valid(_seq):
		_seq.kill()
	_transition()

func _transition() -> void:
	if _done:
		return
	_done = true

	# Apply saved settings to AudioManager before entering main
	var settings: Dictionary = SaveManager.load_settings()
	AudioManager.set_sfx_volume(settings.get("sfx_volume", 1.0))
	AudioManager.set_music_volume(settings.get("music_volume", 0.70))
	AudioManager.set_mute(settings.get("muted", false))

	# Fade everything to black, then change scene
	var ft := create_tween()
	ft.tween_property(_bg, "color", Color.BLACK, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	ft.tween_callback(func():
		get_tree().change_scene_to_file(NEXT_SCENE)
	)
