## font_manager.gd — Central font loader and applicator.
## Autoloaded as "FontManager".
##
## Drop font files into res://assets/fonts/ and they are picked up
## automatically on next launch. Falls back to Godot's built-in font
## gracefully when files are missing — safe in editor and stub builds.
##
## Expected files (download free from fonts.google.com):
##   Rajdhani-Bold.ttf        → display font  (titles, headings, HUD)
##   Rajdhani-SemiBold.ttf    → semi-bold     (buttons, sub-headings)
##   Rajdhani-Regular.ttf     → body font     (descriptions, labels)
##   JetBrainsMono-Regular.ttf → mono font    (pip numbers, equations)
extends Node

# ---------------------------------------------------------------------------
# Font references (null until file is loaded — safe to pass to theme overrides)
# ---------------------------------------------------------------------------
var _display:   Font = null   # Rajdhani Bold    — titles ≥ 22 px
var _semibold:  Font = null   # Rajdhani SemiBold — buttons, sub-headings
var _body:      Font = null   # Rajdhani Regular  — body text
var _mono:      Font = null   # JetBrains Mono    — pip numbers, equations

# ---------------------------------------------------------------------------
# Size threshold: labels at or above this size get the display (bold) font
# ---------------------------------------------------------------------------
const DISPLAY_SIZE_THRESHOLD: int = 20

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func _ready() -> void:
	_display  = _try_load("res://assets/fonts/Rajdhani-Bold.ttf")
	_semibold = _try_load("res://assets/fonts/Rajdhani-SemiBold.ttf")
	_body     = _try_load("res://assets/fonts/Rajdhani-Regular.ttf")
	_mono     = _try_load("res://assets/fonts/JetBrainsMono-Regular.ttf")

	if _display != null:
		print("FontManager: Rajdhani Bold loaded")
	if _body != null:
		print("FontManager: Rajdhani Regular loaded")
	if _mono != null:
		print("FontManager: JetBrains Mono loaded")

# ---------------------------------------------------------------------------
# Public — getters
# ---------------------------------------------------------------------------
func display()  -> Font: return _display
func semibold() -> Font: return _semibold
func body()     -> Font: return _body
func mono()     -> Font: return _mono

## Returns true if at least the body font has been loaded.
func has_fonts() -> bool:
	return _body != null

# ---------------------------------------------------------------------------
# Public — apply helpers (no-op when font file is missing)
# ---------------------------------------------------------------------------

## Apply the appropriate font to a Label based on its size.
## Labels >= DISPLAY_SIZE_THRESHOLD get the bold display font;
## smaller labels get the body font.
func apply_auto(lbl: Label) -> void:
	var size: int = lbl.get_theme_font_size("font_size")
	# get_theme_font_size returns 0 if no override is set; fall back to 14
	if size <= 0:
		size = 14
	_apply_font(lbl, size)

## Apply the correct font for a given explicit size (called from _make_label).
func apply_for_size(control: Control, size: int) -> void:
	_apply_font(control, size)

## Force the display (bold) font onto a control — for manually promoted labels.
func apply_display(control: Control) -> void:
	if _display != null:
		control.add_theme_font_override("font", _display)

## Force the body font onto a control.
func apply_body(control: Control) -> void:
	if _body != null:
		control.add_theme_font_override("font", _body)

## Force the semibold font onto a control (buttons, sub-headings).
func apply_semibold(control: Control) -> void:
	var f := _semibold if _semibold != null else _display
	if f != null:
		control.add_theme_font_override("font", f)

## Force the mono font onto a control (pip numbers, score equations).
func apply_mono(control: Control) -> void:
	if _mono != null:
		control.add_theme_font_override("font", _mono)

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------
func _apply_font(control: Control, size: int) -> void:
	if size >= DISPLAY_SIZE_THRESHOLD:
		if _display != null:
			control.add_theme_font_override("font", _display)
	else:
		if _body != null:
			control.add_theme_font_override("font", _body)

func _try_load(path: String) -> Font:
	if ResourceLoader.exists(path):
		return load(path) as Font
	return null
