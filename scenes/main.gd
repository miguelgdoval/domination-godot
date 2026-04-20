## main.gd — Trial Cycle controller + procedural UI (Milestone 4)
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
const C_TILE_BODY       := Color(0.21, 0.17, 0.11)   # dark ebony outer frame
const C_TILE_FACE       := Color(0.89, 0.85, 0.74)   # aged ivory pip-half face
const C_TILE_FACE_HOVER := Color(0.96, 0.92, 0.82)   # brightened hover
const C_TILE_FACE_DIM   := Color(0.46, 0.43, 0.38)   # strongly faded
const C_TILE_FACE_SEL   := Color(0.96, 0.88, 0.52)   # amber/gold selected (active, not red)
const C_TILE_BORDER     := Color(0.60, 0.48, 0.26)   # rich brass
const C_TILE_BORDER_SEL := Color(0.96, 0.80, 0.28)   # bright gold for selected tiles
const C_TILE_DIVIDER    := Color(0.52, 0.42, 0.22)   # brass divider bar
const C_TILE_PIP        := Color(0.10, 0.08, 0.06)
const C_TITLE_GLOW      := Color(0.85, 0.70, 0.30)
const C_SELECTED_BORDER := Color(0.85, 0.75, 0.30)
const C_PIP_DOT         := Color(0.09, 0.07, 0.04)   # very dark crisp pip dots
const C_PIP_DOT_TILE    := Color(0.92, 0.88, 0.80)

# ---------------------------------------------------------------------------
# Artisan / Emporium greeting lines (indexed by etapa 0–3)
# ---------------------------------------------------------------------------
const EMPORIUM_GREETINGS: Array = [
	"Welcome to the Brass Emporium. Finest calibration work in the cycle.",
	"Back again. The signal grows erratic — choose well, Operator.",
	"You've come far. The shelves are yours — take what the pulse needs.",
	"I won't waste your time. Take what you need and stabilise that pulse.",
]
const ARTISAN_GREETINGS: Array = [
	"Initial calibration nominal. The workshop is open.",
	"Some turbulence in the higher frequencies. Reinforce while you can.",
	"The Chronometer strains audibly now. I've set aside my best work.",
	"Operator. Listen carefully. This may be our last transaction.",
]

# Etapa transition cinematic (indexed 0–3)
const ETAPA_ROMAN:       Array[String] = ["I", "II", "III", "IV"]
const ETAPA_SHORT_NAMES: Array[String] = ["Mahogany", "Brass", "Obsidian", "Void"]
const ETAPA_ATMOSPHERE:  Array[String] = [
	"The Chronometer hums.\nAll signals nominal.",
	"Strain detected.\nAmber frequencies rising.",
	"Systems degrading.\nVisual crackle intensifies.",
	"Critical failure imminent.\nHold the line, Operator.",
]
# Boss intro atmospheric lore (one line per etapa)
const BOSS_LORE: Array[String] = [
	"The frequencies bleed.\nWhat was stable becomes noise.",
	"Your signal reaches us fractured.\nThe decay accelerates.",
	"The resonance lock has no key.\nOnly pressure.",
	"This is not a test.\nThe Chronometer cannot hold much longer.",
]

# Pip positions in a 3×3 grid (index 0-8, left-to-right top-to-bottom)
const PIP_POSITIONS: Array = [
	[],                             # 0
	[4],                            # 1
	[2, 6],                         # 2
	[2, 4, 6],                      # 3
	[0, 2, 6, 8],                   # 4
	[0, 2, 4, 6, 8],                # 5
	[0, 2, 3, 5, 6, 8],             # 6
	[0, 2, 3, 4, 5, 6, 8],          # 7
	[0, 1, 2, 3, 5, 6, 7, 8],       # 8
	[0, 1, 2, 3, 4, 5, 6, 7, 8],    # 9
]

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
enum Phase { TITLE, CORE_SELECT, PROTOCOL_SELECT, TILE_REMOVAL, BOSS_WARNING, PLAYING, ROUND_RESULT, SHOP, GAME_OVER, VICTORY }

var _phase: Phase = Phase.TITLE
var _rm: RoundManager
var _dm: DirectiveManager
var _selected_tiles: Array = []
var _building_chain: bool  = false   # suppresses intermediate UI refreshes during batch-add
var _tile_btns: Array = []
var _tile_conn_lbls: Array = []   # connection-arrow labels, parallel to _tile_btns
var _scoring_active: bool = false # input locked while scoring animation plays
var _shop_inventory: Array = []          # module entries [{item, cost}]
var _shop_bought: Array = []             # module ids bought this visit
# Artisan's Workshop tile state
var _tile_offers: Array = []             # [{tile, cost}] — tiles for sale
var _tile_offers_bought: Array = []      # indices already bought
var _removal_candidates: Array = []      # Array[Domino] shown for thinning
var _removal_selected: Array = []        # indices selected for removal
const MAX_FREE_REMOVALS: int = 2

# Selection state for run setup
var _pending_core:     int = 0
var _pending_protocol: int = 0
var _core_cards:    Array = []
var _protocol_cards: Array = []

# ---------------------------------------------------------------------------
# UI references — gameplay
# ---------------------------------------------------------------------------
var _lbl_round:   Label
var _lbl_etapa:   Label
var _lbl_monedas: Label
# Chronos progress bar
var _chronos_bar:            ProgressBar
var _chronos_bar_lbl:        Label
var _chronos_bar_fill_style: StyleBoxFlat
# Hands / discards dot indicators
var _hands_dot_row:    HBoxContainer
var _discards_dot_row: HBoxContainer
var _chain_container:  HBoxContainer
var _lbl_preview:      Label
var _lbl_chain_bonus:  Label   # "N more for +1 Mult" threshold hint
var _lbl_last_hand:    Label
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
var _shop_overlay:         Control
var _lbl_shop_title:       Label
var _lbl_shop_greeting:    Label
var _lbl_shop_monedas:     Label
var _shop_items_row:       HBoxContainer
var _shop_modules_row:     HBoxContainer
var _lbl_slots:            Label
# Artisan-only UI
var _artisan_section:      Control
var _tile_offers_row:      HBoxContainer
var _tile_removal_row:     HBoxContainer
var _lbl_removals_left:    Label
var _btn_confirm_removal:  Button

## Etapa theme — stored style references for live colour updates
var _bg_rect:          ColorRect
var _table_style:      StyleBoxFlat
var _hud_style:        StyleBoxFlat
var _hand_panel_style: StyleBoxFlat
var _lbl_table_title:  Label

## Canvas layer reference for floating score animations
var _ui_layer: CanvasLayer

# UI references — starting tile removal overlay
var _tile_removal_overlay:   Control
var _start_removal_row:      HBoxContainer
var _start_removal_lbl:      Label
var _start_removal_btn:      Button
var _start_removal_candidates: Array = []   # Array[Domino]
var _start_removal_selected:   Array = []   # selected indices

# Module rack (displayed during play, below directives)
var _module_rack_row:  HBoxContainer
var _module_rack_panel: Control

# UI references — directives panel
var _directives_panel:   Control
var _directive_labels:   Array = []   # Array[Label], one per active directive

# UI references — boss warning overlay (cinematic)
var _boss_overlay:      Control
var _lbl_boss_warning:  Label   # "⚠ CORRUPTION DETECTED" — fades in first
var _lbl_boss_name:     Label   # glitch→typewriter reveal
var _lbl_boss_lore:     Label   # atmospheric one-liner
var _lbl_boss_desc:     Label   # mechanical effect text
var _boss_begin_btn:    Button  # delayed fade-in at end of sequence

# UI references — etapa transition cinematic overlay
var _etapa_transition_overlay: Control
var _etapa_content_vbox:       VBoxContainer
var _lbl_etapa_numeral:        Label
var _lbl_etapa_name_big:       Label
var _lbl_etapa_atmosphere:     Label
var _last_etapa:               int = -1   # tracks previous etapa for change detection

# Module rack pulse tracking (id → rack card Control)
var _rack_card_by_id: Dictionary = {}

# ---------------------------------------------------------------------------
# Module tooltip (floating overlay shown on hover)
# ---------------------------------------------------------------------------
var _tooltip_panel:      Control
var _tooltip_rarity_lbl: Label
var _tooltip_name_lbl:   Label
var _tooltip_desc_lbl:   Label
var _tooltip_lore_lbl:   Label

# ---------------------------------------------------------------------------
# Run-end cinematic overlay (victory / defeat — replaces simple result panel)
# ---------------------------------------------------------------------------
var _run_end_overlay:       Control
var _lbl_run_end_glyph:     Label
var _lbl_run_end_title:     Label
var _lbl_run_end_sub:       Label
var _run_end_stats_col:     VBoxContainer
var _run_end_progress_bar:  ProgressBar
var _run_end_progress_lbl:  Label
var _btn_run_end:           Button

# ---------------------------------------------------------------------------
# Ambient degradation (etapas 2–4 visual noise)
# ---------------------------------------------------------------------------
var _ambient_active: bool = false

# ---------------------------------------------------------------------------
# Chain tile idle breathing
# ---------------------------------------------------------------------------
var _chain_idle_tweens: Array = []

# ---------------------------------------------------------------------------
# Tile face texture (loaded once, used by all pip-half panels)
# ---------------------------------------------------------------------------
var _tile_face_tex: Texture2D = null

# UI references — title / selection overlays
var _title_overlay:        Control
var _core_select_overlay:  Control
var _proto_select_overlay: Control

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
	_ambient_active = false
	_kill_chain_idle_tweens()
	_title_overlay.show()
	_core_select_overlay.hide()
	_proto_select_overlay.hide()
	_tile_removal_overlay.hide()
	_result_overlay.hide()
	_shop_overlay.hide()
	_run_end_overlay.hide()

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
	_show_start_removal()

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
	var new_etapa: int = GameState.current_etapa()
	if new_etapa != _last_etapa:
		_last_etapa = new_etapa
		_show_etapa_transition(new_etapa)

	# Boss rounds show a cinematic warning before play begins
	if GameState.is_boss_round():
		_show_boss_warning()
		return
	_begin_round_play()

func _show_boss_warning() -> void:
	_phase = Phase.BOSS_WARNING
	var etapa: int    = GameState.current_etapa()
	var boss_name: String = Constants.BOSS_NAMES[etapa]

	# Reset all elements to invisible before showing overlay
	_lbl_boss_warning.modulate.a = 0.0
	_lbl_boss_name.modulate.a    = 0.0
	_lbl_boss_lore.modulate.a    = 0.0
	_lbl_boss_desc.modulate.a    = 0.0
	_boss_begin_btn.modulate.a   = 0.0
	_boss_begin_btn.disabled     = true
	_lbl_boss_name.text          = ""
	_lbl_boss_lore.text          = BOSS_LORE[clampi(etapa, 0, 3)]
	_lbl_boss_desc.text          = Constants.BOSS_DESCS[etapa]

	# Reset separator
	for child in _boss_overlay.get_child(0).get_child(0).get_children():
		if child.has_meta("is_boss_sep"):
			child.modulate.a = 0.0

	_boss_overlay.show()

	var seq := create_tween()

	# Phase 1 — warning header pulses in (0.3s)
	seq.tween_property(_lbl_boss_warning, "modulate:a", 1.0, 0.30)
	seq.tween_interval(0.40)

	# Phase 2 — boss name: glitch scramble × 4, then typewriter letter-by-letter
	seq.tween_callback(func():
		_lbl_boss_name.modulate.a = 1.0
		_lbl_boss_name.text = _glitch_text(boss_name)
	)
	for _i in range(3):
		seq.tween_interval(0.09)
		seq.tween_callback(func(): _lbl_boss_name.text = _glitch_text(boss_name))
	seq.tween_interval(0.11)
	# Typewriter: one real character per 70 ms
	for i in range(1, boss_name.length() + 1):
		var n: int = i   # capture loop index
		seq.tween_callback(func(): _lbl_boss_name.text = boss_name.substr(0, n))
		seq.tween_interval(0.07)

	# Phase 3 — atmospheric lore fades in
	seq.tween_interval(0.18)
	seq.tween_property(_lbl_boss_lore, "modulate:a", 1.0, 0.45)

	# Phase 4 — separator + mechanic desc appears
	seq.tween_interval(0.15)
	seq.tween_callback(func():
		for child in _boss_overlay.get_child(0).get_child(0).get_children():
			if child.has_meta("is_boss_sep"):
				child.modulate.a = 1.0
	)
	seq.tween_property(_lbl_boss_desc, "modulate:a", 1.0, 0.30)

	# Phase 5 — button fades in and becomes interactive
	seq.tween_interval(0.40)
	seq.tween_callback(func():
		_boss_begin_btn.disabled = false
	)
	seq.tween_property(_boss_begin_btn, "modulate:a", 1.0, 0.40)

func _on_boss_begin_pressed() -> void:
	_boss_overlay.hide()
	_begin_round_play()

func _begin_round_play() -> void:
	_phase = Phase.PLAYING
	_scoring_active = false
	_selected_tiles.clear()

	# Apply etapa colour theme (tweened)
	_apply_etapa_theme(GameState.current_etapa())

	# Compute round params: protocol base + boss delta + module bonuses
	var hand_size: int  = GameState.protocol_hand_size()
	var max_hands: int  = GameState.protocol_hands()
	var max_disc: int   = GameState.protocol_discards()

	if GameState.is_boss_round():
		var e: int = GameState.current_etapa()
		hand_size  = maxi(1, hand_size  + Constants.BOSS_HAND_DELTA[e])
		max_hands  = maxi(1, max_hands  + Constants.BOSS_HANDS_DELTA[e])
		max_disc   = maxi(0, max_disc   + Constants.BOSS_DISCARD_DELTA[e])

	hand_size = maxi(1, hand_size + GameState.module_hand_size_bonus())
	max_hands = maxi(1, max_hands + GameState.module_hands_bonus())
	max_disc  = maxi(0, max_disc  + GameState.module_discard_bonus())

	_rm = RoundManager.new()
	_rm.setup(GameState.box, GameState.round_index, hand_size, max_hands, max_disc)
	_rm.chain_changed.connect(_on_chain_changed)
	_rm.hand_changed.connect(_on_hand_changed)
	_rm.hand_scored.connect(_on_hand_scored)
	_rm.round_ended.connect(_on_round_ended)

	_dm = DirectiveManager.new()
	_dm.setup(_rm, 2)
	_dm.directive_completed.connect(_on_directive_completed)

	_result_overlay.hide()
	_shop_overlay.hide()
	_refresh_hud()
	_rebuild_hand()
	_refresh_chain_display()
	_refresh_directives()
	_refresh_module_rack()
	_start_ambient_effects(GameState.current_etapa())

