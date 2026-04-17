## main.gd — Trial Cycle controller + procedural UI
## Milestone 1: core engine + playable round (no shop)
extends Node

# ---------------------------------------------------------------------------
# Colours — Perpetual Chronometer palette
# ---------------------------------------------------------------------------
const C_BG          := Color(0.08, 0.07, 0.05)       # dark mahogany
const C_PANEL       := Color(0.13, 0.11, 0.08, 0.95)
const C_TEXT        := Color(0.90, 0.88, 0.82)
const C_DIM         := Color(0.45, 0.43, 0.40)
const C_CHRONOS     := Color(0.40, 0.92, 0.40)
const C_TARGET      := Color(1.00, 0.52, 0.30)
const C_MONEDAS     := Color(1.00, 0.86, 0.20)
const C_CHAIN       := Color(0.80, 0.95, 1.00)
const C_PREVIEW     := Color(0.70, 1.00, 0.70)
const C_LAST_HAND   := Color(1.00, 0.86, 0.30)
const C_WIN         := Color(0.40, 1.00, 0.40)
const C_LOSE        := Color(1.00, 0.30, 0.30)
const C_TILE_NORMAL := Color(0.95, 0.92, 0.85)
const C_TILE_DIM    := Color(0.40, 0.38, 0.35)
const C_TILE_SELECT := Color(1.00, 0.40, 0.35)

# ---------------------------------------------------------------------------
# Game state
# ---------------------------------------------------------------------------
enum Phase { PLAYING, ROUND_RESULT, GAME_OVER, VICTORY }

var _phase: Phase = Phase.PLAYING
var _rm: RoundManager               # current round manager
var _selected_discard: Array = []   # hand indices selected for discard
var _tile_btns: Array = []          # Button nodes in hand area

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
var _lbl_chain:       Label
var _lbl_preview:     Label
var _lbl_last_hand:   Label
var _hand_container:  HBoxContainer
var _btn_play:        Button
var _btn_discard:     Button
var _btn_undo:        Button
var _overlay:         Control       # result overlay
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

func _end_round(won: bool) -> void:
	if won:
		_phase = Phase.ROUND_RESULT
		var earned: int = GameState.award_monedas(_rm.unused_hands())
		_lbl_result.text = "RECALIBRATION SUCCESSFUL"
		_lbl_result.add_theme_color_override("font_color", C_WIN)
		_lbl_result_sub.text = (
			"Chronos: %d / %d\n+%d Monedas earned\n\n%s" % [
				_rm.chronos, _rm.target, earned,
				"— SIMULATION FAILURE. REINITIALIZING PROTOCOL. OPERATOR REMAINS AVAILABLE. —" if false else ""
			]
		)
		_btn_continue.text = "NEXT ROUND"
	else:
		_phase = Phase.GAME_OVER
		_lbl_result.text = "SIMULATION FAILURE"
		_lbl_result.add_theme_color_override("font_color", C_LOSE)
		_lbl_result_sub.text = (
			"Chronos: %d / %d\n\nREINITIALIZING PROTOCOL.\nOPERATOR REMAINS AVAILABLE." % [
				_rm.chronos, _rm.target
			]
		)
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
		result["chips"], result["mult"], result["total"]
	]
	_refresh_hud()

func _on_round_ended(won: bool) -> void:
	_end_round(won)

func _on_tile_left_click(index: int) -> void:
	if _phase != Phase.PLAYING:
		return
	# Remove from discard selection first if present
	_selected_discard.erase(index)
	var added: bool = _rm.try_add_to_chain(index)
	if not added:
		# Tile can't connect — do nothing (visual already grayed out)
		pass

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
	if _phase != Phase.PLAYING or _selected_discard.is_empty():
		return
	if not _rm.can_discard():
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
				_lbl_result_sub.text = "The Perpetual Chronometer stabilizes.\nEntropy contained. For now.\n\nOPERATOR COMMENDED."
				_btn_continue.text = "NEW TRIAL CYCLE"
				return
			_start_round()
		Phase.GAME_OVER, Phase.VICTORY:
			GameState.start_run()
			_start_round()

# ===========================================================================
# UI refresh helpers
# ===========================================================================
func _refresh_hud() -> void:
	_lbl_round.text    = GameState.round_display()
	_lbl_etapa.text    = GameState.etapa_name()
	_lbl_chronos.text  = "Chronos: %d" % _rm.chronos
	_lbl_target.text   = "Target: %d"  % _rm.target
	_lbl_hands.text    = "Hands: %d"   % _rm.hands_remaining
	_lbl_discards.text = "Discards: %d" % _rm.discards_remaining
	_lbl_monedas.text  = "Monedas: %d" % GameState.monedas

	# Colour chronos green when at/above target
	var over: bool = _rm.chronos >= _rm.target
	_lbl_chronos.add_theme_color_override("font_color",
		C_WIN if over else C_CHRONOS)

