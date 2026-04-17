## main.gd — Trial Cycle controller + procedural UI
## Milestone 1: core engine + playable round (no shop)
extends Node

# ---------------------------------------------------------------------------
# Palette — Perpetual Chronometer
# ---------------------------------------------------------------------------
const C_BG          := Color(0.08, 0.07, 0.05)
const C_PANEL       := Color(0.13, 0.11, 0.08, 0.95)
const C_TEXT        := Color(0.90, 0.88, 0.82)
const C_DIM         := Color(0.45, 0.43, 0.40)
const C_CHRONOS     := Color(0.40, 0.92, 0.40)
const C_TARGET      := Color(1.00, 0.52, 0.30)
const C_MONEDAS     := Color(1.00, 0.86, 0.20)
const C_PREVIEW     := Color(0.70, 1.00, 0.70)
const C_LAST_HAND   := Color(1.00, 0.86, 0.30)
const C_WIN         := Color(0.40, 1.00, 0.40)
const C_LOSE        := Color(1.00, 0.30, 0.30)

# Domino tile colours
const C_TILE_FACE       := Color(0.94, 0.91, 0.83)   # ivory/bone
const C_TILE_FACE_HOVER := Color(1.00, 0.97, 0.89)
const C_TILE_FACE_DIM   := Color(0.55, 0.52, 0.46)   # greyed — can't connect
const C_TILE_FACE_SEL   := Color(0.72, 0.22, 0.18)   # red — selected for discard
const C_TILE_BORDER     := Color(0.42, 0.36, 0.26)
const C_TILE_DIVIDER    := Color(0.42, 0.36, 0.26)
const C_TILE_PIP        := Color(0.10, 0.08, 0.06)   # dark ink

# ---------------------------------------------------------------------------
# Game state
# ---------------------------------------------------------------------------
enum Phase { PLAYING, ROUND_RESULT, GAME_OVER, VICTORY }

var _phase: Phase = Phase.PLAYING
var _rm: RoundManager
var _selected_discard: Array = []
var _tile_btns: Array = []            # Button nodes in hand

# ---------------------------------------------------------------------------
# UI node references
# ---------------------------------------------------------------------------
var _lbl_round:       Label
var _lbl_chronos:     Label
var _lbl_target:      Label
var _lbl_hands:       Label
var _lbl_discards:    Label
var _lbl_monedas:     Label
var _lbl_etapa:       Label
var _chain_container: HBoxContainer   # visual domino tiles in chain
var _lbl_preview:     Label
var _lbl_last_hand:   Label
var _hand_container:  HBoxContainer
var _btn_play:        Button
var _btn_discard:     Button
var _btn_undo:        Button
var _overlay:         Control
var _lbl_result:      Label
var _lbl_result_sub:  Label
var _btn_continue:    Button

# ===========================================================================
# Godot lifecycle
# ===========================================================================
func _ready() -> void:
	_build_ui()
	GameState.start_run()
	_start_round()

# ===========================================================================
# Round lifecycle
# ===========================================================================
func _start_round() -> void:
	_phase = Phase.PLAYING
	_selected_discard.clear()

	_rm = RoundManager.new()
	_rm.setup(GameState.box, GameState.round_index)
	_rm.chain_changed.connect(_on_chain_changed)
	_rm.hand_changed.connect(_on_hand_changed)
	_rm.hand_scored.connect(_on_hand_scored)
	_rm.round_ended.connect(_on_round_ended)

	_overlay.hide()
	_refresh_hud()
	_rebuild_hand()
	_refresh_chain_display()

func _end_round(won: bool) -> void:
	if won:
		_phase = Phase.ROUND_RESULT
		var earned: int = GameState.award_monedas(_rm.unused_hands())
		_lbl_result.text = "RECALIBRATION SUCCESSFUL"
		_lbl_result.add_theme_color_override("font_color", C_WIN)
		_lbl_result_sub.text = "Chronos: %d / %d\n+%d Monedas earned" % [
			_rm.chronos, _rm.target, earned]
		_btn_continue.text = "NEXT ROUND"
	else:
		_phase = Phase.GAME_OVER
		_lbl_result.text = "SIMULATION FAILURE"
		_lbl_result.add_theme_color_override("font_color", C_LOSE)
		_lbl_result_sub.text = (
			"Chronos: %d / %d\n\n" % [_rm.chronos, _rm.target] +
			"REINITIALIZING PROTOCOL.\nOPERATOR REMAINS AVAILABLE.")
		_btn_continue.text = "NEW TRIAL CYCLE"
	_overlay.show()