func _end_round(won: bool) -> void:
	if won:
		_phase = Phase.ROUND_RESULT
		# Check round-end directives before awarding monedas
		var dir_bonus: int = _dm.check_round_win()
		GameState.monedas += dir_bonus
		var earned: int = GameState.award_monedas(_rm.unused_hands())
		_lbl_result.text = "RECALIBRATION SUCCESSFUL"
		_lbl_result.add_theme_color_override("font_color", C_WIN)
		var detail: String = "Chronos: %d / %d    +%d Monedas" % [
			_rm.chronos, _rm.target, earned]
		if dir_bonus > 0:
			detail += "\nDirectives: +%d Monedas" % dir_bonus
		_lbl_result_sub.text = detail
		var shop_name: String = \
			"ARTISAN'S WORKSHOP" if GameState.is_boss_round() else "BRASS EMPORIUM"
		_btn_result_action.text = "VISIT " + shop_name
	else:
		_show_run_end(false)
		return
	_result_overlay.show()

func _show_shop() -> void:
	_phase = Phase.SHOP
	_result_overlay.hide()
	_ambient_active = false

	var etapa: int = GameState.current_etapa()
	var owned_ids: Array = GameState.modules.map(func(m): return m.id)
	if GameState.is_boss_round():
		_lbl_shop_title.text = "THE ARTISAN'S WORKSHOP"
		_lbl_shop_greeting.text = ARTISAN_GREETINGS[clampi(etapa, 0, 3)]
		_shop_inventory = ShopManager.generate_artisan(owned_ids)
		_tile_offers = TileShopManager.generate_offers(3)
		_tile_offers_bought.clear()
		_removal_candidates = TileShopManager.generate_removal_candidates(GameState.box, 8)
		_removal_selected.clear()
		_artisan_section.show()
	else:
		_lbl_shop_title.text = "THE BRASS EMPORIUM"
		_lbl_shop_greeting.text = EMPORIUM_GREETINGS[clampi(etapa, 0, 3)]
		_shop_inventory = ShopManager.generate_emporium(3, owned_ids)
		_artisan_section.hide()

	_shop_bought.clear()
	_populate_shop()
	_shop_overlay.modulate.a = 0.0
	_shop_overlay.scale      = Vector2(0.96, 0.96)
	_shop_overlay.show()
	# Slide-in transition
	var st := create_tween().set_parallel(true)
	st.tween_property(_shop_overlay, "modulate:a", 1.0, 0.28)
	st.tween_property(_shop_overlay, "scale", Vector2.ONE, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ===========================================================================
# Signal handlers — gameplay
# ===========================================================================
func _on_chain_changed() -> void:
	if _building_chain:
		return
	_refresh_chain_display()
	_refresh_action_buttons()
	_refresh_tile_visuals()

func _on_hand_changed() -> void:
	if _building_chain:
		return
	_rebuild_hand()
	_refresh_hud()

func _on_hand_scored(result: Dictionary) -> void:
	_lbl_last_hand.text = "%d chips  ×  %d  =  %d Chronos" % [
		result["chips"], result["mult"], result["total"]]
	GameState.record_hand(result["total"])
	var dir_bonus: int = _dm.check_play(result)
	if dir_bonus > 0:
		GameState.monedas += dir_bonus

	# Pre-scan modules for display-side chip calculation
	# (scoring.gd is the source of truth; this is only for the "+N chips" pop-up labels)
	var double_pip_mult:   int   = 1
	var wild_pip_chips_ui: int   = 0
	var sacrifice_specs_ui: Array = []
	var blank_pip_val_ui:  int   = 0
	for m in GameState.modules:
		match m.effect_type:
			Module.EffectType.DOUBLE_PIP_BOOST:
				double_pip_mult   = maxi(double_pip_mult,   m.effect_value)
			Module.EffectType.WILD_PIP_VALUE:
				wild_pip_chips_ui = maxi(wild_pip_chips_ui, m.effect_value * 2)
			Module.EffectType.LOW_PIP_TO_MULT:
				sacrifice_specs_ui.append({"t": m.effect_param})
			Module.EffectType.BLANK_TO_CHIPS:
				blank_pip_val_ui  = maxi(blank_pip_val_ui,  m.effect_value)

	# Snapshot every chain tile while they are still on screen.
	# Direct PanelContainer children = tile panels (VBoxContainer = end indicators, Label = arrows).
	var overlay_infos: Array = []
	var chain_tiles: Array = _rm.current_chain.tiles.duplicate()
	var idx: int = 0
	for child in _chain_container.get_children():
		if child is PanelContainer and idx < chain_tiles.size():
			var tile: Domino = chain_tiles[idx]
			var pips: int = tile.total_pips()
			var dw: int = tile.double_weight if tile.double_weight >= 0 \
				else (1 if tile.is_double() else 0)

			# Sacrifice check: if any spec covers this tile, show 0 chips
			var is_sac: bool = false
			if not tile.is_wild:
				for spec in sacrifice_specs_ui:
					if pips <= spec["t"]:
						is_sac = true
						break

			var chips: int = 0
			if is_sac:
				chips = 0   # sacrificed — traded for mult
			elif dw > 0 and tile.is_wild and wild_pip_chips_ui > 0:
				chips = wild_pip_chips_ui
			elif dw > 0:
				chips = pips * double_pip_mult + tile.bonus_chips
			else:
				chips = pips + tile.bonus_chips
				if blank_pip_val_ui > 0 and not tile.is_wild:
					if tile.left  == 0: chips += blank_pip_val_ui
					if tile.right == 0: chips += blank_pip_val_ui

			overlay_infos.append({
				"overlay":    _build_score_overlay(child.global_position, child.size, tile),
				"center":     child.global_position + child.size * 0.5,
				"chips":      chips,
				"is_double":  dw > 0,
				"is_wild":    tile.is_wild,
				"max_pip":    max(tile.left, tile.right),
				"has_blank":  not tile.is_wild and (tile.left == 0 or tile.right == 0),
				"total_pips": pips if not tile.is_wild else 999,
			})
			idx += 1

	# Determine which modules fired so the rack can pulse them
	var has_doubles:      bool = false
	var has_wilds:        bool = false
	var has_blanks:       bool = false
	var max_pip_in_chain: int  = 0
	var min_pips_in_chain: int = 999
	for info in overlay_infos:
		if info["is_double"]: has_doubles = true
		if info["is_wild"]:   has_wilds   = true
		if info["has_blank"]: has_blanks  = true
		max_pip_in_chain  = maxi(max_pip_in_chain,  info["max_pip"])
		min_pips_in_chain = mini(min_pips_in_chain, info["total_pips"])
	var active_ids: Array = _get_active_module_ids(
		has_doubles, _rm.current_chain.length(), has_wilds, max_pip_in_chain,
		has_blanks, min_pips_in_chain)

	_scoring_active = true
	_run_scoring_sequence(overlay_infos, result, _rm.chronos, active_ids)
	_refresh_hud()
	_refresh_directives()

func _on_directive_completed(directive: Directive, earned: int) -> void:
	# Flash the last-hand label briefly to show directive reward
	_lbl_last_hand.text += "   |   Directive: +%d Monedas" % earned

func _on_round_ended(won: bool) -> void:
	_end_round(won)

func _on_tile_left_click(index: int) -> void:
	if _phase != Phase.PLAYING or _scoring_active:
		return
	# Toggle selection (Balatro-style: click to select/deselect, Play acts on selection)
	if index in _selected_tiles:
		_selected_tiles.erase(index)
	else:
		_selected_tiles.append(index)
	_refresh_tile_visuals()
	_refresh_chain_display()
	_refresh_action_buttons()

func _on_play_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active or _selected_tiles.is_empty():
		return
	if _rm.hands_remaining <= 0:
		return

	# Validate: preview chain must include all selected tiles in a legal sequence
	var preview := Chain.new()
	var tiles_to_play: Array = []
	for idx in _selected_tiles:
		if idx < _rm.hand.size():
			var t: Domino = _rm.hand[idx]
			if not preview.add(t):
				return   # invalid sequence — shouldn't normally happen if visuals are right
			tiles_to_play.append(t)
	if preview.is_empty():
		return

	# Batch-add to real chain (guards suppress intermediate chain_changed / hand_changed)
	_building_chain = true
	for tile in tiles_to_play:
		var cur_idx: int = _rm.hand.find(tile)
		if cur_idx >= 0:
			_rm.try_add_to_chain(cur_idx)
	_building_chain = false

	# Clear selection WITHOUT refreshing display — _chain_container still shows preview
	# tiles at their correct positions (needed by _on_hand_scored for animation)
	_selected_tiles.clear()

	# Play — fires hand_scored (captures tile positions), then chain_changed, hand_changed
	_rm.play_chain()

func _on_discard_pressed() -> void:
	if _phase == Phase.PLAYING and not _scoring_active \
			and not _selected_tiles.is_empty() and _rm.can_discard():
		_rm.discard(_selected_tiles)
		_selected_tiles.clear()

func _on_undo_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active:
		return
	# Undo = deselect last selected tile (pop from selection order)
	if not _selected_tiles.is_empty():
		_selected_tiles.pop_back()
		_refresh_tile_visuals()
		_refresh_chain_display()
		_refresh_action_buttons()

# ===========================================================================
# Signal handlers — result overlay
# ===========================================================================
func _on_result_action_pressed() -> void:
	if _phase == Phase.ROUND_RESULT:
		_show_shop()

func _on_run_end_pressed() -> void:
	_run_end_overlay.hide()
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

func _on_buy_tile_pressed(index: int) -> void:
	if index in _tile_offers_bought:
		return
	var entry: Dictionary = _tile_offers[index]
	if not GameState.spend_monedas(entry["cost"]):
		return
	# Create a fresh Domino instance (RefCounted has no duplicate())
	var t: Domino = entry["tile"]
	GameState.box.add_tile(Domino.new(t.left, t.right, t.rarity, t.is_wild))
	_tile_offers_bought.append(index)
	_populate_shop()

func _on_toggle_removal(index: int) -> void:
	if index in _removal_selected:
		_removal_selected.erase(index)
	elif _removal_selected.size() < MAX_FREE_REMOVALS:
		_removal_selected.append(index)
	_populate_artisan_tiles()

func _on_confirm_removal_pressed() -> void:
	if _removal_selected.is_empty():
		return
	# Remove in descending index order to avoid shifting issues
	var sorted: Array = _removal_selected.duplicate()
	sorted.sort()
	sorted.reverse()
	for i in sorted:
		if i < _removal_candidates.size():
			GameState.box.remove_tile(_removal_candidates[i])
	_removal_selected.clear()
	# Refresh candidates from the now-smaller box
	_removal_candidates = TileShopManager.generate_removal_candidates(GameState.box, 8)
	_populate_artisan_tiles()

func _on_shop_continue_pressed() -> void:
	# Fade the shop out before navigating
	var et := create_tween().set_parallel(true)
	et.tween_property(_shop_overlay, "modulate:a", 0.0, 0.22)
	et.tween_property(_shop_overlay, "scale", Vector2(0.97, 0.97), 0.22)
	et.chain().tween_callback(func():
		_shop_overlay.hide()
		_shop_overlay.modulate.a = 1.0
		_shop_overlay.scale      = Vector2.ONE
		GameState.advance_round()
		if GameState.is_run_complete():
			_show_run_end(true)
			return
		_start_round()
	)

func _show_run_end(victory: bool) -> void:
	_phase      = Phase.VICTORY if victory else Phase.GAME_OVER
	_ambient_active = false
	_shop_overlay.hide()
	_result_overlay.hide()

	# ── Overlay tint: warm dark for victory, blood red for defeat ────────────
	(_run_end_overlay as ColorRect).color = \
		Color(0.05, 0.04, 0.02, 0.97) if victory else Color(0.07, 0.02, 0.02, 0.97)
	_run_end_overlay.modulate.a = 0.0

	# ── Glyph ────────────────────────────────────────────────────────────────
	var glyph_text: String  = "⬡"  if victory else "⚠"
	var glyph_color: Color  = C_MONEDAS if victory else C_LOSE
	_lbl_run_end_glyph.text = glyph_text
	_lbl_run_end_glyph.add_theme_color_override("font_color", glyph_color)
	_lbl_run_end_glyph.scale = Vector2(0.3, 0.3) if victory else Vector2(1.0, 1.0)
	_lbl_run_end_glyph.modulate.a = 0.0

	# ── Title ────────────────────────────────────────────────────────────────
	var title_text: String  = "THE CHRONOMETER STABILIZES" if victory else "REINITIALIZING PROTOCOL"
	var title_color: Color  = C_MONEDAS if victory else C_LOSE
	_lbl_run_end_title.text = ""   # will be typewritten
	_lbl_run_end_title.add_theme_color_override("font_color", title_color)
	_lbl_run_end_title.modulate.a = 0.0

	# ── Sub line ─────────────────────────────────────────────────────────────
	_lbl_run_end_sub.text = \
		"Entropy contained. The age persists." if victory else \
		"The Chronometer cannot be recovered."
	_lbl_run_end_sub.modulate.a = 0.0

	# ── Stats ─────────────────────────────────────────────────────────────────
	for child in _run_end_stats_col.get_children():
		child.queue_free()

	var rounds_done: int  = GameState.round_index
	var total_rounds: int = GameState.total_rounds()
	var stat_lines: Array = [
		["Rounds completed",  "%d / %d" % [rounds_done, total_rounds]],
		["Total Chronos",     "%d"       % GameState.total_chronos],
		["Best single Pulse", "%d"       % GameState.best_hand],
		["Hands played",      "%d"       % GameState.hands_played],
		["Core",              Constants.CORE_NAMES[GameState.chosen_core]],
		["Protocol",          Constants.PROTOCOL_NAMES[GameState.chosen_protocol]],
	]
	if not GameState.modules.is_empty():
		var names: Array = GameState.modules.map(func(m): return m.display_name)
		stat_lines.append(["Modules", ", ".join(names)])

	var stat_labels: Array = []
	for pair in stat_lines:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.modulate.a = 0.0
		_run_end_stats_col.add_child(row)

		var key_lbl := _make_label(pair[0] + ":", C_DIM, 14)
		key_lbl.custom_minimum_size = Vector2(200, 0)
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(key_lbl)

		var val_color := C_TEXT if victory else C_DIM.lerp(C_TEXT, 0.5)
		var val_lbl := _make_label(pair[1], val_color, 14)
		val_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		val_lbl.custom_minimum_size = Vector2(320, 0)
		row.add_child(val_lbl)

		stat_labels.append(row)

	# ── Progress bar (defeat only) ────────────────────────────────────────────
	_run_end_progress_bar.visible = not victory
	_run_end_progress_bar.value   = 0
	_run_end_progress_bar.modulate.a = 0.0 if not victory else 0.0
	_run_end_progress_lbl.visible = not victory
	_run_end_progress_lbl.modulate.a = 0.0

	# ── Button ────────────────────────────────────────────────────────────────
	_btn_run_end.text = "NEW TRIAL CYCLE  →"
	_btn_run_end.modulate.a = 0.0
	_btn_run_end.disabled   = true

	_run_end_overlay.show()

	# ════════════════════════════════════════════════════════════════════════
	# CINEMATIC SEQUENCE
	# ════════════════════════════════════════════════════════════════════════
	var seq := create_tween()

	if victory:
		# ── VICTORY SEQUENCE ──────────────────────────────────────────────
		# 1. Background fades in softly
		seq.tween_property(_run_end_overlay, "modulate:a", 1.0, 0.40)

		# 2. Glyph bounces in (scale 0.3 → 1.0 with BACK ease)
		seq.tween_callback(func():
			_lbl_run_end_glyph.pivot_offset = _lbl_run_end_glyph.size * 0.5
		)
		seq.tween_property(_lbl_run_end_glyph, "modulate:a", 1.0, 0.05)
		seq.parallel().tween_property(_lbl_run_end_glyph, "scale",
			Vector2(1.0, 1.0), 0.50).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		seq.tween_interval(0.15)

		# 3. Title typewriters in
		seq.tween_callback(func(): _lbl_run_end_title.modulate.a = 1.0)
		for i in range(1, title_text.length() + 1):
			var n: int = i
			seq.tween_callback(func(): _lbl_run_end_title.text = title_text.substr(0, n))
			seq.tween_interval(0.04)

		# 4. Sub line fades in
		seq.tween_interval(0.12)
		seq.tween_property(_lbl_run_end_sub, "modulate:a", 1.0, 0.45)
		seq.tween_interval(0.10)

		# 5. Stats stagger in one by one
		for row in stat_labels:
			var r: Control = row
			seq.tween_callback(func(): r.modulate.a = 1.0)
			seq.tween_interval(0.08)

		# 6. Button pulses in — then keeps gently glowing
		seq.tween_interval(0.20)
		seq.tween_callback(func(): _btn_run_end.disabled = false)
		seq.tween_property(_btn_run_end, "modulate:a", 1.0, 0.45)

		# 7. Spawn golden drift particles in background
		seq.tween_callback(func(): _spawn_victory_particles())

	else:
		# ── DEFEAT SEQUENCE ───────────────────────────────────────────────
		# 1. Background cuts in fast
		seq.tween_property(_run_end_overlay, "modulate:a", 1.0, 0.18)

		# 2. Glyph glitches in (flicker then settle)
		seq.tween_callback(func():
			_lbl_run_end_glyph.modulate.a = 1.0
			_lbl_run_end_glyph.text = _glitch_text("WARN")
		)
		for _gi in range(4):
			seq.tween_interval(0.09)
			seq.tween_callback(func(): _lbl_run_end_glyph.text = _glitch_text("WARN"))
		seq.tween_interval(0.09)
		seq.tween_callback(func(): _lbl_run_end_glyph.text = glyph_text)

		# 3. Title: glitch scramble → typewriter
		seq.tween_interval(0.10)
		seq.tween_callback(func():
			_lbl_run_end_title.modulate.a = 1.0
			_lbl_run_end_title.text = _glitch_text(title_text)
		)
		for _gi in range(3):
			seq.tween_interval(0.08)
			seq.tween_callback(func(): _lbl_run_end_title.text = _glitch_text(title_text))
		seq.tween_interval(0.10)
		for i in range(1, title_text.length() + 1):
			var n: int = i
			seq.tween_callback(func(): _lbl_run_end_title.text = title_text.substr(0, n))
			seq.tween_interval(0.06)

		# 4. Sub line
		seq.tween_interval(0.15)
		seq.tween_property(_lbl_run_end_sub, "modulate:a", 1.0, 0.35)

		# 5. Stats appear as a group (no individual stagger — more oppressive)
		seq.tween_interval(0.20)
		for row in stat_labels:
			var r: Control = row
			r.modulate.a = 0.0
		seq.tween_callback(func():
			for row in stat_labels:
				row.modulate.a = 1.0
		)

		# 6. Progress bar: "REBOOTING OPERATOR INTERFACE"
		seq.tween_interval(0.30)
		seq.tween_property(_run_end_progress_lbl, "modulate:a", 1.0, 0.20)
		seq.tween_property(_run_end_progress_bar, "modulate:a", 1.0, 0.20)
		seq.tween_callback(func():
			var bt := create_tween()
			bt.tween_property(_run_end_progress_bar, "value", 100.0, 2.0) \
				.set_trans(Tween.TRANS_LINEAR)
		)
		seq.tween_interval(2.10)

		# 7. Button appears after reboot completes
		seq.tween_callback(func(): _btn_run_end.disabled = false)
		seq.tween_property(_btn_run_end, "modulate:a", 1.0, 0.35)

		# 8. Start corruption flashes
		seq.tween_callback(func(): _start_defeat_corruption())

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

	if GameState.is_boss_round():
		_populate_artisan_tiles()

func _populate_artisan_tiles() -> void:
	# --- Tile offers ---
	for child in _tile_offers_row.get_children():
		child.queue_free()
	for i in range(_tile_offers.size()):
		_tile_offers_row.add_child(_build_tile_offer_card(i, _tile_offers[i]))

	# --- Removal candidates ---
	for child in _tile_removal_row.get_children():
		child.queue_free()
	for i in range(_removal_candidates.size()):
		_tile_removal_row.add_child(_build_removal_tile(i, _removal_candidates[i]))

	var left: int = MAX_FREE_REMOVALS - _removal_selected.size()
	_lbl_removals_left.text = "%d removal%s remaining (free)" % [
		left, "" if left == 1 else "s"]
	_btn_confirm_removal.disabled = _removal_selected.is_empty()

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

	# Tooltip — lore text and full description on hover
	_add_module_tooltip(panel, m)
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

	# Tooltip — lore and full description on hover
	_add_module_tooltip(panel, m)
	return panel

# ===========================================================================
# Gameplay UI refresh
# ===========================================================================
func _refresh_hud() -> void:
	_lbl_round.text   = GameState.round_display()
	_lbl_etapa.text   = GameState.etapa_name()
	_lbl_monedas.text = "Monedas: %d" % GameState.monedas

	# Chronos bar — skipped during scoring animation (animation drives the fill)
	if not _scoring_active:
		var t: int = _rm.target if _rm != null else 1
		var c: int = _rm.chronos if _rm != null else 0
		_set_chronos_bar(c, t)

	# Hands dots
	for ch in _hands_dot_row.get_children(): ch.queue_free()
	var hands_color := Color(0.7, 0.8, 1.0)
	var last_hand := _rm.hands_remaining == 1 and not _rm.did_win()
	for i in range(_rm.max_hands):
		var filled := i < _rm.hands_remaining
		_hands_dot_row.add_child(_make_hud_dot(
			filled, C_LOSE if (last_hand and filled) else hands_color))

	# Discards dots
	for ch in _discards_dot_row.get_children(): ch.queue_free()
	for i in range(_rm.max_discards):
		_discards_dot_row.add_child(
			_make_hud_dot(i < _rm.discards_remaining, Color(0.8, 0.7, 1.0)))

## Build a preview Chain from the current selection (in click order).
## Stops at the first tile that fails to connect — partial chains are valid previews.
func _build_preview_chain() -> Chain:
	var preview := Chain.new()
	for idx in _selected_tiles:
		if idx < _rm.hand.size():
			if not preview.add(_rm.hand[idx]):
				break
	return preview

func _refresh_chain_display() -> void:
	_kill_chain_idle_tweens()
	for child in _chain_container.get_children():
		child.queue_free()

	var preview := _build_preview_chain()

	if preview.is_empty():
		var lbl := _make_label("Select tiles to build a chain", C_DIM, 14)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_chain_container.add_child(lbl)
	else:
		# Left connection port
		_chain_container.add_child(
			_build_chain_end_indicator(preview.left_end, true))

		for i in range(preview.tile_displays.size()):
			if i > 0:
				var arr := _make_label("→", C_DIM, 16)
				arr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				_chain_container.add_child(arr)
			var d: Vector2i = preview.tile_displays[i]
			_chain_container.add_child(_build_chain_tile(d.x, d.y))

		# Right connection port
		_chain_container.add_child(
			_build_chain_end_indicator(preview.right_end, false))

		# Start idle breathing on each tile panel (random phase so they're independent)
		for child in _chain_container.get_children():
			if child is PanelContainer:
				var idle := _start_tile_breathe(child)
				if idle != null:
					_chain_idle_tweens.append(idle)

	if not preview.is_empty():
		var r: Dictionary = Scoring.calculate(preview, GameState.modules)
		_lbl_preview.text = "%d chips  ×  %d  =  %d Chronos" % [
			r["chips"], r["mult"], r["total"]]
		_refresh_chain_bonus_label(preview.length())
	else:
		_lbl_preview.text = ""
		_lbl_chain_bonus.text = ""

func _refresh_action_buttons() -> void:
	# Preview must be fully valid (all selected tiles connected) to enable Play
	var preview := _build_preview_chain()
	var all_connected: bool = not _selected_tiles.is_empty() \
		and preview.length() == _selected_tiles.size()
	_btn_play.disabled    = not (all_connected and _rm.hands_remaining > 0)
	_btn_discard.disabled = not _rm.can_discard() or _selected_tiles.is_empty()
	_btn_undo.disabled    = _selected_tiles.is_empty()
	_btn_discard.text     = "Discard (%d)" % _selected_tiles.size()

func _rebuild_hand() -> void:
	_selected_tiles.clear()
	for child in _hand_container.get_children():
		child.queue_free()
	_tile_btns.clear()
	_tile_conn_lbls.clear()
	for i in range(_rm.hand.size()):
		var btn := _create_hand_tile(_rm.hand[i], i)
		_hand_container.add_child(btn)
		_tile_btns.append(btn)
	_refresh_tile_visuals()
	_refresh_action_buttons()

func _refresh_directives() -> void:
	if _dm == null:
		return
	for i in range(_directive_labels.size()):
		if i >= _dm.active.size():
			break
		var d: Directive = _dm.active[i]
		var lbl: Label = _directive_labels[i]
		if d.completed:
			lbl.text = "✓ %s  (+%d)" % [d.text, d.reward]
			lbl.add_theme_color_override("font_color", C_WIN)
		else:
			lbl.text = "○ %s  (+%d)" % [d.text, d.reward]
			lbl.add_theme_color_override("font_color", C_DIM)

func _refresh_tile_visuals() -> void:
	# Use the preview chain (built from current selection) for connection arrow logic
	var preview      := _build_preview_chain()
	var preview_empty := preview.is_empty()
	var le := preview.left_end
	var re := preview.right_end

	for i in range(_tile_btns.size()):
		if i >= _rm.hand.size():
			break
		var btn:  Button = _tile_btns[i]
		var tile: Domino = _rm.hand[i]
		var conn: Label  = _tile_conn_lbls[i] if i < _tile_conn_lbls.size() else null

		# Rarity-tinted base border stored on creation
		var base_border := C_TILE_BORDER
		if btn.has_meta("base_border"):
			base_border = btn.get_meta("base_border")

		var sel_order: int = _selected_tiles.find(i)
		if sel_order >= 0:
			# Selected: amber face + bright gold border + order number
			_apply_tile_style(btn, C_TILE_FACE_SEL, C_TILE_FACE_SEL, C_TILE_BORDER_SEL)
			if conn:
				conn.text = str(sel_order + 1)
				conn.add_theme_color_override("font_color", C_TILE_BORDER_SEL)
			continue

		# Unselected: show connection arrow relative to current preview end
		if preview.can_add(tile):
			_apply_tile_style(btn, C_TILE_FACE, C_TILE_FACE_HOVER, base_border)
			if conn:
				if preview_empty or tile.is_wild:
					conn.text = "↔"
					conn.add_theme_color_override("font_color", C_WIN)
				else:
					var fl := _tile_fits_left(tile, le)
					var fr := _tile_fits_right(tile, re)
					if fl and fr:
						conn.text = "↔"
					elif fl:
						conn.text = "←"
					else:
						conn.text = "→"
					conn.add_theme_color_override("font_color", C_WIN)
		else:
			_apply_tile_style(btn, C_TILE_FACE_DIM, C_TILE_FACE_DIM,
					base_border.darkened(0.42))
			if conn:
				conn.text = "·"
				conn.add_theme_color_override("font_color", C_DIM)

# ===========================================================================
# Domino tile widgets
# ===========================================================================
func _create_hand_tile(tile: Domino, index: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(88, 148)
	btn.text = ""
	btn.clip_contents = true

	# ── Inner layout inset from button edges so the dark body shows as a frame ──
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   = 4;  vbox.offset_top    = 4
	vbox.offset_right  = -4; vbox.offset_bottom = -4
	vbox.add_theme_constant_override("separation", 0)
	btn.add_child(vbox)

	# ── Top pip-half panel ──
	var top_panel := PanelContainer.new()
	top_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var top_dot := C_TITLE_GLOW if tile.left < 0 else C_PIP_DOT
	top_panel.add_child(_make_pip_display(tile.left, 15, top_dot))
	vbox.add_child(top_panel)
	btn.set_meta("top_panel", top_panel)

	# Rarity / custom name strip (between pip halves, narrow)
	if tile.custom_name != "":
		var name_lbl := Label.new()
		name_lbl.text = tile.custom_name
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", C_RARITY[tile.rarity])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.clip_contents = true
		vbox.add_child(name_lbl)

	# ── Divider ──
	vbox.add_child(_make_tile_hsep())

	# ── Bottom pip-half panel ──
	var bot_panel := PanelContainer.new()
	bot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bot_dot := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	bot_panel.add_child(_make_pip_display(tile.right, 15, bot_dot))
	vbox.add_child(bot_panel)
	btn.set_meta("bot_panel", bot_panel)

	# ── Connection / selection indicator (bottom strip) ──
	var conn_lbl := _make_label("", C_DIM, 12)
	conn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	conn_lbl.custom_minimum_size  = Vector2(0, 16)
	vbox.add_child(conn_lbl)
	_tile_conn_lbls.append(conn_lbl)

	# ── Rarity-tinted border: subtle identity per tile grade ──
	var base_border: Color
	match tile.rarity:
		Constants.Rarity.CARVED:   base_border = C_TILE_BORDER.lerp(Color(0.30, 0.72, 0.30), 0.22)
		Constants.Rarity.IVORY:    base_border = C_TILE_BORDER.lerp(Color(0.90, 0.82, 0.28), 0.30)
		Constants.Rarity.OBSIDIAN: base_border = C_TILE_BORDER.lerp(Color(0.60, 0.28, 0.92), 0.32)
		_:                         base_border = C_TILE_BORDER   # BONE: plain brass
	if tile.is_wild:
		base_border = C_TITLE_GLOW   # wilds always shine gold
	btn.set_meta("base_border", base_border)

	# Apply full style (outer frame + pip-half faces)
	_apply_tile_style(btn, C_TILE_FACE, C_TILE_FACE_HOVER, base_border)

	# All children must be transparent so the Button receives clicks
	_ignore_mouse(vbox)

	btn.pressed.connect(_on_tile_left_click.bind(index))
	return btn

func _build_chain_tile(disp_left: int, disp_right: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(78, 140)

	# Dark ebony outer frame — content_margin creates the inner inset
	var style := StyleBoxFlat.new()
	style.bg_color    = C_TILE_BODY
	style.border_color = C_TILE_BORDER
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.40); style.shadow_size = 3
	style.set_content_margin_all(4)
	panel.add_theme_stylebox_override("panel", style)
	# Store style ref so _start_tile_breathe can animate the border
	panel.set_meta("border_style",      style)
	panel.set_meta("base_border_color", C_TILE_BORDER)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	# Top pip-half panel
	var top_panel := PanelContainer.new()
	top_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(top_panel, C_TILE_FACE, true)
	var top_dot := C_TITLE_GLOW if disp_left < 0 else C_PIP_DOT
	top_panel.add_child(_make_pip_display(disp_left, 13, top_dot))
	vbox.add_child(top_panel)

	vbox.add_child(_make_tile_hsep())

	# Bottom pip-half panel
	var bot_panel := PanelContainer.new()
	bot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bot_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(bot_panel, C_TILE_FACE, false)
	var bot_dot := C_TITLE_GLOW if disp_right < 0 else C_PIP_DOT
	bot_panel.add_child(_make_pip_display(disp_right, 13, bot_dot))
	vbox.add_child(bot_panel)

	return panel

## Build a pip-dot display for one half of a domino.
## dot_size: diameter of each dot in pixels.
## dot_color: fill color of the dots.
func _make_pip_display(pip: int, dot_size: int, dot_color: Color) -> Control:
	if pip < 0:
		# Wild — show a star label
		var lbl := Label.new()
		lbl.text = "★"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", dot_size + 8)
		lbl.add_theme_color_override("font_color", dot_color)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		return lbl

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	# Centre the grid within its parent
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical   = Control.SIZE_SHRINK_CENTER

	var positions: Array = PIP_POSITIONS[clampi(pip, 0, 9)]
	for cell in range(9):
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(dot_size, dot_size)
		if cell in positions:
			var dot := PanelContainer.new()
			dot.custom_minimum_size = Vector2(dot_size, dot_size)
			var s := StyleBoxFlat.new()
			s.bg_color = dot_color
			s.set_corner_radius_all(dot_size / 2)
			dot.add_theme_stylebox_override("panel", s)
			slot.add_child(dot)
			dot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		grid.add_child(slot)

	# Wrap in a container that expands to fill its parent and centres the grid
	var wrap := CenterContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	wrap.add_child(grid)
	return wrap

# ===========================================================================
# Etapa visual theme
# ===========================================================================
func _apply_etapa_theme(etapa: int) -> void:
	var e := clampi(etapa, 0, 3)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_bg_rect,    "color",    Constants.ETAPA_BG[e],    0.6)
	tween.tween_method(func(c: Color): _table_style.bg_color     = c,
		_table_style.bg_color,     Constants.ETAPA_TABLE[e],        0.6)
	tween.tween_method(func(c: Color): _table_style.border_color = c,
		_table_style.border_color, Constants.ETAPA_TABLE_BORDER[e], 0.6)
	tween.tween_method(func(c: Color): _hud_style.bg_color       = c,
		_hud_style.bg_color,       Constants.ETAPA_PANEL[e],        0.6)
	tween.tween_method(func(c: Color): _hand_panel_style.bg_color = c,
		_hand_panel_style.bg_color, Constants.ETAPA_PANEL[e],       0.6)
	# Accent: etapa label + table title
	var accent: Color = Constants.ETAPA_ACCENT[e]
	_lbl_etapa.add_theme_color_override("font_color", accent)
	_lbl_table_title.add_theme_color_override("font_color", accent)

# ===========================================================================
# Keyboard shortcuts
# ===========================================================================
func _unhandled_input(event: InputEvent) -> void:
	if _phase != Phase.PLAYING:
		return
	if not (event is InputEventKey) or not (event as InputEventKey).pressed:
		return
	if _scoring_active:
		return
	match (event as InputEventKey).keycode:
		KEY_SPACE, KEY_ENTER:
			_on_play_pressed()
		KEY_U:
			_on_undo_pressed()
		KEY_D:
			if not _selected_tiles.is_empty() and _rm.can_discard():
				_rm.discard(_selected_tiles)
				_selected_tiles.clear()
		KEY_ESCAPE:
			if not _selected_tiles.is_empty():
				_selected_tiles.clear()
				_refresh_tile_visuals()
				_refresh_chain_display()
				_refresh_action_buttons()

## Recursively set MOUSE_FILTER_IGNORE on a node and all its Control children,
## so mouse events pass through to the parent Button unobstructed.
func _ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)