func _refresh_chain_display() -> void:
	_lbl_chain.text = _rm.current_chain.display()
	if not _rm.current_chain.is_empty():
		var r: Dictionary = Scoring.calculate(_rm.current_chain)
		_lbl_preview.text = "%d chips  ×  %d  =  %d Chronos" % [
			r["chips"], r["mult"], r["total"]
		]
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
		var tile: Domino = _rm.hand[i]
		var btn: Button  = _create_tile_button(tile, i)
		_hand_container.add_child(btn)
		_tile_btns.append(btn)

	_refresh_tile_visuals()
	_refresh_action_buttons()

func _refresh_tile_visuals() -> void:
	for i in range(_tile_btns.size()):
		if i >= _rm.hand.size():
			break
		var tile: Domino = _rm.hand[i]
		var btn:  Button = _tile_btns[i]
		if i in _selected_discard:
			btn.modulate = C_TILE_SELECT
		elif _rm.current_chain.can_add(tile):
			btn.modulate = C_TILE_NORMAL
		else:
			btn.modulate = C_TILE_DIM

func _create_tile_button(tile: Domino, index: int) -> Button:
	var btn := Button.new()

	# Split display: left pip on top, right pip on bottom
	var top := str(tile.left)  if tile.left  >= 0 else "★"
	var bot := str(tile.right) if tile.right >= 0 else "★"
	btn.text = "%s\n—\n%s" % [top, bot]

	btn.custom_minimum_size = Vector2(72, 100)
	btn.add_theme_font_size_override("font_size", 20)

	# Left click: add to chain
	btn.pressed.connect(_on_tile_left_click.bind(index))

	# Right click: toggle discard selection
	btn.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mbe := event as InputEventMouseButton
			if mbe.button_index == MOUSE_BUTTON_RIGHT and mbe.pressed:
				_on_tile_right_click(index)
	)

	return btn

# ===========================================================================
# UI construction — built entirely in code (no separate .tscn needed)
# ===========================================================================
func _build_ui() -> void:
	# ---- Background ----
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

	# ---- HUD ----
	root.add_child(_build_hud())

	# ---- Chain area ----
	root.add_child(_build_chain_area())

	# ---- Last hand result ----
	_lbl_last_hand = _make_label("", C_LAST_HAND, 15)
	_lbl_last_hand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_lbl_last_hand)

	# ---- Spacer ----
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	# ---- Isolation Chamber label ----
	var hand_title := _make_label("ISOLATION CHAMBER", C_DIM, 11)
	hand_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hand_title)

	# ---- Hand (tile buttons) ----
	_hand_container = HBoxContainer.new()
	_hand_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_hand_container.add_theme_constant_override("separation", 10)
	_hand_container.custom_minimum_size = Vector2(0, 110)
	root.add_child(_hand_container)

	# ---- Action bar ----
	root.add_child(_build_action_bar())

	# ---- Controls hint ----
	var hint := _make_label(
		"Left-click tile → add to chain   |   Right-click tile → select for discard",
		C_DIM, 11)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hint)

	# ---- Result overlay (modal) ----
	_overlay = _build_overlay()
	ui.add_child(_overlay)
	_overlay.hide()

# ---- HUD bar ----
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

func _make_hud_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	return lbl

# ---- Chain display ----
func _build_chain_area() -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = C_PANEL
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := _make_label("COHESION PULSE", C_DIM, 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_lbl_chain = _make_label("(empty)", C_CHAIN, 20)
	_lbl_chain.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_chain.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_lbl_chain)

	_lbl_preview = _make_label("", C_PREVIEW, 14)
	_lbl_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_preview)

	return panel

# ---- Action bar ----
func _build_action_bar() -> Control:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	hbox.custom_minimum_size = Vector2(0, 60)

	_btn_undo    = _make_button("Undo", _on_undo_pressed,    Vector2(120, 50))
	_btn_discard = _make_button("Discard (0)", _on_discard_pressed, Vector2(160, 50))
	_btn_play    = _make_button("▶  Play Pulse", _on_play_pressed,  Vector2(180, 50))

	hbox.add_child(_btn_undo)
	hbox.add_child(_btn_discard)
	hbox.add_child(_btn_play)

	return hbox

func _make_button(label: String, callback: Callable,
		min_size: Vector2 = Vector2(120, 48)) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = min_size
	btn.pressed.connect(callback)
	return btn

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
	style.bg_color = Color(0.10, 0.09, 0.07, 0.98)
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

# ---- Utility ----
func _make_label(text: String, color: Color, size: int = 14) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl
