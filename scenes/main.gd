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
const C_TARGETING       := Color(0.30, 0.90, 0.85)   # teal — reinforcement targeting mode
const C_TARGETING_SEL   := Color(0.20, 1.00, 0.90)   # bright teal — tile selected for targeting

# ---------------------------------------------------------------------------
# Design-image palette additions
# ---------------------------------------------------------------------------
const C_WOOD         := Color(0.09, 0.06, 0.03)
const C_FELT         := Color(0.07, 0.16, 0.09)
const C_FELT_BORDER  := Color(0.18, 0.32, 0.18)
const C_PANEL_DARK   := Color(0.08, 0.06, 0.04, 0.97)
const C_PARCHMENT    := Color(0.18, 0.15, 0.10, 0.95)
const C_GOLD_RIM     := Color(0.52, 0.40, 0.16)
const C_GOLD_TITLE   := Color(0.85, 0.72, 0.30)
const C_MANOS_BG     := Color(0.10, 0.16, 0.28, 0.92)
const C_DISC_BG      := Color(0.28, 0.08, 0.08, 0.92)
const C_ARTIFACT_HDR := Color(0.18, 0.08, 0.30, 0.95)
const C_CHAIN_BAR_BG := Color(0.06, 0.14, 0.14, 0.90)
const C_SCORE_BIG    := Color(0.90, 0.76, 0.22)
const C_MULT         := Color(0.72, 0.30, 0.90)

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
	"The mirror eats its reflection.\nWhat resonates now devours.",
	"The Archive remembers what it pleases.\nYou must remember the rest.",
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
# Reinforcement targeting state
var _reinforcement_pending           = null   # Reinforcement being activated (or null)
var _reinforcement_targets: Array    = []     # hand indices picked during targeting
var _reinforcement_needs: int        = 0      # how many tiles the pending effect needs
# Deferred one-shot effect flags
var _fortune_essence_active: bool    = false  # next chain: +2 bonus Monedas
var _talisman_active: bool           = false  # next chain: +10 bonus chips
# Compass modal reference (built on demand)
var _compass_overlay: Control        = null
var _tile_btns: Array = []
var _tile_conn_lbls: Array = []   # connection-arrow labels, parallel to _tile_btns
var _scoring_active: bool = false # input locked while scoring animation plays
# Currently-playing skippable cinematic (boss warning, scoring cascade,
# run-end reveal). Pressing Space/Enter/Esc/click fast-forwards it by
# spiking the tween's speed_scale; null when no cinematic is active.
var _active_cinematic_tween: Tween = null
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
## Chain area: a VBoxContainer of HBoxContainer rows. Tiles wrap to multiple
## rows (serpentine: even rows L→R, odd rows R→L) so 21+ tile chains fit.
## Doubles render perpendicular to the row direction (vertical in a horizontal
## row), matching physical-domino aesthetics.
var _chain_container:  VBoxContainer
## Ordered list of tile PanelContainers — index i maps to current_chain.tiles[i].
## Used by the scoring sequence to find each tile's screen position regardless
## of which row it landed in.
var _chain_tile_panels: Array[Control] = []
## Floating row above the chain that renders open branch ends created by
## previously-placed doubles. Each entry is a small pip-badge showing the
## pip value the chain can match next via that branch. Empty when no
## branches are open.
var _chain_branches_row: HBoxContainer
var _lbl_preview:          Label   # equation line: "N chips × M"
var _lbl_preview_total:    Label   # big total line: "= TOTAL" (dominant)
var _chain_milestone_row:  HBoxContainer   # visual dot-progress bar for chain bonuses
## Big tier-name banner above the milestone row. Shows the active tier
## (e.g. "RESONANCE  +4 MULT") so the player can read their bonus level
## at a glance without parsing the segment-bar colours. Empty when the
## chain is below Pulse (length 1-3 = Fragment, no bonus).
var _lbl_active_tier:      Label
## Highest tier index reached so far in the current round (-1 = none).
## Used to detect tier crossings and fire a celebration animation.
var _last_tier_reached: int = -1
## Set true the first time chronos crosses the round target so the
## "target reached" confetti burst only fires once per round.
var _target_celebrated: bool = false
var _lbl_last_hand:        Label
# Play button pulse tween (looping amber glow when valid chain ready)
var _play_pulse_tween: Tween = null
# Monedas delta tracking (for "+N" pop animation)
var _last_monedas: int = 0
var _hand_container:  HBoxContainer
var _btn_play:        Button
var _btn_discard:     Button
var _btn_undo:        Button
var _btn_stand:       Button   # appears only once chronos ≥ target
var _btn_pass:        Button   # appears only when softlocked (no legal moves)
## Two-line hint shown next to the Stand button when target is reached.
## Top line: monedas the player would bank from unused hands by standing.
## Bottom: distance to next tier (and the mult bonus it unlocks). Helps the
## player make an informed choice between safe and greedy.
var _lbl_stand_hint:  Label
# Reinforcement tray
var _reinforcement_tray: HBoxContainer
# Contract indicator
var _contract_bar:   Control
var _lbl_contract:   Label

# ---------------------------------------------------------------------------
# Tutorial overlay
# ---------------------------------------------------------------------------
var _tutorial_overlay:   Control   # root node (fullscreen)
var _tut_dim:            ColorRect  # semi-transparent backdrop
var _tut_spotlight:      Control    # glowing border around target
var _tut_hint_box:       PanelContainer
var _tut_hint_title:     Label
var _tut_hint_body:      Label
var _tut_next_btn:       Button
var _tut_step_lbl:       Label      # "1 / 5"
var _tutorial_step:      int  = 0
var _tutorial_active:    bool = false

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
var _btn_continue_run:     Button   # shown only when SaveManager has a saved run
var _btn_daily_trial:      Button   # one attempt per day, deterministic seed
var _btn_daily_history:    Button   # opens the daily-history overlay
var _daily_history_overlay: Control # built lazily on first open
## Small caption under the title-screen button row that names today's
## fallen Operator — the memorial each Daily Cycle honours.
var _lbl_daily_memorial:   Label
var _btn_achievements:     Button   # opens the achievements overlay
var _achievements_overlay: Control  # built lazily on first open
var _btn_stats:            Button   # opens the lifetime statistics overlay
var _stats_overlay:        Control  # built lazily on first open
var _btn_help:             Button   # opens the help / glossary overlay
var _help_overlay:         Control  # built lazily on first open
var _btn_codex:            Button   # opens the Codex (lore archive)
var _codex_overlay:        Control  # built lazily on first open
var _codex_active_cat:     int = 0  # currently-selected category tab
## Archiver transmission strip — thin overlay near the top of the
## viewport that fades in with a single line from the Archiver at
## select round-starts. Lazy-built on first use.
var _transmission_overlay: Control
var _transmission_label:   Label
var _transmission_tween:   Tween
var _settings_overlay:     Control  # volume / mute panel, accessible anywhere
## Mid-run pause overlay. Shown via the HUD pause button or ESC during
## PLAYING phase when nothing else is active. Blocks game input by sitting
## on the UI layer; "RESUME" hides it, "QUIT" returns to the title screen
## without clearing the saved run (so Continue still works on reload).
var _pause_overlay:        Control
## Confirmation modal shown when quitting a daily run (forfeit warning).
## Lazy-built on first daily-run quit; sits on top of the pause overlay
## so cancelling drops back to the pause menu without losing context.
var _quit_confirm_overlay: Control

# ---------------------------------------------------------------------------
# Design-image layout refs
# ---------------------------------------------------------------------------
var _lbl_score_big:       Label
var _lbl_score_label:     Label
var _lbl_manos_count:     Label
## Tile count remaining in the box (draw pile) for the current round.
## Lets the player see at a glance how much they still have to draw —
## matters most on Slimline (drains fast) but useful on every core.
var _lbl_box_count:        Label
## Visible monedas counter pill in the HUD. Was previously a hidden
## label inside the centre score column; promoted here to its own pill
## so the player sees their wallet during play, not only when entering
## the shop. Updated via _animate_monedas_to which tweens the count.
var _lbl_monedas_pill:     Label
var _lbl_monedas_pill_value: int = 0    # last value the pill DISPLAYED
var _lbl_descartes_count: Label
var _contracts_vbox:      VBoxContainer
var _artifacts_vbox:      VBoxContainer
var _usables_hbox:        HBoxContainer
var _lbl_tile_box_count:  Label
var _chain_info_lbl:      Label
var _chain_bonus_lbl:     Label
## Persistent boss-effect reminder shown in the chain info pill during
## boss rounds with non-stat effects. Hidden on normal / stat-cut bosses
## since the cinematic + stat changes are warning enough there.
var _boss_effect_lbl:     Label

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
	# Restore saved audio settings
	var _s: Dictionary = SaveManager.load_settings()
	AudioManager.set_sfx_volume(_s.get("sfx_volume", 1.0))
	AudioManager.set_music_volume(_s.get("music_volume", 0.70))
	AudioManager.set_mute(_s.get("muted", false))
	AudioManager.play_music("menu_theme")
	# Show "Continue" button only when a mid-run save exists
	if _btn_continue_run != null:
		_btn_continue_run.visible = SaveManager.has_saved_run()
	# Daily Trial: one attempt per calendar day. Locked once today's
	# attempt has been recorded; the button re-labels to show the result.
	_refresh_daily_trial_button()

func _on_title_start_pressed() -> void:
	_pending_core     = 0
	_pending_protocol = 0
	_title_overlay.hide()
	_refresh_core_cards()
	_core_select_overlay.show()

func _on_continue_run_pressed() -> void:
	if not SaveManager.has_saved_run():
		return
	_title_overlay.hide()
	SaveManager.load_run()
	_start_round()

## Open the daily-history overlay. Built lazily on first open so the UI
## tree stays slim if the player never uses the feature.
func _on_daily_history_pressed() -> void:
	if _daily_history_overlay == null:
		_daily_history_overlay = _build_daily_history_overlay()
		# Parent to the same UI layer the title overlay lives on.
		_title_overlay.get_parent().add_child(_daily_history_overlay)
	_refresh_daily_history_overlay()
	_daily_history_overlay.show()

func _on_daily_history_close_pressed() -> void:
	if _daily_history_overlay != null:
		_daily_history_overlay.hide()

func _on_achievements_pressed() -> void:
	if _achievements_overlay == null:
		_achievements_overlay = _build_achievements_overlay()
		_title_overlay.get_parent().add_child(_achievements_overlay)
	_refresh_achievements_overlay()
	_achievements_overlay.show()

func _on_achievements_close_pressed() -> void:
	if _achievements_overlay != null:
		_achievements_overlay.hide()

func _on_stats_pressed() -> void:
	if _stats_overlay == null:
		_stats_overlay = _build_stats_overlay()
		_title_overlay.get_parent().add_child(_stats_overlay)
	_refresh_stats_overlay()
	_stats_overlay.show()

func _on_stats_close_pressed() -> void:
	if _stats_overlay != null:
		_stats_overlay.hide()

func _on_help_pressed() -> void:
	if _help_overlay == null:
		_help_overlay = _build_help_overlay()
		_title_overlay.get_parent().add_child(_help_overlay)
	_help_overlay.show()

func _on_help_close_pressed() -> void:
	if _help_overlay != null:
		_help_overlay.hide()

func _on_codex_pressed() -> void:
	if _codex_overlay == null:
		_codex_overlay = _build_codex_overlay()
		_title_overlay.get_parent().add_child(_codex_overlay)
	_refresh_codex_overlay()
	_codex_overlay.show()

func _on_codex_close_pressed() -> void:
	if _codex_overlay != null:
		_codex_overlay.hide()

func _on_codex_tab_pressed(cat: int) -> void:
	_codex_active_cat = cat
	_refresh_codex_overlay()

## Copy today's daily result to the OS clipboard so the player can
## paste it into chat / social. Format is compact and recognisable —
## same shape as Wordle / Balatro daily share strings.
func _on_daily_share_pressed() -> void:
	if not SaveManager.daily_attempted_today():
		return
	var entry: Dictionary = SaveManager.get_daily_today()
	var won:   bool   = entry.get("won", false)
	var score: int    = int(entry.get("score", 0))
	var round_r: int  = int(entry.get("round_reached", 0))
	var seed_n: int   = SaveManager.today_daily_seed()
	var date_s: String = SaveManager.today_date_key()
	var streak: int   = SaveManager.daily_streak()
	# Compact, scannable. Seed lets others run the same daily for
	# verification; the operator name carries the lore framing
	# ("memorial cycle for a fallen Operator").
	var icon: String = "✓" if won else "✗"
	var op:   String = SaveManager.daily_operator_name(date_s)
	var verb: String = "honoured" if won else "fell again"
	var lines := [
		"Domination — Memorial Cycle %s" % date_s,
		"%s  %s %s.  R%d — %d Chronos" % [icon, op, verb, round_r, score],
		"Seed: %d" % seed_n,
	]
	if streak > 1:
		lines.append("Streak: %d days" % streak)
	var text: String = "\n".join(lines)
	DisplayServer.clipboard_set(text)
	# Brief toast confirming the copy. Pops at the share-button anchor
	# (panel center) so the player's eye is already there.
	var anchor: Vector2 = _daily_history_overlay.get_global_rect().get_center()
	_do_tile_pop("Copied!", C_WIN, anchor, 18, 1.10)
	AudioManager.play_sfx("module_equip")

## Begin today's daily trial. Skips core/protocol selection — daily uses
## the standard core + equilibrium protocol so every player faces the
## same starting state, and reseeds the RNG via GameState.start_daily_run.
## One attempt per day; the button is disabled once the attempt is logged.
func _on_daily_trial_pressed() -> void:
	if SaveManager.daily_attempted_today():
		return
	_title_overlay.hide()
	GameState.start_daily_run()
	# Skip the start-of-run tile-removal step too — daily is fixed-state.
	_start_round()

## Build the modal overlay shown when the player taps "📅 HISTORY" on
## the title screen. Layout:
##   header  : aggregate stats — total wins / attempts / current streak
##   body    : scrollable list of past attempts, newest first
##   footer  : close button
## State is reloaded each open via _refresh_daily_history_overlay.
func _build_daily_history_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 600)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.08, 0.06, 0.10, 0.98)   # tinted to match Daily violet
	ps.border_color = Color(0.70, 0.55, 0.95)
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.set_meta("history_root", true)
	panel.add_child(vbox)

	var title := _make_label("MEMORIAL CYCLES", C_TITLE_GLOW, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Stats strip — the actual labels are populated in _refresh_*. Names
	# are stored as meta so refresh can find them without globals.
	var strip := HBoxContainer.new()
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.add_theme_constant_override("separation", 24)
	vbox.add_child(strip)
	for key in ["streak", "wins", "attempts"]:
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		var caption := _make_label(key.to_upper(), C_DIM, 10)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(caption)
		var val := _make_label("0", C_TEXT, 20)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		FontManager.apply_mono(val)
		col.add_child(val)
		col.set_meta("stat_key", key)
		col.set_meta("stat_label", val)
		strip.add_child(col)
	vbox.set_meta("stats_strip", strip)

	vbox.add_child(_make_hsep())

	# Scrollable list of attempts.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(520, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)
	vbox.set_meta("history_list", list)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	# SHARE button — only meaningful once today's daily has been attempted.
	# Visibility toggled in _refresh_daily_history_overlay so it disappears
	# until there's something worth sharing.
	var share_btn := _make_button("📋  SHARE TODAY",
		_on_daily_share_pressed, Vector2(180, 44))
	share_btn.visible = false
	vbox.set_meta("share_btn", share_btn)
	btn_row.add_child(share_btn)

	btn_row.add_child(_make_button("CLOSE", _on_daily_history_close_pressed,
		Vector2(160, 44)))

	return overlay

func _refresh_daily_history_overlay() -> void:
	if _daily_history_overlay == null:
		return
	# The structure above stuffs the root vbox into the panel as the only
	# child of center → panel. Walk down to the vbox we tagged.
	var root: Node = _daily_history_overlay.get_child(0).get_child(0).get_child(0)
	var summary: Dictionary = SaveManager.daily_summary()
	var strip: Node = root.get_meta("stats_strip")
	for col in strip.get_children():
		if col is VBoxContainer and col.has_meta("stat_key"):
			var k: String = col.get_meta("stat_key")
			var lbl: Label = col.get_meta("stat_label")
			lbl.text = "%d" % int(summary.get(k, 0))

	var list: VBoxContainer = root.get_meta("history_list")
	for child in list.get_children():
		child.queue_free()

	var entries: Array = SaveManager.daily_history_sorted()
	if entries.is_empty():
		var empty := _make_label(
			"No attempts yet. Today's trial awaits.", C_DIM, 13)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list.add_child(empty)
	else:
		for entry in entries:
			list.add_child(_build_daily_history_row(entry))

	# SHARE button shows only when today has been attempted (the player
	# has something they could share). Hidden otherwise so the empty
	# state stays clean.
	if root.has_meta("share_btn"):
		var share_btn: Button = root.get_meta("share_btn")
		share_btn.visible = SaveManager.daily_attempted_today()

func _build_daily_history_row(entry: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var won: bool = entry.get("won", false)
	var icon := _make_label("✓" if won else "✗",
		C_WIN if won else C_LOSE, 16)
	icon.custom_minimum_size = Vector2(24, 0)
	row.add_child(icon)

	var date_str: String = String(entry.get("date", "?"))
	var date_lbl := _make_label(date_str, C_TEXT, 13)
	date_lbl.custom_minimum_size = Vector2(110, 0)
	FontManager.apply_mono(date_lbl)
	row.add_child(date_lbl)

	# Operator number — the fallen Operator whose memorial this Cycle
	# honoured. Same date always shows the same Operator across all
	# players (deterministic hash of the date key).
	var op_lbl := _make_label(
		SaveManager.daily_operator_name(date_str),
		C_TITLE_GLOW.darkened(0.2), 12)
	op_lbl.custom_minimum_size = Vector2(110, 0)
	FontManager.apply_mono(op_lbl)
	row.add_child(op_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var round_lbl := _make_label(
		"R%d" % int(entry.get("round_reached", 0)), C_DIM, 13)
	round_lbl.custom_minimum_size = Vector2(48, 0)
	FontManager.apply_mono(round_lbl)
	row.add_child(round_lbl)

	var score_lbl := _make_label(
		"%d" % int(entry.get("score", 0)), C_CHRONOS, 14)
	score_lbl.custom_minimum_size = Vector2(110, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	FontManager.apply_mono(score_lbl)
	row.add_child(score_lbl)

	return row

## Build the achievements browser overlay. Each Constants.ACHIEVEMENTS
## entry becomes a card showing icon, name, and unlock condition; earned
## cards render full-colour with a glow border, locked cards are dimmed.
## Lazy-built (called once on first open).
func _build_achievements_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 580)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.08, 0.07, 0.05, 0.98)
	ps.border_color = Color(0.85, 0.70, 0.30)   # warm amber match for "achievement" feel
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := _make_label("ACHIEVEMENTS", C_TITLE_GLOW, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := _make_label("", C_DIM, 12)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_meta("ach_summary", true)
	vbox.add_child(sub)

	vbox.add_child(_make_hsep())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 420)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	vbox.set_meta("ach_grid", grid)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button("CLOSE",
		_on_achievements_close_pressed, Vector2(160, 44)))

	return overlay

func _refresh_achievements_overlay() -> void:
	if _achievements_overlay == null:
		return
	var root: Node = _achievements_overlay.get_child(0).get_child(0).get_child(0)
	var lifetime: Dictionary = SaveManager.get_lifetime_stats()
	var streak:   int        = SaveManager.daily_streak()

	var earned_n: int = 0
	for i in range(Constants.ACHIEVEMENTS.size()):
		if Constants.achievement_earned(i, lifetime, streak):
			earned_n += 1
	for child in root.get_children():
		if child is Label and child.has_meta("ach_summary"):
			child.text = "%d / %d earned" % [earned_n, Constants.ACHIEVEMENTS.size()]
			break

	var grid: GridContainer = root.get_meta("ach_grid")
	for child in grid.get_children():
		child.queue_free()
	for i in range(Constants.ACHIEVEMENTS.size()):
		var earned: bool = Constants.achievement_earned(i, lifetime, streak)
		grid.add_child(_build_achievement_card(Constants.ACHIEVEMENTS[i], earned))

func _build_achievement_card(a: Dictionary, earned: bool) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(216, 92)
	var s := StyleBoxFlat.new()
	if earned:
		s.bg_color     = Color(0.14, 0.11, 0.06)
		s.border_color = Color(0.85, 0.70, 0.30)
	else:
		s.bg_color     = Color(0.06, 0.05, 0.04)
		s.border_color = Color(0.28, 0.24, 0.18)
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	s.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", s)
	if not earned:
		panel.modulate = Color(0.65, 0.65, 0.65)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var icon := _make_label(String(a.get("icon", "?")),
		Color(0.85, 0.70, 0.30) if earned else C_DIM, 26)
	icon.custom_minimum_size = Vector2(40, 0)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	hbox.add_child(col)

	col.add_child(_make_label(String(a.get("name", "?")),
		C_TEXT if earned else C_DIM, 13))
	var desc_lbl := _make_label(String(a.get("desc", "")), C_PREVIEW, 10)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(150, 0)
	col.add_child(desc_lbl)

	return panel

## Etapa vignette — a brief atmospheric overlay shown the FIRST round
## a player enters a new chamber of the Chronometer. Darkened backdrop
## with one evocative line in the etapa's accent colour, fades in and
## out over ~3 seconds. Fires only on round_index 5 / 10 / 15 (the
## transition rounds).
##
## Entry-of-Etapa lines, indexed by etapa (0=Mahogany start, 1-3 =
## transitions). Etapa 0 has no transition vignette — the player is
## arriving for the first time, the title screen + tutorial + Archiver
## already greet them.
const ETAPA_VIGNETTE_LINES: Array[String] = [
	"",   # Etapa 0 — no transition (you start here)
	"The mahogany gives way to steam. The brass is dripping.",
	"The temperature drops. The Machine breathes slower here.",
	"You are inside the Archive now. It is inside you.",
]

func _show_etapa_vignette(etapa: int) -> void:
	if etapa <= 0 or etapa >= ETAPA_VIGNETTE_LINES.size():
		return
	var line: String = ETAPA_VIGNETTE_LINES[etapa]
	if line.is_empty():
		return

	# Build a one-shot overlay each fire — quick to construct, cheap to
	# free. Using a fresh node avoids state leaking across vignettes.
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var accent: Color = Constants.ETAPA_ACCENT[clampi(etapa, 0, 3)]
	var lbl := _make_label(line, accent, 22)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate.a = 0.0
	FontManager.apply_mono(lbl)
	center.add_child(lbl)

	# Fade dark backdrop in, then text, hold, then fade everything out.
	var seq := create_tween()
	seq.tween_property(overlay, "color:a", 0.78, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	seq.parallel().tween_property(lbl, "modulate:a", 1.0, 0.55) \
		.set_delay(0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	seq.tween_interval(2.0)
	seq.tween_property(lbl, "modulate:a", 0.0, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	seq.parallel().tween_property(overlay, "color:a", 0.0, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	seq.tween_callback(overlay.queue_free)

## Archiver transmission strip. A thin, semi-transparent banner that
## fades in near the top of the viewport, holds for a few seconds, then
## fades out — used to surface a single line of Archiver dialogue at
## select round starts without blocking input.
##
## Lazy-built on first use so the scene tree stays slim if the line
## bank returns "" (no transmission for this round).
func _build_transmission_overlay() -> Control:
	var outer := Control.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	outer.custom_minimum_size = Vector2(0, 80)
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(center)

	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(560, 0)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := StyleBoxFlat.new()
	s.bg_color     = Color(0.04, 0.03, 0.05, 0.92)
	s.border_color = C_TITLE_GLOW.darkened(0.3)
	s.set_border_width_all(1)
	s.set_corner_radius_all(14)
	s.set_content_margin_all(12)
	pill.add_theme_stylebox_override("panel", s)
	center.add_child(pill)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	pill.add_child(hbox)

	# Eye glyph — the Archiver's signature (a single optical eye on brass).
	hbox.add_child(_make_label("◉", C_TITLE_GLOW.darkened(0.1), 14))
	hbox.add_child(_make_label("TRANSMISSION — ARCHIVE",
		C_DIM, 10))
	hbox.add_child(_make_label("·", C_DIM, 12))

	_transmission_label = _make_label("", C_TEXT, 13)
	_transmission_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	FontManager.apply_mono(_transmission_label)
	hbox.add_child(_transmission_label)

	outer.modulate.a = 0.0
	return outer

## Fade the transmission strip in with the given text, hold, then fade
## out. Re-entrant: a new call interrupts any in-flight fade.
func _show_transmission(text: String) -> void:
	if text.is_empty():
		return
	if _transmission_overlay == null:
		_transmission_overlay = _build_transmission_overlay()
		# Parent to the UI layer so it sits above gameplay but below modals.
		_ui_layer.add_child(_transmission_overlay)
	if _transmission_tween != null and _transmission_tween.is_valid():
		_transmission_tween.kill()
	_transmission_label.text = text
	_transmission_overlay.modulate.a = 0.0
	_transmission_overlay.show()
	_transmission_tween = create_tween()
	_transmission_tween.tween_property(_transmission_overlay,
		"modulate:a", 1.0, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_transmission_tween.tween_interval(3.2)
	_transmission_tween.tween_property(_transmission_overlay,
		"modulate:a", 0.0, 0.50) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

## Codex / Archive overlay — browsable lore archive that unlocks
## organically as the player encounters things across runs. Layout:
##
##   ┌───────────────────────────────────────────────┐
##   │  THE ARCHIVE                                  │
##   ├───────────────────────────────────────────────┤
##   │  PEOPLE  PLACES  CONCEPTS  ANOM.  FAIL.  TX.  │  ← tab strip
##   ├───────────────────────────────────────────────┤
##   │                                               │
##   │   Entry name              X / Y unlocked      │
##   │   ──────────────────────                      │
##   │   <body text, scrollable>                     │
##   │                                               │
##   │   [previous]  [next entry]                    │
##   ├───────────────────────────────────────────────┤
##   │                  [ CLOSE ]                    │
##   └───────────────────────────────────────────────┘
##
## Locked entries appear in the list as "???" — selectable so the
## player sees the unlock hint, but with no body until earned.
func _build_codex_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.92)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820, 640)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.07, 0.05, 0.04, 0.98)
	ps.border_color = C_TITLE_GLOW.darkened(0.2)
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Title strip
	var title := _make_label("THE ARCHIVE", C_TITLE_GLOW, 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(title)
	vbox.add_child(title)

	vbox.add_child(_make_hsep())

	# Category tabs — rebuilt each refresh so the active highlight + the
	# X/Y progress counter stays current.
	var tab_strip := HBoxContainer.new()
	tab_strip.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_strip.add_theme_constant_override("separation", 4)
	vbox.add_child(tab_strip)
	vbox.set_meta("codex_tabs", tab_strip)

	vbox.add_child(_make_hsep())

	# Two-column body: list of entry titles on the left, detail of the
	# selected entry on the right. The selected entry index is tracked
	# in tab_strip's meta so a category change can reset it.
	var body_hbox := HBoxContainer.new()
	body_hbox.add_theme_constant_override("separation", 12)
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body_hbox)

	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(240, 480)
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_hbox.add_child(list_scroll)
	var list_col := VBoxContainer.new()
	list_col.add_theme_constant_override("separation", 2)
	list_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(list_col)
	vbox.set_meta("codex_list", list_col)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.custom_minimum_size = Vector2(540, 480)
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_hbox.add_child(detail_scroll)
	var detail_col := VBoxContainer.new()
	detail_col.add_theme_constant_override("separation", 10)
	detail_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(detail_col)
	vbox.set_meta("codex_detail", detail_col)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button("CLOSE",
		_on_codex_close_pressed, Vector2(160, 44)))

	return overlay

func _refresh_codex_overlay() -> void:
	if _codex_overlay == null:
		return
	var root: Node = _codex_overlay.get_child(0).get_child(0).get_child(0)
	var lifetime: Dictionary = SaveManager.get_lifetime_stats()
	var seen:     Array      = SaveManager.codex_seen()
	var streak:   int        = SaveManager.daily_streak()

	# Rebuild the tab strip with current progress per category.
	var tabs: HBoxContainer = root.get_meta("codex_tabs")
	for child in tabs.get_children():
		child.queue_free()
	for cat in range(Codex.CATEGORY_NAMES.size()):
		var name: String = Codex.CATEGORY_NAMES[cat]
		var total: int   = Codex.count_in_category(cat)
		var got:   int   = Codex.unlocked_in_category(cat, lifetime, seen, streak)
		var label: String = "%s  %d/%d" % [name, got, total]
		var btn := Button.new()
		btn.text = label
		btn.add_theme_font_size_override("font_size", 11)
		btn.custom_minimum_size = Vector2(0, 32)
		btn.pressed.connect(_on_codex_tab_pressed.bind(cat))
		# Active tab — chronos-green border for distinction
		var s := StyleBoxFlat.new()
		s.bg_color     = Color(0.10, 0.08, 0.06) if cat != _codex_active_cat \
			else Color(0.10, 0.18, 0.13)
		s.border_color = C_DIM if cat != _codex_active_cat \
			else C_CHRONOS
		s.set_border_width_all(1 if cat != _codex_active_cat else 2)
		s.set_corner_radius_all(4)
		s.set_content_margin_all(6)
		btn.add_theme_stylebox_override("normal", s)
		btn.add_theme_stylebox_override("hover", s)
		tabs.add_child(btn)

	# Find entries in the active category, build the list.
	var list_col: VBoxContainer = root.get_meta("codex_list")
	for child in list_col.get_children():
		child.queue_free()
	var entries_in_cat: Array = []
	for i in range(Codex.ENTRIES.size()):
		if int(Codex.ENTRIES[i].get("category", -1)) == _codex_active_cat:
			entries_in_cat.append(i)
	# Selection: persist within this overlay session. Reset on tab change.
	var selected_idx: int = root.get_meta("codex_selected", -1)
	if not selected_idx in entries_in_cat:
		selected_idx = entries_in_cat[0] if not entries_in_cat.is_empty() else -1
		root.set_meta("codex_selected", selected_idx)

	for entry_idx in entries_in_cat:
		var unlocked: bool = Codex.is_unlocked(entry_idx, lifetime, seen, streak)
		var entry: Dictionary = Codex.ENTRIES[entry_idx]
		var btn := _build_codex_list_entry(entry, unlocked,
			entry_idx == selected_idx, entry_idx)
		list_col.add_child(btn)

	# Detail panel for the selected entry.
	var detail_col: VBoxContainer = root.get_meta("codex_detail")
	for child in detail_col.get_children():
		child.queue_free()
	if selected_idx >= 0:
		var entry: Dictionary = Codex.ENTRIES[selected_idx]
		var unlocked: bool = Codex.is_unlocked(selected_idx, lifetime, seen, streak)
		var name_lbl: Label = _make_label(
			entry["name"] if unlocked else "??? ??? ???",
			C_TITLE_GLOW if unlocked else C_DIM, 18)
		FontManager.apply_mono(name_lbl)
		detail_col.add_child(name_lbl)

		var sep := ColorRect.new()
		sep.color = C_TITLE_GLOW.darkened(0.5)
		sep.custom_minimum_size = Vector2(0, 1)
		detail_col.add_child(sep)

		var body_text: String
		if unlocked:
			body_text = String(entry.get("body", ""))
		else:
			body_text = "Undiscovered.\n\n" + \
				String(entry.get("unlock", {}).get("hint", ""))
		var body_lbl: Label = _make_label(body_text, C_TEXT, 13)
		body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body_lbl.custom_minimum_size = Vector2(520, 0)
		detail_col.add_child(body_lbl)

func _build_codex_list_entry(entry: Dictionary, unlocked: bool,
		selected: bool, entry_idx: int) -> Control:
	var btn := Button.new()
	btn.text = entry["name"] if unlocked else "???"
	btn.add_theme_font_size_override("font_size", 12)
	btn.custom_minimum_size = Vector2(0, 30)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_on_codex_entry_pressed.bind(entry_idx))
	var s := StyleBoxFlat.new()
	if selected:
		s.bg_color     = Color(0.10, 0.18, 0.13)
		s.border_color = C_CHRONOS
		s.set_border_width_all(1)
	else:
		s.bg_color     = Color(0.09, 0.07, 0.05) if unlocked \
			else Color(0.06, 0.05, 0.04)
		s.border_color = Color(0.25, 0.20, 0.12) if unlocked \
			else Color(0.18, 0.15, 0.10)
		s.set_border_width_all(1)
	s.set_corner_radius_all(3)
	s.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("hover", s)
	if not unlocked:
		btn.add_theme_color_override("font_color", C_DIM)
	return btn

func _on_codex_entry_pressed(entry_idx: int) -> void:
	if _codex_overlay == null:
		return
	var root: Node = _codex_overlay.get_child(0).get_child(0).get_child(0)
	root.set_meta("codex_selected", entry_idx)
	_refresh_codex_overlay()

## Help / glossary overlay — quick reference for game terms and rules.
## Replaces the player's reliance on the one-time tutorial. Sectioned by
## topic so the player can scan-find what they need without reading the
## whole document.
func _build_help_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 600)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.07, 0.06, 0.05, 0.98)
	ps.border_color = C_TITLE_GLOW.darkened(0.2)
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := _make_label("HELP & GLOSSARY", C_TITLE_GLOW, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_hsep())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(640, 460)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	# Sections — keys and short bodies. Multi-line bodies use \n.
	var sections: Array = [
		["THE BASICS", [
			["Objective",
				"Reach the round's Chronos target. Build a chain of dominoes; chain score = chips × multiplier."],
			["Persistent Chain",
				"The chain is shared across all hands in a round. Every play extends the same chain — it doesn't reset.\nThe round target is checked against the chain's final score."],
			["Hands & Discards",
				"Each round you have a fixed number of plays (hands) and discards. Use them sparingly — running out without hitting target ends the run."],
		]],
		["TIER BONUSES", [
			["Pulse",       "4-6 tiles → +1 mult"],
			["Cohesion",    "7-10 tiles → +2 mult"],
			["Resonance",   "11-15 tiles → +4 mult"],
			["Harmonic",    "16-20 tiles → +7 mult"],
			["Singularity", "21+ tiles → +12 mult"],
		]],
		["DOUBLES & BRANCHING", [
			["Doubles",
				"A double tile (e.g. 5|5) grants +1 mult per double in the chain.\nThe first 5 doubles count fully; further doubles count for half (so all-doubles builds don't run away)."],
			["Branching",
				"When a double is placed, its pip value becomes a NEW open end.\nFuture tiles can match the chain's left end, right end, OR any branch end. Branches are shown as small badges above the chain."],
		]],
		["ROUND ACTIONS", [
			["Play",        "Commit the selected tiles to the chain. Scores the full chain."],
			["Discard",     "Return selected tiles to the box and draw replacements. Targeted re-draw — fitting tiles are surfaced first when possible."],
			["Stand",       "Once you've crossed the round target, lock in your score. Banks any unused hands as bonus Monedas."],
			["Pass Hand",   "Anti-softlock: if no tile fits and no productive discard exists, burn one hand and redraw."],
		]],
		["BOSS EFFECTS", [
			["Frequency Drain (Boss 1)",
				"Hand size −1 for the round."],
			["Mirror Decay (Boss 2)",
				"Each pip's chip contribution is INVERTED — a 9 scores as 0, a 0 scores as 9. Lean low-pip / blank-heavy this round."],
			["Resonance Inversion (Boss 3)",
				"Doubles SUBTRACT from your multiplier instead of adding. Avoid stacking doubles for one round."],
			["Ghost Chain (Boss 4)",
				"A third of your placed tiles fade from view. Trust your memory."],
		]],
		["MODULES & ARCHETYPES", [
			["Modules",
				"Bought at the Brass Emporium / Artisan's Workshop. Modify scoring, economy, or rules. Up to 4 active slots (some modules grant +1 slot)."],
			["Archetypes",
				"Each module belongs to an archetype: Doubles, Long-Chain, High-Pip, Blanks, Sacrifice, Economy, Utility.\nThe shop biases toward archetypes you already own — synergy builds form naturally."],
		]],
		["MONEDAS", [
			["Earning",
				"Round-clear bonus + 1 per unused hand + boss bonus + module income + directive rewards."],
			["Spending",
				"Modules at the Emporium, special tiles + tile removals at the Workshop."],
		]],
	]

	for sec in sections:
		var section_title: String = sec[0]
		var entries: Array = sec[1]
		content.add_child(_build_help_section_header(section_title))
		for entry in entries:
			content.add_child(_build_help_row(entry[0], entry[1]))

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button("CLOSE",
		_on_help_close_pressed, Vector2(160, 44)))

	return overlay

func _build_help_section_header(text: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	var lbl := _make_label(text, C_TITLE_GLOW, 14)
	FontManager.apply_mono(lbl)
	hbox.add_child(lbl)
	var line := ColorRect.new()
	line.color = C_TITLE_GLOW.darkened(0.5)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(line)
	return hbox

func _build_help_row(key: String, body: String) -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var k := _make_label(key, C_MONEDAS, 13)
	FontManager.apply_mono(k)
	vbox.add_child(k)

	var b := _make_label(body, C_TEXT, 12)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(620, 0)
	vbox.add_child(b)

	return vbox

## Lifetime statistics overlay — browsable breakdown of every stat
## SaveManager tracks across runs. Sections:
##
##   RUNS         — runs / wins / win rate
##   CHAINS       — longest chain, best tier reached
##   PLAY         — hands played, doubles placed, total chronos
##   PROGRESSION  — furthest round, achievements earned, modules seen
##   DAILY        — attempts, wins, current streak
##
## All values are read-only snapshots; no edit affordances. Lazy-built
## on first open (same pattern as achievements / daily history).
func _build_stats_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 600)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.07, 0.06, 0.05, 0.98)
	ps.border_color = C_CHRONOS.darkened(0.2)
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := _make_label("LIFETIME STATISTICS", C_TITLE_GLOW, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_hsep())

	# Sections panel — content rebuilt by _refresh_stats_overlay so we
	# don't need to thread per-section labels through metadata. Just
	# stash the host VBox and replace its children on refresh.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(580, 460)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	vbox.set_meta("stats_content", content)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button("CLOSE",
		_on_stats_close_pressed, Vector2(160, 44)))

	return overlay

func _refresh_stats_overlay() -> void:
	if _stats_overlay == null:
		return
	var root: Node = _stats_overlay.get_child(0).get_child(0).get_child(0)
	var content: VBoxContainer = root.get_meta("stats_content")
	for child in content.get_children():
		child.queue_free()

	var lt: Dictionary = SaveManager.get_lifetime_stats()
	var streak: int = SaveManager.daily_streak()
	var daily: Dictionary = SaveManager.daily_summary()

	var runs: int = int(lt.get("runs", 0))
	var wins: int = int(lt.get("wins", 0))
	var win_rate_str: String = "—"
	if runs > 0:
		win_rate_str = "%d%%" % int(round(100.0 * wins / float(runs)))

	var best_tier: int = int(lt.get("best_tier", -1))
	var best_tier_str: String = "—"
	if best_tier >= 0 and best_tier < Constants.CHAIN_TIER_NAMES.size():
		best_tier_str = Constants.CHAIN_TIER_NAMES[best_tier]

	var ach_total: int = Constants.ACHIEVEMENTS.size()
	var ach_earned: int = 0
	for i in range(ach_total):
		if Constants.achievement_earned(i, lt, streak):
			ach_earned += 1

	var modules_seen: Array = lt.get("modules_seen", [])

	# Helper closure — append a section header + key/value rows.
	var add_section: Callable = func(title_s: String, rows: Array):
		content.add_child(_build_stats_section_header(title_s))
		for r in rows:
			content.add_child(_build_stats_row(r[0], r[1]))

	add_section.call("RUNS", [
		["Total runs",      "%d" % runs],
		["Wins",            "%d" % wins],
		["Win rate",        win_rate_str],
		["Furthest round",  "%d" % int(lt.get("best_round", 0))],
	])
	add_section.call("CHAINS", [
		["Longest chain",   "%d tiles" % int(lt.get("longest_chain", 0))],
		["Best tier",       best_tier_str],
	])
	add_section.call("PLAY", [
		["Hands played",    "%d" % int(lt.get("hands_played", 0))],
		["Doubles played",  "%d" % int(lt.get("doubles_played", 0))],
		["Total Chronos",   "%d" % int(lt.get("chronos", 0))],
	])
	add_section.call("PROGRESSION", [
		["Achievements",    "%d / %d" % [ach_earned, ach_total]],
		["Modules seen",    "%d" % modules_seen.size()],
	])
	add_section.call("DAILY TRIAL", [
		["Attempts",        "%d" % int(daily.get("attempts", 0))],
		["Wins",            "%d" % int(daily.get("wins", 0))],
		["Current streak",  "%d days" % streak],
	])