func _make_tile_hsep() -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_DIVIDER
	sep.custom_minimum_size   = Vector2(0, 4)
	sep.size_flags_horizontal = Control.SIZE_FILL
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sep

func _make_tile_vsep() -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_DIVIDER
	sep.custom_minimum_size  = Vector2(2, 0)
	sep.size_flags_vertical  = Control.SIZE_FILL
	return sep

## Set the face of one pip half-panel (top or bottom).
## When _tile_face_tex is loaded: uses StyleBoxTexture + per-channel modulate
## so the parchment grain shows through every state (dim, selected, hover).
## Falls back to a flat StyleBoxFlat when no texture is available.
func _set_pip_panel_face(panel: PanelContainer, face: Color, is_top: bool) -> void:
	if _tile_face_tex != null:
		# ── Texture mode ──────────────────────────────────────────────────────
		# Only create the StyleBoxTexture once; subsequent calls just modulate.
		if not panel.has_theme_stylebox_override("panel") \
				or not (panel.get_theme_stylebox("panel") is StyleBoxTexture):
			var s := StyleBoxTexture.new()
			s.texture = _tile_face_tex
			s.set_content_margin_all(5)
			panel.add_theme_stylebox_override("panel", s)
		# Scale the texture colour toward the requested face colour per-channel.
		# face == C_TILE_FACE  → modulate = white  (texture shown as-is)
		# face == C_TILE_FACE_DIM  → darkens + desaturates naturally
		# face == C_TILE_FACE_SEL  → warms/ambers it
		panel.modulate = Color(
			clampf(face.r / C_TILE_FACE.r, 0.0, 2.0),
			clampf(face.g / C_TILE_FACE.g, 0.0, 2.0),
			clampf(face.b / C_TILE_FACE.b, 0.0, 2.0),
			1.0)
	else:
		# ── Flat colour fallback ───────────────────────────────────────────────
		var s := StyleBoxFlat.new()
		s.bg_color = face; s.set_content_margin_all(4)
		if is_top:
			s.corner_radius_top_left    = 4; s.corner_radius_top_right    = 4
			s.corner_radius_bottom_left = 0; s.corner_radius_bottom_right = 0
		else:
			s.corner_radius_top_left    = 0; s.corner_radius_top_right    = 0
			s.corner_radius_bottom_left = 4; s.corner_radius_bottom_right = 4
		panel.add_theme_stylebox_override("panel", s)

