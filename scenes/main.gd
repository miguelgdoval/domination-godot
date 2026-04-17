## main.gd — Trial Cycle controller + procedural UI (Milestone 3)
extends Node

# ---------------------------------------------------------------------------
# Palette
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
const C_TILE_FACE       := Color(0.94, 0.91, 0.83)
const C_TILE_FACE_HOVER := Color(1.00, 0.97, 0.89)
const C_TILE_FACE_DIM   := Color(0.55, 0.52, 0.46)
const C_TILE_FACE_SEL   := Color(0.72, 0.22, 0.18)
const C_TILE_BORDER     := Color(0.42, 0.36, 0.26)
const C_TILE_DIVIDER    := Color(0.42, 0.36, 0.26)
const C_TILE_PIP        := Color(0.10, 0.08, 0.06)
const C_TITLE_GLOW      := Color(0.85, 0.70, 0.30)
const C_SELECTED_BORDER := Color(0.85, 0.75, 0.30)

# Rarity badge colours
const C_RARITY := [
	Color(0.75, 0.72, 0.65),  # Bone
	Color(0.55, 0.75, 0.55),  # Carved
	Color(0.90, 0.80, 0.40),  # Ivory
	Color(0.55, 0.35, 0.85),  # Obsidian
]

# ---------------------------------------------------------------------------
# Game state
# ---------------------------------------------------------------------------
enum Phase { TITLE, CORE_SELECT, PROTOCOL_SELECT, PLAYING, ROUND_RESULT, SHOP, GAME_OVER, VICTORY }

var _phase: Phase = Phase.TITLE
var _rm: RoundManager
var _selected_discard: Array = []
var _tile_btns: Array = []
var _shop_inventory: Array = []   # current shop entries [{item, cost}]
var _shop_bought: Array = []      # ids bought this visit

# Selection state for run setup
var _pending_core:     int = 0
var _pending_protocol: int = 0
var _core_cards:    Array = []
var _protocol_cards: Array = []

# ---------------------------------------------------------------------------
# UI references — gameplay
# ---------------------------------------------------------------------------
var _lbl_round:       Label
var _lbl_chronos:     Label
var _lbl_target:      Label
var _lbl_hands:       Label
var _lbl_discards:    Label
var _lbl_monedas:     Label
var _lbl_etapa:       Label
var _chain_container: HBoxContainer
var _lbl_preview:     Label
var _lbl_last_hand:   Label
var _hand_container:  HBoxContainer
var _btn_play:        Button
var _btn_discard:     Button
var _btn_undo:        Button

# UI references — result overlay
var _result_overlay:    Control
var _lbl_result:        Label
var _lbl_result_sub:    Label
var _btn_result_action: Button

# UI references — shop overlay
var _shop_overlay:       Control
var _lbl_shop_title:     Label
var _lbl_shop_monedas:   Label
var _shop_items_row:     HBoxContainer
var _shop_modules_row:   HBoxContainer
var _lbl_slots:          Label

# UI references — title / selection overlays
var _title_overlay:        Control
var _core_select_overlay:  Control
var _proto_select_overlay: Control
var _lbl_core_confirm:     Label
var _lbl_proto_confirm:    Label

# ===========================================================================
# Lifecycle
# ===========================================================================
func _ready() -> void:
	_build_ui()
	_show_title()

# ===========================================================================
# Title / selection flow
# ===========================================================================
func _show_title() -> void:
	_phase = Phase.TITLE
	_title_overlay.show()
	_core_select_overlay.hide()
	_proto_select_overlay.hide()
	_result_overlay.hide()
	_shop_overlay.hide()

func _on_title_start_pressed() -> void:
	_pending_core     = 0
	_pending_protocol = 0
	_title_overlay.hide()
	_refresh_core_cards()
	_core_select_overlay.show()

func _on_core_card_pressed(index: int) -> void:
	_pending_core = index
	_refresh_core_cards()

func _on_core_confirm_pressed() -> void:
	_core_select_overlay.hide()
	_refresh_protocol_cards()
	_proto_select_overlay.show()

func _on_protocol_card_pressed(index: int) -> void:
	_pending_protocol = index
	_refresh_protocol_cards()

func _on_protocol_confirm_pressed() -> void:
	_proto_select_overlay.hide()
	GameState.start_run(_pending_core, _pending_protocol)
	_start_round()

func _refresh_core_cards() -> void:
	for i in range(_core_cards.size()):
		var panel: PanelContainer = _core_cards[i]
		_set_selection_border(panel, i == _pending_core, Constants.CORE_RARITIES[i])

func _refresh_protocol_cards() -> void:
	for i in range(_protocol_cards.size()):
		var panel: PanelContainer = _protocol_cards[i]
		_set_selection_border(panel, i == _pending_protocol, Constants.PROTOCOL_RARITIES[i])

func _set_selection_border(panel: PanelContainer, selected: bool, rarity: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.10, 0.07) if not selected else Color(0.16, 0.14, 0.09)
	style.border_color = C_SELECTED_BORDER if selected else C_RARITY[rarity]
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

# ===========================================================================
# Round lifecycle
# ===========================================================================
func _start_round() -> void:
	_phase = Phase.PLAYING
	_selected_discard.clear()

	_rm = RoundManager.new()
	_rm.setup(
		GameState.box,
		GameState.round_index,
		GameState.protocol_hand_size(),
		GameState.protocol_hands(),
		GameState.protocol_discards()
	)
	_rm.chain_changed.connect(_on_chain_changed)
	_rm.hand_changed.connect(_on_hand_changed)
	_rm.hand_scored.connect(_on_hand_scored)
	_rm.round_ended.connect(_on_round_ended)

	_result_overlay.hide()
	_shop_overlay.hide()
	_refresh_hud()
	_rebuild_hand()
	_refresh_chain_display()

func _end_round(won: bool) -> void:
	if won:
		_phase = Phase.ROUND_RESULT
		var earned: int = GameState.award_monedas(_rm.unused_hands())
		_lbl_result.text = "RECALIBRATION SUCCESSFUL"
		_lbl_result.add_theme_color_override("font_color", C_WIN)
		_lbl_result_sub.text = "Chronos: %d / %d    +%d Monedas" % [
			_rm.chronos, _rm.target, earned]
		var shop_name: String = \
			"ARTISAN'S WORKSHOP" if GameState.is_boss_round() else "BRASS EMPORIUM"
		_btn_result_action.text = "VISIT " + shop_name
	else:
		_phase = Phase.GAME_OVER
		_lbl_result.text = "SIMULATION FAILURE"
		_lbl_result.add_theme_color_override("font_color", C_LOSE)
		_lbl_result_sub.text = \
			"Chronos: %d / %d\n\nREINITIALIZING PROTOCOL.\nOPERATOR REMAINS AVAILABLE." % \
			[_rm.chronos, _rm.target]
		_btn_result_action.text = "NEW TRIAL CYCLE"
	_result_overlay.show()

func _show_shop() -> void:
	_phase = Phase.SHOP
	_result_overlay.hide()

	var owned_ids: Array = GameState.modules.map(func(m): return m.id)
	if GameState.is_boss_round():
		_lbl_shop_title.text = "THE ARTISAN'S WORKSHOP"
		_shop_inventory = ShopManager.generate_artisan(owned_ids)
	else:
		_lbl_shop_title.text = "THE BRASS EMPORIUM"
		_shop_inventory = ShopManager.generate_emporium(3, owned_ids)

	_shop_bought.clear()
	_populate_shop()
	_shop_overlay.show()

# ===========================================================================
# Signal handlers — gameplay
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
	if _phase == Phase.PLAYING and _rm.can_play():
		_rm.play_chain()

func _on_discard_pressed() -> void:
	if _phase == Phase.PLAYING and not _selected_discard.is_empty() and _rm.can_discard():
		_rm.discard(_selected_discard)
		_selected_discard.clear()

func _on_undo_pressed() -> void:
	if _phase == Phase.PLAYING:
		_rm.undo_last_chain_tile()

# ===========================================================================
# Signal handlers — result overlay
# ===========================================================================
func _on_result_action_pressed() -> void:
	match _phase:
		Phase.ROUND_RESULT:
			_show_shop()
		Phase.GAME_OVER:
			_show_title()
		Phase.VICTORY:
			_show_title()

# ===========================================================================
# Signal handlers — shop
# ===========================================================================
func _on_buy_pressed(entry: Dictionary) -> void:
	var m: Module = entry["item"]
	var cost: int = entry["cost"]

	if not GameState.has_free_slot():
		return
	if GameState.owns_module(m.id):
		return
	if not GameState.spend_monedas(cost):
		return

	GameState.add_module(m)
	_shop_bought.append(m.id)
	_populate_shop()

func _on_sell_pressed(m: Module) -> void:
	if GameState.sell_module(m):
		_populate_shop()

func _on_shop_continue_pressed() -> void:
	GameState.advance_round()
	if GameState.is_run_complete():
		_phase = Phase.VICTORY
		_lbl_result.text = "CHRONOMETER RECALIBRATED"
		_lbl_result.add_theme_color_override("font_color", C_MONEDAS)
		_lbl_result_sub.text = \
			"The Perpetual Chronometer stabilizes.\nEntropy contained. For now.\n\nOPERATOR COMMENDED."
		_btn_result_action.text = "NEW TRIAL CYCLE"
		_shop_overlay.hide()
		_result_overlay.show()
		return
	_start_round()

# ===========================================================================
# Shop population
# ===========================================================================
func _populate_shop() -> void:
	_lbl_shop_monedas.text = "Monedas: %d" % GameState.monedas
	_lbl_slots.text = "Modules: %d / %d" % [
		GameState.modules.size(), GameState.module_slots]

	for child in _shop_items_row.get_children():
		child.queue_free()
	for entry in _shop_inventory:
		_shop_items_row.add_child(_build_shop_item_card(entry))

	for child in _shop_modules_row.get_children():
		child.queue_free()
	if GameState.modules.is_empty():
		var none_lbl := _make_label("(no modules equipped)", C_DIM, 13)
		none_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_shop_modules_row.add_child(none_lbl)
	else:
		for m in GameState.modules:
			_shop_modules_row.add_child(_build_equipped_module_card(m))

func _build_shop_item_card(entry: Dictionary) -> Control:
	var m: Module  = entry["item"]
	var cost: int  = entry["cost"]
	var bought: bool = m.id in _shop_bought or GameState.owns_module(m.id)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(260, 0)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.11, 0.10, 0.07)
	style.border_color = C_RARITY[m.rarity]
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	vbox.add_child(_make_label(Constants.RARITY_NAMES[m.rarity].to_upper(), C_RARITY[m.rarity], 11))
	vbox.add_child(_make_label(m.display_name, C_TEXT, 18))

	var desc_lbl := _make_label(m.description, C_PREVIEW, 13)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(240, 0)
	vbox.add_child(desc_lbl)

	if m.lore_text != "":
		var lore_lbl := _make_label(m.lore_text, C_DIM, 11)
		lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lore_lbl.custom_minimum_size = Vector2(240, 0)
		vbox.add_child(lore_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var bottom_row := HBoxContainer.new()
	vbox.add_child(bottom_row)

	var cost_lbl := _make_label("%d Monedas" % cost, C_MONEDAS, 14)
	cost_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(cost_lbl)

	if bought:
		bottom_row.add_child(_make_label("OWNED", C_WIN, 13))
	else:
		var can_buy: bool = (GameState.monedas >= cost) and \
							GameState.has_free_slot() and \
							not GameState.owns_module(m.id)
		var buy_btn := Button.new()
		buy_btn.text = "BUY"
		buy_btn.disabled = not can_buy
		buy_btn.pressed.connect(_on_buy_pressed.bind(entry))
		bottom_row.add_child(buy_btn)

	return panel

func _build_equipped_module_card(m: Module) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.12, 0.11, 0.08)
	style.border_color = C_RARITY[m.rarity]
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	panel.add_child(vbox)

	var name_row := HBoxContainer.new()
	vbox.add_child(name_row)
	name_row.add_child(_make_label("●", C_RARITY[m.rarity], 12))
	var name_lbl := _make_label(" " + m.display_name, C_TEXT, 14)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_lbl)

	var desc_lbl := _make_label(m.description, C_DIM, 11)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(160, 0)
	vbox.add_child(desc_lbl)

	var sell_btn := Button.new()
	sell_btn.text = "SELL  +%d" % Constants.RARITY_SELL[m.rarity]
	var new_slots: int = GameState.module_slots - m.extra_slots
	sell_btn.disabled = new_slots < GameState.modules.size() - 1
	sell_btn.pressed.connect(_on_sell_pressed.bind(m))
	vbox.add_child(sell_btn)

	return panel

# ===========================================================================
# Gameplay UI refresh
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

func _refresh_chain_display() -> void:
	for child in _chain_container.get_children():
		child.queue_free()

	if _rm.current_chain.is_empty():
		var lbl := _make_label("(empty)", C_DIM, 15)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_chain_container.add_child(lbl)
	else:
		for i in range(_rm.current_chain.tile_displays.size()):
			if i > 0:
				var arr := _make_label("→", C_DIM, 14)
				arr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				_chain_container.add_child(arr)
			var d: Vector2i = _rm.current_chain.tile_displays[i]
			_chain_container.add_child(_build_chain_tile(d.x, d.y))

	if not _rm.current_chain.is_empty():
		var r: Dictionary = Scoring.calculate(_rm.current_chain, GameState.modules)
		_lbl_preview.text = "%d chips  ×  %d  =  %d Chronos" % [
			r["chips"], r["mult"], r["total"]]
	else:
		_lbl_preview.text = ""

func _refresh_action_buttons() -> void:
	_btn_play.disabled    = not _rm.can_play()
	_btn_discard.disabled = not _rm.can_discard() or _selected_discard.is_empty()
	_btn_undo.disabled    = _rm.current_chain.is_empty()
	_btn_discard.text     = "Discard (%d)" % _selected_discard.size()

func _rebuild_hand() -> void:
	_selected_discard.clear()
	for child in _hand_container.get_children():
		child.queue_free()
	_tile_btns.clear()
	for i in range(_rm.hand.size()):
		var btn := _create_hand_tile(_rm.hand[i], i)
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

func _build_chain_tile(disp_left: int, disp_right: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(76, 48)
	var style := StyleBoxFlat.new()
	style.bg_color     = C_TILE_FACE
	style.border_color = C_TILE_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	var ll := _make_pip_label(disp_left)
	ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(ll)
	hbox.add_child(_make_tile_vsep())
	var rl := _make_pip_label(disp_right)
	rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(rl)
	return panel

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
	sep.custom_minimum_size   = Vector2(0, 2)
	sep.size_flags_horizontal = Control.SIZE_FILL
	return sep

func _make_tile_vsep() -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_DIVIDER
	sep.custom_minimum_size  = Vector2(2, 0)
	sep.size_flags_vertical  = Control.SIZE_FILL
	return sep

func _apply_tile_style(btn: Button, face: Color, hover: Color) -> void:
	for n in ["normal", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = face; s.border_color = C_TILE_BORDER
		s.set_border_width_all(2); s.set_corner_radius_all(5)
		btn.add_theme_stylebox_override(n, s)
	var sh := StyleBoxFlat.new()
	sh.bg_color = hover; sh.border_color = C_TILE_BORDER
	sh.set_border_width_all(2); sh.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("hover", sh)
	var sp := StyleBoxFlat.new()
	sp.bg_color = face.darkened(0.12); sp.border_color = C_TILE_BORDER
	sp.set_border_width_all(2); sp.set_corner_radius_all(5)
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

	_result_overlay = _build_result_overlay()
	ui.add_child(_result_overlay)
	_result_overlay.hide()

	_shop_overlay = _build_shop_overlay()
	ui.add_child(_shop_overlay)
	_shop_overlay.hide()

	_title_overlay = _build_title_overlay()
	ui.add_child(_title_overlay)

	_core_select_overlay = _build_selection_overlay(
		"CALIBRATION CORE",
		"Choose your starting tile configuration.",
		Constants.CORE_COUNT,
		Constants.CORE_NAMES,
		Constants.CORE_RARITIES,
		Constants.CORE_DESCS,
		Constants.CORE_LORES,
		_on_core_card_pressed,
		_on_core_confirm_pressed,
		"LOCK IN CORE  →",
		_core_cards
	)
	ui.add_child(_core_select_overlay)
	_core_select_overlay.hide()

	_proto_select_overlay = _build_selection_overlay(
		"OPERATIONAL PROTOCOL",
		"Choose your run parameters.",
		Constants.PROTOCOL_COUNT,
		Constants.PROTOCOL_NAMES,
		Constants.PROTOCOL_RARITIES,
		Constants.PROTOCOL_DESCS,
		Constants.PROTOCOL_LORES,
		_on_protocol_card_pressed,
		_on_protocol_confirm_pressed,
		"BEGIN TRIAL CYCLE  →",
		_protocol_cards
	)
	ui.add_child(_proto_select_overlay)
	_proto_select_overlay.hide()

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
	_btn_undo    = _make_button("↩ Undo",       _on_undo_pressed,    Vector2(120, 50))
	_btn_discard = _make_button("Discard (0)",   _on_discard_pressed, Vector2(160, 50))
	_btn_play    = _make_button("▶  Play Pulse", _on_play_pressed,    Vector2(180, 50))
	hbox.add_child(_btn_undo)
	hbox.add_child(_btn_discard)
	hbox.add_child(_btn_play)
	return hbox

# ---- Result overlay ----
func _build_result_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 260)
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
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(row)
	_btn_result_action = _make_button("VISIT EMPORIUM", _on_result_action_pressed,
		Vector2(220, 48))
	row.add_child(_btn_result_action)
	return overlay

# ---- Shop overlay ----
func _build_shop_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1100, 0)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.09, 0.07)
	style.border_color = Color(0.50, 0.45, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	_lbl_shop_title = _make_label("THE BRASS EMPORIUM", C_TEXT, 22)
	_lbl_shop_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_lbl_shop_title)

	var right_col := VBoxContainer.new()
	right_col.alignment = BoxContainer.ALIGNMENT_END
	header.add_child(right_col)

	_lbl_shop_monedas = _make_label("Monedas: 0", C_MONEDAS, 16)
	_lbl_shop_monedas.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_col.add_child(_lbl_shop_monedas)

	_lbl_slots = _make_label("Modules: 0/4", C_DIM, 13)
	_lbl_slots.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_col.add_child(_lbl_slots)

	vbox.add_child(_make_hsep())

	_shop_items_row = HBoxContainer.new()
	_shop_items_row.add_theme_constant_override("separation", 16)
	_shop_items_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(_shop_items_row)

	vbox.add_child(_make_hsep())

	vbox.add_child(_make_label("EQUIPPED MODULES", C_DIM, 12))

	_shop_modules_row = HBoxContainer.new()
	_shop_modules_row.add_theme_constant_override("separation", 12)
	vbox.add_child(_shop_modules_row)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(btn_row)
	btn_row.add_child(
		_make_button("CONTINUE TO NEXT ROUND  →", _on_shop_continue_pressed,
			Vector2(260, 50))
	)

	return overlay

# ---- Title overlay ----
func _build_title_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0.06, 0.05, 0.04)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	vbox.custom_minimum_size = Vector2(600, 0)
	center.add_child(vbox)

	# Decorative glyph
	var glyph := _make_label("⬡", C_TITLE_GLOW, 48)
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(glyph)

	# Title
	var title_lbl := _make_label("DOMINATION", C_TITLE_GLOW, 54)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	# Subtitle
	var sub_lbl := _make_label("Trials of the Perpetual Chronometer", C_DIM, 16)
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub_lbl)

	vbox.add_child(_make_hsep())

	# Lore blurb
	var lore_lbl := _make_label(
		"The Chronometer falters.\nYou are the Operator.\nCalibrate the signal before entropy claims the age.",
		C_TEXT, 15)
	lore_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_lbl.custom_minimum_size = Vector2(480, 0)
	vbox.add_child(lore_lbl)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	btn_row.add_child(_make_button(
		"INITIATE TRIAL CYCLE  →", _on_title_start_pressed, Vector2(280, 54)))

	return overlay

# ---- Generic selection overlay (used for both Core and Protocol) ----
func _build_selection_overlay(
		title_text: String,
		sub_text: String,
		count: int,
		names: Array,
		rarities: Array,
		descs: Array,
		lores: Array,
		card_callback: Callable,
		confirm_callback: Callable,
		confirm_label: String,
		out_cards: Array) -> Control:

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.90)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1140, 0)
	var pstyle := StyleBoxFlat.new()
	pstyle.bg_color     = Color(0.10, 0.09, 0.07)
	pstyle.border_color = Color(0.50, 0.45, 0.35)
	pstyle.set_border_width_all(2)
	pstyle.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", pstyle)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)

	# Header
	var hdr := _make_label(title_text, C_TITLE_GLOW, 26)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)

	var sub := _make_label(sub_text, C_DIM, 14)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	vbox.add_child(_make_hsep())

	# Cards row
	var cards_row := HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 16)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(cards_row)

	out_cards.clear()
	for i in range(count):
		var card := _build_selection_card(
			i, names[i], rarities[i], descs[i], lores[i], card_callback)
		cards_row.add_child(card)
		out_cards.append(card)

	vbox.add_child(_make_hsep())

	# Confirm button
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button(confirm_label, confirm_callback, Vector2(280, 52)))

	return overlay

func _build_selection_card(
		index: int,
		card_name: String,
		rarity: int,
		desc: String,
		lore: String,
		callback: Callable) -> PanelContainer:

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(256, 200)

	# Initial style (unselected)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.11, 0.10, 0.07)
	style.border_color = C_RARITY[rarity]
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Rarity badge
	vbox.add_child(_make_label(Constants.RARITY_NAMES[rarity].to_upper(), C_RARITY[rarity], 11))

	# Name
	vbox.add_child(_make_label(card_name, C_TEXT, 20))

	# Description (may be multiline)
	var desc_lbl := _make_label(desc, C_PREVIEW, 13)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(236, 0)
	vbox.add_child(desc_lbl)

	# Lore
	var lore_lbl := _make_label(lore, C_DIM, 11)
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_lbl.custom_minimum_size = Vector2(236, 0)
	vbox.add_child(lore_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# SELECT button
	var btn := Button.new()
	btn.text = "SELECT"
	btn.pressed.connect(callback.bind(index))
	vbox.add_child(btn)

	return panel

# ===========================================================================
# Generic helpers
# ===========================================================================
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

func _make_hsep() -> Control:
	var sep := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.28, 0.22)
	sep.add_theme_stylebox_override("separator", style)
	return sep