func _build_stats_section_header(text: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	var lbl := _make_label(text, C_CHRONOS, 13)
	FontManager.apply_mono(lbl)
	hbox.add_child(lbl)
	var line := ColorRect.new()
	line.color = C_CHRONOS.darkened(0.5)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(line)
	return hbox

func _build_stats_row(key: String, value: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var k := _make_label(key, C_DIM, 12)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(k)

	var v := _make_label(value, C_TEXT, 13)
	FontManager.apply_mono(v)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.custom_minimum_size = Vector2(180, 0)
	hbox.add_child(v)

	return hbox

## Update the Daily Trial button label and enabled state. Called from
## _show_title and from anywhere that might transition back to the title.
func _refresh_daily_trial_button() -> void:
	if _btn_daily_trial == null:
		return
	var op: String = SaveManager.daily_operator_name()
	if SaveManager.daily_attempted_today():
		var d: Dictionary = SaveManager.get_daily_today()
		var icon: String = "✓" if d.get("won", false) else "✗"
		_btn_daily_trial.text     = "DAILY TRIAL  %s" % icon
		_btn_daily_trial.disabled = true
		if _lbl_daily_memorial != null:
			var verb: String = "honoured" if d.get("won", false) else "fell again"
			_lbl_daily_memorial.text = "Today: %s — %s." % [op, verb]
	else:
		_btn_daily_trial.text     = "DAILY TRIAL  ↺"
		_btn_daily_trial.disabled = false
		if _lbl_daily_memorial != null:
			_lbl_daily_memorial.text = "Today's Memorial: %s." % op

func _on_settings_btn_pressed() -> void:
	_refresh_settings_overlay()
	_settings_overlay.show()

## Show the mid-run pause overlay. Lazy-built on first open. Doesn't
## change _phase (the play state stays PLAYING so refreshes still target
## the right widgets), but the overlay sits on top of the UI layer and
## blocks input via a full-rect MOUSE_FILTER_STOP backdrop.
func _on_pause_pressed() -> void:
	if _phase != Phase.PLAYING:
		return
	if _pause_overlay == null:
		_pause_overlay = _build_pause_overlay()
		_title_overlay.get_parent().add_child(_pause_overlay)
	_pause_overlay.show()

func _on_pause_resume_pressed() -> void:
	if _pause_overlay != null:
		_pause_overlay.hide()

func _on_pause_settings_pressed() -> void:
	# Close the pause overlay, open settings on top. Settings has its own
	# close handling and the player returns to play directly from there
	# without seeing the pause overlay again — settings is the natural
	# follow-on action.
	if _pause_overlay != null:
		_pause_overlay.hide()
	_on_settings_btn_pressed()

## Quit the current run back to the title screen. Daily runs forfeit
## today's attempt as a loss (one-attempt-per-day rule prevents rage-
## quitting bad starts), so we route through a confirm dialog first.
## Regular runs auto-save; quit is non-destructive so it goes straight.
func _on_pause_quit_pressed() -> void:
	if GameState.is_daily_run:
		_show_quit_confirm()
		return
	_quit_to_title()

## Actually perform the quit. Called from _on_pause_quit_pressed for
## regular runs and from the confirm dialog's "QUIT" branch for dailies.
func _quit_to_title() -> void:
	if GameState.is_daily_run:
		SaveManager.record_daily_attempt(false,
			GameState.total_chronos, GameState.round_index)
	if _pause_overlay != null:
		_pause_overlay.hide()
	if _quit_confirm_overlay != null:
		_quit_confirm_overlay.hide()
	_phase = Phase.TITLE
	_show_title()

## Lazy-built modal that warns the player today's daily will be
## recorded as a loss. Two buttons: KEEP PLAYING (cancel) and FORFEIT
## (proceed to _quit_to_title). Sits over the pause overlay rather than
## replacing it, so cancelling drops back to the pause menu.
func _show_quit_confirm() -> void:
	if _quit_confirm_overlay == null:
		_quit_confirm_overlay = _build_quit_confirm_overlay()
		_title_overlay.get_parent().add_child(_quit_confirm_overlay)
	_quit_confirm_overlay.show()

func _on_quit_confirm_cancel() -> void:
	if _quit_confirm_overlay != null:
		_quit_confirm_overlay.hide()

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
	_register_cinematic(seq)

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
	_play_boss_entry_flash()

## Brief red table flash + screen shake when the player commits to a boss
## round. Reinforces "this is dangerous" right as control returns to play.
## The flash bg colour is tweened back to the etapa's normal table tone so
## it overlays cleanly with the existing etapa-theme transition.
func _play_boss_entry_flash() -> void:
	if _table_style == null:
		return
	var etapa: int = clampi(GameState.current_etapa(), 0, 3)
	var normal_bg: Color = Constants.ETAPA_TABLE[etapa]
	var flash_bg:  Color = Color(0.55, 0.06, 0.06, normal_bg.a)
	var t := create_tween()
	t.tween_method(func(c: Color): _table_style.bg_color = c,
		normal_bg, flash_bg, 0.10)
	t.tween_method(func(c: Color): _table_style.bg_color = c,
		flash_bg, normal_bg, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Modest screen-shake on the same beat as the flash peak.
	_maybe_table_shake(220)
	AudioManager.play_sfx("chain_play")

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
	# Reset tier-crossing tracker so each round can celebrate its tier
	# milestones independently.
	_last_tier_reached = -1
	_target_celebrated = false

	_dm = DirectiveManager.new()
	# Per-core directive count override (The Runner core starts with 3
	# active directive slots instead of the standard 2).
	var directive_count: int = 2
	if GameState.chosen_core >= 0 and GameState.chosen_core < Constants.CORE_PROFILES.size():
		directive_count = int(Constants.CORE_PROFILES[GameState.chosen_core] \
			.get("start_directives", 2))
	_dm.setup(_rm, directive_count)
	_dm.directive_completed.connect(_on_directive_completed)

	_result_overlay.hide()
	_shop_overlay.hide()
	_refresh_hud()
	# Music: boss rounds get the heavier track
	var track := "boss_ambient" if GameState.is_boss_round() else "game_ambient"
	AudioManager.play_music(track)
	_rebuild_hand()
	_refresh_chain_display()
	_refresh_directives()
	_refresh_module_rack()
	_refresh_boss_effect_lbl()
	_start_ambient_effects(GameState.current_etapa())
	# Etapa vignette — fires once when the player enters a new chamber
	# of the Chronometer (round_index 5 / 10 / 15 = first round of
	# Etapas II / III / IV). Played BEFORE the Archiver transmission so
	# the vignette lands first, then the Archiver speaks once it's gone.
	var entering_new_etapa: bool = (GameState.round_index == 5
		or GameState.round_index == 10
		or GameState.round_index == 15)
	if entering_new_etapa:
		get_tree().create_timer(0.40).timeout.connect(
			_show_etapa_vignette.bind(GameState.current_etapa()),
			CONNECT_ONE_SHOT)

	# Tutorial: show on the very first round of a brand-new run
	if GameState.round_index == 0 and not SaveManager.is_tutorial_seen():
		get_tree().create_timer(0.55).timeout.connect(_start_tutorial, CONNECT_ONE_SHOT)
	# Archiver transmission. Skipped on boss rounds (the cinematic + the
	# persistent ⚠ label already speak for the boss), and on the first
	# round of a brand-new run while the tutorial is firing. When entering
	# a new etapa, delay enough that the vignette plays out first.
	elif not GameState.is_boss_round():
		var lifetime: Dictionary = SaveManager.get_lifetime_stats()
		var line: String = Archiver.line_for_round(
			GameState.round_index, lifetime)
		if not line.is_empty():
			# 0.65s default delay; longer when stacked behind a vignette
			# (vignette ~3s total, so wait it out).
			var delay: float = 3.6 if entering_new_etapa else 0.65
			get_tree().create_timer(delay).timeout.connect(
				_show_transmission.bind(line), CONNECT_ONE_SHOT)

func _end_round(won: bool) -> void:
	if won:
		AudioManager.play_sfx("round_clear")
		_phase = Phase.ROUND_RESULT
		# Check round-end directives before awarding monedas
		var dir_bonus: int = _dm.check_round_win()
		GameState.monedas += dir_bonus
		var earned: int = GameState.award_monedas(_rm.unused_hands())
		# Codex: first round-clear introduces the Guild and their currency.
		# Failure entries auto-unlock via their `best_round` stat gates
		# at boss-encounter time, so no explicit hook needed there.
		SaveManager.unlock_codex("copper_guild")
		SaveManager.unlock_codex("monedas")
		_lbl_result.text = "RECALIBRATION SUCCESSFUL"
		_lbl_result.add_theme_color_override("font_color", C_WIN)
		_lbl_result_sub.text = _build_round_summary_text(earned, dir_bonus)
		var shop_name: String = \
			"ARTISAN'S WORKSHOP" if GameState.is_boss_round() else "BRASS EMPORIUM"
		_btn_result_action.text = "VISIT " + shop_name
	else:
		_show_run_end(false)
		return
	# Snapshot run state the moment the round is banked. If the player
	# crashes during the shop phase or in the boss-warning cinematic
	# they keep the round-clear (monedas + advanced index).
	SaveManager.save_run()
	_result_overlay.show()

## Compose the round-summary text shown in the result overlay. Pulls the
## final chain stats from the Scoring module so the breakdown reflects all
## modifiers (doubles bonus, tier bonus, module-driven mult/chips).
func _build_round_summary_text(monedas_earned: int, dir_bonus: int) -> String:
	if _rm == null or _rm.current_chain == null:
		return "Chronos: %d / %d    +%d Monedas" % [
			_rm.chronos if _rm else 0, _rm.target if _rm else 0, monedas_earned]

	var result: Dictionary = Scoring.calculate(_rm.current_chain, GameState.modules)
	var length:  int = result.get("length", 0)
	var doubles: int = result.get("doubles", 0)
	var chips:   int = result.get("chips", 0)
	var mult:    int = result.get("mult", 1)

	# Highest tier the chain reached + the bonus it contributed.
	var tier_name:  String = "Fragment"
	var tier_bonus: int    = 0
	for ti in range(Constants.CHAIN_TIER_MIN.size() - 1, -1, -1):
		if length >= Constants.CHAIN_TIER_MIN[ti]:
			tier_name  = Constants.CHAIN_TIER_NAMES[ti]
			tier_bonus = Constants.CHAIN_TIER_BONUS[ti]
			break

	# Doubles mult bonus (with the diminishing-returns cap from scoring.gd).
	var full_d:  int = mini(doubles, Constants.DOUBLES_FULL_THRESHOLD)
	var bonus_d: int = maxi(0, doubles - Constants.DOUBLES_FULL_THRESHOLD)
	var doubles_mult_bonus: int = full_d + bonus_d / 2

	# Monedas breakdown — mirrors GameState.award_monedas.
	var base_m:   int = Constants.MONEDAS_PER_ROUND
	var unused:   int = _rm.unused_hands()
	var unused_m: int = unused * Constants.MONEDAS_PER_UNUSED_HAND
	var boss_m:   int = Constants.BOSS_MONEDAS_BONUS if GameState.is_boss_round() else 0
	var module_m: int = monedas_earned - base_m - unused_m - boss_m

	var lines: Array = []
	lines.append("Chronos: %d / %d" % [_rm.chronos, _rm.target])
	lines.append("")
	lines.append("══ Chain ══")
	lines.append("%d tiles · %d doubles · %s tier" % [length, doubles, tier_name])
	lines.append("%d chips × %d mult = %d Chronos" % [chips, mult, chips * mult])
	lines.append("")
	lines.append("══ Mult sources ══")
	lines.append("  Base: ×1")
	if doubles_mult_bonus > 0:
		var note: String = ""
		if bonus_d > 0:
			note = "  (cap: first %d full, rest half)" % Constants.DOUBLES_FULL_THRESHOLD
		lines.append("  Doubles (%d): +%d%s" % [doubles, doubles_mult_bonus, note])
	if tier_bonus > 0:
		lines.append("  Tier (%s): +%d" % [tier_name, tier_bonus])
	lines.append("")
	lines.append("══ Monedas earned: +%d ══" % monedas_earned)
	lines.append("  Round base: +%d" % base_m)
	if unused_m > 0:
		lines.append("  Unused hands (%d): +%d" % [unused, unused_m])
	if boss_m > 0:
		lines.append("  Boss bonus: +%d" % boss_m)
	if module_m > 0:
		lines.append("  Modules: +%d" % module_m)
	if dir_bonus > 0:
		lines.append("  Directives: +%d" % dir_bonus)

	# Near-miss nudge: how close were we to the next bonus tier?
	var next_threshold: int = -1
	for t_min in Constants.CHAIN_TIER_MIN:
		if length < t_min:
			next_threshold = t_min
			break
	if next_threshold > 0:
		var to_go: int = next_threshold - length
		lines.append("")
		lines.append("Almost: %d more tile%s to next tier." % [to_go, "s" if to_go > 1 else ""])

	return "\n".join(lines)

func _show_shop() -> void:
	_phase = Phase.SHOP
	_result_overlay.hide()
	_ambient_active = false

	var etapa: int = GameState.current_etapa()
	var owned_ids: Array = GameState.modules.map(func(m): return m.id)
	# Pass full module objects too — ShopManager uses them to derive the
	# player's archetype investment and bias shop offers toward synergies.
	var owned_modules: Array = GameState.modules
	if GameState.is_boss_round():
		_lbl_shop_title.text = "THE ARTISAN'S WORKSHOP"
		_lbl_shop_greeting.text = ARTISAN_GREETINGS[clampi(etapa, 0, 3)]
		_shop_inventory = ShopManager.generate_artisan(owned_ids, owned_modules)
		_tile_offers = TileShopManager.generate_offers(3)
		_tile_offers_bought.clear()
		_removal_candidates = TileShopManager.generate_removal_candidates(GameState.box, 8)
		_removal_selected.clear()
		_artisan_section.show()
		# Codex: meeting the Workshop crew. The Forge's keeper plus the
		# unsanctioned Mechanic both appear here post-boss. Module
		# discoveries are gated on actual purchase / equip, not just
		# encountering the shop.
		SaveManager.unlock_codex("master_of_forge")
		SaveManager.unlock_codex("renegade_mechanic")
	else:
		_lbl_shop_title.text = "THE BRASS EMPORIUM"
		_lbl_shop_greeting.text = EMPORIUM_GREETINGS[clampi(etapa, 0, 3)]
		_shop_inventory = ShopManager.generate_emporium(3, owned_ids, owned_modules)
		_artisan_section.hide()
		# Codex: first contact with the Emporium's automated terminal.
		SaveManager.unlock_codex("emporium_voice")

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
	# Don't tear down the chain panels mid-scoring — the in-place glow/scale
	# animation runs on those exact nodes and would end up animating dead
	# references. A final refresh fires from the scoring sequence's last step.
	if _scoring_active:
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
	# In the persistent-chain model, `result` describes the FULL chain after
	# this play. `delta_total` is what this placement actually contributed.
	var delta_total: int = result.get("delta_total", result["total"])
	var prev_length: int = result.get("prev_length", 0)
	var new_length:  int = result.get("length", 0)

	_lbl_last_hand.text = "%d chips  ×  %d  =  %d Chronos" % [
		result["chips"], result["mult"], result["total"]]
	GameState.record_hand(delta_total, result.get("doubles", 0))
	# Track per-run maxima for the run-end recap and lifetime stats.
	if new_length > GameState.longest_chain:
		GameState.longest_chain = new_length
	for ti in range(Constants.CHAIN_TIER_MIN.size() - 1, -1, -1):
		if new_length >= Constants.CHAIN_TIER_MIN[ti]:
			if ti > GameState.best_tier:
				GameState.best_tier = ti
			break
	var dir_bonus: int = _dm.check_play(result)
	if dir_bonus > 0:
		GameState.monedas += dir_bonus
	# CHAIN_COIN_BONUS — only fire when this play crosses a threshold,
	# otherwise the same chain would re-trigger every subsequent play.
	var coin_bonus: int = GameState.chain_coin_bonus_crossed(prev_length, new_length)
	if coin_bonus > 0:
		GameState.monedas += coin_bonus
	# FORTUNE_ESSENCE — one-shot: +2 bonus Monedas (or 2× module bonus, whichever is larger)
	if _fortune_essence_active:
		_fortune_essence_active = false
		GameState.monedas += maxi(2, coin_bonus)   # guaranteed at least 2 even with no module
	# GOLD_TALISMAN — one-shot: +10 bonus chips fed back as Chronos.
	# Routed through `extra_chronos` so it survives the chain re-score on
	# the next play (which would otherwise overwrite a direct chronos bump).
	if _talisman_active:
		_talisman_active = false
		var talisman_chronos: int = 10 * result.get("mult", 1)
		_rm.extra_chronos += talisman_chronos
		_rm.chronos       += talisman_chronos

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

	# Snapshot every chain tile while it's still on screen. Tiles are now
	# distributed across multiple serpentine rows, so we iterate the ordered
	# `_chain_tile_panels` list (chain-index → panel) rather than scanning
	# direct container children.
	var overlay_infos: Array = []
	var chain_tiles: Array = _rm.current_chain.tiles.duplicate()
	for idx in range(chain_tiles.size()):
		if idx < _chain_tile_panels.size() and is_instance_valid(_chain_tile_panels[idx]):
			var child: Control = _chain_tile_panels[idx]
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
			# Per-tile module-firing tags. Short label per module type that
			# actually contributed chips/mult on THIS specific tile, so the
			# scoring animation can pop a tag above the tile and the player
			# can see which tile triggered which module bonus.
			var fired_tags: Array = []
			if is_sac:
				chips = 0   # sacrificed — traded for mult
				fired_tags.append("SACRIFICE")
			elif dw > 0 and tile.is_wild and wild_pip_chips_ui > 0:
				chips = wild_pip_chips_ui
				fired_tags.append("WILD")
			elif dw > 0:
				chips = pips * double_pip_mult + tile.bonus_chips
				if double_pip_mult > 1:
					fired_tags.append("DOUBLE")
			else:
				chips = pips + tile.bonus_chips
				if blank_pip_val_ui > 0 and not tile.is_wild:
					var blank_count: int = (1 if tile.left == 0 else 0) \
						+ (1 if tile.right == 0 else 0)
					if blank_count > 0:
						chips += blank_pip_val_ui * blank_count
						fired_tags.append("BLANK")
			# HIGH_PIP_BONUS triggers when max(left, right) ≥ threshold.
			# Re-derive here without re-iterating modules — we only need
			# to know whether ANY high-pip module fired on this tile.
			if not tile.is_wild:
				for m in GameState.modules:
					if m.effect_type == Module.EffectType.HIGH_PIP_BONUS \
							and max(tile.left, tile.right) >= m.effect_param:
						chips += m.effect_value
						fired_tags.append("HIGH-PIP")
						break

			# `panel` is the actual chain tile, animated in place. No overlay
			# duplicate is built any more — the tile itself glows and scales.
			overlay_infos.append({
				"panel":      child,
				"center":     child.global_position + child.size * 0.5,
				"chips":      chips,
				"is_double":  dw > 0,
				"is_wild":    tile.is_wild,
				"max_pip":    max(tile.left, tile.right),
				"has_blank":  not tile.is_wild and (tile.left == 0 or tile.right == 0),
				"total_pips": pips if not tile.is_wild else 999,
				"tags":       fired_tags,
			})

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
	# If a reinforcement is waiting for a tile target, route there instead
	if _reinforcement_pending != null:
		_on_tile_targeting_click(index)
		return
	# Normal Balatro-style selection toggle
	if index in _selected_tiles:
		_selected_tiles.erase(index)
		AudioManager.play_sfx("tile_deselect")
	else:
		_selected_tiles.append(index)
		AudioManager.play_sfx("tile_click")
	_refresh_tile_visuals()
	_refresh_chain_display()
	_refresh_action_buttons()

func _on_play_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active or _selected_tiles.is_empty():
		return
	if _rm.hands_remaining <= 0:
		return

	AudioManager.play_sfx("chain_play")
	# Validate: the selected tiles must extend the PERSISTENT chain legally.
	# Use Chain.clone() to seed with the actual committed chain state
	# (tiles + ends + extra_ends + history). Re-running .add() on each
	# committed tile would re-route branch-placed tiles through
	# fits_right/fits_left, producing a different extra_ends state and
	# silently rejecting otherwise-legal selections.
	var preview: Chain = _rm.current_chain.clone()
	var seeded_len: int = preview.length()
	var tiles_to_play: Array = []
	for idx in _selected_tiles:
		if idx < _rm.hand.size():
			var t: Domino = _rm.hand[idx]
			if not preview.add(t):
				return   # invalid sequence — shouldn't normally happen if visuals are right
			tiles_to_play.append(t)
	if preview.length() == seeded_len:
		return  # nothing was actually added

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
		# Snapshot the hand BEFORE the discard so we can identify which
		# tiles are genuinely new (drawn replacements) vs. which were
		# already in hand. Targeted re-draw promotes fitting tiles to the
		# top of the draw pile, but the player can't tell unless we point
		# at the new arrivals after the swap.
		var pre_hand: Array = _rm.hand.duplicate()
		AudioManager.play_sfx("discard")
		_rm.discard(_selected_tiles)
		_selected_tiles.clear()
		# After the swap, briefly highlight any newly-drawn tiles that fit
		# the chain. Fires on the next frame so _rebuild_hand has run.
		call_deferred("_flash_fitting_redraws", pre_hand)

## Pulse any hand tile that (a) is new since `pre_hand` and (b) currently
## fits the persistent chain's open ends. Reveals the targeted-re-draw
## mechanic that was previously invisible.
func _flash_fitting_redraws(pre_hand: Array) -> void:
	if _rm == null or _rm.current_chain == null or _rm.current_chain.is_empty():
		return
	for i in range(_rm.hand.size()):
		if i >= _tile_btns.size():
			break
		var tile: Domino = _rm.hand[i]
		# Was this exact tile object already in pre_hand? RefCounted
		# identity check is fine — discard removes by index, draw appends
		# fresh references.
		if tile in pre_hand:
			continue
		if not _rm.current_chain.can_add(tile):
			continue
		var btn: Button = _tile_btns[i]
		if btn == null or not is_instance_valid(btn):
			continue
		btn.pivot_offset = btn.size * 0.5
		var t := create_tween().set_parallel(true)
		t.tween_property(btn, "modulate", Color(1.5, 1.4, 1.0), 0.18) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.tween_property(btn, "modulate", Color.WHITE, 0.32) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(0.18)

func _on_undo_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active:
		return
	# Undo = deselect last selected tile (pop from selection order)
	if not _selected_tiles.is_empty():
		_selected_tiles.pop_back()
		_refresh_tile_visuals()
		_refresh_chain_display()
		_refresh_action_buttons()

## Wipe every selected tile in one shot. Reached via right-click on the
## Undo button (mouse equivalent of pressing Esc with selections live),
## via the keyboard via `Shift+U` for hands-on-mouse-shy players, and via
## the existing Esc path. Single click on Undo still pops only the last
## tile so the precise behaviour is preserved.
func _on_undo_clear_all() -> void:
	if _phase != Phase.PLAYING or _scoring_active:
		return
	if _selected_tiles.is_empty():
		return
	_selected_tiles.clear()
	_refresh_tile_visuals()
	_refresh_chain_display()
	_refresh_action_buttons()
	AudioManager.play_sfx("ui_click")

## Player chooses to lock in the round once they've crossed the target.
## Banks remaining hands for the unused-hand Moneda bonus.
func _on_stand_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active or _rm == null:
		return
	if _rm.chronos < _rm.target:
		return
	AudioManager.play_sfx("round_clear")
	_rm.stand()

## True when the player has no legal way to advance: no hand tile fits
## the chain's open ends AND discarding wouldn't help (no discards left
## or the box is empty so any draw would just reproduce the dead state).
func _is_player_stuck() -> bool:
	if _rm == null:
		return false
	if _rm.hands_remaining <= 0:
		return false
	# An empty chain accepts any tile — never stuck if hand isn't empty.
	if not _rm.current_chain.is_empty():
		for t in _rm.hand:
			if _rm.current_chain.can_add(t):
				return false
	elif not _rm.hand.is_empty():
		return false
	# No tile fits. Discarding only helps if discards remain AND the box
	# still has tiles left to draw replacements from.
	if _rm.can_discard() and not _rm.box.is_empty():
		return false
	return true

## Confetti-style burst when the player first crosses the round target.
## Twelve coloured dots launch upward from the chronos bar at staggered
## angles, fade out, and queue_free themselves. Visual fanfare for the
## moment the round actually feels won.
func _burst_target_celebration() -> void:
	if _chronos_bar == null or not is_instance_valid(_chronos_bar):
		return
	var origin: Vector2 = _chronos_bar.global_position \
		+ Vector2(_chronos_bar.size.x * 0.5, _chronos_bar.size.y * 0.5)
	var palette: Array = [C_WIN, C_MONEDAS, C_CHRONOS, C_TITLE_GLOW]
	for i in range(12):
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(7, 7)
		var color: Color = palette[i % palette.size()]
		var ds := StyleBoxFlat.new()
		ds.bg_color = color
		ds.set_corner_radius_all(4)
		dot.add_theme_stylebox_override("panel", ds)
		dot.position = origin - Vector2(3.5, 3.5)
		_ui_layer.add_child(dot)

		# Spread dots in an upward fan. Each gets a slightly different
		# trajectory so the burst doesn't look like a single arc.
		var angle: float = -PI * 0.5 + randf_range(-PI * 0.5, PI * 0.5)
		var dist:  float = randf_range(80.0, 160.0)
		var dur:   float = randf_range(0.55, 0.85)
		var end:   Vector2 = origin + Vector2(cos(angle), sin(angle)) * dist
		end.y += 40.0   # mild gravity drop at the end
		var t := create_tween().set_parallel(true)
		t.tween_property(dot, "position", end - Vector2(3.5, 3.5), dur) \
			.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		t.tween_property(dot, "modulate:a", 0.0, dur)
		t.chain().tween_callback(dot.queue_free)
	AudioManager.play_sfx("round_clear")

## One-shot pulse on the Stand button the first time it becomes visible
## within a round — bigger entrance, gold flash, then settles. Player
## who's been head-down on chain building gets a clear "new option" cue.
func _pulse_stand_button() -> void:
	if _btn_stand == null or not is_instance_valid(_btn_stand):
		return
	_btn_stand.pivot_offset = _btn_stand.size * 0.5
	_btn_stand.scale = Vector2(0.7, 0.7)
	_btn_stand.modulate = Color(1.5, 1.4, 0.9)
	var t := create_tween().set_parallel(true)
	t.tween_property(_btn_stand, "scale", Vector2(1.10, 1.10), 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_btn_stand, "modulate", Color.WHITE, 0.32) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	var settle := create_tween()
	settle.tween_interval(0.18)
	settle.tween_property(_btn_stand, "scale", Vector2.ONE, 0.22) \
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	AudioManager.play_sfx("round_clear")

## Update the inline Stand hint whenever the action bar refreshes.
## Hidden unless the Stand button itself is visible.
func _refresh_stand_hint() -> void:
	if _lbl_stand_hint == null or _btn_stand == null:
		return
	if not _btn_stand.visible:
		_lbl_stand_hint.visible = false
		return
	_lbl_stand_hint.visible = true

	var unused: int = _rm.unused_hands()
	var bank:   int = unused * Constants.MONEDAS_PER_UNUSED_HAND
	var stand_line: String = "STAND  +%d Monedas (%d unused)" % [bank, unused]

	# How far to the next bonus tier the chain hasn't crossed yet?
	var length: int = _rm.committed_chain_length
	var next_min:   int = -1
	var next_bonus: int = 0
	var next_name:  String = ""
	for ti in range(Constants.CHAIN_TIER_MIN.size()):
		if length < Constants.CHAIN_TIER_MIN[ti]:
			next_min   = Constants.CHAIN_TIER_MIN[ti]
			next_bonus = Constants.CHAIN_TIER_BONUS[ti]
			next_name  = Constants.CHAIN_TIER_NAMES[ti]
			break

	var extend_line: String
	if next_min < 0:
		extend_line = "EXTEND →  Singularity reached, push for more chips"
	else:
		var to_go: int = next_min - length
		extend_line = "EXTEND →  +%d tile%s for %s (+%d mult)" % [
			to_go, "s" if to_go > 1 else "", next_name, next_bonus]

	_lbl_stand_hint.text = stand_line + "\n" + extend_line

## Burn a hand without scoring — the anti-softlock escape hatch.
func _on_pass_pressed() -> void:
	if _phase != Phase.PLAYING or _scoring_active or _rm == null:
		return
	if not _is_player_stuck():
		return
	AudioManager.play_sfx("discard")
	_selected_tiles.clear()
	_rm.pass_hand()

# ===========================================================================
# Reinforcement tile activation
# ===========================================================================

## Called when the player clicks a filled reinforcement slot.
func _on_reinforcement_slot_pressed(r: Reinforcement) -> void:
	if _phase != Phase.PLAYING or _scoring_active:
		return
	_activate_reinforcement(r)

## Dispatch: immediate effects fire now; targeting effects enter picking mode.
func _activate_reinforcement(r: Reinforcement) -> void:
	match r.effect_type:
		# ── Immediate effects ─────────────────────────────────────────────
		Reinforcement.EffectType.HOURGLASS:
			_rm.hands_remaining += r.effect_value
			_rm.max_hands       += r.effect_value
			GameState.use_reinforcement(r)
			_refresh_reinforcement_tray()
			_refresh_hud()

		Reinforcement.EffectType.FORTUNE_ESSENCE:
			_fortune_essence_active = true
			GameState.use_reinforcement(r)
			_refresh_reinforcement_tray()

		Reinforcement.EffectType.GOLD_TALISMAN:
			_talisman_active = true
			GameState.use_reinforcement(r)
			_refresh_reinforcement_tray()

		Reinforcement.EffectType.WILDCARD:
			# Add a real wild domino to the hand — uses the existing wild-tile system
			var wild := Domino.new(Domino.WILD, Domino.WILD, 0, true)
			wild.custom_name = "Comodín"
			_rm.hand.append(wild)
			_rm.hand_changed.emit()
			GameState.use_reinforcement(r)
			_refresh_reinforcement_tray()

		# ── Targeting effects (1 tile) ────────────────────────────────────
		Reinforcement.EffectType.BOMB, \
		Reinforcement.EffectType.RECYCLER, \
		Reinforcement.EffectType.COPY_MIRROR:
			_start_reinforcement_targeting(r, 1)

		# ── Targeting effects (2 tiles) ───────────────────────────────────
		Reinforcement.EffectType.FUSION_HAMMER:
			_start_reinforcement_targeting(r, 2)

		# ── Special modal ─────────────────────────────────────────────────
		Reinforcement.EffectType.COMPASS:
			_show_compass_modal(r)

## Enter tile-targeting mode: hand tiles show teal highlight, next click picks a target.
func _start_reinforcement_targeting(r: Reinforcement, needs: int) -> void:
	_reinforcement_pending  = r
	_reinforcement_needs    = needs
	_reinforcement_targets.clear()
	_selected_tiles.clear()          # clear any existing play-selection
	_refresh_chain_display()
	_refresh_action_buttons()
	_refresh_tile_visuals()

## Cancel targeting mode (Esc key or player clicks elsewhere).
func _cancel_reinforcement_targeting() -> void:
	_reinforcement_pending = null
	_reinforcement_targets.clear()
	_reinforcement_needs   = 0
	_refresh_tile_visuals()
	_refresh_action_buttons()

## Handle a tile click while in targeting mode.
func _on_tile_targeting_click(index: int) -> void:
	if index >= _rm.hand.size():
		return
	# FUSION_HAMMER: disallow picking the same tile twice
	if _reinforcement_targets.has(index):
		_reinforcement_targets.erase(index)
	else:
		_reinforcement_targets.append(index)
	_refresh_tile_visuals()
	if _reinforcement_targets.size() >= _reinforcement_needs:
		_execute_reinforcement_effect()

## Fire the targeting effect, then clean up targeting state.
func _execute_reinforcement_effect() -> void:
	var r: Reinforcement = _reinforcement_pending
	# Sort descending so removal indices don't shift each other
	var indices: Array = _reinforcement_targets.duplicate()
	indices.sort()
	indices.reverse()

	_cancel_reinforcement_targeting()

	match r.effect_type:
		Reinforcement.EffectType.BOMB:
			var idx: int = indices[0]
			if idx < _rm.hand.size():
				var t: Domino = _rm.hand[idx]
				_rm.hand.remove_at(idx)
				GameState.box.remove_tile(t)
				_rm.hand_changed.emit()

		Reinforcement.EffectType.RECYCLER:
			var idx: int = indices[0]
			if idx < _rm.hand.size():
				var t: Domino = _rm.hand[idx]
				_rm.hand.remove_at(idx)
				GameState.box.return_tile(t)   # put back in draw pile at random position
				var replacements := _rm.box.draw(1)
				_rm.hand.append_array(replacements)
				_rm.hand_changed.emit()

		Reinforcement.EffectType.COPY_MIRROR:
			var idx: int = indices[0]
			if idx < _rm.hand.size():
				var t: Domino = _rm.hand[idx]
				var copy := Domino.new(t.left, t.right, t.rarity, t.is_wild)
				copy.custom_name = t.custom_name
				copy.bonus_chips = t.bonus_chips
				_rm.hand.append(copy)
				_rm.hand_changed.emit()

		Reinforcement.EffectType.FUSION_HAMMER:
			if indices.size() >= 2:
				var i1: int = indices[0]
				var i2: int = indices[1]
				if i1 < _rm.hand.size() and i2 < _rm.hand.size():
					var t1: Domino = _rm.hand[i1]
					var t2: Domino = _rm.hand[i2]
					var max_face: int = maxi(maxi(t1.left, t1.right), maxi(t2.left, t2.right))
					_rm.hand.remove_at(i1)
					_rm.hand.remove_at(i2)
					var fused := Domino.new(max_face, max_face, Constants.Rarity.CARVED)
					fused.custom_name = "Fused"
					_rm.hand.append(fused)
					_rm.hand_changed.emit()

	GameState.use_reinforcement(r)
	_refresh_reinforcement_tray()

# ---------------------------------------------------------------------------
# Compass modal — peek top 3, promote one to top of draw pile
# ---------------------------------------------------------------------------
func _show_compass_modal(r: Reinforcement) -> void:
	if _compass_overlay != null:
		_compass_overlay.queue_free()
		_compass_overlay = null

	var peeked: Array[Domino] = _rm.box.peek(3)
	if peeked.is_empty():
		# Nothing to peek — use immediately with no effect
		GameState.use_reinforcement(r)
		_refresh_reinforcement_tray()
		return

	_compass_overlay = _build_compass_modal(r, peeked)
	_ui_layer.add_child(_compass_overlay)

func _build_compass_modal(r: Reinforcement, tiles: Array[Domino]) -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 0)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.10, 0.09, 0.07, 0.98)
	ps.border_color = C_TARGETING
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	vbox.add_child(_make_label("BRÚJULA — Next draw", C_TARGETING, 16))
	vbox.add_child(_make_label("Choose which tile comes next from the box.", C_DIM, 12))

	var tile_row := HBoxContainer.new()
	tile_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tile_row.add_theme_constant_override("separation", 14)
	vbox.add_child(tile_row)

	for i in range(tiles.size()):
		var t: Domino = tiles[i]
		var tile_btn := Button.new()
		tile_btn.text = ""
		tile_btn.custom_minimum_size = Vector2(88, 176)
		tile_btn.clip_contents = true
		var sn := StyleBoxFlat.new()
		sn.bg_color = C_TILE_BODY; sn.border_color = C_TARGETING
		sn.set_border_width_all(2); sn.set_corner_radius_all(12)
		tile_btn.add_theme_stylebox_override("normal", sn)
		tile_btn.add_theme_stylebox_override("focus",  sn)
		var sh := StyleBoxFlat.new()
		sh.bg_color = C_TILE_BODY.lightened(0.12); sh.border_color = C_TARGETING_SEL
		sh.set_border_width_all(3); sh.set_corner_radius_all(12)
		tile_btn.add_theme_stylebox_override("hover", sh)
		# Pip display inside — VBox with top/bot pip halves + divider
		var inner := VBoxContainer.new()
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.offset_left = 11; inner.offset_top = 11
		inner.offset_right = -11; inner.offset_bottom = -11
		inner.add_theme_constant_override("separation", 0)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tp := PanelContainer.new()
		tp.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_pip_panel_face(tp, C_TILE_FACE, true)
		tp.add_child(_make_pip_display(t.left, 14, C_PIP_DOT))
		inner.add_child(tp)
		inner.add_child(_make_tile_hsep())
		var bp := PanelContainer.new()
		bp.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_pip_panel_face(bp, C_TILE_FACE, false)
		bp.add_child(_make_pip_display(t.right, 14, C_PIP_DOT))
		inner.add_child(bp)
		tile_btn.add_child(inner)
		tile_btn.pressed.connect(_on_compass_pick.bind(r, t))
		tile_row.add_child(tile_btn)

	var cancel_btn := _make_button("Cancel (Esc)", _on_compass_cancel, Vector2(140, 40))
	cancel_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(cancel_btn)

	return overlay

func _on_compass_cancel() -> void:
	if _compass_overlay:
		_compass_overlay.queue_free()
		_compass_overlay = null

func _on_compass_pick(r: Reinforcement, chosen: Domino) -> void:
	_rm.box.promote_to_top(chosen)
	if _compass_overlay:
		_compass_overlay.queue_free()
		_compass_overlay = null
	GameState.use_reinforcement(r)
	_refresh_reinforcement_tray()

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
	AudioManager.play_sfx("module_equip")
	_shop_bought.append(m.id)
	# Codex: discovery entry unlocks on first equip. Idempotent —
	# subsequent purchases of the same module are no-ops.
	SaveManager.unlock_codex("module_" + m.id)
	# Auto-save after every purchase so a mid-shop crash doesn't lose the
	# upgrade. Save is cheap (single JSON write) and idempotent.
	SaveManager.save_run()
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
	# Codex: discovery entry unlocks on acquire. Slug derived from the
	# tile's custom_name ("The Anchor" → "tile_anchor").
	var slug: String = _codex_slug_for_tile(t)
	if not slug.is_empty():
		SaveManager.unlock_codex(slug)
	SaveManager.save_run()
	_populate_shop()

## Derive the Codex entry id for a special tile from its custom_name.
## Returns "" if the tile has no custom_name (a regular numbered tile,
## which has no Codex entry).
func _codex_slug_for_tile(t: Domino) -> String:
	if t == null or t.custom_name.is_empty():
		return ""
	var s: String = t.custom_name.to_lower()
	# Strip the leading "the " article so "The Anchor" → "anchor".
	if s.begins_with("the "):
		s = s.substr(4)
	s = s.replace(" ", "_").strip_edges()
	return "tile_" + s

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
		SaveManager.save_run()
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
	# Persist result + clear mid-run save
	SaveManager.record_run_result(
		GameState.difficulty,
		GameState.round_index,
		GameState.total_chronos,
		GameState.modules.size()
	)
	# Daily trial: lock today's attempt so the title-screen button shows
	# the result and disables itself until tomorrow's seed.
	if GameState.is_daily_run:
		SaveManager.record_daily_attempt(victory,
			GameState.total_chronos, GameState.round_index)
	# Snapshot lifetime stats *before* accumulating this run's stats so we
	# can detect cores/protocols that just unlocked.
	var lt_before: Dictionary = SaveManager.get_lifetime_stats()
	# Lifetime stats — accumulated across every run, win or loss. Powers
	# the Run Stats block below (and any future achievement system).
	SaveManager.accumulate_run_stats({
		"won":            victory,
		"difficulty":     GameState.difficulty,
		"total_chronos":  GameState.total_chronos,
		"hands_played":   GameState.hands_played,
		"doubles_played": GameState.doubles_played,
		"longest_chain":  GameState.longest_chain,
		"best_tier":      GameState.best_tier,
		"round_reached":  GameState.round_index,
		"module_ids":     GameState.modules.map(func(m): return m.id),
	})
	var lt_after: Dictionary = SaveManager.get_lifetime_stats()
	var new_unlocks: Array = _detect_new_unlocks(lt_before, lt_after)
	var new_achievements: Array = _detect_new_achievements(lt_before, lt_after)
	SaveManager.clear_run()
	# Music cue
	AudioManager.play_music("menu_theme")
	# Interstitial ad on defeat (fires before stats reveal — 1.5s delay)
	if not victory:
		get_tree().create_timer(1.5).timeout.connect(
			AdManager.show_interstitial, CONNECT_ONE_SHOT)

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
	# Title text escalates with the lifetime failure count. The Operator's
	# anonymity wears off — by the 100th Failure the Machine addresses
	# them directly. lt_before is the snapshot taken just above; the
	# pending Failure makes the count `runs - wins + 1` on a loss.
	var title_text: String
	var title_color: Color = C_MONEDAS if victory else C_LOSE
	if victory:
		title_text = _build_victory_title(lt_before)
	else:
		var pending_failures: int = maxi(0,
			int(lt_before.get("runs", 0)) + 1 -
			int(lt_before.get("wins", 0)))
		title_text = _build_defeat_title(pending_failures)
	_lbl_run_end_title.text = ""   # will be typewritten
	_lbl_run_end_title.add_theme_color_override("font_color", title_color)
	_lbl_run_end_title.modulate.a = 0.0

	# ── Sub line ─────────────────────────────────────────────────────────────
	# Defeat: "N Chronos short" + tone shift; victory: "Entropy contained".
	# At very high failure / win counts the line grows more intimate.
	if victory:
		_lbl_run_end_sub.text = _build_victory_subline(lt_before)
	else:
		_lbl_run_end_sub.text = _build_defeat_attribution()
	_lbl_run_end_sub.modulate.a = 0.0

	# ── Stats ─────────────────────────────────────────────────────────────────
	for child in _run_end_stats_col.get_children():
		child.queue_free()

	var rounds_done: int  = GameState.round_index
	var total_rounds: int = GameState.total_rounds()
	var best_tier_str: String = "—"
	if GameState.best_tier >= 0 and GameState.best_tier < Constants.CHAIN_TIER_NAMES.size():
		best_tier_str = Constants.CHAIN_TIER_NAMES[GameState.best_tier]
	var stat_lines: Array = [
		["Rounds completed",  "%d / %d" % [rounds_done, total_rounds]],
		["Total Chronos",     "%d"       % GameState.total_chronos],
		["Longest chain",     "%d tiles  (%s)" % [GameState.longest_chain, best_tier_str]],
		["Best single Pulse", "%d"       % GameState.best_hand],
		["Hands played",      "%d"       % GameState.hands_played],
		["Doubles played",    "%d"       % GameState.doubles_played],
		["Core",              Constants.CORE_NAMES[GameState.chosen_core]],
		["Protocol",          Constants.PROTOCOL_NAMES[GameState.chosen_protocol]],
	]
	if not GameState.modules.is_empty():
		var names: Array = GameState.modules.map(func(m): return m.display_name)
		stat_lines.append(["Modules", ", ".join(names)])

	# Lifetime stats divider + cumulative-across-runs lines. Gives the
	# loss/victory motivation by showing context: "this run vs all my runs".
	var lt: Dictionary = SaveManager.get_lifetime_stats()
	var lt_best_tier: String = "—"
	if int(lt["best_tier"]) >= 0 and int(lt["best_tier"]) < Constants.CHAIN_TIER_NAMES.size():
		lt_best_tier = Constants.CHAIN_TIER_NAMES[int(lt["best_tier"])]
	stat_lines.append(["─── LIFETIME ───", ""])
	stat_lines.append(["Total runs",    "%d (%d won)" % [lt["runs"], lt["wins"]]])
	stat_lines.append(["Total Chronos", "%d" % lt["chronos"]])
	stat_lines.append(["Longest chain", "%d tiles  (%s)" % [lt["longest_chain"], lt_best_tier]])
	stat_lines.append(["Furthest round", "%d" % lt["best_round"]])

	# Newly-unlocked cores / protocols this run — surface them prominently
	# so the player knows their next run has new options.
	if not new_unlocks.is_empty():
		stat_lines.append(["─── 🔓 NEW UNLOCKS ───", ""])
		for u in new_unlocks:
			stat_lines.append([u["kind"], u["name"]])

	# Newly-earned achievements — separate from unlocks (unlocks gate
	# playable content; achievements are pure milestone markers).
	if not new_achievements.is_empty():
		stat_lines.append(["─── ★ ACHIEVEMENTS ───", ""])
		for a in new_achievements:
			stat_lines.append(["%s  %s" % [a["icon"], a["name"]], ""])

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
	_register_cinematic(seq)

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
		# Fill tween is part of the parent seq (not a nested create_tween)
		# so the global anim-speed and skip-request both apply to it. With
		# a separate child tween it would keep ticking at 1× even after a
		# skip and the progress bar would dawdle past the dismissed UI.
		seq.tween_interval(0.30)
		seq.tween_property(_run_end_progress_lbl, "modulate:a", 1.0, 0.20)
		seq.tween_property(_run_end_progress_bar, "modulate:a", 1.0, 0.20)
		seq.tween_property(_run_end_progress_bar, "value", 100.0, 2.0) \
			.set_trans(Tween.TRANS_LINEAR)
		seq.tween_interval(0.10)

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
	# Apply SHOP_DISCOUNT modules
	var disc: int = GameState.shop_discount_pct()
	if disc > 0:
		cost = maxi(1, int(cost * (100 - disc) / 100.0))
	# Per-core flat surcharge (Obsidian Core costs +2 per item).
	cost = maxi(1, cost + GameState.core_shop_price_delta())
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

	# Module icon — 64×64, loads from assets/modules/{id}.png or shows placeholder
	vbox.add_child(_build_item_icon(m.icon_path, m.display_name, C_RARITY[m.rarity], Vector2(64, 64)))

	# Rarity + archetype tag row. Archetype lets the player see at a glance
	# what build the module slots into (DOUBLES, LONG-CHAIN, ECONOMY, etc.)
	# and why the shop is offering it — synergies are no longer invisible.
	var tag_row := HBoxContainer.new()
	tag_row.add_theme_constant_override("separation", 8)
	tag_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tag_row.add_child(_make_label(Constants.RARITY_NAMES[m.rarity].to_upper(),
		C_RARITY[m.rarity], 11))
	var arch_name: String = _archetype_label(m.archetype())
	if arch_name != "":
		tag_row.add_child(_make_label("·", C_DIM, 11))
		tag_row.add_child(_make_label(arch_name, _archetype_color(m.archetype()), 11))
	vbox.add_child(tag_row)
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

	var cost_text: String = "%d Monedas" % cost
	if disc > 0:
		cost_text += "  (-%d%%)" % disc
	var cost_lbl := _make_label(cost_text, C_MONEDAS, 14)
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
	_lbl_round.text = GameState.round_display()
	_lbl_etapa.text = GameState.etapa_name()

	# Monedas: pop "+N" if value increased during play; tween the pill
	# counter from its previous DISPLAYED value to the new amount so the
	# count-up reads as a fluid animation rather than a snap.
	var new_m := GameState.monedas
	if new_m > _last_monedas and _phase == Phase.PLAYING and not _scoring_active:
		call_deferred("_pop_monedas_delta", new_m - _last_monedas)
	_last_monedas = new_m
	_lbl_monedas.text = "Monedas: %d" % new_m
	_animate_monedas_to(new_m)

	# Chronos bar — skipped during scoring animation (animation drives the fill)
	if not _scoring_active:
		var t: int = _rm.target if _rm != null else 1
		var c: int = _rm.chronos if _rm != null else 0
		_set_chronos_bar(c, t)

	# Big score label (shows chronos / score accumulated)
	if _lbl_score_big != null:
		var score_val: int = _rm.chronos if _rm != null else 0
		_lbl_score_big.text = "%d" % score_val

	# Manos / Descartes pill counts
	if _lbl_manos_count != null and _rm != null:
		_lbl_manos_count.text = "%d/%d" % [_rm.hands_remaining, _rm.max_hands]
	if _lbl_descartes_count != null and _rm != null:
		_lbl_descartes_count.text = "%d/%d" % [_rm.discards_remaining, _rm.max_discards]
	# Box (draw pile) count: remaining / total. Reflects targeted re-draws,
	# permanent box additions/removals from the shop, and tile_offers buys.
	if _lbl_box_count != null and _rm != null and _rm.box != null:
		_lbl_box_count.text = "%d/%d" % [_rm.box.draw_pile_size(), _rm.box.total_tiles()]

	# Hands dots — hidden HBoxContainers kept for compatibility; still update them
	for ch in _hands_dot_row.get_children(): ch.queue_free()
	var hands_color := Color(0.7, 0.8, 1.0)
	var last_hand := _rm.hands_remaining == 1 and not _rm.did_win()
	for i in range(_rm.max_hands):
		var filled := i < _rm.hands_remaining
		_hands_dot_row.add_child(_make_hud_dot(
			filled, C_LOSE if (last_hand and filled) else hands_color))

	# Discards dots — hidden HBoxContainers kept for compatibility; still update them
	for ch in _discards_dot_row.get_children(): ch.queue_free()
	for i in range(_rm.max_discards):
		_discards_dot_row.add_child(
			_make_hud_dot(i < _rm.discards_remaining, Color(0.8, 0.7, 1.0)))

	# Refresh side panels and tile box
	_refresh_contracts_panel()
	_refresh_artifacts_panel()
	_refresh_tile_box()

## Build a preview Chain from the current selection (in click order).
## Stops at the first tile that fails to connect — partial chains are valid previews.
## Update the persistent boss-effect reminder label that sits in the chain
## info pill during boss rounds. Hidden on normal rounds and on plain
## STAT_CUT bosses (the cinematic + visible hand/discard cuts already
## carry that warning). Special-effect bosses get a "⚠ NAME" stamp.
func _refresh_boss_effect_lbl() -> void:
	if _boss_effect_lbl == null:
		return
	if not GameState.is_boss_round():
		_boss_effect_lbl.visible = false
		return
	var effect: int = GameState.active_boss_effect()
	if effect == Constants.BossEffect.STAT_CUT:
		_boss_effect_lbl.visible = false
		return
	var etapa: int = GameState.current_etapa()
	if etapa < 0 or etapa >= Constants.BOSS_NAMES.size():
		_boss_effect_lbl.visible = false
		return
	_boss_effect_lbl.text = "⚠  %s" % Constants.BOSS_NAMES[etapa]
	_boss_effect_lbl.visible = true

## Build the defeat sub-line shown on the run-end overlay. Pulls the
## last round's chronos vs target so the player sees HOW close they got.
## At high lifetime failure counts, appends an additional intimate line
## from the Archive — the Machine begins to notice you.
func _build_defeat_attribution() -> String:
	var chronos: int = _rm.chronos if _rm != null else 0
	var target:  int = _rm.target  if _rm != null else 0
	var gap:     int = maxi(0, target - chronos)

	# Concrete delta line first.
	var line_a := "The Chronometer cannot be recovered."
	if _rm != null and target > 0:
		if gap == 0:
			line_a = "You reached the target — but ran out of plays."
		elif gap < target * 0.10:
			line_a = "%d Chronos short. So close." % gap
		elif gap < target * 0.30:
			line_a = "%d Chronos short. Sharpen the chain." % gap
		else:
			line_a = "%d Chronos short. The Entropy held." % gap

	# Atmospheric overlay line as the failure count climbs. Each tier of
	# the player's lifetime failure count adds a different second line —
	# the Archive's tone shifting from clinical to personal to haunted.
	var lt: Dictionary = SaveManager.get_lifetime_stats()
	var fails: int = maxi(0, int(lt.get("runs", 0)) + 1 -
		int(lt.get("wins", 0)))
	var line_b: String = ""
	if fails >= 200:
		line_b = "Yo--ou have never left. You understand this, do you not?"
	elif fails >= 100:
		line_b = "The Chronometer remembers you, Operator."
	elif fails >= 50:
		line_b = "(Operator endurance: under review.)"
	elif fails >= 25:
		line_b = "Data preserved. Continuity-- continuity preserved."
	# Below 25 we keep the line sparse — the Operator is still anonymous.

	if line_b.is_empty():
		return line_a
	return line_a + "\n" + line_b

## Build the defeat title — the headline above the stats. Escalates with
## lifetime failure count so a repeat-failing run feels heavier than the
## first one. At high counts the title glitches and starts to address
## the Operator directly.
func _build_defeat_title(pending_failures: int) -> String:
	if pending_failures >= 200:
		return "OPERATOR. THE MACHINE WANTS A WORD."
	if pending_failures >= 100:
		return "FAILURE PROTOCOL #%d.  RECURRENCE NOTED." % pending_failures
	if pending_failures >= 50:
		return "REINITIALIZ--gng--PROTOCOL  #%d" % pending_failures
	if pending_failures >= 25:
		return "REINITIALIZING PROTOCOL  #%d" % pending_failures
	if pending_failures >= 10:
		return "REINITIALIZING PROTOCOL  (#%d)" % pending_failures
	return "REINITIALIZING PROTOCOL"

## Victory title — first win is generic, the Society's standard text.
## Later wins shift in tone as the Archive becomes more invested in
## the Operator's specific record.
func _build_victory_title(lt: Dictionary) -> String:
	var wins: int = int(lt.get("wins", 0))
	# Note: this run's win hasn't been accumulated yet, so `wins` is
	# the count BEFORE this victory. The pending win is wins + 1.
	var w: int = wins + 1
	if w >= 50:
		return "THE CHRONOMETER REMEMBERS YOU."
	if w >= 25:
		return "RECALIBRATION SECURED.  (CYCLE %d.)" % w
	if w >= 10:
		return "RECALIBRATION CONFIRMED.  (CYCLE %d.)" % w
	return "THE CHRONOMETER STABILIZES"

## Victory sub-line. Below 5 wins, the Society's standard congratulation.
## Past that, the Archive begins addressing the Operator personally.
func _build_victory_subline(lt: Dictionary) -> String:
	var w: int = int(lt.get("wins", 0)) + 1
	if w >= 50:
		return "You are the constant. The simulations are not."
	if w >= 25:
		return "The Archive has logged your %d Recalibrations." % w
	if w >= 10:
		return "Reliable Operator. The Architects approve."
	return "Entropy contained. The age persists."

## Compare lifetime stats before/after accumulating this run's data and
## return any achievements that crossed their gate. Achievements use the
## SAME pattern as unlock gates (so the same lifetime keys drive them),
## plus a daily-streak gate that requires SaveManager.daily_streak().
func _detect_new_achievements(before: Dictionary, after: Dictionary) -> Array:
	var streak: int = SaveManager.daily_streak()
	var earned: Array = []
	for i in range(Constants.ACHIEVEMENTS.size()):
		var was: bool = Constants.achievement_earned(i, before, streak)
		var now: bool = Constants.achievement_earned(i, after,  streak)
		if not was and now:
			earned.append(Constants.ACHIEVEMENTS[i])
	return earned

## Compare lifetime stats before/after accumulating this run's data and
## return a list of cores/protocols that just crossed their unlock gates.
## Each entry: { "kind": "Core" | "Protocol", "name": "<display name>" }.
func _detect_new_unlocks(before: Dictionary, after: Dictionary) -> Array:
	var unlocks: Array = []
	for i in range(Constants.CORE_UNLOCKS.size()):
		var was: bool = Constants.is_core_unlocked(i, before)
		var now: bool = Constants.is_core_unlocked(i, after)
		if not was and now:
			unlocks.append({"kind": "Core", "name": Constants.CORE_NAMES[i]})
	for i in range(Constants.PROTOCOL_UNLOCKS.size()):
		var was: bool = Constants.is_protocol_unlocked(i, before)
		var now: bool = Constants.is_protocol_unlocked(i, after)
		if not was and now:
			unlocks.append({"kind": "Protocol", "name": Constants.PROTOCOL_NAMES[i]})
	return unlocks

## Display name for a module archetype. GENERIC returns "" so it doesn't
## clutter the shop card with a redundant tag (FLAT_MULT etc. fit anything).
func _archetype_label(a: int) -> String:
	match a:
		Module.Archetype.DOUBLES:    return "DOUBLES"
		Module.Archetype.LONG_CHAIN: return "LONG-CHAIN"
		Module.Archetype.HIGH_PIP:   return "HIGH-PIP"
		Module.Archetype.BLANKS:     return "BLANKS"
		Module.Archetype.SACRIFICE:  return "SACRIFICE"
		Module.Archetype.ECONOMY:    return "ECONOMY"
		Module.Archetype.UTILITY:    return "UTILITY"
		_: return ""

## Tint for the per-tile module-fired tag pops. Reuses the archetype
## colour so the in-play tag matches the colour shown on the shop card —
## visual continuity between "module type I bought" and "module fired
## here". Falls back to dim for unknown tags.
func _archetype_color_for_tag(tag: String) -> Color:
	match tag:
		"DOUBLE":    return _archetype_color(Module.Archetype.DOUBLES)
		"HIGH-PIP":  return _archetype_color(Module.Archetype.HIGH_PIP)
		"BLANK":     return _archetype_color(Module.Archetype.BLANKS)
		"WILD":      return _archetype_color(Module.Archetype.BLANKS)
		"SACRIFICE": return _archetype_color(Module.Archetype.SACRIFICE)
		_: return C_DIM

## Color tag for archetype. Gives each build identity a distinct hue so
## a deck-heavy shop card visually clusters by colour.
func _archetype_color(a: int) -> Color:
	match a:
		Module.Archetype.DOUBLES:    return C_MONEDAS
		Module.Archetype.LONG_CHAIN: return C_CHRONOS
		Module.Archetype.HIGH_PIP:   return Color(0.95, 0.58, 0.20)
		Module.Archetype.BLANKS:     return Color(0.85, 0.85, 0.95)
		Module.Archetype.SACRIFICE:  return Color(0.95, 0.40, 0.40)
		Module.Archetype.ECONOMY:    return C_MONEDAS.lerp(Color.WHITE, 0.25)
		Module.Archetype.UTILITY:    return Color(0.55, 0.85, 0.95)
		_: return C_DIM

## Rebuild the branch indicator row above the chain. One small badge per
## entry in the preview chain's `extra_ends` array — the live list of
## branch open-end values created by previously-placed doubles. Each
## badge shows the pip value the chain can still match via that branch.
##
## When the chain has no extra_ends (no doubles placed yet, or every
## branch already extended), the row collapses to nothing.
func _refresh_branch_indicators(preview: Chain) -> void:
	if _chain_branches_row == null:
		return
	for child in _chain_branches_row.get_children():
		child.queue_free()
	if preview == null or preview.extra_ends.is_empty():
		return
	# Header label — explains the row to anyone who hasn't seen it before.
	_chain_branches_row.add_child(_make_label("BRANCHES:", C_DIM, 10))
	for v in preview.extra_ends:
		_chain_branches_row.add_child(_build_branch_badge(int(v)))

## Compact circular pip badge. Shows a number (or ★ for wild) on a
## small dark disc with the etapa accent colour as a glow ring.
func _build_branch_badge(pip: int) -> Control:
	var size: int = 22
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(size, size)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var accent: Color = Constants.ETAPA_ACCENT[clampi(GameState.current_etapa(), 0, 3)]
	var s := StyleBoxFlat.new()
	s.bg_color     = Color(0.10, 0.09, 0.07, 0.95)
	s.border_color = accent
	s.set_border_width_all(1)
	s.set_corner_radius_all(size / 2)
	panel.add_theme_stylebox_override("panel", s)

	var lbl := _make_label("★" if pip < 0 else str(pip), accent, 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	FontManager.apply_mono(lbl)
	panel.add_child(lbl)
	return panel

## Render the chain's open ends as a compact string for the info bar.
## Includes left_end, right_end, and any branching `extra_ends` so the
## player can see *all* the pip values they could connect a tile to —
## including the extra ends spawned by previously-placed doubles.
## "★" represents a wild end. Empty string if the chain has no tiles yet.
func _format_open_ends(c: Chain) -> String:
	if c == null or c.is_empty():
		return ""
	var values: Array = []
	if c.left_end != Chain.EMPTY:
		values.append("★" if c.left_end == Chain.WILD else str(c.left_end))
	if c.right_end != Chain.EMPTY and c.right_end != c.left_end:
		values.append("★" if c.right_end == Chain.WILD else str(c.right_end))
	for v in c.extra_ends:
		values.append("★" if v == Chain.WILD else str(v))
	return ", ".join(values)

## Builds the chain that would result from playing the current selection
## on top of the persistent chain. Used for both visual rendering and
## live score projection.
##
## Uses Chain.clone() to seed the preview with a faithful copy of the
## committed chain's state — including every live extra_end. Replaying
## the chain via repeated .add() calls (the old approach) re-routed
## branch-placed tiles through fits_right/fits_left, producing a
## different extra_ends state in the preview than in the actual chain.
## That divergence silently disabled the Play button on otherwise-legal
## plays whenever a downstream selection depended on the real branch
## state.
func _build_preview_chain() -> Chain:
	var preview: Chain
	if _rm != null and _rm.current_chain != null:
		preview = _rm.current_chain.clone()
	else:
		preview = Chain.new()
	for idx in _selected_tiles:
		if idx < _rm.hand.size():
			if not preview.add(_rm.hand[idx]):
				break
	return preview

func _refresh_chain_display() -> void:
	_kill_chain_idle_tweens()
	for child in _chain_container.get_children():
		child.queue_free()
	_chain_tile_panels.clear()

	var preview := _build_preview_chain()

	if preview.is_empty():
		var lbl := _make_label("Select tiles to build a chain", C_DIM, 14)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_chain_container.add_child(lbl)
	else:
		_layout_chain_serpentine(preview)
		# Idle breathing on every tile (random phase per tile for organic feel)
		for tile_panel in _chain_tile_panels:
			var idle := _start_tile_breathe(tile_panel)
			if idle != null:
				_chain_idle_tweens.append(idle)
	_refresh_branch_indicators(preview)

	if not preview.is_empty():
		var r: Dictionary = Scoring.calculate(preview, GameState.modules)
		# Equation line: dim, small — sets the context
		_lbl_preview.text = "%d chips  ×  %d" % [r["chips"], r["mult"]]
		_lbl_preview.add_theme_color_override("font_color", C_DIM)
		# Total line: large, green — the number the player wants to see
		_lbl_preview_total.text = "= %d" % r["total"]
		_lbl_preview_total.add_theme_color_override("font_color", C_CHRONOS)
		_refresh_chain_milestone(preview.length())
		# Persistent-chain ghost: show only the score the new selection would
		# add on top of the already-committed chain.
		var delta_proj: int = r["total"] - _rm.committed_chain_score
		_update_chronos_ghost(maxi(0, delta_proj))
		# Chain info bar update
		if _chain_info_lbl != null:
			# CADENA: <length>   ↔ <open ends with extras from doubles>
			var ends_str: String = _format_open_ends(preview)
			if ends_str.is_empty():
				_chain_info_lbl.text = "CADENA: %d" % preview.length()
			else:
				_chain_info_lbl.text = "CADENA: %d   ↔ %s" % [preview.length(), ends_str]
		if _chain_bonus_lbl != null:
			_chain_bonus_lbl.text = "+%d" % r["total"]
	else:
		_lbl_preview.text = ""
		_lbl_preview_total.text = ""
		_update_chronos_ghost(0)
		_refresh_chain_milestone(0)
		if _chain_info_lbl != null:
			_chain_info_lbl.text = "CADENA: 0"
		if _chain_bonus_lbl != null:
			_chain_bonus_lbl.text = ""

func _refresh_action_buttons() -> void:
	# Preview must be fully valid (all selected tiles connected) to enable Play.
	# Preview length = committed chain + every selected tile that legally fit.
	var preview := _build_preview_chain()
	var committed_len: int = _rm.current_chain.length() if _rm != null else 0
	var all_connected: bool = not _selected_tiles.is_empty() \
		and preview.length() == committed_len + _selected_tiles.size()
	_btn_play.disabled    = not (all_connected and _rm.hands_remaining > 0)
	_btn_discard.disabled = not _rm.can_discard() or _selected_tiles.is_empty()
	_btn_undo.disabled    = _selected_tiles.is_empty()
	_btn_discard.text     = "Discard (%d)" % _selected_tiles.size()
	# Surface selection count on Undo when there's >1 tile to clear, so the
	# "right-click clears all" affordance has a visible hook. Single-tile
	# selections keep the unchanged label.
	_btn_undo.text = "↩ Undo  ×%d" % _selected_tiles.size() \
		if _selected_tiles.size() > 1 else "↩ Undo"
	# Stand becomes available the moment the round target is met. Player
	# can keep extending for tier bonuses / directives, or lock in here.
	if _btn_stand != null:
		var was_visible: bool = _btn_stand.visible
		var should_show: bool = _rm.chronos >= _rm.target and _rm.hands_remaining > 0
		_btn_stand.visible  = should_show
		_btn_stand.disabled = not should_show
		# First-time appearance pulse: draw the player's eye to the new
		# action without forcing a tutorial popup. Only pulses on the
		# transition (off → on), not every refresh.
		if should_show and not was_visible:
			_pulse_stand_button()
			# Same trigger as the Stand pulse, but a wider celebration —
			# the player just hit the chronos target for the round, the
			# moment they've been chasing. Fires once per round.
			if not _target_celebrated:
				_target_celebrated = true
				_burst_target_celebration()
		_refresh_stand_hint()

	# Pass appears only when truly stuck (anti-softlock).
	if _btn_pass != null:
		var stuck: bool = _is_player_stuck()
		_btn_pass.visible  = stuck
		_btn_pass.disabled = not stuck

	# Play button glow pulse — looping amber oscillation when a valid chain is ready
	if not _btn_play.disabled:
		if _play_pulse_tween == null or not _play_pulse_tween.is_valid():
			_play_pulse_tween = create_tween().set_loops()
			_play_pulse_tween.tween_property(_btn_play, "modulate",
				Color(1.18, 1.08, 0.78), 0.65).set_trans(Tween.TRANS_SINE)
			_play_pulse_tween.tween_property(_btn_play, "modulate",
				Color.WHITE, 0.65).set_trans(Tween.TRANS_SINE)
	else:
		if _play_pulse_tween != null:
			_play_pulse_tween.kill()
			_play_pulse_tween = null
		_btn_play.modulate = Color.WHITE

func _rebuild_hand() -> void:
	_selected_tiles.clear()
	for child in _hand_container.get_children():
		child.queue_free()
	_tile_btns.clear()
	_tile_conn_lbls.clear()
	# Cap total stagger time so a 10-tile hand doesn't burn half a second
	# of pure wait. ~0.030s per tile, total clamped to 0.22s; large hands
	# end up overlapping more but the cascade still reads as a sequence.
	# Also honour the user's anim-speed setting so a FASTER preset shaves
	# this down further (matches what cinematics do).
	var per_tile: float = clampf(0.22 / maxi(1, _rm.hand.size()), 0.018, 0.030)
	per_tile /= maxf(0.5, _anim_speed())
	for i in range(_rm.hand.size()):
		var btn := _create_hand_tile(_rm.hand[i], i)
		_hand_container.add_child(btn)
		_tile_btns.append(btn)
		# Slide-in animation: pop up from below with fade + scale, staggered per tile
		if not _scoring_active:
			btn.modulate.a = 0.0
			btn.scale      = Vector2(0.88, 0.88)
			var tw := btn.create_tween().set_parallel(true)
			var delay: float = i * per_tile
			tw.tween_property(btn, "modulate:a", 1.0, 0.20) \
				.set_delay(delay) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn, "scale", Vector2.ONE, 0.22) \
				.set_delay(delay) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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

		# Reinforcement targeting mode — teal highlight, replaces normal selection
		if _reinforcement_pending != null:
			var is_tgt: bool = _reinforcement_targets.has(i)
			var tgt_face  := C_TILE_FACE_SEL.lerp(C_TARGETING, 0.55) if is_tgt else C_TILE_FACE
			var tgt_border := C_TARGETING_SEL if is_tgt else C_TARGETING.darkened(0.25)
			_apply_tile_style(btn, tgt_face, C_TILE_FACE_HOVER, tgt_border)
			if conn:
				conn.text   = "✓" if is_tgt else "?"
				conn.add_theme_color_override("font_color", C_TARGETING_SEL if is_tgt else C_TARGETING)
			_apply_tile_lift(btn, false)   # no lift in targeting mode
			continue

		var sel_order: int = _selected_tiles.find(i)
		if sel_order >= 0:
			# Selected: amber face + bright gold border + order number
			_apply_tile_style(btn, C_TILE_FACE_SEL, C_TILE_FACE_SEL, C_TILE_BORDER_SEL)
			if conn:
				conn.text = str(sel_order + 1)
				conn.add_theme_color_override("font_color", C_TILE_BORDER_SEL)
			_apply_tile_lift(btn, true)    # lift selected tile
			continue

		# Unselected: show connection arrow relative to current preview end
		_apply_tile_lift(btn, false)   # ensure tile is at rest
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
	# Real domino proportions: 2:1 (98 × 196). 11px inset ensures the ivory face
	# never intrudes into the 12px rounded corners of the outer ebony frame.
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(88, 180)
	btn.text = ""
	btn.clip_contents = true

	# Inner layout — 11px inset on all sides exposes the dark body as a frame
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   = 11; vbox.offset_top    = 11
	vbox.offset_right  = -11; vbox.offset_bottom = -11
	vbox.add_theme_constant_override("separation", 0)
	btn.add_child(vbox)

	# Top pip-half panel
	var top_panel := PanelContainer.new()
	top_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var top_dot := C_TITLE_GLOW if tile.left < 0 else C_PIP_DOT
	top_panel.add_child(_make_pip_display(tile.left, 15, top_dot))
	vbox.add_child(top_panel)
	btn.set_meta("top_panel", top_panel)

	# Custom name badge (special / wild tiles)
	if tile.custom_name != "":
		var name_lbl := Label.new()
		name_lbl.text = tile.custom_name
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", C_RARITY[tile.rarity])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.clip_contents = true
		vbox.add_child(name_lbl)

	# Spine divider with centre spinner rivet
	vbox.add_child(_make_tile_hsep())

	# Bottom pip-half panel
	var bot_panel := PanelContainer.new()
	bot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bot_dot := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	bot_panel.add_child(_make_pip_display(tile.right, 15, bot_dot))
	vbox.add_child(bot_panel)
	btn.set_meta("bot_panel", bot_panel)

	# Connection / selection indicator strip
	var conn_lbl := _make_label("", C_DIM, 13)
	conn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	conn_lbl.custom_minimum_size  = Vector2(0, 18)
	vbox.add_child(conn_lbl)
	_tile_conn_lbls.append(conn_lbl)

	# Rarity-tinted border for subtle tile-grade identity
	var base_border: Color
	match tile.rarity:
		Constants.Rarity.CARVED:   base_border = C_TILE_BORDER.lerp(Color(0.30, 0.72, 0.30), 0.22)
		Constants.Rarity.IVORY:    base_border = C_TILE_BORDER.lerp(Color(0.90, 0.82, 0.28), 0.30)
		Constants.Rarity.OBSIDIAN: base_border = C_TILE_BORDER.lerp(Color(0.60, 0.28, 0.92), 0.32)
		_:                         base_border = C_TILE_BORDER
	if tile.is_wild:
		base_border = C_TITLE_GLOW
	btn.set_meta("base_border", base_border)

	_apply_tile_style(btn, C_TILE_FACE, C_TILE_FACE_HOVER, base_border)
	_ignore_mouse(vbox)
	btn.pressed.connect(_on_tile_left_click.bind(index))
	return btn

## Lay out the chain into one or more rows with serpentine direction:
##   row 0 → left-to-right, row 1 → right-to-left, row 2 → left-to-right, …
## Doubles render perpendicular to the row (vertical when chain is horizontal),
## matching how physical dominoes are placed on a table.
##
## Tile size scales down for longer chains so 21+ tile chains still fit
## comfortably inside the table panel without horizontal overflow.
##
## Populates `_chain_tile_panels` so the scoring sequence can locate each
## tile by chain index regardless of which row it ended up in.
func _layout_chain_serpentine(chain: Chain) -> void:
	var n: int = chain.length()

	# Adaptive sizing — half = one pip face's edge length.
	# Each tile is a SQUARE slot of (2*half + sep) on each side. With no
	# outer padding, slots in a row sit flush against each other, so the
	# pip halves touch neighbours edge-to-edge.
	var half_size: int
	var per_row:   int
	if n <= 8:
		half_size = 36 ; per_row = 8
	elif n <= 14:
		half_size = 30 ; per_row = 9
	elif n <= 22:
		half_size = 24 ; per_row = 11
	elif n <= 30:
		half_size = 20 ; per_row = 13
	else:
		half_size = 16 ; per_row = 16

	# Group indices into rows (serpentine direction handled at render time).
	var rows: Array = []
	var current: Array = []
	for i in range(n):
		current.append(i)
		if current.size() >= per_row and i < n - 1:
			rows.append(current)
			current = []
	if current.size() > 0:
		rows.append(current)

	# Pre-allocate tile panels so we can fill _chain_tile_panels in chain order
	# even when odd rows render right-to-left.
	_chain_tile_panels.resize(n)

	for r_idx in range(rows.size()):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		# Slots abut directly — no row gap. Each tile's faint outline (set
		# in _build_chain_tile) provides the visible seam between adjacent
		# pieces, so they read as touching but distinct.
		row.add_theme_constant_override("separation", 0)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var indices: Array = rows[r_idx].duplicate()
		var reverse: bool = (r_idx % 2) == 1
		if reverse:
			indices.reverse()

		# GHOST_CHAIN: a deterministic third of the placed tiles render at
		# very low opacity. The rule (`(idx + 1) % 3 == 0`) is stable across
		# renders within a round so the player can lock in which tiles are
		# ghosted and remember them — but they look near-blank, no pip
		# values readable.
		var ghosting: bool = GameState.active_boss_effect() == Constants.BossEffect.GHOST_CHAIN
		for tile_idx in indices:
			var d: Vector2i = chain.tile_displays[tile_idx]
			var is_double: bool = (d.x == d.y)
			# Double  → render perpendicular (vertical) in this horizontal row.
			# Single  → render along the row (horizontal).
			# When the row is reversed (right-to-left), swap left/right faces
			# so the connecting edges still meet correctly visually.
			var left_pip:  int = d.y if reverse else d.x
			var right_pip: int = d.x if reverse else d.y
			var tile_panel: Control = _build_chain_tile(
				left_pip, right_pip, half_size, is_double)
			if ghosting and (tile_idx + 1) % 3 == 0:
				tile_panel.modulate.a = 0.18
			row.add_child(tile_panel)
			_chain_tile_panels[tile_idx] = tile_panel

		_chain_container.add_child(row)

## Build a chain tile in either orientation.
##   vertical=true  → double tile, halves stacked top/bottom (perpendicular).
##                    Rendered as a SQUARE so it matches the row's vertical
##                    rhythm without protruding above/below the non-doubles.
##                    Pip halves are compressed to fit the square footprint.
##   vertical=false → non-double tile, halves laid out left/right (along row).
##                    Standard 2:1 wide rectangle.
##
## Both orientations share the same total HEIGHT, keeping rows uniform when
## doubles and non-doubles are mixed. Doubles' "perpendicular" identity is
## preserved by the stacked-halves layout, just within a square frame.
##
## `half_size` is the edge length of one pip face on a non-double tile. Pip
## dot size, border, corner, and padding all scale from it.
func _build_chain_tile(disp_left: int, disp_right: int,
		half_size: int = 60, vertical: bool = true) -> Control:
	var sep_thickness: int = 2
	var dot_size: int = maxi(4, int(half_size * 0.18))

	# Slot height is identical for every tile (2*half + sep) so all tiles
	# share the row baseline. Slot WIDTH depends on orientation:
	#   - Non-double: full square (2*half + sep) — two halves side-by-side.
	#   - Vertical double: only as wide as its stacked halves (half_size),
	#     so there are no empty lateral bands. The double's halves butt
	#     directly against the neighbouring tiles' halves.
	var slot: int = half_size * 2 + sep_thickness
	var slot_w: int = half_size if vertical else slot

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = Vector2(slot_w, slot)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Faint outline only — no fill, no shadow. This is enough to give each
	# tile a visible silhouette so adjacent tiles don't read as one blob,
	# without bringing back the heavy ebony frame.
	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0, 0, 0, 0)
	style.border_color = Color(0.05, 0.04, 0.03, 0.55)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_meta("border_style",      style)
	panel.set_meta("base_border_color", style.border_color)

	# Centered content keeps every face exactly half_size × half_size square,
	# regardless of orientation. The inner box sits at its natural minimum
	# size in the centre of the slot — content doesn't stretch to fill, so
	# horizontal and vertical tiles render at identical visual proportions.
	#
	# Tiles still "touch" their neighbours in the row because the SLOT
	# edges abut (row separation = 0) and each slot has a faint outline
	# defining the seam between adjacent pieces.
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(center)

	var box: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(box)

	var face_min := Vector2(half_size, half_size)
	var face_h_flag: int = Control.SIZE_SHRINK_CENTER
	var face_v_flag: int = Control.SIZE_SHRINK_CENTER

	var first_panel := PanelContainer.new()
	first_panel.size_flags_horizontal = face_h_flag
	first_panel.size_flags_vertical   = face_v_flag
	first_panel.custom_minimum_size = face_min
	first_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(first_panel, C_TILE_FACE, true)
	_compact_face_panel(first_panel)
	var first_dot_color := C_TITLE_GLOW if disp_left < 0 else C_PIP_DOT
	first_panel.add_child(_make_pip_display(disp_left, dot_size, first_dot_color))
	box.add_child(first_panel)

	# Divider between the two halves — perpendicular to the box axis.
	box.add_child(_make_tile_separator(vertical, sep_thickness))

	var second_panel := PanelContainer.new()
	second_panel.size_flags_horizontal = face_h_flag
	second_panel.size_flags_vertical   = face_v_flag
	second_panel.custom_minimum_size = face_min
	second_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(second_panel, C_TILE_FACE, false)
	_compact_face_panel(second_panel)
	var second_dot_color := C_TITLE_GLOW if disp_right < 0 else C_PIP_DOT
	second_panel.add_child(_make_pip_display(disp_right, dot_size, second_dot_color))
	box.add_child(second_panel)

	return panel

## Override the face panel's stylebox content margin to a small value so the
## panel's own minimum size is dominated by the pip-display content rather
## than its texture padding. Used by the chain tile builder so vertical
## doubles don't end up much taller than horizontal tiles.
func _compact_face_panel(face: PanelContainer) -> void:
	var sb: StyleBox = face.get_theme_stylebox("panel")
	if sb == null:
		return
	# StyleBoxTexture and StyleBoxFlat both expose set_content_margin_all.
	if sb is StyleBoxTexture or sb is StyleBoxFlat:
		sb.set_content_margin_all(1.0)

## Tile-half divider. Vertical tile gets a horizontal line; horizontal tile
## gets a vertical line. Falls back to ColorRect to avoid pulling in the
## existing `_make_tile_hsep` helper which only does the horizontal flavour.
func _make_tile_separator(vertical: bool, thickness: int) -> Control:
	var sep := ColorRect.new()
	sep.color = C_TILE_BORDER.darkened(0.2)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if vertical:
		sep.custom_minimum_size = Vector2(0, thickness)
		sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		sep.custom_minimum_size = Vector2(thickness, 0)
		sep.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	return sep

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
		lbl.add_theme_font_size_override("font_size", dot_size + 12)
		lbl.add_theme_color_override("font_color", dot_color)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		return lbl

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
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
# Cinematic skip helpers
# ===========================================================================

## Current animation-speed multiplier (1.0 baseline). Applied to long
## cinematics at creation time via Tween.set_speed_scale().
func _anim_speed() -> float:
	return maxf(0.1, SaveManager.get_anim_speed())

## Register a tween as the currently-active skippable cinematic, then
## scale it by the user's anim-speed preference. The finish handler
## clears the reference only if the finishing tween is still the active
## one — so if a new cinematic starts before this one's signal fires
## it doesn't accidentally null out the new tween.
func _register_cinematic(t: Tween) -> void:
	_active_cinematic_tween = t
	if t != null:
		t.set_speed_scale(_anim_speed())
		t.finished.connect(func():
			if _active_cinematic_tween == t:
				_active_cinematic_tween = null
		)

## Fast-forward the active cinematic to completion. Called from input
## handlers (Space/Enter/Esc/click) and from buttons that explicitly
## offer a skip affordance. Safe to call when no cinematic is active.
func _request_cinematic_skip() -> void:
	if _active_cinematic_tween == null:
		return
	if not is_instance_valid(_active_cinematic_tween):
		_active_cinematic_tween = null
		return
	# 100x scale resolves multi-second cinematics in a frame or two and
	# still fires every tween_callback in order. Cleaner than killing
	# the tween outright (which would drop final-state callbacks).
	_active_cinematic_tween.set_speed_scale(100.0)

## True when an input event during BOSS_WARNING / scoring / GAME_OVER /
## VICTORY should be consumed as a fast-forward rather than a game
## action. Centralised so input handler + button handler stay in sync.
func _can_skip_cinematic() -> bool:
	if _active_cinematic_tween == null:
		return false
	if not is_instance_valid(_active_cinematic_tween):
		return false
	# Modal overlays consume their own input — don't let Space/click leak
	# through and skip a cinematic the player can't even see right now.
	if _settings_overlay != null and _settings_overlay.visible:
		return false
	if _pause_overlay != null and _pause_overlay.visible:
		return false
	return true

# ===========================================================================
# Keyboard shortcuts
# ===========================================================================
func _unhandled_input(event: InputEvent) -> void:
	# Skip-cinematic is universal across phases. Trigger it first, before
	# the per-phase routing below, so the player can fast-forward the boss
	# warning, scoring cascade, or run-end reveal with one key.
	if _can_skip_cinematic():
		var skip := false
		if event is InputEventKey and (event as InputEventKey).pressed:
			var kc := (event as InputEventKey).keycode
			if kc == KEY_SPACE or kc == KEY_ENTER or kc == KEY_KP_ENTER \
					or kc == KEY_ESCAPE:
				skip = true
		elif event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
				skip = true
		if skip:
			_request_cinematic_skip()
			get_viewport().set_input_as_handled()
			return
	# Cinematic finished — Space/Enter act as "confirm" on the post-
	# cinematic screens (boss warning's BEGIN, run-end's NEW TRIAL CYCLE)
	# so a player who skipped a cutscene isn't forced to also reach for
	# the mouse to dismiss it.
	if event is InputEventKey and (event as InputEventKey).pressed:
		var ekc := (event as InputEventKey).keycode
		var is_confirm := ekc == KEY_SPACE or ekc == KEY_ENTER or ekc == KEY_KP_ENTER
		if is_confirm:
			if _phase == Phase.BOSS_WARNING and _boss_begin_btn != null \
					and not _boss_begin_btn.disabled:
				_on_boss_begin_pressed()
				get_viewport().set_input_as_handled()
				return
			if (_phase == Phase.GAME_OVER or _phase == Phase.VICTORY) \
					and _btn_run_end != null and not _btn_run_end.disabled:
				_on_run_end_pressed()
				get_viewport().set_input_as_handled()
				return
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
			# Shift+U clears the entire selection in one keystroke. Matches
			# the right-click affordance on the Undo button so keyboard and
			# mouse users share the same shortcut surface.
			if (event as InputEventKey).shift_pressed:
				_on_undo_clear_all()
			else:
				_on_undo_pressed()
		KEY_D:
			if not _selected_tiles.is_empty() and _rm.can_discard():
				_rm.discard(_selected_tiles)
				_selected_tiles.clear()
		KEY_ESCAPE:
			# ESC priority: cancel modal-like states first, fall through to
			# clearing selection, finally open the pause overlay if there's
			# nothing else to dismiss. Pressing ESC again closes pause.
			if _pause_overlay != null and _pause_overlay.visible:
				_on_pause_resume_pressed()
			elif _compass_overlay != null:
				_on_compass_cancel()
			elif _reinforcement_pending != null:
				_cancel_reinforcement_targeting()
			elif not _selected_tiles.is_empty():
				_selected_tiles.clear()
				_refresh_tile_visuals()
				_refresh_chain_display()
				_refresh_action_buttons()
			else:
				_on_pause_pressed()

## Animate a hand-tile button lifting (selected) or returning to rest (deselected).
## State-guarded so tweens don't stack on rapid clicks.
func _apply_tile_lift(btn: Button, lift: bool) -> void:
	# Guard with has_meta — Godot's get_meta(name, default) returns the
	# default correctly but still logs an "object has no meta with key X"
	# error when the key is missing. has_meta keeps the console clean on
	# the first refresh after a tile is created.
	var was_lifted: bool = false
	if btn.has_meta("_lifted"):
		was_lifted = btn.get_meta("_lifted")
	if was_lifted == lift:
		return
	btn.set_meta("_lifted", lift)
	var prev: Tween = null
	if btn.has_meta("_lt"):
		prev = btn.get_meta("_lt")
	if prev != null and is_instance_valid(prev):
		prev.kill()
	var lt := btn.create_tween().set_parallel(true)
	btn.set_meta("_lt", lt)
	if lift:
		lt.tween_property(btn, "position:y", -9.0, 0.12) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		lt.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.12) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		lt.tween_property(btn, "position:y", 0.0, 0.10) \
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		lt.tween_property(btn, "scale", Vector2.ONE, 0.10) \
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

## Recursively set MOUSE_FILTER_IGNORE on a node and all its Control children,
## so mouse events pass through to the parent Button unobstructed.
func _ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)

