## font_manager.gd — Central font loader and applicator.
## Autoloaded as "FontManager".
##
## Drop font files into res://assets/fonts/ and they load automatically.
## Falls back to Godot's default font when files are missing.
##
## Expected files (Google Fonts, SIL OFL license):
##   assets/fonts/Rajdhani/Rajdhani-Bold.ttf                       → display
##   assets/fonts/Rajdhani/Rajdhani-SemiBold.ttf                   → semibold
##   assets/fonts/Rajdhani/Rajdhani-Regular.ttf                    → body
##   assets/fonts/JetBrains_Mono/static/JetBrainsMono-Regular.ttf  → mono
extends Node

const DISPLAY_SIZE_THRESHOLD: int = 20

# Untyped — holds a FontFile when loaded, null otherwise
var _display  = null
var _semibold = null
var _body     = null
var _mono     = null

func _ready() -> void:
	_display  = _try_load("res://assets/fonts/Rajdhani/Rajdhani-Bold.ttf")
	_semibold = _try_load("res://assets/fonts/Rajdhani/Rajdhani-SemiBold.ttf")
	_body     = _try_load("res://assets/fonts/Rajdhani/Rajdhani-Regular.ttf")
	_mono     = _try_load("res://assets/fonts/JetBrains_Mono/static/JetBrainsMono-Regular.ttf")

# ---------------------------------------------------------------------------
# Apply helpers — no-op when font is null (file missing)
# ---------------------------------------------------------------------------

## Auto-select display or body font based on the label's font size.
## Call this from _make_label after setting the font_size override.
func apply_for_size(control: Control, size: int) -> void:
	if size >= DISPLAY_SIZE_THRESHOLD:
		if _display != null:
			control.add_theme_font_override("font", _display)
	else:
		if _body != null:
			control.add_theme_font_override("font", _body)

## Force the bold display font (titles, large headings).
func apply_display(control: Control) -> void:
	if _display != null:
		control.add_theme_font_override("font", _display)

## Force the body font (descriptions, small labels).
func apply_body(control: Control) -> void:
	if _body != null:
		control.add_theme_font_override("font", _body)

## Force the semibold font (buttons, sub-headings).
func apply_semibold(control: Control) -> void:
	var f = _semibold if _semibold != null else _display
	if f != null:
		control.add_theme_font_override("font", f)

## Force the mono font (score equations, Chronos numbers).
func apply_mono(control: Control) -> void:
	if _mono != null:
		control.add_theme_font_override("font", _mono)

## True if at least the body font loaded successfully.
func has_fonts() -> bool:
	return _body != null

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------
func _try_load(path: String):
	if ResourceLoader.exists(path):
		return load(path)
	return null