## Style a hand-tile Button: dark ebony frame, thick brass border, drop shadow.
## face / hover  — ivory face colour used for the inner pip-half panels.
## border        — border colour; defaults to standard brass, pass C_TILE_BORDER_SEL
##                 for the selected state or a rarity-tinted colour for flavour.
func _apply_tile_style(btn: Button, face: Color, hover: Color,
		border: Color = C_TILE_BORDER) -> void:
	var shadow := Color(0.0, 0.0, 0.0, 0.42)

	for n in ["normal", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color    = C_TILE_BODY
		s.border_color = border
		s.set_border_width_all(3); s.set_corner_radius_all(8)
		s.shadow_color = shadow; s.shadow_size = 4
		btn.add_theme_stylebox_override(n, s)

	var sh := StyleBoxFlat.new()
	sh.bg_color    = C_TILE_BODY.lightened(0.08)
	sh.border_color = border.lightened(0.28)
	sh.set_border_width_all(3); sh.set_corner_radius_all(8)
	sh.shadow_color = shadow; sh.shadow_size = 5
	btn.add_theme_stylebox_override("hover", sh)

	var sp := StyleBoxFlat.new()
	sp.bg_color    = C_TILE_BODY.darkened(0.08)
	sp.border_color = border
	sp.set_border_width_all(3); sp.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("pressed", sp)

	# Update inner pip-half panels (hand tiles store refs in meta)
	if btn.has_meta("top_panel"):
		_set_pip_panel_face(btn.get_meta("top_panel"), face, true)
	if btn.has_meta("bot_panel"):
		_set_pip_panel_face(btn.get_meta("bot_panel"), face, false)

# ===========================================================================
# UI construction
# ===========================================================================
func _build_ui() -> void:
	# Load tile face texture (graceful fallback to flat colour if missing)
	const TILE_TEX_PATH := "res://assets/tile.png"
	if ResourceLoader.exists(TILE_TEX_PATH):
		_tile_face_tex = load(TILE_TEX_PATH)

	_bg_rect = ColorRect.new()
	_bg_rect.color = C_BG
	_bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg_rect)

	_ui_layer = CanvasLayer.new()
	var ui: CanvasLayer = _ui_layer
	add_child(ui)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	ui.add_child(root)

	root.add_theme_constant_override("separation", 0)
	root.add_child(_build_hud())
	root.add_child(_build_table_area())
	root.add_child(_build_hand_zone())

	_result_overlay = _build_result_overlay()
	ui.add_child(_result_overlay)
	_result_overlay.hide()

	_shop_overlay = _build_shop_overlay()
	ui.add_child(_shop_overlay)
	_shop_overlay.hide()

	_boss_overlay = _build_boss_overlay()
	ui.add_child(_boss_overlay)
	_boss_overlay.hide()

	_tile_removal_overlay = _build_tile_removal_overlay()
	ui.add_child(_tile_removal_overlay)
	_tile_removal_overlay.hide()

	_run_end_overlay = _build_run_end_overlay()
	ui.add_child(_run_end_overlay)
	_run_end_overlay.hide()

	_title_overlay = _build_title_overlay()
	ui.add_child(_title_overlay)

	# Etapa transition — added LAST so it renders over everything
	_etapa_transition_overlay = _build_etapa_transition_overlay()
	ui.add_child(_etapa_transition_overlay)
	_etapa_transition_overlay.hide()

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

	# Tooltip — last child so it renders on top of every overlay
	_tooltip_panel = _build_tooltip_panel()
	ui.add_child(_tooltip_panel)
	_tooltip_panel.hide()

# ---- HUD ----
func _build_hud() -> Control:
	var panel := PanelContainer.new()
	_hud_style = StyleBoxFlat.new()
	_hud_style.bg_color = C_PANEL
	panel.add_theme_stylebox_override("panel", _hud_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	# ── Section 1: Round + Etapa ──────────────────────────
	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 2)
	left_vbox.custom_minimum_size = Vector2(130, 0)
	left_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(left_vbox)
	_lbl_round = _make_label("Round 1 / 15", C_TEXT, 13)
	_lbl_etapa = _make_label("Mahogany", C_DIM, 11)
	left_vbox.add_child(_lbl_round)
	left_vbox.add_child(_lbl_etapa)

	hbox.add_child(_make_vdiv())

	# ── Section 2: Chronos progress bar (dominant) ────────
	var bar_col := VBoxContainer.new()
	bar_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_col.add_theme_constant_override("separation", 3)
	bar_col.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(bar_col)

	var bar_title := _make_label("CHRONOS", C_DIM, 10)
	bar_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar_col.add_child(bar_title)

	# Stacked: ProgressBar behind a centred label
	var bar_wrap := Control.new()
	bar_wrap.custom_minimum_size = Vector2(0, 22)
	bar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_col.add_child(bar_wrap)

	_chronos_bar = ProgressBar.new()
	_chronos_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chronos_bar.min_value = 0
	_chronos_bar.max_value = 100
	_chronos_bar.value     = 0
	_chronos_bar.show_percentage = false
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.08, 0.07, 0.05)
	bar_bg.set_corner_radius_all(4)
	_chronos_bar.add_theme_stylebox_override("background", bar_bg)
	_chronos_bar_fill_style = StyleBoxFlat.new()
	_chronos_bar_fill_style.bg_color = C_CHRONOS.darkened(0.3)
	_chronos_bar_fill_style.set_corner_radius_all(4)
	_chronos_bar.add_theme_stylebox_override("fill", _chronos_bar_fill_style)
	bar_wrap.add_child(_chronos_bar)

	_chronos_bar_lbl = _make_label("0 / 0", C_TEXT, 12)
	_chronos_bar_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chronos_bar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chronos_bar_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_chronos_bar_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_wrap.add_child(_chronos_bar_lbl)

	hbox.add_child(_make_vdiv())

	# ── Section 3: Hands + Discards dot indicators ────────
	var counts_col := VBoxContainer.new()
	counts_col.add_theme_constant_override("separation", 5)
	counts_col.alignment = BoxContainer.ALIGNMENT_CENTER
	counts_col.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(counts_col)

	var h_row := HBoxContainer.new()
	h_row.add_theme_constant_override("separation", 6)
	h_row.alignment = BoxContainer.ALIGNMENT_CENTER
	counts_col.add_child(h_row)
	h_row.add_child(_make_label("HANDS", C_DIM, 10))
	_hands_dot_row = HBoxContainer.new()
	_hands_dot_row.add_theme_constant_override("separation", 4)
	h_row.add_child(_hands_dot_row)

	var d_row := HBoxContainer.new()
	d_row.add_theme_constant_override("separation", 6)
	d_row.alignment = BoxContainer.ALIGNMENT_CENTER
	counts_col.add_child(d_row)
	d_row.add_child(_make_label("DISC", C_DIM, 10))
	_discards_dot_row = HBoxContainer.new()
	_discards_dot_row.add_theme_constant_override("separation", 4)
	d_row.add_child(_discards_dot_row)

	hbox.add_child(_make_vdiv())

	# ── Section 4: Monedas ────────────────────────────────
	_lbl_monedas = _make_label("Monedas: 0", C_MONEDAS, 14)
	_lbl_monedas.custom_minimum_size = Vector2(120, 0)
	_lbl_monedas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_monedas.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(_lbl_monedas)

	return panel

# ---- Table area (dominant game surface — expands to fill) ----
func _build_table_area() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_table_style = StyleBoxFlat.new()
	_table_style.bg_color     = Color(0.07, 0.09, 0.06)
	_table_style.border_color = Color(0.28, 0.24, 0.14)
	_table_style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", _table_style)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Top label
	_lbl_table_title = _make_label("COHESION PULSE", C_DIM, 11)
	_lbl_table_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_table_title)

	# Spacer pushes chain to vertical centre
	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(top_spacer)

	# Chain tiles — centred horizontally, shrinks vertically to tile height
	_chain_container = HBoxContainer.new()
	_chain_container.alignment             = BoxContainer.ALIGNMENT_CENTER
	_chain_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chain_container.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	_chain_container.add_theme_constant_override("separation", 10)
	vbox.add_child(_chain_container)

	# Score preview sits just below the chain
	_lbl_preview = _make_label("", C_PREVIEW, 16)
	_lbl_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_preview)

	# Chain-length milestone hint  e.g. "2 more for +1 Mult  ·  5 more for +2 Mult"
	_lbl_chain_bonus = _make_label("", C_DIM, 12)
	_lbl_chain_bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_chain_bonus)

	# Spacer below keeps last-hand result pinned to the bottom
	var bot_spacer := Control.new()
	bot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(bot_spacer)

	# Last-hand result — pinned at bottom of table
	_lbl_last_hand = _make_label("", C_LAST_HAND, 14)
	_lbl_last_hand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_last_hand)

	return panel

# ---- Hand zone (fixed at bottom, contains directives + tiles + controls) ----
func _build_hand_zone() -> Control:
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 0)

	# Directives bar sits at top of this zone
	_directives_panel = _build_directives_panel()
	outer.add_child(_directives_panel)

	# Module rack — compact cards showing equipped modules during play
	_module_rack_panel = _build_module_rack_panel()
	outer.add_child(_module_rack_panel)

	# Hand panel
	var hand_panel := PanelContainer.new()
	_hand_panel_style = StyleBoxFlat.new()
	_hand_panel_style.bg_color = C_PANEL
	hand_panel.add_theme_stylebox_override("panel", _hand_panel_style)
	outer.add_child(hand_panel)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	hand_panel.add_child(inner)

	var hand_title := _make_label("ISOLATION CHAMBER", C_DIM, 11)
	hand_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(hand_title)

	_hand_container = HBoxContainer.new()
	_hand_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_hand_container.add_theme_constant_override("separation", 10)
	_hand_container.custom_minimum_size = Vector2(0, 152)
	inner.add_child(_hand_container)

	inner.add_child(_build_action_bar())

	var hint := _make_label(
		"Click → chain   Right-click → discard   Space → play   U → undo   Esc → clear",
		C_DIM, 11)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(hint)

	return outer

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
	panel.custom_minimum_size = Vector2(560, 0)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.09, 0.07, 0.98)
	style.border_color = Color(0.5, 0.45, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	_lbl_result = _make_label("", C_WIN, 26)
	_lbl_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_result)
	vbox.add_child(_make_hsep())
	_lbl_result_sub = _make_label("", C_TEXT, 14)
	_lbl_result_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_lbl_result_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_result_sub.custom_minimum_size = Vector2(480, 0)
	vbox.add_child(_lbl_result_sub)
	vbox.add_child(_make_hsep())
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

	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_col.add_theme_constant_override("separation", 4)
	header.add_child(title_col)
	_lbl_shop_title = _make_label("THE BRASS EMPORIUM", C_TEXT, 22)
	title_col.add_child(_lbl_shop_title)
	_lbl_shop_greeting = _make_label("", C_DIM, 13)
	_lbl_shop_greeting.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_col.add_child(_lbl_shop_greeting)

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

	# --- Artisan-only section ---
	_artisan_section = _build_artisan_section()
	vbox.add_child(_artisan_section)
	_artisan_section.hide()

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(btn_row)
	btn_row.add_child(
		_make_button("CONTINUE TO NEXT ROUND  →", _on_shop_continue_pressed,
			Vector2(260, 50))
	)

	return overlay

func _build_artisan_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	vbox.add_child(_make_hsep())

	# --- Tile acquisition ---
	var acq_title := _make_label("TILE ACQUISITION", C_TITLE_GLOW, 14)
	vbox.add_child(acq_title)

	var acq_sub := _make_label(
		"Purchase tiles permanently added to your box.", C_DIM, 12)
	vbox.add_child(acq_sub)

	_tile_offers_row = HBoxContainer.new()
	_tile_offers_row.add_theme_constant_override("separation", 14)
	_tile_offers_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_child(_tile_offers_row)

	vbox.add_child(_make_hsep())

	# --- Tile removal ---
	var rem_title := _make_label("TILE REMOVAL", C_TITLE_GLOW, 14)
	vbox.add_child(rem_title)

	var rem_sub := _make_label(
		"Permanently remove tiles from your box to sharpen your draw pool.", C_DIM, 12)
	vbox.add_child(rem_sub)

	_tile_removal_row = HBoxContainer.new()
	_tile_removal_row.add_theme_constant_override("separation", 8)
	_tile_removal_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_child(_tile_removal_row)

	var rem_footer := HBoxContainer.new()
	rem_footer.add_theme_constant_override("separation", 16)
	vbox.add_child(rem_footer)

	_lbl_removals_left = _make_label("2 removals remaining (free)", C_MONEDAS, 13)
	_lbl_removals_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rem_footer.add_child(_lbl_removals_left)

	_btn_confirm_removal = _make_button(
		"REMOVE SELECTED", _on_confirm_removal_pressed, Vector2(190, 42))
	_btn_confirm_removal.disabled = true
	rem_footer.add_child(_btn_confirm_removal)

	return vbox

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

# ---- Directives panel ----
func _build_directives_panel() -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.09, 0.07, 0.80)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(hbox)

	var title_lbl := _make_label("DIRECTIVES:", C_DIM, 12)
	hbox.add_child(title_lbl)

	_directive_labels.clear()
	for i in range(2):
		var lbl := _make_label("", C_DIM, 12)
		hbox.add_child(lbl)
		_directive_labels.append(lbl)

	return panel

# ---- Boss warning overlay (cinematic) ----
func _build_boss_overlay() -> Control:
	# Pure black — the cinematic backdrop
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.96)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 22)
	vbox.custom_minimum_size = Vector2(600, 0)
	center.add_child(vbox)

	# ── Warning header ───────────────────────────────────────
	_lbl_boss_warning = _make_label("⚠   CORRUPTION DETECTED   ⚠", C_LOSE, 13)
	_lbl_boss_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_boss_warning.modulate.a = 0.0
	vbox.add_child(_lbl_boss_warning)

	# ── Boss entity name (glitch → typewriter) ────────────────
	_lbl_boss_name = _make_label("", C_LOSE, 42)
	_lbl_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_boss_name.modulate.a = 0.0
	vbox.add_child(_lbl_boss_name)

	# ── Atmospheric lore line ─────────────────────────────────
	_lbl_boss_lore = _make_label("", C_TEXT, 17)
	_lbl_boss_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_boss_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_boss_lore.custom_minimum_size = Vector2(520, 0)
	_lbl_boss_lore.modulate.a = 0.0
	vbox.add_child(_lbl_boss_lore)

	# Thin separator
	var sep := _make_hsep()
	sep.modulate.a = 0.0
	sep.set_meta("is_boss_sep", true)
	vbox.add_child(sep)

	# ── Mechanical effect description ─────────────────────────
	_lbl_boss_desc = _make_label("", C_DIM, 14)
	_lbl_boss_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_boss_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_boss_desc.custom_minimum_size = Vector2(480, 0)
	_lbl_boss_desc.modulate.a = 0.0
	vbox.add_child(_lbl_boss_desc)

	# ── Begin button (appears last, delayed) ──────────────────
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	_boss_begin_btn = _make_button("FACE THE CORRUPTION  →", _on_boss_begin_pressed,
		Vector2(280, 52))
	_boss_begin_btn.modulate.a = 0.0
	btn_row.add_child(_boss_begin_btn)

	return overlay

# ---- Etapa transition cinematic overlay ----
func _build_etapa_transition_overlay() -> Control:
	# Full-screen black backdrop — we animate color:a not modulate so
	# children can have independent modulate values
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Block input while the cinematic plays
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	_etapa_content_vbox = VBoxContainer.new()
	_etapa_content_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_etapa_content_vbox.add_theme_constant_override("separation", 10)
	_etapa_content_vbox.custom_minimum_size = Vector2(580, 0)
	_etapa_content_vbox.modulate.a = 0.0
	center.add_child(_etapa_content_vbox)

	_lbl_etapa_numeral = _make_label("I", C_TITLE_GLOW, 100)
	_lbl_etapa_numeral.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etapa_content_vbox.add_child(_lbl_etapa_numeral)

	_lbl_etapa_name_big = _make_label("MAHOGANY", C_TEXT, 38)
	_lbl_etapa_name_big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etapa_content_vbox.add_child(_lbl_etapa_name_big)

	var sep := _make_hsep()
	sep.custom_minimum_size = Vector2(300, 0)
	_etapa_content_vbox.add_child(sep)

	_lbl_etapa_atmosphere = _make_label("", C_DIM, 16)
	_lbl_etapa_atmosphere.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_etapa_atmosphere.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_etapa_atmosphere.custom_minimum_size = Vector2(460, 0)
	_etapa_content_vbox.add_child(_lbl_etapa_atmosphere)

	return overlay

func _show_etapa_transition(etapa: int) -> void:
	var e := clampi(etapa, 0, 3)
	var accent: Color = Constants.ETAPA_ACCENT[e]

	# Populate content
	_lbl_etapa_numeral.text = ETAPA_ROMAN[e]
	_lbl_etapa_numeral.add_theme_color_override("font_color", accent)
	_lbl_etapa_name_big.text = ETAPA_SHORT_NAMES[e].to_upper()
	_lbl_etapa_name_big.add_theme_color_override("font_color", C_TEXT)
	_lbl_etapa_atmosphere.text = ETAPA_ATMOSPHERE[e]
	_lbl_etapa_atmosphere.add_theme_color_override("font_color", C_DIM.lerp(accent, 0.35))

	# Reset state
	_etapa_transition_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_etapa_content_vbox.modulate.a = 0.0
	_etapa_content_vbox.scale      = Vector2(0.86, 0.86)
	_etapa_transition_overlay.show()

	var seq := create_tween()
	# Set pivot to centre after one frame so size is computed
	seq.tween_callback(func():
		_etapa_content_vbox.pivot_offset = _etapa_content_vbox.size * 0.5
	)
	# Phase 1 — background fades in; content scales + fades in simultaneously
	seq.tween_property(_etapa_transition_overlay, "color:a", 0.88, 0.28)
	seq.parallel().tween_property(_etapa_content_vbox, "modulate:a", 1.0, 0.38)
	seq.parallel().tween_property(_etapa_content_vbox, "scale",
		Vector2(1.0, 1.0), 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Hold at full opacity
	seq.tween_interval(1.20)
	# Phase 2 — fade everything out
	seq.tween_property(_etapa_transition_overlay, "color:a", 0.0, 0.42)
	seq.parallel().tween_property(_etapa_content_vbox, "modulate:a", 0.0, 0.42)
	seq.tween_callback(_etapa_transition_overlay.hide)

# ---- Artisan tile offer card ----
func _build_tile_offer_card(index: int, entry: Dictionary) -> Control:
	var t: Domino   = entry["tile"]
	var cost: int   = entry["cost"]
	var bought: bool = index in _tile_offers_bought

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(140, 0)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.11, 0.10, 0.07)
	style.border_color = C_MONEDAS if not bought else C_DIM
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Pip display (horizontal mini domino)
	var pip_panel := PanelContainer.new()
	pip_panel.custom_minimum_size = Vector2(0, 52)
	var pip_bg := StyleBoxFlat.new()
	pip_bg.bg_color = C_TILE_BODY
	pip_bg.border_color = (C_TITLE_GLOW if t.is_wild else C_RARITY[t.rarity].lerp(C_TILE_BORDER, 0.5))
	pip_bg.set_border_width_all(2)
	pip_bg.set_corner_radius_all(5)
	pip_bg.set_content_margin_all(3)
	pip_panel.add_theme_stylebox_override("panel", pip_bg)
	vbox.add_child(pip_panel)

	var pip_row := HBoxContainer.new()
	pip_row.add_theme_constant_override("separation", 0)
	pip_panel.add_child(pip_row)

	var left_half := PanelContainer.new()
	left_half.custom_minimum_size = Vector2(52, 0)
	left_half.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lhs := StyleBoxFlat.new(); lhs.bg_color = C_TILE_FACE
	lhs.corner_radius_top_left = 3; lhs.corner_radius_bottom_left = 3
	lhs.set_content_margin_all(3)
	left_half.add_theme_stylebox_override("panel", lhs)
	var ld := C_TITLE_GLOW if t.left < 0 else C_PIP_DOT
	left_half.add_child(_make_pip_display(t.left, 10, ld))
	pip_row.add_child(left_half)

	pip_row.add_child(_make_tile_vsep())

	var right_half := PanelContainer.new()
	right_half.custom_minimum_size = Vector2(52, 0)
	right_half.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rhs := StyleBoxFlat.new(); rhs.bg_color = C_TILE_FACE
	rhs.corner_radius_top_right = 3; rhs.corner_radius_bottom_right = 3
	rhs.set_content_margin_all(3)
	right_half.add_theme_stylebox_override("panel", rhs)
	var rd := C_TITLE_GLOW if t.right < 0 else C_PIP_DOT
	right_half.add_child(_make_pip_display(t.right, 10, rd))
	pip_row.add_child(right_half)

	# Special tile name
	if t.custom_name != "":
		vbox.add_child(_make_label(t.custom_name, C_RARITY[t.rarity], 13))

	# Tags
	var tags := ""
	if t.is_wild:
		tags = "Wild"
	elif t.is_double():
		tags = "Double  ·  %d pips" % t.total_pips()
	else:
		tags = "%d pips" % t.total_pips()
	vbox.add_child(_make_label(tags, C_DIM, 11))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	if bought:
		vbox.add_child(_make_label("ADDED", C_WIN, 13))
	else:
		var can_buy: bool = GameState.monedas >= cost
		var cost_lbl := _make_label("%d Monedas" % cost, C_MONEDAS, 13)
		vbox.add_child(cost_lbl)
		var buy_btn := Button.new()
		buy_btn.text = "BUY"
		buy_btn.disabled = not can_buy
		buy_btn.pressed.connect(_on_buy_tile_pressed.bind(index))
		vbox.add_child(buy_btn)

	return panel

# ---- Artisan tile removal button ----
func _build_removal_tile(index: int, tile: Domino) -> Control:
	var selected: bool = index in _removal_selected
	var at_cap: bool   = _removal_selected.size() >= MAX_FREE_REMOVALS

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 60)
	var style := StyleBoxFlat.new()
	style.bg_color     = C_TILE_BODY
	style.border_color = C_LOSE if selected else (C_DIM.darkened(0.2) if at_cap else C_TILE_BORDER)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Pip display with ivory bg so dots are visible on the dark panel
	var pip_outer := PanelContainer.new()
	pip_outer.custom_minimum_size = Vector2(0, 32)
	var pip_bg := StyleBoxFlat.new()
	pip_bg.bg_color = C_TILE_FACE.darkened(0.08) if selected else C_TILE_FACE
	pip_bg.set_corner_radius_all(3); pip_bg.set_content_margin_all(2)
	pip_outer.add_theme_stylebox_override("panel", pip_bg)
	vbox.add_child(pip_outer)

	var pip_row := HBoxContainer.new()
	pip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pip_row.add_theme_constant_override("separation", 0)
	pip_outer.add_child(pip_row)

	var lcd := C_TITLE_GLOW if tile.left  < 0 else C_PIP_DOT
	var rcd := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	var lc := _make_pip_display(tile.left,  7, lcd)
	lc.custom_minimum_size = Vector2(28, 0)
	pip_row.add_child(lc)
	pip_row.add_child(_make_tile_vsep())
	var rc := _make_pip_display(tile.right, 7, rcd)
	rc.custom_minimum_size = Vector2(28, 0)
	pip_row.add_child(rc)

	var mark_lbl := _make_label("✕" if selected else "○", C_LOSE if selected else C_DIM, 11)
	mark_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(mark_lbl)

	# Click handler via a transparent Button overlay
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Make the button transparent/invisible
	for s_name in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override(s_name, s)
	btn.text = ""
	btn.disabled = at_cap and not selected
	btn.pressed.connect(_on_toggle_removal.bind(index))
	panel.add_child(btn)

	return panel

# ===========================================================================
# Glitch text helper (boss name scramble effect)
# ===========================================================================
## Returns a same-length string of random glitch characters,
## preserving spaces so the layout doesn't jump around.
func _glitch_text(src: String) -> String:
	const GLITCH: String = "▒▓░█▌▐▀▄╬╪╫╦╩╗╝╔╚═║╠╣"
	var result := ""
	for i in range(src.length()):
		if src[i] == " ":
			result += " "
		else:
			result += GLITCH[randi() % GLITCH.length()]
	return result

# ===========================================================================
# Chronos bar helper
# ===========================================================================
func _set_chronos_bar(c: int, t: int) -> void:
	_chronos_bar.max_value = t
	_chronos_bar.value     = float(c)
	_chronos_bar_lbl.text  = "%d / %d" % [c, t]
	var ratio := clampf(float(c) / float(t), 0.0, 2.0) if t > 0 else 0.0
	if ratio >= 1.0:
		_chronos_bar_fill_style.bg_color = C_WIN
	elif ratio >= 0.75:
		_chronos_bar_fill_style.bg_color = C_CHRONOS
	else:
		_chronos_bar_fill_style.bg_color = C_CHRONOS.darkened(0.30)
	_chronos_bar.add_theme_stylebox_override("fill", _chronos_bar_fill_style)

# ===========================================================================
# Chain length milestone hint
# ===========================================================================
func _refresh_chain_bonus_label(length: int) -> void:
	var sm := Constants.CHAIN_BONUS_SMALL
	var lg := Constants.CHAIN_BONUS_LARGE

	if length >= lg:
		_lbl_chain_bonus.text = "Chain bonus: +2 Mult  ✓"
		_lbl_chain_bonus.add_theme_color_override("font_color", C_WIN)
	elif length >= sm:
		var need := lg - length
		_lbl_chain_bonus.text = "+1 Mult  ✓    %d more tile%s for +2 Mult" % \
			[need, "" if need == 1 else "s"]
		_lbl_chain_bonus.add_theme_color_override("font_color", C_MONEDAS)
	else:
		var ns := sm - length
		var nl := lg - length
		_lbl_chain_bonus.text = "%d more for +1 Mult  ·  %d more for +2 Mult" % [ns, nl]
		# Brighten as player approaches the first threshold
		var urgency := clampf(float(length) / float(sm), 0.0, 1.0)
		_lbl_chain_bonus.add_theme_color_override("font_color", C_DIM.lerp(C_TEXT, urgency))

# ===========================================================================
# Module rack (shown during play)
# ===========================================================================
func _build_module_rack_panel() -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.09, 0.07, 0.75)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(hbox)

	var lbl := _make_label("MODULES:", C_DIM, 11)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(lbl)

	_module_rack_row = HBoxContainer.new()
	_module_rack_row.add_theme_constant_override("separation", 6)
	hbox.add_child(_module_rack_row)

	return panel

func _refresh_module_rack() -> void:
	for child in _module_rack_row.get_children():
		child.queue_free()
	_rack_card_by_id.clear()

	if GameState.modules.is_empty():
		var none_lbl := _make_label("none equipped", C_DIM, 11)
		_module_rack_row.add_child(none_lbl)
		return

	for m in GameState.modules:
		var card := _build_rack_module_card(m)
		_module_rack_row.add_child(card)
		_rack_card_by_id[m.id] = card

func _build_rack_module_card(m: Module) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 36)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.12, 0.11, 0.08)
	style.border_color = C_RARITY[m.rarity]
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)
	# Store style reference for pulse animation
	panel.set_meta("border_style", style)
	panel.set_meta("base_border_color", C_RARITY[m.rarity])

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 5)
	panel.add_child(hbox)

	var dot := _make_label("●", C_RARITY[m.rarity], 10)
	dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(dot)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(col)

	col.add_child(_make_label(m.display_name, C_TEXT, 11))
	col.add_child(_make_label(m.description,  C_DIM,  10))

	# Hover tooltip — full name, description, and lore on mouse-over
	_add_module_tooltip(panel, m)

	return panel

# ===========================================================================
# Scoring animation sequence
# ===========================================================================

## Determine which module IDs actually fired this hand.
## Returns the list of IDs whose rack card should pulse.
func _get_active_module_ids(has_doubles: bool, chain_length: int,
		has_wilds: bool = false, max_pip: int = 0,
		has_blanks: bool = false, min_pips: int = 999) -> Array:
	var active: Array = []
	for m in GameState.modules:
		match m.effect_type:
			Module.EffectType.FLAT_MULT, \
			Module.EffectType.FLAT_CHIPS, \
			Module.EffectType.CHIPS_PER_TILE, \
			Module.EffectType.ERA_SCALING_MULT, \
			Module.EffectType.ROUND_SCALING_MULT:
				# Always contributes every hand
				active.append(m.id)
			Module.EffectType.DOUBLE_PIP_BOOST, \
			Module.EffectType.DOUBLE_MULT_BOOST:
				if has_doubles:
					active.append(m.id)
			Module.EffectType.LONG_CHAIN_BOOST:
				if chain_length >= m.effect_param:
					active.append(m.id)
			Module.EffectType.HIGH_PIP_BONUS:
				if max_pip >= m.effect_param:
					active.append(m.id)
			Module.EffectType.WILD_PIP_VALUE:
				if has_wilds:
					active.append(m.id)
			Module.EffectType.CLOSING_TILE_BONUS:
				if chain_length >= 3:
					active.append(m.id)
			Module.EffectType.LOW_PIP_TO_MULT:
				# Fires if any tile was within the sacrifice threshold
				if min_pips <= m.effect_param:
					active.append(m.id)
			Module.EffectType.BLANK_TO_CHIPS:
				if has_blanks:
					active.append(m.id)
	return active

## Scale + glow a module rack card to signal its effect fired.
func _pulse_rack_card(card: Control) -> void:
	card.pivot_offset = card.size * 0.5
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.10, 1.10), 0.11) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(card, "scale", Vector2(1.0, 1.0), 0.18) \
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	# Flash border bright then back
	if card.has_meta("border_style") and card.has_meta("base_border_color"):
		var style: StyleBoxFlat = card.get_meta("border_style")
		var base_col: Color     = card.get_meta("base_border_color")
		var flash_col: Color    = base_col.lightened(0.65)
		var bt := create_tween()
		bt.tween_method(func(c: Color):
			style.border_color = c
			card.add_theme_stylebox_override("panel", style),
			base_col, flash_col, 0.11)
		bt.tween_method(func(c: Color):
			style.border_color = c
			card.add_theme_stylebox_override("panel", style),
			flash_col, base_col, 0.28)

## Full Balatro-style scoring sequence.
## overlay_infos: Array of Dicts built in _on_hand_scored while tiles still on screen.
## active_module_ids: IDs of modules that fired this hand (for rack pulse).
## new_chronos: the updated _rm.chronos value used to animate the bar fill.
func _run_scoring_sequence(overlay_infos: Array, result: Dictionary,
		new_chronos: int, active_module_ids: Array) -> void:
	var seq := create_tween()

	# Pre-compute cumulative chip totals so closures can capture the right value
	# for each tile without relying on mutable loop-variable capture.
	var cum_chips: Array[int] = []
	var running: int = 0
	for info in overlay_infos:
		running += int(info["chips"])
		cum_chips.append(running)
	var total_chips: int = running

	# Initialise the accumulating counter (written to _lbl_preview which is cleared
	# by _refresh_chain_display on the same frame; this callback runs next frame)
	seq.tween_callback(func():
		_lbl_preview.text = "0  chips"
		_lbl_preview.add_theme_color_override("font_color", C_DIM)
		_lbl_preview.add_theme_font_size_override("font_size", 18)
	)

	for ti in range(overlay_infos.size()):
		var info:      Dictionary = overlay_infos[ti]
		var overlay:   Control    = info["overlay"]
		var center:    Vector2    = info["center"]
		var chips:     int        = info["chips"]
		var is_dbl:    bool       = info["is_double"]
		var hl_color:  Color      = C_MONEDAS if is_dbl else C_CHRONOS
		var pop_color: Color      = C_MONEDAS if is_dbl else C_TEXT
		var chips_so_far: int     = cum_chips[ti]   # captured fresh per iteration ✓

		# Step 1 — tile flashes (bright border + tinted background)
		seq.tween_callback(func():
			var hl := StyleBoxFlat.new()
			hl.bg_color     = hl_color.lerp(C_TILE_FACE, 0.45)
			hl.border_color = hl_color
			hl.set_border_width_all(3)
			hl.set_corner_radius_all(6)
			overlay.add_theme_stylebox_override("panel", hl)
		)
		seq.tween_interval(0.07)

		# Step 2 — chip pop rises; counter ticks up; overlay ghost fades out
		seq.tween_callback(func():
			_lbl_preview.text = "%d  chips" % chips_so_far
			_lbl_preview.add_theme_color_override("font_color",
				C_MONEDAS if is_dbl else C_PREVIEW)
			_do_tile_pop("+%d" % chips, pop_color, center, 21, 0.80)
			var fade := create_tween()
			fade.tween_interval(0.05)
			fade.tween_property(overlay, "modulate:a", 0.0, 0.22)
			fade.tween_callback(overlay.queue_free)
		)
		seq.tween_interval(0.13)

	# Step 3 — module activation pulses (cards glow if their effect fired)
	if not active_module_ids.is_empty():
		seq.tween_interval(0.04)
		seq.tween_callback(func():
			for m_id in active_module_ids:
				if m_id in _rack_card_by_id:
					_pulse_rack_card(_rack_card_by_id[m_id])
		)
		seq.tween_interval(0.18)

	# Step 4 — multiplier slam: counter pivots to "N chips × M"
	var chain_center := _chain_container.global_position + _chain_container.size * 0.5
	seq.tween_interval(0.05)
	if result["mult"] > 1:
		seq.tween_callback(func():
			_lbl_preview.text = "%d  chips  ×  %d" % [total_chips, result["mult"]]
			_lbl_preview.add_theme_color_override("font_color", C_TARGET)
			_do_tile_pop("×%d" % result["mult"], C_TARGET, chain_center, 34, 1.10)
		)
		seq.tween_interval(0.32)

	# Step 5 — total Chronos burst; counter shows full equation; bar animates
	seq.tween_callback(func():
		_lbl_preview.text = "%d  chips  ×  %d  =  %d" % \
			[total_chips, result["mult"], result["total"]]
		_lbl_preview.add_theme_color_override("font_color", C_CHRONOS)
		_do_tile_pop("+%d Chronos" % result["total"], C_CHRONOS, chain_center, 38, 1.50)
		var bar_tween := create_tween()
		bar_tween.tween_property(_chronos_bar, "value", float(new_chronos), 0.55)
		_maybe_table_shake(result["total"])
	)

	# Step 6 — unlock input, finalise bar colour/label, restore preview style
	seq.tween_interval(0.28)
	seq.tween_callback(func():
		_scoring_active = false
		_lbl_preview.add_theme_font_size_override("font_size", 16)
		_lbl_preview.add_theme_color_override("font_color", C_PREVIEW)
		if _rm != null:
			_set_chronos_bar(_rm.chronos, _rm.target)
	)

## Build a ghost domino overlay at screen_pos, parented to the UI layer.
## Positioned over the real tile before the chain clears.
func _build_score_overlay(screen_pos: Vector2, tile_size: Vector2, tile: Domino) -> Control:
	var panel := PanelContainer.new()
	panel.position = screen_pos
	panel.custom_minimum_size = tile_size

	# Match the new dark-frame tile style
	var style := StyleBoxFlat.new()
	style.bg_color     = C_TILE_BODY
	style.border_color = C_TILE_BORDER
	style.set_border_width_all(3); style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.40); style.shadow_size = 3
	style.set_content_margin_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	var top_panel := PanelContainer.new()
	top_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(top_panel, C_TILE_FACE, true)
	var top_dot := C_TITLE_GLOW if tile.left < 0 else C_PIP_DOT
	top_panel.add_child(_make_pip_display(tile.left, 12, top_dot))
	vbox.add_child(top_panel)

	vbox.add_child(_make_tile_hsep())

	var bot_panel := PanelContainer.new()
	bot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bot_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(bot_panel, C_TILE_FACE, false)
	var bot_dot := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	bot_panel.add_child(_make_pip_display(tile.right, 12, bot_dot))
	vbox.add_child(bot_panel)

	_ui_layer.add_child(panel)
	return panel

## Called deferred after a successful tile placement so layout has settled.
## Finds the correct panel in the rebuilt chain and fires a connection spark.
func _fire_chain_spark(added_left: bool, was_first: bool) -> void:
	# Collect only tile PanelContainers (end indicators are VBoxContainers)
	var tile_panels: Array = []
	for child in _chain_container.get_children():
		if child is PanelContainer:
			tile_panels.append(child)
	if tile_panels.is_empty():
		return

	# First tile → spark at centre; left add → leftmost panel; right add → rightmost
	var panel: Control = tile_panels[0] if (was_first or added_left) else tile_panels[-1]
	var spark_pos: Vector2 = panel.global_position + panel.size * 0.5
	var accent: Color = Constants.ETAPA_ACCENT[clampi(GameState.current_etapa(), 0, 3)]
	_do_chain_spark(spark_pos, accent)

## Burst effect at the tile-connection point: expanding ring + 6 radial sparks.
func _do_chain_spark(pos: Vector2, color: Color) -> void:
	# 1. Expanding ring — scale up while fading
	var ring := PanelContainer.new()
	ring.custom_minimum_size = Vector2(30, 30)
	var rs := StyleBoxFlat.new()
	rs.bg_color     = Color(color.r, color.g, color.b, 0.12)
	rs.border_color = color
	rs.set_border_width_all(2)
	rs.set_corner_radius_all(15)
	ring.add_theme_stylebox_override("panel", rs)
	ring.pivot_offset = Vector2(15, 15)
	ring.scale        = Vector2(0.2, 0.2)
	ring.position     = pos - Vector2(15, 15)
	ring.modulate.a   = 1.0
	_ui_layer.add_child(ring)

	var rt := create_tween().set_parallel(true)
	rt.tween_property(ring, "scale", Vector2(1.7, 1.7), 0.22) \
		.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	rt.tween_property(ring, "modulate:a", 0.0, 0.22)
	rt.chain().tween_callback(ring.queue_free)

	# 2. Six dots radiating outward at 60° intervals
	for i in range(6):
		var rad: float = i * PI / 3.0
		var dir := Vector2(cos(rad), sin(rad))
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(5, 5)
		var ds := StyleBoxFlat.new()
		ds.bg_color = color
		ds.set_corner_radius_all(3)
		dot.add_theme_stylebox_override("panel", ds)
		dot.position = pos - Vector2(2.5, 2.5)
		_ui_layer.add_child(dot)

		var end_pos: Vector2 = pos + dir * 30.0 - Vector2(2.5, 2.5)
		var dt := create_tween().set_parallel(true)
		dt.tween_property(dot, "position", end_pos, 0.27) \
			.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		dt.tween_property(dot, "modulate:a", 0.0, 0.27)
		dt.chain().tween_callback(dot.queue_free)

## Create a floating label at screen_pos and tween it up + out.
func _do_tile_pop(text: String, color: Color, screen_pos: Vector2,
		font_size: int, duration: float) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.modulate.a = 1.0
	_ui_layer.add_child(lbl)
	_animate_pop_at.call_deferred(lbl, screen_pos, duration)

func _animate_pop_at(lbl: Label, screen_pos: Vector2, duration: float) -> void:
	lbl.position = screen_pos - lbl.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 75.0, duration)
	tween.tween_property(lbl, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(lbl.queue_free)

# ===========================================================================
# Chain end pip indicators
# ===========================================================================

## Glowing connector port flanking the chain — shows which pip value is free.
func _build_chain_end_indicator(pip: int, is_left: bool) -> Control:
	var outer := VBoxContainer.new()
	outer.alignment = BoxContainer.ALIGNMENT_CENTER
	outer.add_theme_constant_override("separation", 3)

	var accent: Color = Constants.ETAPA_ACCENT[GameState.current_etapa()]

	var pip_panel := PanelContainer.new()
	pip_panel.custom_minimum_size = Vector2(48, 48)
	var s := StyleBoxFlat.new()
	s.bg_color     = Color(0.07, 0.09, 0.06)
	s.border_color = accent
	s.set_border_width_all(2)
	s.set_corner_radius_all(5)
	pip_panel.add_theme_stylebox_override("panel", s)

	if pip == Chain.WILD:
		var star := _make_label("★", accent, 16)
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		star.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		star.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		pip_panel.add_child(star)
	else:
		pip_panel.add_child(_make_pip_display(pip, 7, accent))

	var arrow := _make_label("←" if is_left else "→", accent, 12)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.modulate.a = 0.65

	if is_left:
		outer.add_child(arrow)
		outer.add_child(pip_panel)
	else:
		outer.add_child(pip_panel)
		outer.add_child(arrow)
	return outer

# ===========================================================================
# Connection direction helpers (mirrors Chain private logic for UI use)
# ===========================================================================
func _tile_fits_left(tile: Domino, le: int) -> bool:
	if tile.is_wild or le == Chain.WILD or le == Chain.EMPTY:
		return true
	return tile.right == le or tile.left == le

func _tile_fits_right(tile: Domino, re: int) -> bool:
	if tile.is_wild or re == Chain.WILD or re == Chain.EMPTY:
		return true
	return tile.left == re or tile.right == re

# ===========================================================================
# Small widget helpers
# ===========================================================================

## Filled / unfilled dot for hands and discards counters in the HUD.
func _make_hud_dot(filled: bool, color: Color) -> Control:
	var dot := PanelContainer.new()
	dot.custom_minimum_size = Vector2(11, 11)
	var s := StyleBoxFlat.new()
	s.bg_color = color if filled else color.darkened(0.65)
	s.set_corner_radius_all(6)
	dot.add_theme_stylebox_override("panel", s)
	return dot

## Vertical divider for the HUD sections.
func _make_vdiv() -> Control:
	var sep := VSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.30, 0.28, 0.22, 0.55)
	style.set_content_margin_all(0)
	sep.add_theme_stylebox_override("separator", style)
	sep.add_theme_constant_override("separation", 1)
	return sep

# ===========================================================================
# Starting tile removal
# ===========================================================================
func _show_start_removal() -> void:
	_phase = Phase.TILE_REMOVAL
	_start_removal_candidates = TileShopManager.generate_removal_candidates(GameState.box, 8)
	_start_removal_selected.clear()
	_populate_start_removal()
	_tile_removal_overlay.show()

func _on_start_removal_toggle(index: int) -> void:
	if index in _start_removal_selected:
		_start_removal_selected.erase(index)
	elif _start_removal_selected.size() < MAX_FREE_REMOVALS:
		_start_removal_selected.append(index)
	_populate_start_removal()

func _on_start_removal_confirm_pressed() -> void:
	var sorted: Array = _start_removal_selected.duplicate()
	sorted.sort()
	sorted.reverse()
	for i in sorted:
		if i < _start_removal_candidates.size():
			GameState.box.remove_tile(_start_removal_candidates[i])
	_tile_removal_overlay.hide()
	_start_round()

func _on_start_removal_skip_pressed() -> void:
	_tile_removal_overlay.hide()
	_start_round()

func _populate_start_removal() -> void:
	for child in _start_removal_row.get_children():
		child.queue_free()
	for i in range(_start_removal_candidates.size()):
		_start_removal_row.add_child(
			_build_start_removal_tile(i, _start_removal_candidates[i]))
	var left: int = MAX_FREE_REMOVALS - _start_removal_selected.size()
	_start_removal_lbl.text = "%d removal%s remaining (free)" % [
		left, "" if left == 1 else "s"]
	_start_removal_btn.disabled = _start_removal_selected.is_empty()

func _build_start_removal_tile(index: int, tile: Domino) -> Control:
	var selected: bool = index in _start_removal_selected
	var at_cap: bool   = _start_removal_selected.size() >= MAX_FREE_REMOVALS

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 70)
	var style := StyleBoxFlat.new()
	style.bg_color     = C_TILE_BODY
	style.border_color = C_LOSE if selected else (C_DIM.darkened(0.2) if at_cap else C_TILE_BORDER)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Ivory pip area so dots are visible
	var pip_outer := PanelContainer.new()
	pip_outer.custom_minimum_size = Vector2(0, 36)
	var pip_bg := StyleBoxFlat.new()
	pip_bg.bg_color = C_TILE_FACE.darkened(0.08) if selected else C_TILE_FACE
	pip_bg.set_corner_radius_all(3); pip_bg.set_content_margin_all(2)
	pip_outer.add_theme_stylebox_override("panel", pip_bg)
	vbox.add_child(pip_outer)

	var pip_row := HBoxContainer.new()
	pip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pip_row.add_theme_constant_override("separation", 0)
	pip_outer.add_child(pip_row)

	var lcd2 := C_TITLE_GLOW if tile.left  < 0 else C_PIP_DOT
	var rcd2 := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	var lc := _make_pip_display(tile.left,  8, lcd2)
	lc.custom_minimum_size = Vector2(30, 0)
	pip_row.add_child(lc)
	pip_row.add_child(_make_tile_vsep())
	var rc := _make_pip_display(tile.right, 8, rcd2)
	rc.custom_minimum_size = Vector2(30, 0)
	pip_row.add_child(rc)

	var pips_lbl := _make_label("%d|%d" % [tile.left, tile.right], C_DIM, 10)
	pips_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pips_lbl)

	var mark_lbl := _make_label("✕ REMOVE" if selected else "○", C_LOSE if selected else C_DIM, 10)
	mark_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(mark_lbl)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s_name in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(s_name, StyleBoxEmpty.new())
	btn.text = ""
	btn.disabled = at_cap and not selected
	btn.pressed.connect(_on_start_removal_toggle.bind(index))
	panel.add_child(btn)

	return panel

func _build_tile_removal_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 0)
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.09, 0.07)
	style.border_color = Color(0.50, 0.45, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# Header
	var hdr := _make_label("INITIAL CALIBRATION", C_TITLE_GLOW, 26)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)

	var sub := _make_label(
		"Before the first round, you may remove up to 2 tiles from your starting box.\nThe tiles shown are the weakest in your configuration.",
		C_DIM, 14)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(700, 0)
	vbox.add_child(sub)

	vbox.add_child(_make_hsep())

	# Tile row
	_start_removal_row = HBoxContainer.new()
	_start_removal_row.add_theme_constant_override("separation", 10)
	_start_removal_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(_start_removal_row)

	vbox.add_child(_make_hsep())

	# Footer
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 16)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(footer)

	_start_removal_lbl = _make_label("2 removals remaining (free)", C_MONEDAS, 13)
	_start_removal_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_start_removal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_child(_start_removal_lbl)

	var skip_btn := _make_button("SKIP  →", _on_start_removal_skip_pressed, Vector2(120, 44))
	footer.add_child(skip_btn)

	_start_removal_btn = _make_button(
		"REMOVE & BEGIN  →", _on_start_removal_confirm_pressed, Vector2(200, 44))
	_start_removal_btn.disabled = true
	footer.add_child(_start_removal_btn)

	return overlay

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

# ===========================================================================
# Run-end cinematic overlay (build)
# ===========================================================================
## Constructs the full-screen victory / defeat overlay.
## _show_run_end() populates and animates it; this just wires up the nodes.
func _build_run_end_overlay() -> Control:
	# Root is a ColorRect so _show_run_end() can tint it per outcome
	var overlay := ColorRect.new()
	overlay.color = Color(0.05, 0.04, 0.02, 0.97)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	vbox.custom_minimum_size = Vector2(660, 0)
	center.add_child(vbox)

	# ── Glyph (⬡ victory / ⚠ defeat) ────────────────────────────────────────
	_lbl_run_end_glyph = _make_label("⬡", C_MONEDAS, 72)
	_lbl_run_end_glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_run_end_glyph)

	# ── Title (typewritten in the sequence) ──────────────────────────────────
	_lbl_run_end_title = _make_label("", C_MONEDAS, 28)
	_lbl_run_end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_run_end_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_run_end_title.custom_minimum_size = Vector2(580, 0)
	vbox.add_child(_lbl_run_end_title)

	# ── Sub-line ──────────────────────────────────────────────────────────────
	_lbl_run_end_sub = _make_label("", C_DIM, 15)
	_lbl_run_end_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_run_end_sub)

	vbox.add_child(_make_hsep())

	# ── Stats block (rows built dynamically in _show_run_end) ────────────────
	_run_end_stats_col = VBoxContainer.new()
	_run_end_stats_col.add_theme_constant_override("separation", 6)
	vbox.add_child(_run_end_stats_col)

	vbox.add_child(_make_hsep())

	# ── Defeat-only: rebooting progress bar ──────────────────────────────────
	_run_end_progress_lbl = _make_label("REBOOTING OPERATOR INTERFACE", C_DIM, 12)
	_run_end_progress_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_run_end_progress_lbl)

	_run_end_progress_bar = ProgressBar.new()
	_run_end_progress_bar.min_value = 0.0
	_run_end_progress_bar.max_value = 100.0
	_run_end_progress_bar.value     = 0.0
	_run_end_progress_bar.show_percentage = false
	_run_end_progress_bar.custom_minimum_size = Vector2(420, 20)
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color(0.08, 0.03, 0.03)
	pb_bg.set_corner_radius_all(4)
	_run_end_progress_bar.add_theme_stylebox_override("background", pb_bg)
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = C_LOSE.darkened(0.25)
	pb_fill.set_corner_radius_all(4)
	_run_end_progress_bar.add_theme_stylebox_override("fill", pb_fill)
	vbox.add_child(_run_end_progress_bar)

	# ── Button ─────────────────────────────────────────────────────────────────
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	_btn_run_end = _make_button("NEW TRIAL CYCLE  →", _on_run_end_pressed,
		Vector2(260, 52))
	_btn_run_end.modulate.a = 0.0
	_btn_run_end.disabled   = true
	btn_row.add_child(_btn_run_end)

	return overlay

# ===========================================================================
# Chain tile idle breathing
# ===========================================================================
## Kill every stored idle-breathe tween and clear the array.
## Must be called before rebuilding the chain display.
func _kill_chain_idle_tweens() -> void:
	for t in _chain_idle_tweens:
		if t is Tween and t.is_valid():
			t.kill()
	_chain_idle_tweens.clear()

## Creates a looping, sinusoidal border-glow pulse on a chain tile panel.
## Returns the Tween so the caller can store and later kill it.
## Panels lacking the stored "border_style" meta are skipped (returns null).
func _start_tile_breathe(panel: Control) -> Tween:
	if not panel.has_meta("border_style"):
		return null
	var style: StyleBoxFlat = panel.get_meta("border_style") as StyleBoxFlat
	if style == null:
		return null

	var base_col:   Color = panel.get_meta("base_border_color") as Color
	var bright_col: Color = base_col.lightened(0.32)

	# Random initial offset so tiles don't pulse in sync.
	# The delay is inside the loop so it repeats — this effectively stretches
	# one cycle slightly, which is imperceptible at the 0–1.8 s range used.
	var delay: float = randf_range(0.0, 1.8)

	var t := create_tween().set_loops()
	t.tween_interval(delay)
	t.tween_method(func(c: Color): style.border_color = c,
		base_col, bright_col, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(c: Color): style.border_color = c,
		bright_col, base_col, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t

# ===========================================================================
# Camera shake
# ===========================================================================
## Briefly shake the entire UI layer proportional to the score.
## threshold ≥80: mild (±3 px); ≥200: medium (±7 px); ≥500: strong (±13 px).
func _maybe_table_shake(score: int) -> void:
	if score < 80:
		return

	# Intensity: smooth ramp from 3 at score=80 to 13 at score=600+
	var t_val: float = clampf((score - 80.0) / 520.0, 0.0, 1.0)
	var intensity: float = lerpf(3.0, 13.0, t_val)
	var cycles:    int   = 3 if score < 200 else (4 if score < 500 else 5)

	var origin: Vector2 = _ui_layer.offset
	var shk := create_tween()
	for _i in range(cycles):
		var dx: float = randf_range(-intensity, intensity)
		var dy: float = randf_range(-intensity * 0.45, intensity * 0.45)
		shk.tween_property(_ui_layer, "offset", origin + Vector2(dx, dy), 0.038) \
			.set_trans(Tween.TRANS_SINE)
	# Spring back to rest
	shk.tween_property(_ui_layer, "offset", origin, 0.12) \
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

# ===========================================================================
# Victory particles
# ===========================================================================
## Spawns 12 golden drift particles on the UI layer that float upward and
## fade out — used as a background effect on the victory end-screen.
func _spawn_victory_particles() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	for i in range(12):
		var n: int = i   # capture loop index in closure

		var sz: float = randf_range(5.0, 12.0)
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(sz, sz)
		var ds := StyleBoxFlat.new()
		ds.bg_color = C_MONEDAS.lerp(C_WIN, randf())
		ds.set_corner_radius_all(ceili(sz * 0.5))
		dot.add_theme_stylebox_override("panel", ds)

		var start_pos := Vector2(
			randf_range(screen_size.x * 0.12, screen_size.x * 0.88),
			randf_range(screen_size.y * 0.35, screen_size.y * 0.80))
		dot.position   = start_pos
		dot.modulate.a = 0.0
		_ui_layer.add_child(dot)

		var end_pos := start_pos + Vector2(
			randf_range(-45.0, 45.0),
			randf_range(-200.0, -70.0))
		var dur:   float = randf_range(1.8, 3.4)
		var delay: float = float(n) * 0.11 + randf_range(0.0, 0.25)

		var pt := create_tween()
		pt.tween_interval(delay)
		pt.tween_callback(func(): dot.modulate.a = randf_range(0.55, 1.0))
		pt.tween_property(dot, "position", end_pos, dur) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		pt.parallel().tween_property(dot, "modulate:a", 0.0, dur)
		pt.tween_callback(dot.queue_free)

# ===========================================================================
# Defeat corruption flashes
# ===========================================================================
## Self-rescheduling red screen flash used on the defeat end-screen.
## Stops automatically when the phase leaves GAME_OVER.
func _start_defeat_corruption() -> void:
	if _phase != Phase.GAME_OVER:
		return   # navigated away — stop the chain

	var flash := ColorRect.new()
	flash.color        = Color(0.75, 0.08, 0.08, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(flash)

	var peak: float = randf_range(0.05, 0.15)
	var ft := create_tween()
	ft.tween_property(flash, "color:a", peak,  0.08)
	ft.tween_property(flash, "color:a", 0.0,   0.22)
	ft.tween_callback(flash.queue_free)

	# Reschedule: shorter intervals as the "system degrades"
	var next_delay: float = randf_range(0.7, 2.4)
	get_tree().create_timer(next_delay).timeout.connect(
		_start_defeat_corruption, CONNECT_ONE_SHOT)

# ===========================================================================
# Ambient degradation effects (etapas 1–3)
# ===========================================================================
## Kick off the ambient degradation loop for the current etapa.
## Etapa 0 (Mahogany) is intentionally pristine — no effects.
func _start_ambient_effects(etapa: int) -> void:
	_ambient_active = true
	if etapa < 1:
		return   # Mahogany is clean
	_ambient_tick(etapa)

## One tick of ambient degradation. Self-reschedules via create_timer.
func _ambient_tick(etapa: int) -> void:
	if not _ambient_active:
		return

	# Base interval and jitter scale with etapa (later = more frequent)
	const BASE_INTERVALS: Array = [0.0, 4.2, 2.6, 1.3]
	const JITTERS:        Array = [0.0, 2.0, 1.4, 0.8]
	var e: int = clampi(etapa, 0, 3)
	var next: float = BASE_INTERVALS[e] + randf_range(0.0, JITTERS[e])

	match e:
		1:
			# Brass — gentle table-title flicker; occasional chain-label dim
			if randf() > 0.45:
				_flicker_label(_lbl_table_title, 0.18)
			else:
				_flicker_label(_lbl_chain_bonus, 0.22)

		2:
			# Obsidian — more labels affected + occasional amber flash
			match randi() % 3:
				0:
					_flicker_label(_lbl_table_title, 0.28)
					_flicker_label(_lbl_etapa,        0.22)
				1:
					_flicker_label(_lbl_round,        0.20)
					_flicker_label(_lbl_chain_bonus,  0.30)
				2:
					_ambient_glitch_flash(Color(1.00, 0.60, 0.10, 0.045))

		3:
			# Void — heavy distortion across multiple UI elements
			match randi() % 4:
				0:
					_flicker_label(_lbl_table_title, 0.38)
					_flicker_label(_lbl_round,        0.32)
					_flicker_label(_lbl_etapa,        0.32)
				1:
					_ambient_glitch_flash(Color(0.75, 0.15, 0.75, 0.06))
				2:
					_ambient_glitch_flash(Color(0.65, 0.05, 0.05, 0.08))
					_flicker_label(_lbl_preview, 0.40)
				3:
					_flicker_label(_lbl_table_title, 0.45)
					_flicker_label(_lbl_chain_bonus,  0.40)
					_ambient_glitch_flash(Color(0.20, 0.80, 0.80, 0.05))

	get_tree().create_timer(next).timeout.connect(
		func(): _ambient_tick(etapa), CONNECT_ONE_SHOT)

## Brief triple-flicker on a Label: dim → restore → dim → restore.
func _flicker_label(lbl: Label, intensity: float) -> void:
	if not is_instance_valid(lbl):
		return
	var t := create_tween()
	t.tween_property(lbl, "modulate:a", 1.0 - intensity, 0.045)
	t.tween_property(lbl, "modulate:a", 1.0,             0.045)
	t.tween_property(lbl, "modulate:a", 1.0 - intensity * 0.55, 0.030)
	t.tween_property(lbl, "modulate:a", 1.0,             0.07)

## A coloured translucent rectangle flashed over the whole screen for one frame.
func _ambient_glitch_flash(color: Color) -> void:
	var flash := ColorRect.new()
	flash.color        = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(flash)
	var ft := create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.20)
	ft.tween_callback(flash.queue_free)

# ===========================================================================
# Module tooltip
# ===========================================================================
## Builds the floating tooltip panel (hidden by default).
## Added last to the UI layer so it renders above all overlays.
func _build_tooltip_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(290, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE   # never steal clicks
	panel.z_index      = 100                           # above all other controls
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.08, 0.07, 0.05, 0.97)
	style.border_color = Color(0.55, 0.50, 0.38)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	_tooltip_rarity_lbl = _make_label("", C_DIM, 10)
	_tooltip_rarity_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_tooltip_rarity_lbl)

	_tooltip_name_lbl = _make_label("", C_TEXT, 17)
	_tooltip_name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_name_lbl.custom_minimum_size = Vector2(270, 0)
	_tooltip_name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_tooltip_name_lbl)

	var sep := _make_hsep()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	_tooltip_desc_lbl = _make_label("", C_PREVIEW, 13)
	_tooltip_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_desc_lbl.custom_minimum_size = Vector2(270, 0)
	_tooltip_desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_tooltip_desc_lbl)

	_tooltip_lore_lbl = _make_label("", C_DIM, 11)
	_tooltip_lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_lore_lbl.custom_minimum_size = Vector2(270, 0)
	_tooltip_lore_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_tooltip_lore_lbl)

	return panel

## Connect hover signals on any Control so it shows the module tooltip.
func _add_module_tooltip(node: Control, m: Module) -> void:
	node.mouse_entered.connect(func(): _show_module_tooltip(m, node))
	node.mouse_exited.connect(_hide_module_tooltip)

## Populate and display the tooltip near the hovered card.
## Positioning is deferred one frame so the panel's size is known.
func _show_module_tooltip(m: Module, anchor: Control) -> void:
	_tooltip_rarity_lbl.text = Constants.RARITY_NAMES[m.rarity].to_upper()
	_tooltip_rarity_lbl.add_theme_color_override("font_color", C_RARITY[m.rarity])
	_tooltip_name_lbl.text = m.display_name
	_tooltip_name_lbl.add_theme_color_override("font_color",
		C_RARITY[m.rarity].lerp(C_TEXT, 0.45))
	_tooltip_desc_lbl.text = m.description
	_tooltip_lore_lbl.text = m.lore_text
	_tooltip_lore_lbl.visible = m.lore_text != ""
	_tooltip_panel.modulate.a = 0.0
	_tooltip_panel.show()
	# Defer so the panel size is computed before we position it
	_position_tooltip_at.call_deferred(anchor)

## Position the tooltip above (preferred) or below the anchor card.
## Clamped to screen bounds so it never clips off the edges.
func _position_tooltip_at(anchor: Control) -> void:
	if not is_instance_valid(anchor) or not _tooltip_panel.visible:
		return
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var apos:   Vector2 = anchor.global_position
	var ts:     Vector2 = _tooltip_panel.size
	# Prefer above; if that clips the top, place below
	var ty: float = apos.y - ts.y - 8.0
	if ty < 4.0:
		ty = apos.y + anchor.size.y + 8.0
	var tx: float = clampf(apos.x, 4.0, screen.x - ts.x - 4.0)
	_tooltip_panel.position = Vector2(tx, ty)
	# Fade in
	var t := create_tween()
	t.tween_property(_tooltip_panel, "modulate:a", 1.0, 0.14)

## Hide the tooltip immediately.
func _hide_module_tooltip() -> void:
	_tooltip_panel.hide()