func _make_tile_hsep() -> Control:
	# Outer container — 10px tall, full width
	var outer := Control.new()
	outer.custom_minimum_size   = Vector2(0, 10)
	outer.size_flags_horizontal = Control.SIZE_FILL
	outer.mouse_filter          = Control.MOUSE_FILTER_IGNORE

	# Spine bar across the full width, centred vertically (30%–70%)
	var bar := ColorRect.new()
	bar.color          = C_TILE_DIVIDER
	bar.anchor_left    = 0.0;  bar.anchor_right  = 1.0
	bar.anchor_top     = 0.35; bar.anchor_bottom = 0.65
	bar.offset_left    = 0;    bar.offset_right  = 0
	bar.offset_top     = 0;    bar.offset_bottom = 0
	bar.mouse_filter   = Control.MOUSE_FILTER_IGNORE
	outer.add_child(bar)

	# Spinner rivet — a 10×10 rounded circle centred on the spine
	var rivet := PanelContainer.new()
	rivet.anchor_left   = 0.5; rivet.anchor_right  = 0.5
	rivet.anchor_top    = 0.5; rivet.anchor_bottom = 0.5
	rivet.offset_left   = -5;  rivet.offset_right  = 5
	rivet.offset_top    = -5;  rivet.offset_bottom = 5
	rivet.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	var rs := StyleBoxFlat.new()
	rs.bg_color = C_TILE_DIVIDER.lightened(0.45)
	rs.set_corner_radius_all(5)
	rivet.add_theme_stylebox_override("panel", rs)
	outer.add_child(rivet)

	return outer

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
## face / hover  — face colour used for the inner pip-half panels.
## border        — border colour; pass C_TILE_BORDER_SEL for selected state.
func _apply_tile_style(btn: Button, face: Color, hover: Color,
		border: Color = C_TILE_BORDER) -> void:
	var shadow := Color(0.0, 0.0, 0.0, 0.45)

	for n in ["normal", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color     = C_TILE_BODY
		s.border_color = border
		s.set_border_width_all(4); s.set_corner_radius_all(12)
		s.shadow_color = shadow; s.shadow_size = 6
		btn.add_theme_stylebox_override(n, s)

	var sh := StyleBoxFlat.new()
	sh.bg_color     = C_TILE_BODY.lightened(0.09)
	sh.border_color = border.lightened(0.30)
	sh.set_border_width_all(4); sh.set_corner_radius_all(12)
	sh.shadow_color = shadow; sh.shadow_size = 7
	btn.add_theme_stylebox_override("hover", sh)

	var sp := StyleBoxFlat.new()
	sp.bg_color     = C_TILE_BODY.darkened(0.08)
	sp.border_color = border
	sp.set_border_width_all(4); sp.set_corner_radius_all(12)
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
	root.add_theme_constant_override("separation", 0)
	ui.add_child(root)

	# Top HUD bar
	root.add_child(_build_hud())

	# Mid row: contracts | center(table+chain bar) | artifacts
	var mid_hbox := HBoxContainer.new()
	mid_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid_hbox.custom_minimum_size = Vector2(0, 220)
	mid_hbox.add_theme_constant_override("separation", 0)
	root.add_child(mid_hbox)

	mid_hbox.add_child(_build_contracts_panel())

	var center_vbox := VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.add_theme_constant_override("separation", 0)
	mid_hbox.add_child(center_vbox)

	center_vbox.add_child(_build_table_area())
	center_vbox.add_child(_build_chain_info_bar())

	mid_hbox.add_child(_build_artifacts_panel())

	# Bottom row: tile box | hand zone | usables (shrinks to minimum, never steals mid space)
	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_hbox.add_theme_constant_override("separation", 0)
	root.add_child(bottom_hbox)

	bottom_hbox.add_child(_build_tile_box_panel())
	var hand_zone := _build_hand_zone()
	hand_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(hand_zone)
	bottom_hbox.add_child(_build_usables_panel())

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

	_settings_overlay = _build_settings_overlay()
	ui.add_child(_settings_overlay)
	_settings_overlay.hide()

	_tutorial_overlay = _build_tutorial_overlay()
	ui.add_child(_tutorial_overlay)
	_tutorial_overlay.hide()

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
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when hud_panel.png ready
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 64)
	_hud_style = StyleBoxFlat.new()
	_hud_style.bg_color = C_WOOD
	_hud_style.border_color = C_GOLD_RIM
	_hud_style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/hud_panel.png", _hud_style))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(hbox)

	# ── MANOS pill (blue tint) ────────────────────────────
	var manos_pc := PanelContainer.new()
	manos_pc.custom_minimum_size = Vector2(120, 52)
	var manos_style := StyleBoxFlat.new()
	manos_style.bg_color = C_MANOS_BG
	manos_style.set_corner_radius_all(8)
	manos_style.set_border_width_all(1)
	manos_style.border_color = C_GOLD_RIM
	manos_pc.add_theme_stylebox_override("panel", manos_style)
	hbox.add_child(manos_pc)

	var manos_vbox := VBoxContainer.new()
	manos_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	manos_vbox.add_theme_constant_override("separation", 2)
	manos_pc.add_child(manos_vbox)

	var manos_lbl := _make_label("MANOS", C_DIM, 10)
	manos_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	manos_vbox.add_child(manos_lbl)

	var manos_count_row := HBoxContainer.new()
	manos_count_row.alignment = BoxContainer.ALIGNMENT_CENTER
	manos_count_row.add_theme_constant_override("separation", 4)
	manos_vbox.add_child(manos_count_row)
	manos_count_row.add_child(_make_label("✋", C_TEXT, 14))
	_lbl_manos_count = _make_label("0/0", C_TEXT, 22)
	FontManager.apply_mono(_lbl_manos_count)
	manos_count_row.add_child(_lbl_manos_count)

	# Hidden dot rows kept for _refresh_hud() compatibility
	_hands_dot_row = HBoxContainer.new()
	_hands_dot_row.visible = false
	manos_vbox.add_child(_hands_dot_row)

	# ── Left spacer ───────────────────────────────────────
	var spacer_l := Control.new()
	spacer_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer_l)

	# ── Score block (center) ──────────────────────────────
	var score_vbox := VBoxContainer.new()
	score_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	score_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(score_vbox)

	_lbl_score_label = _make_label("PUNTUACIÓN DE RONDA", C_DIM, 10)
	_lbl_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_vbox.add_child(_lbl_score_label)

	_lbl_score_big = _make_label("0", C_SCORE_BIG, 42)
	_lbl_score_big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_score_big)
	score_vbox.add_child(_lbl_score_big)

	# Chronos bar — slim 6px, kept here for _apply_etapa_theme compatibility
	var bar_wrap := Control.new()
	bar_wrap.custom_minimum_size = Vector2(180, 6)
	bar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_vbox.add_child(bar_wrap)

	_chronos_bar = ProgressBar.new()
	_chronos_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chronos_bar.min_value = 0
	_chronos_bar.max_value = 100
	_chronos_bar.value     = 0
	_chronos_bar.show_percentage = false
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.08, 0.07, 0.05)
	bar_bg.set_corner_radius_all(3)
	_chronos_bar.add_theme_stylebox_override("background", bar_bg)
	_chronos_bar_fill_style = StyleBoxFlat.new()
	_chronos_bar_fill_style.bg_color = C_CHRONOS.darkened(0.3)
	_chronos_bar_fill_style.set_corner_radius_all(3)
	_chronos_bar.add_theme_stylebox_override("fill", _chronos_bar_fill_style)
	bar_wrap.add_child(_chronos_bar)

	# Invisible chronos label — still needed by _set_chronos_bar
	_chronos_bar_lbl = _make_label("", C_TEXT, 12)
	_chronos_bar_lbl.visible = false
	FontManager.apply_mono(_chronos_bar_lbl)
	score_vbox.add_child(_chronos_bar_lbl)

	# Round / Etapa / Monedas — kept for _refresh_hud + _apply_etapa_theme
	_lbl_round   = _make_label("Round 1 / 15", C_DIM, 10)
	_lbl_etapa   = _make_label("Mahogany", C_DIM, 10)
	_lbl_monedas = _make_label("Monedas: 0", C_MONEDAS, 10)
	_lbl_round.visible   = false
	_lbl_etapa.visible   = false
	_lbl_monedas.visible = false
	score_vbox.add_child(_lbl_round)
	score_vbox.add_child(_lbl_etapa)
	score_vbox.add_child(_lbl_monedas)

	# ── Right spacer ──────────────────────────────────────
	var spacer_r := Control.new()
	spacer_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer_r)

	# ── DESCARTES pill (red tint) ─────────────────────────
	var disc_pc := PanelContainer.new()
	disc_pc.custom_minimum_size = Vector2(120, 52)
	var disc_style := StyleBoxFlat.new()
	disc_style.bg_color = C_DISC_BG
	disc_style.set_corner_radius_all(8)
	disc_style.set_border_width_all(1)
	disc_style.border_color = C_GOLD_RIM
	disc_pc.add_theme_stylebox_override("panel", disc_style)
	hbox.add_child(disc_pc)

	var disc_vbox := VBoxContainer.new()
	disc_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	disc_vbox.add_theme_constant_override("separation", 2)
	disc_pc.add_child(disc_vbox)

	var disc_lbl := _make_label("DESCARTES", C_DIM, 10)
	disc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	disc_vbox.add_child(disc_lbl)

	var disc_count_row := HBoxContainer.new()
	disc_count_row.alignment = BoxContainer.ALIGNMENT_CENTER
	disc_count_row.add_theme_constant_override("separation", 4)
	disc_vbox.add_child(disc_count_row)
	disc_count_row.add_child(_make_label("🗑", C_TEXT, 14))
	_lbl_descartes_count = _make_label("0/0", C_TEXT, 22)
	FontManager.apply_mono(_lbl_descartes_count)
	disc_count_row.add_child(_lbl_descartes_count)

	# Hidden dot row kept for _refresh_hud() compatibility
	_discards_dot_row = HBoxContainer.new()
	_discards_dot_row.visible = false
	disc_vbox.add_child(_discards_dot_row)

	# ── CAJA pill (box / draw pile) — shows tiles remaining ─
	var box_pc := PanelContainer.new()
	box_pc.custom_minimum_size = Vector2(110, 52)
	var box_style := StyleBoxFlat.new()
	box_style.bg_color = Color(0.10, 0.07, 0.16, 0.92)
	box_style.set_corner_radius_all(8)
	box_style.set_border_width_all(1)
	box_style.border_color = C_GOLD_RIM
	box_pc.add_theme_stylebox_override("panel", box_style)
	hbox.add_child(box_pc)

	var box_vbox := VBoxContainer.new()
	box_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	box_vbox.add_theme_constant_override("separation", 2)
	box_pc.add_child(box_vbox)

	var box_lbl := _make_label("CAJA", C_DIM, 10)
	box_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_vbox.add_child(box_lbl)

	var box_count_row := HBoxContainer.new()
	box_count_row.alignment = BoxContainer.ALIGNMENT_CENTER
	box_count_row.add_theme_constant_override("separation", 4)
	box_vbox.add_child(box_count_row)
	box_count_row.add_child(_make_label("◰", C_TEXT, 14))
	_lbl_box_count = _make_label("0/0", C_TEXT, 22)
	FontManager.apply_mono(_lbl_box_count)
	box_count_row.add_child(_lbl_box_count)

	# ── MONEDAS pill (gold) — visible wallet counter ──────
	var mon_pc := PanelContainer.new()
	mon_pc.custom_minimum_size = Vector2(110, 52)
	var mon_style := StyleBoxFlat.new()
	mon_style.bg_color = Color(0.20, 0.15, 0.04, 0.92)
	mon_style.set_corner_radius_all(8)
	mon_style.set_border_width_all(1)
	mon_style.border_color = C_MONEDAS.darkened(0.3)
	mon_pc.add_theme_stylebox_override("panel", mon_style)
	hbox.add_child(mon_pc)

	var mon_vbox := VBoxContainer.new()
	mon_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	mon_vbox.add_theme_constant_override("separation", 2)
	mon_pc.add_child(mon_vbox)

	var mon_lbl := _make_label("MONEDAS", C_DIM, 10)
	mon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mon_vbox.add_child(mon_lbl)

	var mon_count_row := HBoxContainer.new()
	mon_count_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mon_count_row.add_theme_constant_override("separation", 4)
	mon_vbox.add_child(mon_count_row)
	mon_count_row.add_child(_make_label("◉", C_MONEDAS, 14))
	_lbl_monedas_pill = _make_label("0", C_MONEDAS, 22)
	FontManager.apply_mono(_lbl_monedas_pill)
	mon_count_row.add_child(_lbl_monedas_pill)

	# ── Pause button ──────────────────────────────────────
	# Sits just before the gear so the right edge cluster reads as
	# "session controls" (pause / settings) — distinct from the resource
	# pills (manos / discards / box) on the same row.
	var pause_style := StyleBoxFlat.new()
	pause_style.bg_color = Color(0, 0, 0, 0)
	var pause_btn := Button.new()
	pause_btn.text = "❙❙"
	pause_btn.custom_minimum_size = Vector2(36, 36)
	pause_btn.add_theme_stylebox_override("normal", pause_style)
	pause_btn.add_theme_stylebox_override("hover",  pause_style)
	pause_btn.add_theme_stylebox_override("pressed", pause_style)
	pause_btn.add_theme_font_size_override("font_size", 18)
	pause_btn.add_theme_color_override("font_color", C_DIM)
	pause_btn.pressed.connect(_on_pause_pressed)
	hbox.add_child(pause_btn)

	# ── Gear button ───────────────────────────────────────
	var gear_style := StyleBoxFlat.new()
	gear_style.bg_color = Color(0, 0, 0, 0)
	var gear_btn := Button.new()
	gear_btn.text = "⚙"
	gear_btn.custom_minimum_size = Vector2(36, 36)
	gear_btn.add_theme_stylebox_override("normal", gear_style)
	gear_btn.add_theme_stylebox_override("hover",  gear_style)
	gear_btn.add_theme_stylebox_override("pressed", gear_style)
	gear_btn.add_theme_font_size_override("font_size", 20)
	gear_btn.add_theme_color_override("font_color", C_DIM)
	gear_btn.pressed.connect(_on_settings_btn_pressed)
	hbox.add_child(gear_btn)

	return panel

# ---- Table area (dominant game surface — expands to fill) ----
func _build_table_area() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when felt_table.png ready
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_table_style = StyleBoxFlat.new()
	_table_style.bg_color     = C_FELT
	_table_style.border_color = C_FELT_BORDER
	_table_style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/felt_table.png", _table_style))

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Top label
	_lbl_table_title = _make_label("COHESION PULSE", C_DIM, 11)
	_lbl_table_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_lbl_table_title)

	# Contract bar — shows active mastery contract + progress (hidden when none)
	_contract_bar = _build_contract_bar()
	_contract_bar.hide()
	vbox.add_child(_contract_bar)

	# Branch indicators — populated when the chain has live extra_ends
	# (open branch values from previously-placed doubles). Sits above the
	# chain so the player can see at a glance which pip values can still
	# be matched via branching.
	_chain_branches_row = HBoxContainer.new()
	_chain_branches_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_chain_branches_row.add_theme_constant_override("separation", 6)
	vbox.add_child(_chain_branches_row)

	# Chain tiles — VBox of rows. Each row is built fresh in _refresh_chain_display.
	#
	# Wrapped in a flex-sized Control that:
	#   • reports a small custom_minimum_size (80 px) to the parent layout,
	#     so the table never demands more vertical space than available
	#     (which would push the bottom hand zone past the viewport);
	#   • EXPAND_FILLs vertically inside the table so it absorbs whatever
	#     space the rest of the table panel doesn't claim;
	#   • clips overflow + delegates to a ScrollContainer so a long
	#     serpentine chain still scrolls cleanly when it's taller than the
	#     visible area allows.
	#
	# Plain Control doesn't propagate child min_sizes — the chain VBox
	# inside can be any height without forcing the parent to grow.
	var chain_outer := Control.new()
	chain_outer.custom_minimum_size      = Vector2(0, 80)
	chain_outer.size_flags_horizontal    = Control.SIZE_EXPAND_FILL
	chain_outer.size_flags_vertical      = Control.SIZE_EXPAND_FILL
	chain_outer.clip_contents            = true
	chain_outer.mouse_filter             = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(chain_outer)

	var chain_scroll := ScrollContainer.new()
	chain_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chain_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	chain_outer.add_child(chain_scroll)

	_chain_container = VBoxContainer.new()
	_chain_container.alignment             = BoxContainer.ALIGNMENT_CENTER
	_chain_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chain_container.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	_chain_container.add_theme_constant_override("separation", 6)
	chain_scroll.add_child(_chain_container)

	# Score preview — two lines: equation (dim, small) + total (green, large)
	_lbl_preview = _make_label("", C_DIM, 13)
	_lbl_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_preview)
	vbox.add_child(_lbl_preview)

	_lbl_preview_total = _make_label("", C_CHRONOS, 26)
	_lbl_preview_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_preview_total)
	vbox.add_child(_lbl_preview_total)

	# Active-tier banner — large readable label above the segment bar so
	# the player can see their current bonus level without parsing colours.
	_lbl_active_tier = _make_label("", C_DIM, 14)
	_lbl_active_tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_active_tier)
	vbox.add_child(_lbl_active_tier)

	# Chain-length milestone — dot row: ● ● ● ● ┊+1 ○ ○ ○ ┊+2 ○
	_chain_milestone_row = HBoxContainer.new()
	_chain_milestone_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_chain_milestone_row.add_theme_constant_override("separation", 4)
	vbox.add_child(_chain_milestone_row)

	# (bot_spacer removed — chain_outer is now EXPAND_FILL and absorbs
	# any extra vertical space inside the table panel; an extra spacer
	# would steal expand budget from the chain area.)

	# Last-hand result — pinned at bottom of table
	_lbl_last_hand = _make_label("", C_LAST_HAND, 14)
	_lbl_last_hand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_last_hand)
	vbox.add_child(_lbl_last_hand)

	return panel

# ---- Chain info bar (teal pill between table and hand) ----
func _build_chain_info_bar() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when chain_bar.png ready
	var outer := CenterContainer.new()
	outer.custom_minimum_size = Vector2(0, 28)

	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = C_CHAIN_BAR_BG
	pill_style.set_corner_radius_all(14)
	pill_style.set_border_width_all(1)
	pill_style.border_color = C_GOLD_RIM.darkened(0.4)

	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(320, 24)
	pill.add_theme_stylebox_override("panel", pill_style)
	outer.add_child(pill)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	pill.add_child(hbox)

	hbox.add_child(_make_label("◆", C_CHRONOS.darkened(0.3), 10))

	_chain_info_lbl = _make_label("CADENA: 0", C_DIM, 12)
	hbox.add_child(_chain_info_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Boss-effect reminder — populated each round in _refresh_boss_effect_lbl,
	# visible only when a special-effect boss is active.
	_boss_effect_lbl = _make_label("", C_LOSE, 11)
	_boss_effect_lbl.visible = false
	FontManager.apply_mono(_boss_effect_lbl)
	hbox.add_child(_boss_effect_lbl)

	_chain_bonus_lbl = _make_label("", C_CHRONOS, 14)
	FontManager.apply_mono(_chain_bonus_lbl)
	hbox.add_child(_chain_bonus_lbl)

	hbox.add_child(_make_label("◆", C_CHRONOS.darkened(0.3), 10))

	return outer

# ---- Contracts panel (left, ~220px) ----
func _build_contracts_panel() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when contracts_panel.png ready
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color     = C_PANEL_DARK
	panel_style.border_color = C_GOLD_RIM
	panel_style.set_border_width_all(1)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 0)
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/contracts_panel.png", panel_style))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	vbox.add_child(header)
	var hdr_diamond := _make_label("◆", C_CHRONOS, 12)
	header.add_child(hdr_diamond)
	var hdr_lbl := _make_label("CONTRATOS", C_GOLD_TITLE, 12)
	header.add_child(hdr_lbl)

	# Contract cards vbox
	_contracts_vbox = VBoxContainer.new()
	_contracts_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_contracts_vbox)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Footer: reward total
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 4)
	vbox.add_child(footer)
	footer.add_child(_make_label("RECOMPENSA:", C_DIM, 10))
	footer.add_child(_make_label("◎", C_MONEDAS, 12))
	footer.add_child(_make_label("—", C_MONEDAS, 12))

	return panel

func _build_contract_card(c: MasteryContract) -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when contract_card.png ready
	var card_style := StyleBoxFlat.new()
	card_style.bg_color     = C_PARCHMENT
	card_style.border_color = C_GOLD_RIM
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(4)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", card_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	card.add_child(hbox)

	# Contract icon
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color     = C_PANEL_DARK
	icon_style.border_color = C_GOLD_RIM
	icon_style.set_border_width_all(1)
	icon_style.set_corner_radius_all(4)
	var icon_box := PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(36, 36)
	icon_box.add_theme_stylebox_override("panel", icon_style)
	var icon_lbl := _make_label("◈", C_GOLD_TITLE, 16)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_box.add_child(icon_lbl)
	hbox.add_child(icon_box)

	# Info column
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 2)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_lbl := _make_label(c.display_name, C_TEXT, 13)
	info_vbox.add_child(name_lbl)

	if c.description != "":
		var desc_lbl := _make_label(c.description, C_DIM, 10)
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.custom_minimum_size = Vector2(140, 0)
		info_vbox.add_child(desc_lbl)

	# Progress bar
	var prog_bar := ProgressBar.new()
	prog_bar.custom_minimum_size = Vector2(0, 8)
	prog_bar.min_value = 0
	prog_bar.max_value = maxi(c.target, 1)
	prog_bar.value     = c.progress
	prog_bar.show_percentage = false
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = C_PANEL_DARK
	pb_bg.set_corner_radius_all(4)
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = C_CHRONOS
	pb_fill.set_corner_radius_all(4)
	prog_bar.add_theme_stylebox_override("background", pb_bg)
	prog_bar.add_theme_stylebox_override("fill", pb_fill)
	info_vbox.add_child(prog_bar)

	var prog_lbl := _make_label(c.progress_text(), C_DIM, 10)
	info_vbox.add_child(prog_lbl)

	return card

# ---- Artifacts panel (right, ~220px) ----
func _build_artifacts_panel() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when artifacts_panel.png ready
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color     = C_PANEL_DARK
	panel_style.border_color = C_GOLD_RIM
	panel_style.set_border_width_all(1)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 0)
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/artifacts_panel.png", panel_style))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Header (purple tint)
	var hdr_style := StyleBoxFlat.new()
	hdr_style.bg_color = C_ARTIFACT_HDR
	var hdr_pc := PanelContainer.new()
	hdr_pc.add_theme_stylebox_override("panel", hdr_style)
	vbox.add_child(hdr_pc)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	hdr_pc.add_child(header)
	header.add_child(_make_label("◆", C_MULT, 12))
	header.add_child(_make_label("ARTEFACTOS", C_GOLD_TITLE, 12))

	# Artifact cards vbox
	_artifacts_vbox = VBoxContainer.new()
	_artifacts_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_artifacts_vbox)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	return panel

func _build_artifact_card(m: Module) -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when artifact_card.png ready
	var rarity_color: Color = C_RARITY[m.rarity]
	var card_style := StyleBoxFlat.new()
	card_style.bg_color     = C_PANEL_DARK
	card_style.border_color = rarity_color
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(4)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", card_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	card.add_child(hbox)

	hbox.add_child(_build_item_icon(m.icon_path, m.display_name, rarity_color, Vector2(40, 40)))

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 2)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_lbl := _make_label(m.display_name, rarity_color, 13)
	info_vbox.add_child(name_lbl)

	var desc_lbl := _make_label(m.description, C_DIM, 10)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_lbl)

	# Tier diamonds — use rarity as tier proxy (0–3 filled diamonds)
	var tier: int = m.rarity
	var diamonds_row := HBoxContainer.new()
	diamonds_row.add_theme_constant_override("separation", 2)
	info_vbox.add_child(diamonds_row)
	for i in range(4):
		var sym := "◆" if i < tier else "◇"
		diamonds_row.add_child(_make_label(sym, rarity_color, 10))

	return card

# ---- Tile box panel (bottom-left, ~160px) ----
func _build_tile_box_panel() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when tile_box_panel.png ready
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color     = C_PANEL_DARK
	panel_style.border_color = C_GOLD_RIM
	panel_style.set_border_width_all(1)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 0)
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/tile_box_panel.png", panel_style))

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var hdr := _make_label("CAJA DE FICHAS", C_GOLD_TITLE, 11)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)

	# Book icon placeholder — swappable TextureRect
	var box_icon_style := StyleBoxFlat.new()
	box_icon_style.bg_color     = C_PANEL_DARK.darkened(0.3)
	box_icon_style.border_color = C_GOLD_RIM
	box_icon_style.set_border_width_all(1)
	box_icon_style.set_corner_radius_all(6)
	var box_icon_pc := PanelContainer.new()
	box_icon_pc.custom_minimum_size = Vector2(80, 80)
	box_icon_pc.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box_icon_pc.add_theme_stylebox_override("panel", box_icon_style)
	vbox.add_child(box_icon_pc)
	# ASSET HOOK: replace this Label with TextureRect when box_icon.png ready
	var box_icon_lbl := _make_label("📦", C_GOLD_TITLE, 32)
	box_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_icon_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	box_icon_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box_icon_pc.add_child(box_icon_lbl)

	_lbl_tile_box_count = _make_label("0", C_TEXT, 22)
	_lbl_tile_box_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_tile_box_count)
	vbox.add_child(_lbl_tile_box_count)

	return panel

# ---- Usables panel (bottom-right, ~200px) ----
func _build_usables_panel() -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when usables_panel.png ready
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color     = C_PANEL_DARK
	panel_style.border_color = C_GOLD_RIM
	panel_style.set_border_width_all(1)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 0)
	panel.add_theme_stylebox_override("panel", _style_or_tex("res://assets/ui/usables_panel.png", panel_style))

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var hdr := _make_label("OBJETOS USABLES", C_GOLD_TITLE, 11)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)

	_usables_hbox = HBoxContainer.new()
	_usables_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_usables_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(_usables_hbox)

	return panel

func _build_usable_slot(r) -> Control:
	# ASSET HOOK: swap StyleBoxFlat → StyleBoxTexture when usable_slot.png ready
	var slot_container := Control.new()
	slot_container.custom_minimum_size = Vector2(72, 88)

	var rarity_color: Color = C_RARITY[r.rarity] if r != null and r.get("rarity") != null else C_DIM

	var slot_style := StyleBoxFlat.new()
	slot_style.bg_color     = C_PANEL_DARK
	slot_style.border_color = rarity_color
	slot_style.set_border_width_all(2)
	slot_style.set_corner_radius_all(36)

	var slot_pc := PanelContainer.new()
	slot_pc.custom_minimum_size = Vector2(72, 72)
	slot_pc.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	slot_pc.add_theme_stylebox_override("panel", slot_style)
	slot_container.add_child(slot_pc)

	if r != null:
		var icon := _build_item_icon(r.icon_path, r.display_name, rarity_color, Vector2(60, 60))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot_pc.add_child(icon)

	# Badge (count)
	var badge := _make_label("1", C_TEXT, 11)
	badge.position = Vector2(54, 0)
	badge.custom_minimum_size = Vector2(18, 18)
	slot_container.add_child(badge)

	# Name label below
	var name_text: String = r.display_name if r != null else ""
	var name_lbl := _make_label(name_text, C_DIM, 9)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_lbl.offset_top = 74
	slot_container.add_child(name_lbl)

	return slot_container

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
	_hand_container.custom_minimum_size = Vector2(0, 188)
	inner.add_child(_hand_container)

	# Reinforcement tray — 3 consumable slots, hidden until player has any
	_reinforcement_tray = _build_reinforcement_tray()
	inner.add_child(_reinforcement_tray)

	inner.add_child(_build_action_bar())

	return outer

# ---- Contract bar (active mastery objective indicator) ----
func _build_contract_bar() -> Control:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)

	var icon_lbl := _make_label("◈", C_TITLE_GLOW, 14)
	hbox.add_child(icon_lbl)

	_lbl_contract = _make_label("", C_TEXT, 12)
	_lbl_contract.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(_lbl_contract)

	return hbox

## Refresh contract bar visibility and text from GameState.active_contracts.
func _refresh_contract_bar() -> void:
	if _contract_bar == null or _lbl_contract == null:
		return
	if GameState.active_contracts.is_empty():
		_contract_bar.hide()
		return
	var c: MasteryContract = GameState.active_contracts[0]
	_lbl_contract.text = "CONTRACT: %s  —  %s" % [c.display_name, c.progress_text()]
	_contract_bar.show()

func _refresh_contracts_panel() -> void:
	if _contracts_vbox == null:
		return
	for ch in _contracts_vbox.get_children():
		ch.queue_free()
	for c: MasteryContract in GameState.active_contracts:
		_contracts_vbox.add_child(_build_contract_card(c))

func _refresh_artifacts_panel() -> void:
	if _artifacts_vbox == null:
		return
	for ch in _artifacts_vbox.get_children():
		ch.queue_free()
	for m in GameState.modules:
		_artifacts_vbox.add_child(_build_artifact_card(m))

func _refresh_tile_box() -> void:
	if _lbl_tile_box_count == null:
		return
	_lbl_tile_box_count.text = "%d" % GameState.box.draw_pile_size()

func _refresh_usables_panel() -> void:
	if _usables_hbox == null:
		return
	for ch in _usables_hbox.get_children():
		ch.queue_free()
	var count := mini(GameState.reinforcements.size(), 3)
	for i in range(count):
		_usables_hbox.add_child(_build_usable_slot(GameState.reinforcements[i]))

# ---- Reinforcement tray (3 consumable slots) ----
func _build_reinforcement_tray() -> Control:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	hbox.custom_minimum_size = Vector2(0, 44)
	# Tray label
	var lbl := _make_label("REINFORCEMENTS", C_DIM, 10)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(100, 0)
	hbox.add_child(lbl)
	# 3 empty slots
	for i in range(GameState.MAX_REINFORCEMENTS):
		var slot := _build_reinforcement_slot(null, i)
		hbox.add_child(slot)
	return hbox

## Build one reinforcement slot button. r = null → empty/disabled placeholder.
func _build_reinforcement_slot(r, _slot_index: int) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(52, 52)
	btn.text = ""
	btn.clip_contents = true

	var has_item: bool = r != null
	var accent: Color = Color(0.80, 0.65, 0.30) if has_item else C_DIM

	# Normal style
	var sn := StyleBoxFlat.new()
	sn.bg_color     = C_TILE_BODY if has_item else Color(0.10, 0.09, 0.07)
	sn.border_color = accent
	sn.set_border_width_all(2)
	sn.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal", sn)
	btn.add_theme_stylebox_override("focus",  sn)

	# Hover style (only matters if enabled)
	var sh := StyleBoxFlat.new()
	sh.bg_color     = C_TILE_BODY.lightened(0.12)
	sh.border_color = accent.lightened(0.25)
	sh.set_border_width_all(2)
	sh.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("hover", sh)

	if has_item:
		var icon := _build_item_icon(r.icon_path, r.display_name, accent, Vector2(44, 44))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(icon)
		btn.disabled = (_phase != Phase.PLAYING or _scoring_active)
		btn.tooltip_text = "%s\n%s" % [r.display_name, r.description]
		btn.pressed.connect(_on_reinforcement_slot_pressed.bind(r))
	else:
		btn.disabled = true
		var lbl := Label.new()
		lbl.text = "·"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.add_theme_color_override("font_color", C_DIM)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(lbl)
		btn.modulate.a = 0.35

	return btn