# ===========================================================================
# Signal handlers
# ===========================================================================
func _on_chain_changed() -> void:
	_refresh_chain_display()
	_refresh_action_buttons()
	_refresh_tile_visuals()

func _on_hand_changed() -> void:
	_rebuild_hand()
	_refresh_hud()

func _on_hand_scored(result: Dictionary) -> void:
	_lbl_last_hand.text = "%d chips  ×  %d  =  %d Chronos" % [
		result["chips"], result["mult"], result["total"]]
	_refresh_hud()

func _on_round_ended(won: bool) -> void:
	_end_round(won)

func _on_tile_left_click(index: int) -> void:
	if _phase != Phase.PLAYING:
		return
	_selected_discard.erase(index)
	_rm.try_add_to_chain(index)

func _on_tile_right_click(index: int) -> void:
	if _phase != Phase.PLAYING:
		return
	if index in _selected_discard:
		_selected_discard.erase(index)
	else:
		_selected_discard.append(index)
	_refresh_tile_visuals()
	_refresh_action_buttons()

func _on_play_pressed() -> void:
	if _phase != Phase.PLAYING or not _rm.can_play():
		return
	_rm.play_chain()

func _on_discard_pressed() -> void:
	if _phase != Phase.PLAYING or _selected_discard.is_empty() or not _rm.can_discard():
		return
	_rm.discard(_selected_discard)
	_selected_discard.clear()

func _on_undo_pressed() -> void:
	if _phase != Phase.PLAYING:
		return
	_rm.undo_last_chain_tile()

func _on_continue_pressed() -> void:
	match _phase:
		Phase.ROUND_RESULT:
			GameState.advance_round()
			if GameState.is_run_complete():
				_phase = Phase.VICTORY
				_lbl_result.text = "CHRONOMETER RECALIBRATED"
				_lbl_result.add_theme_color_override("font_color", C_MONEDAS)
				_lbl_result_sub.text = (
					"The Perpetual Chronometer stabilizes.\n" +
					"Entropy contained. For now.\n\nOPERATOR COMMENDED.")
				_btn_continue.text = "NEW TRIAL CYCLE"
				return
			_start_round()
		Phase.GAME_OVER, Phase.VICTORY:
			GameState.start_run()
			_start_round()

# ===========================================================================
# UI refresh
# ===========================================================================
func _refresh_hud() -> void:
	_lbl_round.text    = GameState.round_display()
	_lbl_etapa.text    = GameState.etapa_name()
	_lbl_chronos.text  = "Chronos: %d" % _rm.chronos
	_lbl_target.text   = "Target: %d"  % _rm.target
	_lbl_hands.text    = "Hands: %d"   % _rm.hands_remaining
	_lbl_discards.text = "Discards: %d" % _rm.discards_remaining
	_lbl_monedas.text  = "Monedas: %d" % GameState.monedas
	var over: bool = _rm.chronos >= _rm.target
	_lbl_chronos.add_theme_color_override("font_color", C_WIN if over else C_CHRONOS)

## Rebuild the visual chain from current chain.tile_displays.
func _refresh_chain_display() -> void:
	for child in _chain_container.get_children():
		child.queue_free()

	if _rm.current_chain.is_empty():
		var lbl := _make_label("(empty)", C_DIM, 15)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_chain_container.add_child(lbl)
	else:
		var displays := _rm.current_chain.tile_displays
		for i in range(displays.size()):
			# Connector arrow between tiles
			if i > 0:
				var arrow := _make_label("→", C_DIM, 14)
				arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				_chain_container.add_child(arrow)
			var disp: Vector2i = displays[i]
			_chain_container.add_child(_build_chain_tile(disp.x, disp.y))

	# Score preview
	if not _rm.current_chain.is_empty():
		var r: Dictionary = Scoring.calculate(_rm.current_chain)
		_lbl_preview.text = "%d chips  ×  %d  =  %d Chronos" % [
			r["chips"], r["mult"], r["total"]]
	else:
		_lbl_preview.text = ""