## Refresh the reinforcement tray to reflect current GameState.reinforcements.
func _refresh_reinforcement_tray() -> void:
	if _reinforcement_tray == null:
		return
	# Remove old slots (keep the label at index 0)
	while _reinforcement_tray.get_child_count() > 1:
		_reinforcement_tray.get_child(1).queue_free()
	for i in range(GameState.MAX_REINFORCEMENTS):
		var r = GameState.reinforcements[i] if i < GameState.reinforcements.size() else null
		_reinforcement_tray.add_child(_build_reinforcement_slot(r, i))
	# Also refresh the new usables panel on the right
	_refresh_usables_panel()

# ---- Action bar ----
func _build_action_bar() -> Control:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	hbox.custom_minimum_size = Vector2(0, 48)
	_btn_undo    = _make_button("↩ Undo",       _on_undo_pressed,    Vector2(110, 42))
	# Right-click on Undo = clear every selected tile in one go. Mirrors the
	# Esc-during-PLAYING shortcut so mouse-only players get the same comfort
	# without needing to know the keybind.
	_btn_undo.tooltip_text = "Click: undo last selection\nRight-click / Shift+U: clear all"
	_btn_undo.mouse_filter = Control.MOUSE_FILTER_STOP
	_btn_undo.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed \
				and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			_on_undo_clear_all()
			_btn_undo.accept_event()
	)
	_btn_discard = _make_button("Discard (0)",   _on_discard_pressed, Vector2(148, 42))
	_btn_play    = _make_button("▶  Play Pulse", _on_play_pressed,    Vector2(166, 42))
	# Stand: once the chronos target is reached, the player can lock in
	# the current chain instead of being forced to keep extending. Hidden
	# until target is met; the action-bar refresh toggles its visibility.
	_btn_stand   = _make_button("⏹  Stand",      _on_stand_pressed,   Vector2(132, 42))
	_btn_stand.visible = false
	# Pass: appears only when the player is truly stuck — no hand tile can
	# extend the chain AND there's no productive discard available. Burns
	# one hand without scoring so the round can drain to its natural end.
	_btn_pass    = _make_button("⏭  Pass Hand",  _on_pass_pressed,    Vector2(150, 42))
	_btn_pass.visible = false

	# Stand-decision hint: a small two-line label sitting next to the Stand
	# button so the player can weigh "lock in for monedas" against
	# "keep extending for the next tier".
	_lbl_stand_hint = _make_label("", C_DIM, 11)
	_lbl_stand_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_lbl_stand_hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	_lbl_stand_hint.visible = false
	FontManager.apply_mono(_lbl_stand_hint)

	hbox.add_child(_btn_undo)
	hbox.add_child(_btn_discard)
	hbox.add_child(_btn_play)
	hbox.add_child(_btn_stand)
	hbox.add_child(_lbl_stand_hint)
	hbox.add_child(_btn_pass)
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
	panel.custom_minimum_size = Vector2(620, 0)
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
	# Multi-line round summary: chain stats, mult breakdown, monedas earned.
	# Mono font keeps the columnar "  Doubles (4): +4" lines aligned.
	_lbl_result_sub = _make_label("", C_TEXT, 13)
	_lbl_result_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_lbl_result_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_result_sub.custom_minimum_size = Vector2(540, 0)
	FontManager.apply_mono(_lbl_result_sub)
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

	# Daily Trial: deterministic seed per calendar day, one attempt each.
	# Sits between the standard new-run button and the continue button.
	_btn_daily_trial = _make_button(
		"DAILY TRIAL  ↺", _on_daily_trial_pressed, Vector2(200, 54))
	# Distinct violet styling so the Daily button reads as its own mode
	# rather than a variant of "new run".
	var ds := StyleBoxFlat.new()
	ds.bg_color     = Color(0.18, 0.10, 0.24)
	ds.border_color = Color(0.70, 0.55, 0.95)
	ds.set_border_width_all(2)
	ds.set_corner_radius_all(6)
	ds.set_content_margin_all(10)
	_btn_daily_trial.add_theme_stylebox_override("normal", ds)
	var ds_hov := ds.duplicate() as StyleBoxFlat
	ds_hov.bg_color = Color(0.24, 0.14, 0.32)
	_btn_daily_trial.add_theme_stylebox_override("hover", ds_hov)
	btn_row.add_child(_btn_daily_trial)

	# Daily history viewer — small icon-only button right next to the daily
	# trial button. Always visible (even with no attempts) so the player
	# discovers the feature naturally.
	_btn_daily_history = _make_button("📅",
		_on_daily_history_pressed, Vector2(54, 54))
	_btn_daily_history.add_theme_stylebox_override("normal", ds)
	_btn_daily_history.add_theme_stylebox_override("hover", ds_hov)
	btn_row.add_child(_btn_daily_history)

	# Achievements browser — amber-styled to match the achievement panel.
	# Always visible so first-time players see the feature exists.
	_btn_achievements = _make_button("★",
		_on_achievements_pressed, Vector2(54, 54))
	var as_style := StyleBoxFlat.new()
	as_style.bg_color     = Color(0.14, 0.11, 0.06)
	as_style.border_color = Color(0.85, 0.70, 0.30)
	as_style.set_border_width_all(2)
	as_style.set_corner_radius_all(6)
	as_style.set_content_margin_all(10)
	_btn_achievements.add_theme_stylebox_override("normal", as_style)
	var as_hov := as_style.duplicate() as StyleBoxFlat
	as_hov.bg_color = Color(0.20, 0.15, 0.08)
	_btn_achievements.add_theme_stylebox_override("hover", as_hov)
	btn_row.add_child(_btn_achievements)

	# Lifetime stats viewer — green-styled to match the chronos accent
	# of the stats overlay border.
	_btn_stats = _make_button("📊",
		_on_stats_pressed, Vector2(54, 54))
	var st_style := StyleBoxFlat.new()
	st_style.bg_color     = Color(0.06, 0.13, 0.10)
	st_style.border_color = C_CHRONOS.darkened(0.2)
	st_style.set_border_width_all(2)
	st_style.set_corner_radius_all(6)
	st_style.set_content_margin_all(10)
	_btn_stats.add_theme_stylebox_override("normal", st_style)
	var st_hov := st_style.duplicate() as StyleBoxFlat
	st_hov.bg_color = Color(0.08, 0.18, 0.13)
	_btn_stats.add_theme_stylebox_override("hover", st_hov)
	btn_row.add_child(_btn_stats)

	# Help / glossary — gold-styled to match the title-glow border on
	# the help overlay. Reference for game terms and rules at any time.
	_btn_help = _make_button("?",
		_on_help_pressed, Vector2(54, 54))
	var hp_style := StyleBoxFlat.new()
	hp_style.bg_color     = Color(0.13, 0.10, 0.04)
	hp_style.border_color = C_TITLE_GLOW.darkened(0.2)
	hp_style.set_border_width_all(2)
	hp_style.set_corner_radius_all(6)
	hp_style.set_content_margin_all(10)
	_btn_help.add_theme_stylebox_override("normal", hp_style)
	var hp_hov := hp_style.duplicate() as StyleBoxFlat
	hp_hov.bg_color = Color(0.18, 0.14, 0.06)
	_btn_help.add_theme_stylebox_override("hover", hp_hov)
	btn_row.add_child(_btn_help)

	# Codex / Archive — the lore archive. Same modal pattern as the other
	# title-screen browsers; styled with the title-glow accent.
	_btn_codex = _make_button("⬡",
		_on_codex_pressed, Vector2(54, 54))
	_btn_codex.add_theme_stylebox_override("normal", hp_style)
	_btn_codex.add_theme_stylebox_override("hover", hp_hov)
	btn_row.add_child(_btn_codex)

	# Memorial caption — names today's fallen Operator. Updated each
	# call to _refresh_daily_trial_button. Sits beneath the button row
	# so the title screen has a piece of always-shifting daily lore
	# without crowding the buttons themselves.
	_lbl_daily_memorial = _make_label("", C_DIM, 11)
	_lbl_daily_memorial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(_lbl_daily_memorial)
	vbox.add_child(_lbl_daily_memorial)

	# "Continue Run" — hidden until SaveManager confirms a mid-run save exists
	_btn_continue_run = _make_button(
		"CONTINUE RUN  ↩", _on_continue_run_pressed, Vector2(200, 54))
	_btn_continue_run.visible = false   # updated in _show_title()
	# Style it distinctly (teal/cyan)
	var cs := StyleBoxFlat.new()
	cs.bg_color     = Color(0.08, 0.22, 0.22)
	cs.border_color = Color(0.30, 0.80, 0.75)
	cs.set_border_width_all(2)
	cs.set_corner_radius_all(6)
	cs.set_content_margin_all(10)
	_btn_continue_run.add_theme_stylebox_override("normal", cs)
	var cs_hov := cs.duplicate() as StyleBoxFlat
	cs_hov.bg_color = Color(0.10, 0.30, 0.30)
	_btn_continue_run.add_theme_stylebox_override("hover", cs_hov)
	btn_row.add_child(_btn_continue_run)

	# Settings gear button — always visible, bottom-right of the overlay
	var settings_btn := _make_button("⚙", _on_settings_btn_pressed, Vector2(48, 48))
	settings_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	settings_btn.offset_right  = -16
	settings_btn.offset_bottom = -16
	settings_btn.offset_left   = settings_btn.offset_right  - 48
	settings_btn.offset_top    = settings_btn.offset_bottom - 48
	overlay.add_child(settings_btn)

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

	# Cards grid — wraps to multiple rows when there are many cores /
	# protocols. Up to 4 columns wide so each card stays at full size;
	# additional cards flow to the next row instead of forcing a horizontal
	# scrollbar inside the selection panel.
	var cards_wrap := CenterContainer.new()
	vbox.add_child(cards_wrap)
	var cards_grid := GridContainer.new()
	cards_grid.columns = mini(4, count)
	cards_grid.add_theme_constant_override("h_separation", 16)
	cards_grid.add_theme_constant_override("v_separation", 16)
	cards_wrap.add_child(cards_grid)

	# Pull lifetime stats once and pass each card the right unlock gate so
	# locked entries render dim with a requirement hint instead of being
	# selectable.
	var lifetime: Dictionary = SaveManager.get_lifetime_stats()
	var is_core: bool = title_text.begins_with("CALIBRATION")
	out_cards.clear()
	for i in range(count):
		var unlocked: bool = true
		var unlock_label: String = ""
		if is_core:
			unlocked = Constants.is_core_unlocked(i, lifetime)
			if not unlocked:
				unlock_label = Constants.CORE_UNLOCKS[i].get("label", "Locked.")
		else:
			unlocked = Constants.is_protocol_unlocked(i, lifetime)
			if not unlocked:
				unlock_label = Constants.PROTOCOL_UNLOCKS[i].get("label", "Locked.")
		var card := _build_selection_card(
			i, names[i], rarities[i], descs[i], lores[i], card_callback,
			unlocked, unlock_label)
		cards_grid.add_child(card)
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
		callback: Callable,
		unlocked: bool = true,
		unlock_label: String = "") -> PanelContainer:

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(256, 200)

	# Locked cards are dimmer (less saturation) and use a muted border.
	var style := StyleBoxFlat.new()
	if unlocked:
		style.bg_color     = Color(0.11, 0.10, 0.07)
		style.border_color = C_RARITY[rarity]
	else:
		style.bg_color     = Color(0.06, 0.05, 0.04)
		style.border_color = Color(0.32, 0.28, 0.20)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	if not unlocked:
		panel.modulate = Color(0.65, 0.65, 0.65)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Rarity badge — supplemented by 🔒 LOCKED for gated cards.
	if unlocked:
		vbox.add_child(_make_label(Constants.RARITY_NAMES[rarity].to_upper(),
			C_RARITY[rarity], 11))
	else:
		vbox.add_child(_make_label("🔒  LOCKED", C_DIM, 11))

	# Name
	vbox.add_child(_make_label(card_name, C_TEXT if unlocked else C_DIM, 20))

	# Description (may be multiline) — replaced with the unlock requirement
	# if the card is locked, so the player learns *how* to unlock it.
	if unlocked:
		var desc_lbl := _make_label(desc, C_PREVIEW, 13)
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.custom_minimum_size = Vector2(236, 0)
		vbox.add_child(desc_lbl)

		# Lore
		var lore_lbl := _make_label(lore, C_DIM, 11)
		lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lore_lbl.custom_minimum_size = Vector2(236, 0)
		vbox.add_child(lore_lbl)
	else:
		var req_header := _make_label("UNLOCK REQUIREMENT", C_DIM, 10)
		vbox.add_child(req_header)
		var req_lbl := _make_label(unlock_label, C_PREVIEW, 12)
		req_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		req_lbl.custom_minimum_size = Vector2(236, 0)
		vbox.add_child(req_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# SELECT button — disabled and relabelled if locked.
	var btn := Button.new()
	if unlocked:
		btn.text = "SELECT"
		btn.pressed.connect(callback.bind(index))
	else:
		btn.text = "LOCKED"
		btn.disabled = true
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

	# Allocate 3 slots so The Runner core (which starts with 3 active
	# directives) has somewhere to render. Standard / 2-directive runs
	# leave the third label blank — costs one empty Label, saves a UI
	# rebuild on core change.
	_directive_labels.clear()
	for i in range(3):
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
## Show projected Chronos total on the bar label when a chain is selected.
## extra = 0 clears the ghost and shows plain "current / target".
func _update_chronos_ghost(extra: int) -> void:
	if _rm == null or _scoring_active:
		return
	var c := _rm.chronos
	var t := _rm.target
	if extra > 0:
		var proj := c + extra
		_chronos_bar_lbl.text = "%d + %d → %d / %d" % [c, extra, proj, t]
	else:
		_chronos_bar_lbl.text = "%d / %d" % [c, t]

## Pop a "+N" gold label from the Monedas display whenever coins increase.
func _pop_monedas_delta(delta: int) -> void:
	# Prefer the visible MONEDAS pill — that's where the player's eye is
	# tracking the wallet during play. Fall back to the legacy hidden
	# label if the pill hasn't been built yet (e.g. during init flicker).
	var anchor: Control = _lbl_monedas_pill if (_lbl_monedas_pill != null \
		and is_instance_valid(_lbl_monedas_pill)) else _lbl_monedas
	if anchor == null or not is_instance_valid(anchor):
		return
	var pos := anchor.global_position + Vector2(anchor.size.x * 0.5, 0)
	_do_tile_pop("+%d" % delta, C_MONEDAS, pos, 15, 0.90)

## Smoothly tween the MONEDAS pill counter from its currently-displayed
## value to `target`. ~0.4s with circ ease — slow at the end so the
## final number is readable. Fires from _refresh_hud whenever the
## monedas balance changes (earned or spent).
func _animate_monedas_to(target: int) -> void:
	if _lbl_monedas_pill == null or not is_instance_valid(_lbl_monedas_pill):
		return
	if target == _lbl_monedas_pill_value:
		_lbl_monedas_pill.text = "%d" % target
		return
	var from: int = _lbl_monedas_pill_value
	_lbl_monedas_pill_value = target
	var t := create_tween()
	t.tween_method(func(v: float):
		if _lbl_monedas_pill != null and is_instance_valid(_lbl_monedas_pill):
			_lbl_monedas_pill.text = "%d" % int(round(v)),
		float(from), float(target), 0.40) \
		.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

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
## Rebuild the chain milestone tier-bar. Shows one segment per scoring tier
## (Fragment → Singularity). Each segment is one of three visual states:
##   - LOCKED   (dim)   : chain hasn't reached this tier yet
##   - CURRENT  (accent): chain is currently in this tier (between this
##                       threshold and the next); the bonus is "live"
##   - ACHIEVED (gold)  : chain has surpassed this tier — bonus banked,
##                       a higher tier is now in play
##
## Replaces the old per-tile dot row, which capped at 8 tiles. Tier segments
## scale visually to any chain length, including 21+ Singularity chains.
func _refresh_chain_milestone(length: int) -> void:
	for ch in _chain_milestone_row.get_children():
		ch.queue_free()

	# Build the tier list: Fragment (no bonus) + each scoring tier from constants.
	# Each entry: { name, bonus, min, max } — max is exclusive upper bound (-1 = open).
	var tiers: Array = [{"name": "FRAG", "bonus": 0, "min": 1, "max": Constants.CHAIN_TIER_MIN[0]}]
	for i in range(Constants.CHAIN_TIER_MIN.size()):
		var lo: int = Constants.CHAIN_TIER_MIN[i]
		var hi: int = Constants.CHAIN_TIER_MIN[i + 1] if i + 1 < Constants.CHAIN_TIER_MIN.size() else -1
		tiers.append({
			"name":  Constants.CHAIN_TIER_NAMES[i].to_upper(),
			"bonus": Constants.CHAIN_TIER_BONUS[i],
			"min":   lo,
			"max":   hi,
		})

	# Determine which tier the current chain length sits in.
	var current_idx: int = 0
	for i in range(tiers.size()):
		if length >= tiers[i]["min"]:
			current_idx = i

	# Build segments and remember each one's screen target so we can fire a
	# celebration if we cross into a new tier.
	var current_segment: Control = null
	for i in range(tiers.size()):
		var tier: Dictionary = tiers[i]
		var state: String
		if i < current_idx:
			state = "achieved"
		elif i == current_idx and length >= tier["min"]:
			state = "current"
		else:
			state = "locked"

		var seg := _build_tier_segment(tier, state, length)
		_chain_milestone_row.add_child(seg)
		if state == "current":
			current_segment = seg

	# Tier-crossing celebration: only when the player's chain enters a tier
	# strictly higher than any seen this round (so undo / partial selection
	# doesn't spam the animation). Only fires for the bonus tiers — entering
	# Fragment from nothing isn't a milestone.
	if current_idx > _last_tier_reached and current_idx > 0 and current_segment != null:
		_last_tier_reached = current_idx
		_celebrate_tier_segment(current_segment, tiers[current_idx])

	# Update the active-tier banner above the segment bar. Empty string
	# (rather than "FRAGMENT") for chains below Pulse so the banner only
	# appears once a tier bonus is actually live.
	if _lbl_active_tier != null:
		if current_idx <= 0 or length <= 0:
			_lbl_active_tier.text = ""
		else:
			var tier: Dictionary = tiers[current_idx]
			_lbl_active_tier.text = "%s   +%d MULT" % [tier["name"], tier["bonus"]]
			# Tier index 1..5 map to Pulse / Cohesion / Resonance / Harmonic /
			# Singularity — graduate the colour from chronos green to gold to
			# the win/celebration tone as the tier climbs.
			var tier_colors: Array = [C_DIM, C_CHRONOS, C_CHRONOS.lerp(C_WIN, 0.3),
				C_MONEDAS, C_MONEDAS.lerp(C_TITLE_GLOW, 0.4), C_TITLE_GLOW]
			var ci: int = clampi(current_idx, 0, tier_colors.size() - 1)
			_lbl_active_tier.add_theme_color_override("font_color",
				tier_colors[ci])

## Plays a celebration on the just-crossed tier segment: the segment scales
## up with a back-ease, flashes bright, and pops a "+N MULT" label above it.
## Pairs with a sound sting so the player viscerally feels the milestone.
func _celebrate_tier_segment(seg: Control, tier: Dictionary) -> void:
	if seg == null or not is_instance_valid(seg):
		return
	seg.pivot_offset = seg.size * 0.5
	var pop := create_tween().set_parallel(true)
	pop.tween_property(seg, "scale", Vector2(1.30, 1.30), 0.16) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(seg, "modulate", Color(1.5, 1.4, 0.9), 0.16) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var rest := create_tween().set_parallel(true)
	rest.tween_interval(0.16)
	rest.tween_property(seg, "scale", Vector2.ONE, 0.32) \
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	rest.tween_property(seg, "modulate", Color.WHITE, 0.32) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Floating label above the segment: "PULSE +1", "RESONANCE +4", etc.
	var center := seg.global_position + seg.size * 0.5
	var label_text: String = "%s  +%d MULT" % [tier["name"], tier["bonus"]]
	_do_tile_pop(label_text, C_MONEDAS, center + Vector2(0, -seg.size.y * 0.6), 18, 1.10)

	AudioManager.play_sfx("round_clear")

func _build_tier_segment(tier: Dictionary, state: String, length: int) -> Control:
	var bonus: int = tier["bonus"]
	var label_text: String = tier["name"]
	if bonus > 0:
		label_text += "  +%d" % bonus

	# Colour scheme per state
	var fg: Color
	var bg: Color
	var border: Color
	match state:
		"achieved":
			fg     = C_WIN
			bg     = C_WIN.darkened(0.78)
			border = C_WIN.darkened(0.45)
		"current":
			fg     = C_MONEDAS
			bg     = C_CHRONOS.darkened(0.55)
			border = C_MONEDAS
		_: # locked
			fg     = C_DIM
			bg     = Color(0.10, 0.10, 0.10, 0.55)
			border = Color(0.22, 0.20, 0.17)

	var style := StyleBoxFlat.new()
	style.bg_color     = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 2
	style.content_margin_bottom = 2

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.mouse_filter        = Control.MOUSE_FILTER_IGNORE

	var inner := VBoxContainer.new()
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("separation", 0)
	panel.add_child(inner)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", fg)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(lbl)
	inner.add_child(lbl)

	# Range hint under the name (e.g. "7-10" or "21+"). Anchors the segment
	# to a concrete tile count so players learn the thresholds in context.
	var range_text: String
	if tier["max"] == -1:
		range_text = "%d+" % tier["min"]
	else:
		range_text = "%d-%d" % [tier["min"], int(tier["max"]) - 1]
	# Append live tile count to the active tier so the player can see how
	# close they are to the next threshold without hunting elsewhere.
	if state == "current":
		if tier["max"] == -1:
			range_text = "%d  (%d)" % [tier["min"], length]
		else:
			range_text = "%d/%d" % [length, int(tier["max"]) - 1]

	var sub := Label.new()
	sub.text = range_text
	sub.add_theme_font_size_override("font_size", 7)
	sub.add_theme_color_override("font_color", fg.darkened(0.25) if state != "locked" else fg)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontManager.apply_mono(sub)
	inner.add_child(sub)

	return panel

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
	_register_cinematic(seq)

	# Pre-compute cumulative chip totals so closures can capture the right value
	# for each tile without relying on mutable loop-variable capture.
	var cum_chips: Array[int] = []
	var running: int = 0
	for info in overlay_infos:
		running += int(info["chips"])
		cum_chips.append(running)
	var total_chips: int = running

	# Initialise scoring display: stop play-button pulse, clear total, start counter
	seq.tween_callback(func():
		# Kill play button glow — scoring is starting
		if _play_pulse_tween != null:
			_play_pulse_tween.kill()
			_play_pulse_tween = null
		_btn_play.modulate = Color.WHITE
		# Clear ghost projection and total label
		_lbl_preview_total.text = ""
		_update_chronos_ghost(0)
		# Start chip accumulation counter
		_lbl_preview.text = "0  chips"
		_lbl_preview.add_theme_color_override("font_color", C_DIM)
		_lbl_preview.add_theme_font_size_override("font_size", 18)
	)

	for ti in range(overlay_infos.size()):
		var info:      Dictionary = overlay_infos[ti]
		var panel:     Control    = info["panel"]
		var center:    Vector2    = info["center"]
		var chips:     int        = info["chips"]
		var is_dbl:    bool       = info["is_double"]
		var pop_color: Color      = C_MONEDAS if is_dbl else C_TEXT
		var glow:      Color      = C_MONEDAS if is_dbl else Color(1.45, 1.40, 1.10)
		var chips_so_far: int     = cum_chips[ti]   # captured fresh per iteration ✓

		# Step 1 — tile brightens and pops up in place (no duplicate overlay).
		# Doubles also fire a connection spark to signal "branch end created".
		# When a module fired on this specific tile, pop short tags above it
		# so the player can see WHICH tile triggered which bonus.
		var tags: Array = info.get("tags", [])
		# Per-tile pitch ramp so the scoring cascade rises tonally across
		# the chain — each tile is +2% pitch over the previous, capped so
		# even a 30-tile chain stays inside reasonable musical range.
		var tile_pitch: float = clampf(1.0 + ti * 0.02, 1.0, 1.6)
		seq.tween_callback(func():
			if panel == null or not is_instance_valid(panel):
				return
			panel.pivot_offset = panel.size * 0.5
			var pulse := create_tween().set_parallel(true)
			pulse.tween_property(panel, "modulate", glow, 0.10) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			pulse.tween_property(panel, "scale", Vector2(1.18, 1.18), 0.12) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			AudioManager.play_sfx("tile_score", tile_pitch)
			if is_dbl:
				_do_chain_spark(center, C_MONEDAS)
			# Stagger tags so multiple modules firing on one tile read as
			# distinct labels rather than overlapping into one blob.
			for tag_i in range(tags.size()):
				var tag_text: String = String(tags[tag_i])
				var tag_offset: Vector2 = Vector2(0, -panel.size.y * 0.55 - tag_i * 14)
				_do_tile_pop(tag_text, _archetype_color_for_tag(tag_text),
					center + tag_offset, 11, 1.05)
		)
		seq.tween_interval(0.10)

		# Step 2 — chip pop, counter tick, then the tile eases back to normal.
		seq.tween_callback(func():
			_lbl_preview.text = "%d  chips" % chips_so_far
			_lbl_preview.add_theme_color_override("font_color",
				C_MONEDAS if is_dbl else C_PREVIEW)
			_do_tile_pop("+%d" % chips, pop_color, center, 21, 0.80)
			if panel == null or not is_instance_valid(panel):
				return
			var ret := create_tween().set_parallel(true)
			ret.tween_property(panel, "modulate", Color.WHITE, 0.22) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			ret.tween_property(panel, "scale", Vector2.ONE, 0.22) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
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

	# Step 6 — unlock input, finalise bar colour/label, restore preview style.
	# Refresh chain display now (was deferred during scoring so the in-place
	# animation could run on the actual tile nodes without them being freed).
	seq.tween_interval(0.28)
	seq.tween_callback(func():
		_scoring_active = false
		_lbl_preview.add_theme_font_size_override("font_size", 13)
		_lbl_preview.add_theme_color_override("font_color", C_DIM)
		_lbl_preview_total.text = ""   # will repopulate when player makes next selection
		if _rm != null:
			_set_chronos_bar(_rm.chronos, _rm.target)
		_refresh_chain_display()
		_refresh_action_buttons()
		_refresh_tile_visuals()
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
	style.set_border_width_all(4); style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.42); style.shadow_size = 5
	style.set_content_margin_all(11)
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
	top_panel.add_child(_make_pip_display(tile.left, 13, top_dot))
	vbox.add_child(top_panel)

	vbox.add_child(_make_tile_hsep())

	var bot_panel := PanelContainer.new()
	bot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bot_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_pip_panel_face(bot_panel, C_TILE_FACE, false)
	var bot_dot := C_TITLE_GLOW if tile.right < 0 else C_PIP_DOT
	bot_panel.add_child(_make_pip_display(tile.right, 13, bot_dot))
	vbox.add_child(bot_panel)

	_ui_layer.add_child(panel)
	return panel

## Called deferred after a successful tile placement so layout has settled.
## Finds the correct panel in the rebuilt chain and fires a connection spark.
func _fire_chain_spark(added_left: bool, was_first: bool) -> void:
	# Tiles live in `_chain_tile_panels` in chain order (handles multi-row layout).
	if _chain_tile_panels.is_empty():
		return

	# First tile → spark at centre; left add → leftmost panel; right add → rightmost
	var panel: Control = _chain_tile_panels[0] if (was_first or added_left) else _chain_tile_panels[-1]
	if panel == null or not is_instance_valid(panel):
		return
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
	FontManager.apply_for_size(lbl, size)
	return lbl

## Returns StyleBoxTexture if PNG exists at path, else returns the fallback StyleBoxFlat.
## This is the single hook for swapping in assets later.
func _style_or_tex(path: String, fallback: StyleBoxFlat) -> StyleBox:
	if ResourceLoader.exists(path):
		var s := StyleBoxTexture.new()
		s.texture = load(path)
		s.set_margin_all(12)
		return s
	return fallback

func _make_button(label: String, callback: Callable,
		min_size: Vector2 = Vector2(120, 48)) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = min_size
	btn.pressed.connect(callback)
	FontManager.apply_semibold(btn)
	return btn

func _make_hsep() -> Control:
	var sep := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.28, 0.22)
	sep.add_theme_stylebox_override("separator", style)
	return sep

## Build a square icon box for modules / reinforcements.
## Tries to load icon_path; if missing, shows a rarity-coloured box with initials.
func _build_item_icon(icon_path: String, item_name: String,
		accent: Color, size: Vector2) -> Control:
	var box := Panel.new()
	box.custom_minimum_size = size
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box_style := StyleBoxFlat.new()
	box_style.bg_color = accent.darkened(0.55)
	box_style.set_corner_radius_all(6)
	box_style.set_border_width_all(1)
	box_style.border_color = accent.darkened(0.15)
	box.add_theme_stylebox_override("panel", box_style)

	if icon_path != "" and ResourceLoader.exists(icon_path):
		var tex_rect := TextureRect.new()
		tex_rect.texture = load(icon_path)
		tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(tex_rect)
	else:
		# Placeholder: initials in accent colour
		var lbl := Label.new()
		lbl.text = _item_initials(item_name)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.add_theme_font_size_override("font_size", int(size.y * 0.38))
		lbl.add_theme_color_override("font_color", accent)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(lbl)

	return box

## Returns up to 3 uppercase initials from an item's display name.
func _item_initials(name: String) -> String:
	var words := name.split(" ")
	var result := ""
	for w in words:
		if w.length() > 0:
			result += w[0].to_upper()
	return result.left(3)

# ===========================================================================
# Run-end cinematic overlay (build)
# ===========================================================================
## Constructs the full-screen victory / defeat overlay.
## _show_run_end() populates and animates it; this just wires up the nodes.
## Settings overlay — volume sliders, mute toggle.
## Accessible from title screen and (in future) from the pause button in-game.
## Mid-run pause overlay. Compact panel with three actions:
##   RESUME           — hide the overlay, return to play
##   SETTINGS         — open the existing settings overlay on top
##   QUIT TO TITLE    — abandon the run (mid-run save is preserved for
##                      regular runs; daily runs forfeit as a loss).
func _build_pause_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.08, 0.07, 0.05, 0.98)
	ps.border_color = C_GOLD_RIM
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := _make_label("PAUSED", C_TITLE_GLOW, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_hsep())

	vbox.add_child(_make_button("▶  RESUME",
		_on_pause_resume_pressed, Vector2(280, 48)))
	vbox.add_child(_make_button("⚙  SETTINGS",
		_on_pause_settings_pressed, Vector2(280, 48)))
	vbox.add_child(_make_button("⤴  QUIT TO TITLE",
		_on_pause_quit_pressed, Vector2(280, 48)))

	return overlay