func _refresh_action_buttons() -> void:
	_btn_play.disabled    = not _rm.can_play()
	_btn_discard.disabled = (not _rm.can_discard()) or _selected_discard.is_empty()
	_btn_undo.disabled    = _rm.current_chain.is_empty()
	_btn_discard.text     = "Discard (%d)" % _selected_discard.size()

func _rebuild_hand() -> void:
	_selected_discard.clear()
	for child in _hand_container.get_children():
		child.queue_free()
	_tile_btns.clear()

	for i in range(_rm.hand.size()):
		var btn: Button = _create_hand_tile(_rm.hand[i], i)
		_hand_container.add_child(btn)
		_tile_btns.append(btn)

	_refresh_tile_visuals()
	_refresh_action_buttons()

func _refresh_tile_visuals() -> void:
	for i in range(_tile_btns.size()):
		if i >= _rm.hand.size():
			break
		var btn: Button = _tile_btns[i]
		if i in _selected_discard:
			_apply_tile_style(btn, C_TILE_FACE_SEL, C_TILE_FACE_SEL)
		elif _rm.current_chain.can_add(_rm.hand[i]):
			_apply_tile_style(btn, C_TILE_FACE, C_TILE_FACE_HOVER)
		else:
			_apply_tile_style(btn, C_TILE_FACE_DIM, C_TILE_FACE_DIM)

# ===========================================================================
# Domino tile widgets
# ===========================================================================

## Hand tile — vertical domino, top pip / divider / bottom pip.
## Clickable: left click = add to chain, right click = select for discard.
func _create_hand_tile(tile: Domino, index: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(64, 108)
	btn.text = ""
	btn.clip_contents = true

	_apply_tile_style(btn, C_TILE_FACE, C_TILE_FACE_HOVER)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	btn.add_child(vbox)

	var top := _make_pip_label(tile.left)
	top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(top)

	vbox.add_child(_make_tile_hsep())

	var bot := _make_pip_label(tile.right)
	bot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(bot)

	btn.pressed.connect(_on_tile_left_click.bind(index))
	btn.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton:
			var m := ev as InputEventMouseButton
			if m.button_index == MOUSE_BUTTON_RIGHT and m.pressed:
				_on_tile_right_click(index)
	)
	return btn

## Chain tile — horizontal domino, left pip | divider | right pip.
## Not interactive — display only.
func _build_chain_tile(disp_left: int, disp_right: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(76, 48)

	var style := StyleBoxFlat.new()
	style.bg_color = C_TILE_FACE
	style.border_color = C_TILE_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	var left_lbl := _make_pip_label(disp_left)
	left_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(left_lbl)

	hbox.add_child(_make_tile_vsep())

	var right_lbl := _make_pip_label(disp_right)
	right_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_lbl)

	return panel

# ---------------------------------------------------------------------------
# Tile sub-element helpers
# ---------------------------------------------------------------------------
func _make_pip_label(pip: int) -> Label:
	var lbl := Label.new()
	lbl.text = str(pip) if pip >= 0 else "★"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", C_TILE_PIP)
	return lbl

func _make_tile_hsep() -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_DIVIDER
	sep.custom_minimum_size = Vector2(0, 2)
	sep.size_flags_horizontal = Control.SIZE_FILL
	return sep

func _make_tile_vsep() -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_DIVIDER
	sep.custom_minimum_size = Vector2(2, 0)
	sep.size_flags_vertical = Control.SIZE_FILL
	return sep

## Apply normal + hover StyleBoxFlat to a Button with tile visual style.
func _apply_tile_style(btn: Button, face: Color, hover: Color) -> void:
	for override_name in ["normal", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color     = face
		s.border_color = C_TILE_BORDER
		s.set_border_width_all(2)
		s.set_corner_radius_all(5)
		btn.add_theme_stylebox_override(override_name, s)

	var sh := StyleBoxFlat.new()
	sh.bg_color     = hover
	sh.border_color = C_TILE_BORDER
	sh.set_border_width_all(2)
	sh.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("hover", sh)

	var sp := StyleBoxFlat.new()
	sp.bg_color     = face.darkened(0.12)
	sp.border_color = C_TILE_BORDER
	sp.set_border_width_all(2)
	sp.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("pressed", sp)

# ===========================================================================
# UI construction
# ===========================================================================
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var ui := CanvasLayer.new()
	add_child(ui)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	ui.add_child(root)

	root.add_child(_build_hud())
	root.add_child(_build_chain_area())

	_lbl_last_hand = _make_label("", C_LAST_HAND, 15)
	_lbl_last_hand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_lbl_last_hand)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	var hand_title := _make_label("ISOLATION CHAMBER", C_DIM, 11)
	hand_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hand_title)

	_hand_container = HBoxContainer.new()
	_hand_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_hand_container.add_theme_constant_override("separation", 10)
	_hand_container.custom_minimum_size = Vector2(0, 118)
	root.add_child(_hand_container)

	root.add_child(_build_action_bar())

	var hint := _make_label(
		"Left-click → add to chain   |   Right-click → select for discard",
		C_DIM, 11)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hint)

	_overlay = _build_overlay()
	ui.add_child(_overlay)
	_overlay.hide()

# ---- HUD ----
func _build_hud() -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = C_PANEL
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	panel.add_child(hbox)

	_lbl_round    = _make_hud_label("Round 1/15",  C_TEXT)
	_lbl_etapa    = _make_hud_label("Mahogany",    C_DIM)
	_lbl_chronos  = _make_hud_label("Chronos: 0",  C_CHRONOS)
	_lbl_target   = _make_hud_label("Target: 150", C_TARGET)
	_lbl_hands    = _make_hud_label("Hands: 4",    Color(0.7, 0.8, 1.0))
	_lbl_discards = _make_hud_label("Discards: 2", Color(0.8, 0.7, 1.0))
	_lbl_monedas  = _make_hud_label("Monedas: 0",  C_MONEDAS)

	for lbl in [_lbl_round, _lbl_etapa, _lbl_chronos, _lbl_target,
				_lbl_hands, _lbl_discards, _lbl_monedas]:
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(lbl)

	return panel

# ---- Chain area ----
func _build_chain_area() -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = C_PANEL
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := _make_label("COHESION PULSE", C_DIM, 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_chain_container = HBoxContainer.new()
	_chain_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_chain_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chain_container.add_theme_constant_override("separation", 6)
	_chain_container.custom_minimum_size = Vector2(0, 58)
	vbox.add_child(_chain_container)

	_lbl_preview = _make_label("", C_PREVIEW, 14)
	_lbl_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_preview)

	return panel

# ---- Action bar ----
func _build_action_bar() -> Control:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	hbox.custom_minimum_size = Vector2(0, 58)

	_btn_undo    = _make_button("↩ Undo",          _on_undo_pressed,    Vector2(120, 50))
	_btn_discard = _make_button("Discard (0)",      _on_discard_pressed, Vector2(160, 50))
	_btn_play    = _make_button("▶  Play Pulse",    _on_play_pressed,    Vector2(180, 50))

	hbox.add_child(_btn_undo)
	hbox.add_child(_btn_discard)
	hbox.add_child(_btn_play)
	return hbox

# ---- Result overlay ----
func _build_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 280)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.09, 0.07, 0.98)
	style.border_color = Color(0.5, 0.45, 0.35)
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	_lbl_result = _make_label("", C_WIN, 26)
	_lbl_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_result)

	_lbl_result_sub = _make_label("", C_TEXT, 14)
	_lbl_result_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_result_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_result_sub.custom_minimum_size = Vector2(400, 0)
	vbox.add_child(_lbl_result_sub)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	_btn_continue = _make_button("NEXT ROUND", _on_continue_pressed, Vector2(180, 48))
	btn_row.add_child(_btn_continue)

	return overlay

# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------
func _make_hud_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	return lbl

func _make_label(text: String, color: Color, size: int = 14) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl

func _make_button(label: String, callback: Callable,
		min_size: Vector2 = Vector2(120, 48)) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = min_size
	btn.pressed.connect(callback)
	return btn