## Daily-run forfeit warning. Shown when the player taps QUIT TO TITLE
## during a daily run — daily mode records the attempt as a loss when
## you quit (anti-rage-quit on bad seeds), so the player gets a heads
## up before the destructive action.
func _build_quit_confirm_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 0)
	var ps := StyleBoxFlat.new()
	ps.bg_color     = Color(0.10, 0.05, 0.05, 0.98)
	ps.border_color = C_LOSE
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title := _make_label("FORFEIT TODAY'S DAILY?", C_LOSE, 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var body := _make_label(
		"You only get one attempt per day. Quitting now\n" +
		"records this run as a loss. Tomorrow's seed will\n" +
		"be different.", C_TEXT, 13)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(body)

	vbox.add_child(_make_hsep())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_row)
	btn_row.add_child(_make_button("KEEP PLAYING",
		_on_quit_confirm_cancel, Vector2(180, 44)))
	# Distinct red styling on the destructive option so a quick
	# muscle-memory click doesn't blow up the run.
	var forfeit_btn := _make_button("FORFEIT",
		_quit_to_title, Vector2(180, 44))
	var fs := StyleBoxFlat.new()
	fs.bg_color     = Color(0.20, 0.06, 0.06)
	fs.border_color = C_LOSE
	fs.set_border_width_all(2)
	fs.set_corner_radius_all(6)
	fs.set_content_margin_all(10)
	forfeit_btn.add_theme_stylebox_override("normal", fs)
	var fs_hov := fs.duplicate() as StyleBoxFlat
	fs_hov.bg_color = Color(0.28, 0.08, 0.08)
	forfeit_btn.add_theme_stylebox_override("hover", fs_hov)
	btn_row.add_child(forfeit_btn)

	return overlay

func _build_settings_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.82)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.gui_input.connect(func(_e): pass)  # swallow background clicks

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	var pstyle := StyleBoxFlat.new()
	pstyle.bg_color     = Color(0.10, 0.09, 0.07)
	pstyle.border_color = Color(0.50, 0.45, 0.35)
	pstyle.set_border_width_all(2)
	pstyle.set_corner_radius_all(10)
	pstyle.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", pstyle)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	# Header
	var hdr := _make_label("SETTINGS", C_TITLE_GLOW, 22)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hdr)
	vbox.add_child(_make_hsep())

	# Music volume
	var music_row := HBoxContainer.new()
	music_row.add_theme_constant_override("separation", 12)
	var music_lbl := _make_label("Music", C_TEXT, 14)
	music_lbl.custom_minimum_size = Vector2(80, 0)
	music_row.add_child(music_lbl)
	var music_slider := HSlider.new()
	music_slider.min_value   = 0.0
	music_slider.max_value   = 1.0
	music_slider.step        = 0.05
	music_slider.value       = AudioManager.get_music_volume()
	music_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_slider.set_meta("type", "music")
	music_slider.value_changed.connect(_on_settings_slider_changed.bind(music_slider))
	music_row.add_child(music_slider)
	overlay.set_meta("music_slider", music_slider)
	vbox.add_child(music_row)

	# SFX volume
	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 12)
	var sfx_lbl := _make_label("SFX", C_TEXT, 14)
	sfx_lbl.custom_minimum_size = Vector2(80, 0)
	sfx_row.add_child(sfx_lbl)
	var sfx_slider := HSlider.new()
	sfx_slider.min_value   = 0.0
	sfx_slider.max_value   = 1.0
	sfx_slider.step        = 0.05
	sfx_slider.value       = AudioManager.get_sfx_volume()
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_slider.set_meta("type", "sfx")
	sfx_slider.value_changed.connect(_on_settings_slider_changed.bind(sfx_slider))
	sfx_row.add_child(sfx_slider)
	overlay.set_meta("sfx_slider", sfx_slider)
	vbox.add_child(sfx_row)

	# Mute toggle
	var mute_row := HBoxContainer.new()
	mute_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mute_row.add_theme_constant_override("separation", 12)
	var mute_lbl := _make_label("Mute All", C_TEXT, 14)
	mute_row.add_child(mute_lbl)
	var mute_btn := CheckButton.new()
	mute_btn.button_pressed = AudioManager.is_muted()
	mute_btn.toggled.connect(func(b: bool):
		AudioManager.set_mute(b)
		_save_audio_settings()
	)
	overlay.set_meta("mute_btn", mute_btn)
	mute_row.add_child(mute_btn)
	vbox.add_child(mute_row)

	vbox.add_child(_make_hsep())

	# Comfort section — pacing controls that scale the long cinematics
	# (boss warning, scoring cascade, run-end reveal). Skip is always
	# available via Space/Enter/Click; this lets the baseline be faster
	# too for players who'd rather skim every animation.
	var comfort_hdr := _make_label("COMFORT", C_DIM, 11)
	vbox.add_child(comfort_hdr)

	var speed_row := HBoxContainer.new()
	speed_row.alignment = BoxContainer.ALIGNMENT_CENTER
	speed_row.add_theme_constant_override("separation", 8)
	var speed_lbl := _make_label("Animation Speed", C_TEXT, 14)
	speed_lbl.custom_minimum_size = Vector2(160, 0)
	speed_row.add_child(speed_lbl)
	var speed_btn := _make_button(_anim_speed_button_label(),
		_on_anim_speed_cycle_pressed, Vector2(120, 36))
	overlay.set_meta("speed_btn", speed_btn)
	speed_row.add_child(speed_btn)
	vbox.add_child(speed_row)

	var skip_hint := _make_label(
		"Tip: press Space, Enter or click to skip a cinematic.",
		C_DIM, 11)
	skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(skip_hint)

	vbox.add_child(_make_hsep())

	# Display section header
	var disp_hdr := _make_label("DISPLAY", C_DIM, 11)
	vbox.add_child(disp_hdr)

	# Fullscreen toggle
	var fs_row := HBoxContainer.new()
	fs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	fs_row.add_theme_constant_override("separation", 12)
	var fs_lbl := _make_label("Fullscreen", C_TEXT, 14)
	fs_row.add_child(fs_lbl)
	var fs_btn := CheckButton.new()
	fs_btn.button_pressed = (DisplayServer.window_get_mode() ==
		DisplayServer.WINDOW_MODE_FULLSCREEN)
	fs_btn.toggled.connect(func(b: bool):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if b
			else DisplayServer.WINDOW_MODE_WINDOWED)
	)
	fs_row.add_child(fs_btn)
	vbox.add_child(fs_row)

	vbox.add_child(_make_hsep())

	# Danger zone — wipes all save data after confirmation. Distinct
	# styling so it's not mistaken for a normal close button.
	var reset_hdr := _make_label("RESET", C_DIM, 11)
	vbox.add_child(reset_hdr)

	var reset_btn := _make_button("ERASE ALL PROGRESS",
		_on_reset_progress_pressed, Vector2(280, 40))
	var rs := StyleBoxFlat.new()
	rs.bg_color     = Color(0.20, 0.06, 0.06)
	rs.border_color = C_LOSE
	rs.set_border_width_all(2)
	rs.set_corner_radius_all(6)
	rs.set_content_margin_all(8)
	reset_btn.add_theme_stylebox_override("normal", rs)
	var rs_hov := rs.duplicate() as StyleBoxFlat
	rs_hov.bg_color = Color(0.28, 0.08, 0.08)
	reset_btn.add_theme_stylebox_override("hover", rs_hov)
	vbox.add_child(reset_btn)

	# Inline confirm shown only after the player taps "ERASE ALL".
	# Two-step pattern avoids needing yet another modal.
	var reset_confirm := HBoxContainer.new()
	reset_confirm.alignment = BoxContainer.ALIGNMENT_CENTER
	reset_confirm.add_theme_constant_override("separation", 8)
	reset_confirm.visible = false
	overlay.set_meta("reset_confirm_row", reset_confirm)
	var rc_lbl := _make_label("Are you sure? This wipes EVERYTHING.",
		C_LOSE, 12)
	reset_confirm.add_child(rc_lbl)
	var rc_yes := _make_button("YES, ERASE",
		_on_reset_progress_confirm, Vector2(120, 36))
	rc_yes.add_theme_stylebox_override("normal", rs)
	rc_yes.add_theme_stylebox_override("hover", rs_hov)
	reset_confirm.add_child(rc_yes)
	var rc_no := _make_button("Cancel",
		_on_reset_progress_cancel, Vector2(80, 36))
	reset_confirm.add_child(rc_no)
	vbox.add_child(reset_confirm)

	vbox.add_child(_make_hsep())

	# Close button
	vbox.add_child(_make_button("CLOSE", func():
		_settings_overlay.hide()
	, Vector2(160, 44)))

	return overlay

## Reveal the inline confirm row under the ERASE ALL PROGRESS button.
## Two-step pattern: tap once to surface the confirm row, tap again to
## actually erase. Cancel hides the row.
func _on_reset_progress_pressed() -> void:
	if _settings_overlay == null:
		return
	var row = _settings_overlay.get_meta("reset_confirm_row", null)
	if row != null:
		row.visible = true

func _on_reset_progress_cancel() -> void:
	if _settings_overlay == null:
		return
	var row = _settings_overlay.get_meta("reset_confirm_row", null)
	if row != null:
		row.visible = false

## Wipe ALL save data — settings, run state, lifetime stats, achievements,
## daily history. Returns to title with a fresh state.
func _on_reset_progress_confirm() -> void:
	# Clear in-memory state, write empty save, return to title
	SaveManager._data = {}
	SaveManager._save_to_disk()
	if _settings_overlay != null:
		_settings_overlay.hide()
	if _pause_overlay != null:
		_pause_overlay.hide()
	_phase = Phase.TITLE
	_show_title()

func _refresh_settings_overlay() -> void:
	if _settings_overlay == null:
		return
	var music_sl = _settings_overlay.get_meta("music_slider", null)
	if music_sl != null:
		music_sl.value = AudioManager.get_music_volume()
	var sfx_sl = _settings_overlay.get_meta("sfx_slider", null)
	if sfx_sl != null:
		sfx_sl.value = AudioManager.get_sfx_volume()
	var mute_b = _settings_overlay.get_meta("mute_btn", null)
	if mute_b != null:
		mute_b.button_pressed = AudioManager.is_muted()
	var speed_b = _settings_overlay.get_meta("speed_btn", null)
	if speed_b != null:
		speed_b.text = _anim_speed_button_label()

func _on_settings_slider_changed(value: float, slider: HSlider) -> void:
	var t: String = slider.get_meta("type", "")
	if t == "music":
		AudioManager.set_music_volume(value)
	elif t == "sfx":
		AudioManager.set_sfx_volume(value)
	_save_audio_settings()

func _save_audio_settings() -> void:
	SaveManager.save_settings(
		AudioManager.get_sfx_volume(),
		AudioManager.get_music_volume(),
		AudioManager.is_muted()
	)

## Label for the Animation Speed cycle button — "NORMAL ×1" / "FAST ×2"
## / "FASTER ×4". Picks the closest preset to whatever value is stored
## so a future preset change doesn't leave the button blank.
func _anim_speed_button_label() -> String:
	var cur: float = SaveManager.get_anim_speed()
	var idx: int = 0
	var best: float = 1e9
	for i in range(SaveManager.ANIM_SPEED_PRESETS.size()):
		var d: float = absf(SaveManager.ANIM_SPEED_PRESETS[i] - cur)
		if d < best:
			best = d
			idx  = i
	return "%s  ×%d" % [
		SaveManager.ANIM_SPEED_LABELS[idx],
		int(SaveManager.ANIM_SPEED_PRESETS[idx]),
	]

## Cycle through the speed presets in order, persist, and update the
## button label. The change applies to the *next* cinematic — no need
## to interrupt an in-flight one.
func _on_anim_speed_cycle_pressed() -> void:
	var cur: float = SaveManager.get_anim_speed()
	var idx: int = 0
	var best: float = 1e9
	for i in range(SaveManager.ANIM_SPEED_PRESETS.size()):
		var d: float = absf(SaveManager.ANIM_SPEED_PRESETS[i] - cur)
		if d < best:
			best = d
			idx  = i
	idx = (idx + 1) % SaveManager.ANIM_SPEED_PRESETS.size()
	SaveManager.set_anim_speed(SaveManager.ANIM_SPEED_PRESETS[idx])
	if _settings_overlay != null:
		var b = _settings_overlay.get_meta("speed_btn", null)
		if b != null:
			b.text = _anim_speed_button_label()

# ===========================================================================
# Tutorial overlay
# ===========================================================================

## Step definitions. Each entry: { title, body, target: Callable→Control, side }
## side: "below" | "above" | "left" | "right"  — where the hint box appears.
func _tutorial_steps() -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	steps.append({
		"title": "Your Isolation Chamber",
		"body":  "These are your tiles for this hand.\nClick any tile to select it.",
		"target": func() -> Control: return _hand_container,
		"side":  "above",
	})
	steps.append({
		"title": "Building the Chain",
		"body":  "Selected tiles form a Cohesion Pulse.\nTiles connect when a pip value matches\nan open end of the chain.\nYour chain PERSISTS across all hands\nin this round — keep extending it.",
		"target": func() -> Control: return _chain_container,
		"side":  "below",
	})
	steps.append({
		"title": "Score Preview",
		"body":  "Chips × Mult = score, applied to the\nFULL chain after each placement.\nLonger chains unlock tier bonuses\n(Pulse, Cohesion, Resonance, …).",
		"target": func() -> Control: return _lbl_preview_total,
		"side":  "above",
	})
	steps.append({
		"title": "Play Your Tiles",
		"body":  "Press PLAY to add the selected tiles\nto your chain. The chain stays on the\ntable for the rest of the round —\nstop only when you Stand or run out.",
		"target": func() -> Control: return _btn_play,
		"side":  "above",
	})
	steps.append({
		"title": "The Chronos Target",
		"body":  "Reach the target Chronos to clear\nthe round. Once the bar is full, a\nSTAND button appears — lock in or\nkeep extending for tier bonuses.",
		"target": func() -> Control: return _chronos_bar,
		"side":  "below",
	})
	return steps

func _build_tutorial_overlay() -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE   # pass clicks through to game

	# Dim backdrop — lets the game stay visible underneath
	_tut_dim = ColorRect.new()
	_tut_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tut_dim.color = Color(0, 0, 0, 0.62)
	_tut_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_tut_dim)

	# Spotlight — glowing border drawn around the target control
	_tut_spotlight = Control.new()
	_tut_spotlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_tut_spotlight)
	# We draw the spotlight as four thin ColorRects forming a border
	for side in ["top", "bottom", "left", "right"]:
		var bar := ColorRect.new()
		bar.color = C_TITLE_GLOW
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.set_meta("side", side)
		_tut_spotlight.add_child(bar)

	# Hint box — floating card with title, body, next button
	_tut_hint_box = PanelContainer.new()
	_tut_hint_box.custom_minimum_size = Vector2(310, 0)
	var hstyle := StyleBoxFlat.new()
	hstyle.bg_color     = Color(0.09, 0.08, 0.06, 0.97)
	hstyle.border_color = C_TITLE_GLOW
	hstyle.set_border_width_all(2)
	hstyle.set_corner_radius_all(8)
	hstyle.set_content_margin_all(16)
	_tut_hint_box.add_theme_stylebox_override("panel", hstyle)
	root.add_child(_tut_hint_box)

	var hint_vbox := VBoxContainer.new()
	hint_vbox.add_theme_constant_override("separation", 10)
	_tut_hint_box.add_child(hint_vbox)

	_tut_hint_title = _make_label("", C_TITLE_GLOW, 16)
	hint_vbox.add_child(_tut_hint_title)

	_tut_hint_body = _make_label("", C_TEXT, 13)
	_tut_hint_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tut_hint_body.custom_minimum_size = Vector2(278, 0)
	hint_vbox.add_child(_tut_hint_body)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 10)
	hint_vbox.add_child(btn_row)

	_tut_step_lbl = _make_label("1 / 5", C_DIM, 11)
	_tut_step_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_tut_step_lbl)

	_tut_next_btn = _make_button("Got it  →", _on_tutorial_next, Vector2(100, 36))
	btn_row.add_child(_tut_next_btn)

	# Skip button — top-right corner, always visible during tutorial
	var skip_btn := _make_button("Skip Tutorial", _on_tutorial_skip, Vector2(130, 34))
	skip_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	skip_btn.offset_right  = -12
	skip_btn.offset_top    = 12
	skip_btn.offset_left   = skip_btn.offset_right - 130
	skip_btn.offset_bottom = skip_btn.offset_top   + 34
	# Dim style
	var ss := StyleBoxFlat.new()
	ss.bg_color     = Color(0.15, 0.14, 0.11)
	ss.border_color = C_DIM
	ss.set_border_width_all(1)
	ss.set_corner_radius_all(5)
	ss.set_content_margin_all(8)
	skip_btn.add_theme_stylebox_override("normal", ss)
	skip_btn.add_theme_color_override("font_color", C_DIM)
	root.add_child(skip_btn)

	return root

func _start_tutorial() -> void:
	if _tutorial_active:
		return
	_tutorial_active = true
	_tutorial_step   = 0
	_tutorial_overlay.show()
	_show_tutorial_step(_tutorial_step)

func _show_tutorial_step(step: int) -> void:
	var steps := _tutorial_steps()
	if step >= steps.size():
		_finish_tutorial()
		return

	var data: Dictionary = steps[step]
	_tut_hint_title.text = data["title"]
	_tut_hint_body.text  = data["body"]
	_tut_step_lbl.text   = "%d / %d" % [step + 1, steps.size()]
	_tut_next_btn.text   = "Got it  →" if step < steps.size() - 1 else "Let's go!"

	# Resolve target control and position spotlight + hint box next frame
	# (needs layout to be settled)
	var getter: Callable = data["target"]
	var side:   String   = data["side"]
	_tutorial_overlay.modulate.a = 0.0
	_tutorial_overlay.show()
	# Wait one frame for layout, then position
	await get_tree().process_frame
	var target: Control = getter.call()
	if not is_instance_valid(target):
		_on_tutorial_next()
		return
	await _position_tutorial_elements(target, side)

	# Fade in
	var tw := create_tween()
	tw.tween_property(_tutorial_overlay, "modulate:a", 1.0, 0.22) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _position_tutorial_elements(target: Control, side: String) -> void:
	const PAD:    float = 8.0   # gap between spotlight border and target
	const THICK:  float = 2.5   # spotlight border thickness
	const MARGIN: float = 12.0  # gap between spotlight and hint box

	var tr: Rect2 = target.get_global_rect()
	# Expand spotlight slightly beyond the target
	var sr := tr.grow(PAD)

	# Rebuild spotlight bars to match sr
	for bar in _tut_spotlight.get_children():
		var s: String = bar.get_meta("side", "")
		match s:
			"top":
				bar.position = sr.position - Vector2(0, THICK)
				bar.size     = Vector2(sr.size.x, THICK)
			"bottom":
				bar.position = sr.position + Vector2(0, sr.size.y)
				bar.size     = Vector2(sr.size.x, THICK)
			"left":
				bar.position = sr.position - Vector2(THICK, 0)
				bar.size     = Vector2(THICK, sr.size.y + THICK * 2)
			"right":
				bar.position = sr.position + Vector2(sr.size.x, -THICK)
				bar.size     = Vector2(THICK, sr.size.y + THICK * 2)

	# Force hint box to lay out so we can read its size
	_tut_hint_box.reset_size()
	await get_tree().process_frame
	var hb_size: Vector2 = _tut_hint_box.size

	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var hb_pos:  Vector2

	match side:
		"below":
			hb_pos = Vector2(
				clampf(sr.position.x, 8.0, vp_size.x - hb_size.x - 8.0),
				sr.position.y + sr.size.y + MARGIN
			)
		"above":
			hb_pos = Vector2(
				clampf(sr.position.x, 8.0, vp_size.x - hb_size.x - 8.0),
				sr.position.y - hb_size.y - MARGIN
			)
		"right":
			hb_pos = Vector2(
				sr.position.x + sr.size.x + MARGIN,
				clampf(sr.position.y, 8.0, vp_size.y - hb_size.y - 8.0)
			)
		"left":
			hb_pos = Vector2(
				sr.position.x - hb_size.x - MARGIN,
				clampf(sr.position.y, 8.0, vp_size.y - hb_size.y - 8.0)
			)

	# Clamp to viewport
	hb_pos.x = clampf(hb_pos.x, 8.0, vp_size.x - hb_size.x - 8.0)
	hb_pos.y = clampf(hb_pos.y, 8.0, vp_size.y - hb_size.y - 8.0)
	_tut_hint_box.position = hb_pos

func _on_tutorial_next() -> void:
	_tutorial_step += 1
	var steps := _tutorial_steps()
	if _tutorial_step >= steps.size():
		_finish_tutorial()
		return
	# Slide hint box out, then show next step
	var tw := create_tween()
	tw.tween_property(_tut_hint_box, "modulate:a", 0.0, 0.14)
	tw.tween_callback(func():
		_tut_hint_box.modulate.a = 1.0
		_show_tutorial_step(_tutorial_step)
	)

func _on_tutorial_skip() -> void:
	_finish_tutorial()

func _finish_tutorial() -> void:
	_tutorial_active = false
	SaveManager.set_tutorial_seen(true)
	var tw := create_tween()
	tw.tween_property(_tutorial_overlay, "modulate:a", 0.0, 0.30)
	tw.tween_callback(_tutorial_overlay.hide)

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
				_flicker_label(_lbl_preview_total, 0.22)

		2:
			# Obsidian — more labels affected + occasional amber flash
			match randi() % 3:
				0:
					_flicker_label(_lbl_table_title, 0.28)
					_flicker_label(_lbl_etapa,        0.22)
				1:
					_flicker_label(_lbl_round,        0.20)
					_flicker_label(_lbl_preview_total,  0.30)
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
					_flicker_label(_lbl_preview_total,  0.40)
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
