# Domination — Demo Launch Plan
> Living document. Updated as phases are completed.
> Last updated: 2026-04-20

---

## Project Context

Domino roguelike (Balatro-inspired) built in Godot 4.6.
Single main scene (`scenes/main.tscn`) with all gameplay logic.
All game systems complete: scoring, chain, modules, reinforcements, contracts, shop, directives.
Target platforms: Android (primary), iOS, Web (itch.io demo), PC.

---

## Current State Audit

### ✅ Exists & Works
- Full gameplay loop (chain-building, scoring, hands/discards)
- Round lifecycle (setup → play → result → shop → next round)
- All 4 Calibration Cores (Standard, Resonant, Dense, Void)
- All 4 Protocols (Equilibrium, Compression, Overload, Cascade)
- Module system (40+ modules, full DB, shop integration)
- Reinforcement tiles (9 types, full activation logic)
- Mastery contracts (7 contracts, class + DB)
- Tile shop (buy/remove tiles per round)
- Directive system
- Boss rounds (4 types with cinematic warning)
- Etapa transitions (4 eras, ambient glitch system)
- Shop overlays (Brass Emporium + Artisan's Workshop)
- Score preview, chain milestones, Chronos ghost bar
- Tile lift animations, selection model, play pulse

### ❌ Missing (Demo Blockers)
- Splash / intro screen
- Settings overlay (volume, mute)
- Save / load system (run state + best scores)
- Audio (zero audio files — music + SFX)
- Custom fonts
- Game over / victory screens need polish (run_end_overlay exists but bare)
- No AdMob / ad integration
- No analytics
- No icon or store assets

---

## Architecture Decision

The single-scene approach (all overlays inside `main.tscn`) is the right call for mobile — no loading screens between gameplay states. The plan extends this architecture:

- `scenes/splash.tscn` — standalone entry scene, transitions to main after intro
- `scripts/audio_manager.gd` — new autoload for all audio
- `scripts/save_manager.gd` — new autoload for persistence
- `scripts/ad_manager.gd` — new autoload, stub until SDK integrated
- All other screens stay as overlays inside `main.tscn`

Scene flow:
```
splash.tscn  →  main.tscn
                  ├── title overlay        (Phase.TITLE)
                  ├── core select          (Phase.CORE_SELECT)
                  ├── protocol select      (Phase.PROTOCOL_SELECT)
                  ├── tile removal         (Phase.TILE_REMOVAL)
                  ├── boss warning         (Phase.BOSS_WARNING)
                  ├── gameplay table       (Phase.PLAYING)
                  ├── round result         (Phase.ROUND_RESULT)
                  ├── shop overlay         (Phase.SHOP)
                  ├── run end              (Phase.GAME_OVER / Phase.VICTORY)
                  └── settings overlay     (any phase, modal)
```

---

## Phase 0 — Foundation Systems
**Status:** 🔲 In Progress
**Goal:** Splash screen, audio skeleton, save/load, settings overlay.

### 0.1 Splash Screen
- `scenes/splash.tscn` as the Godot entry point
- Logo animation: fade in "DOMINATION" title + tagline
- Lore line fades in below
- Auto-advances after ~3.5s or tap-to-skip
- Transitions into `main.tscn` with crossfade

### 0.2 AudioManager Autoload (`scripts/audio_manager.gd`)
- `play_sfx(name: String)` — plays a one-shot SFX
- `play_music(name: String, fade: float)` — crossfades to a new track
- `stop_music(fade: float)`
- `set_sfx_volume(v: float)` / `set_music_volume(v: float)`
- `set_mute(b: bool)`
- All file paths resolved from `res://assets/audio/sfx/` and `res://assets/audio/music/`
- Stubs gracefully when files don't exist (editor-safe)

### 0.3 SaveManager Autoload (`scripts/save_manager.gd`)
- Save slot: `user://save.json`
- Persists: run-in-progress state, best scores per difficulty, settings
- `save_run()` — called after each round + shop visit
- `load_run()` → bool (returns false if no save exists)
- `save_settings(data: Dictionary)`
- `load_settings() -> Dictionary`
- `save_best_score(difficulty: int, round: int, chronos: int)`
- `get_best_scores() -> Array`
- `clear_run()` — called on run complete or new game

### 0.4 Settings Overlay (inside main.tscn)
- Accessible via ⚙️ button visible in title + gameplay phases
- Music volume slider (0–100)
- SFX volume slider (0–100)
- Mute toggle
- "Back" button (no separate scene needed)

---

## Phase 1 — Run End Screens
**Status:** 🔲 Pending
**Goal:** Polish the existing `run_end_overlay` into a proper Game Over and Victory screen.

### 1.1 Game Over Screen
- Header: "SIGNAL LOST" (red, large)
- Sub: atmospheric lore line
- Stats panel:
  - Rounds survived
  - Total Chronos accumulated
  - Best single hand
  - Doubles played
  - Modules acquired
- Best run comparison: "Your best: Round X" (from SaveManager)
- Buttons: "TRY AGAIN" (→ run setup) | "MAIN MENU" (→ title)
- Interstitial ad fires before stats reveal (after 1.5s delay)

### 1.2 Victory Screen
- Header: "CHRONOMETER STABILISED" (gold, large)
- Animated confetti / particle burst (Godot CPUParticles2D)
- Stats panel (same as above + difficulty badge)
- "Best run" compare if new record
- Buttons: "PLAY AGAIN" | "MAIN MENU"

---

## Phase 2 — Tutorial & Onboarding
**Status:** 🔲 Pending
**Goal:** First-time player can understand the game without reading a manual.

### 2.1 First-Run Tutorial Overlay
- Persisted flag in SaveManager: `tutorial_seen: bool`
- If false, show step-by-step overlays during first round:
  1. "Your hand is drawn from your Box." — highlight hand area
  2. "Click tiles to select them — matching pips connect." — arrow to hand
  3. "The preview shows your chain and score." — arrow to chain area
  4. "Press PLAY to score Chronos." — arrow to play button
  5. "Reach the target to clear the round." — arrow to Chronos bar
- Each step: semi-transparent backdrop, highlighted target, "Got it →" button
- Skip button top-right cancels all remaining steps

### 2.2 Tooltip System
- Hover (desktop) or long-press (mobile) on any module card → popup description
- Hover on reinforcement tile → popup
- Hover on Chronos bar → breakdown ("chips × mult = total")
- Implementation: single `TooltipPopup` node reused across all targets

---

## Phase 3 — Audio
**Status:** 🔲 Pending
**Goal:** The game must have sound before any public demo.

### 3.1 Music Tracks (3 minimum)
| File | Where | Style |
|---|---|---|
| `assets/audio/music/menu_theme.ogg` | Title + setup overlays | Ambient electronic, mysterious |
| `assets/audio/music/game_ambient.ogg` | Gameplay loop | Tense, rhythmic, low energy |
| `assets/audio/music/boss_ambient.ogg` | Boss rounds | Heavier variant of game_ambient |

Sources: incompetech.com (Kevin MacLeod, CC-BY), freemusicarchive.org, or commission.

### 3.2 Sound Effects (priority order)
| File | Trigger |
|---|---|
| `sfx/tile_click.ogg` | Tile selected |
| `sfx/tile_deselect.ogg` | Tile deselected |
| `sfx/tile_invalid.ogg` | Tile rejected (wrong pip) |
| `sfx/chain_play.ogg` | Play button pressed |
| `sfx/score_tick.ogg` | Chronos ticking up during scoring |
| `sfx/double_hit.ogg` | Double tile bonus fires |
| `sfx/chain_milestone.ogg` | Chain length milestone (4+, 7+ tiles) |
| `sfx/round_clear.ogg` | Round cleared fanfare |
| `sfx/game_over.ogg` | Defeat sting |
| `sfx/victory.ogg` | Run complete fanfare |
| `sfx/coin_gain.ogg` | Monedas popup animation |
| `sfx/shop_buy.ogg` | Purchase confirmed |
| `sfx/module_equip.ogg` | Module slot filled |
| `sfx/discard.ogg` | Discard hand |
| `sfx/ui_hover.ogg` | Button hover (subtle, 8% vol) |
| `sfx/ui_click.ogg` | Button click |
| `sfx/boss_reveal.ogg` | Boss warning typewriter effect |
| `sfx/etapa_transition.ogg` | Era transition cinematic |
| `sfx/reinforcement_use.ogg` | Reinforcement tile activated |

Sources: freesound.org, Kenney's audio packs (CC0), or custom.

### 3.3 AudioManager Integration Points
Hook AudioManager.play_sfx() into:
- `_on_tile_left_click` → `tile_click` / `tile_deselect`
- `_on_play_pressed` → `chain_play`
- `_run_scoring_sequence` → `score_tick` (per tile pop)
- `_on_round_ended(true)` → `round_clear`
- `_show_run_end(false)` → `game_over`
- `_show_run_end(true)` → `victory`
- `_on_shop_buy` → `shop_buy`
- `_show_boss_warning` → `boss_reveal`
- `_show_etapa_transition` → `etapa_transition`

---

## Phase 4 — Visual Polish
**Status:** 🔲 Pending

### 4.1 Custom Fonts (highest ROI visual change)
Download from Google Fonts (all SIL OFL licensed):
- **Rajdhani Bold** (`assets/fonts/Rajdhani-Bold.ttf`) — titles, round header, HUD labels
- **Rajdhani Regular** (`assets/fonts/Rajdhani-Regular.ttf`) — body text, descriptions
- **JetBrains Mono** (`assets/fonts/JetBrainsMono-Regular.ttf`) — pip numbers on tiles

Apply via `theme.tres` resource shared across all labels.

### 4.2 Tile Art Upgrade
- Current: procedural styled panels (works, clean)
- Improvement: pip dot positions are already correct — add subtle inner glow on selected tiles via shader
- Optional: texture overlay on tile face (aged ivory grain)

### 4.3 Scoring Particles
- `CPUParticles2D` burst on each tile pop during scoring sequence
- Color matches tile rarity / pip value (higher pips = brighter burst)
- Doubles: larger burst + gold sparkle

### 4.4 Round Clear Animation
- Chronos bar flashes green + expands briefly when target hit
- "RECALIBRATION SUCCESSFUL" slides in from top with glow
- Monedas earned counter ticks up

### 4.5 Etapa Background Shader
- Subtle animated noise / grain shader on background ColorRect per etapa
- Etapa 0: warm static, Etapa 1: scanlines, Etapa 2: digital noise, Etapa 3: glitch pulses

---

## Phase 5 — Monetization
**Status:** 🔲 Pending

### 5.1 Platform & SDK
| Platform | SDK | Plugin |
|---|---|---|
| Android | Google AdMob | godot-admob-android (Poing Studios) |
| iOS | Google AdMob | godot-admob-ios (Poing Studios) |
| Web | CrazyGames / Poki SDK | JavaScriptBridge |
| PC | No ads | Demo/full split or donate |

### 5.2 AdManager Autoload (`scripts/ad_manager.gd`)
```gdscript
# All methods are no-ops when SDK not present (desktop / editor)
static func request_rewarded(placement: String, callback: Callable) -> void
static func show_interstitial() -> void
static func is_ready(type: String) -> bool
static func set_enabled(b: bool) -> void  # false if "remove ads" IAP purchased
```

### 5.3 Ad Placement Strategy
**Rewarded ads (best UX, highest CPM — player-initiated):**
- "+1 Discard this round" button in HUD → watch ad → `_rm.discards_remaining += 1`
- "Reroll shop for free" button in shop → watch ad → `_shop_inventory = ShopManager.generate_emporium(...)`
- "+1 Hand this round" button in HUD → watch ad (limited: 1 per round)
- "Revive after game over" → watch ad → restore last round state (1× per run)

**Interstitial ads (between natural breaks):**
- After game over reveal (1.5s delay, before stats animate)
- After every 3rd shop visit (tracked in SaveManager)
- Never during gameplay, never during boss warning

**Banner ads:** Skip — hurts aesthetics, low CPM for this game type.

### 5.4 "Remove Ads" IAP
- Price: $2.99–$4.99
- Removes all interstitials
- Rewarded ads still available by player choice
- Purchase stored in `save.json`, verified on boot
- Show in settings overlay + after 2nd interstitial seen

### 5.5 Economy Balance with Ads
- Base game fully completable without ads
- Ads provide convenience (extra resources), never required
- Hard difficulty locked behind "full game" or IAP ($4.99)

---

## Phase 6 — Distribution
**Status:** 🔲 Pending

### 6.1 Android (Primary)
- Minimum SDK: 24 (Android 7.0+)
- Target SDK: 34
- Stretch mode: `canvas_items`, aspect `expand`
- Touch targets: all buttons ≥ 44dp minimum
- AdMob App ID in AndroidManifest.xml
- Export keystore (store securely, not in git)
- Google Play: package name `com.miguelgdoval.domination`
- Store listing: icon (512×512), feature graphic (1024×500), 4+ screenshots

### 6.2 Web / itch.io (Fastest to market)
- HTML5 export
- itch.io page with embedded player
- Cap demo at Round 10 (Etapa 2 boss) — "Full game coming soon"
- Free, instant, no review process
- Great for getting early feedback

### 6.3 iOS
- After Android is stable
- Same AdMob SDK (iOS plugin)
- App Store: requires Mac + paid developer account ($99/yr)

### 6.4 PC (Steam / itch)
- Windows + macOS exports
- Demo build: Rounds 1–10 only, full build unlocks with purchase
- Steam: $3–$5 price point, demo listing

---

## Phase 7 — Analytics & Retention
**Status:** 🔲 Pending

### 7.1 Analytics SDK
Options:
- **GameAnalytics** (free, cross-platform, Godot GDNative SDK) — recommended
- **Firebase** (more powerful, requires more setup)

### 7.2 Key Events
```
run_started       { core, protocol, difficulty }
round_completed   { round_index, score, target, hands_used, hands_remaining }
round_failed      { round_index, score, target, hands_used }
shop_purchase     { item_id, item_type, cost, monedas_remaining }
shop_reroll       { monedas_spent }
module_equipped   { module_id, rarity, slot_index }
reinforcement_used { reinforcement_id, round_index }
game_over         { round_reached, total_chronos, best_hand, difficulty }
run_complete      { difficulty, total_chronos, modules_owned }
ad_shown          { placement, type }
ad_completed      { placement, type, converted }
ad_skipped        { placement, type }
```

### 7.3 Retention Hooks
- **Best Run** tracking (local): highest round reached per difficulty
- **Daily Challenge**: deterministic seed from date, same for all players
- **Unlock Tease**: show "Hard Mode" and "Archiver's Core" as locked on run setup
- **Session Best**: "New personal best!" banner on game over if record broken
- **Continue Run**: SaveManager persists mid-run, "CONTINUE" button on title

---

## Implementation Timeline

### Week 1 — Phase 0 + 1 (Playable Demo)
- [ ] `scripts/audio_manager.gd` autoload
- [ ] `scripts/save_manager.gd` autoload
- [ ] `scenes/splash.tscn` + `scenes/splash.gd`
- [ ] Update `project.godot` entry point + new autoloads
- [ ] Settings overlay in main.tscn
- [ ] Polish run_end_overlay (Game Over + Victory screens)
- [ ] Wire SaveManager: save after shop, load on boot, best score tracking
- [ ] "Continue Run" button on title screen

### Week 2 — Phase 2 + 3 (Tutorial + Audio)
- [ ] Tutorial overlay system (first-run only)
- [ ] Tooltip system for modules + reinforcements
- [ ] Source and import all SFX files
- [ ] Source music tracks (3)
- [ ] Wire all AudioManager.play_sfx() call sites
- [ ] Volume settings wired to AudioManager

### Week 3 — Phase 4 (Visual Polish)
- [ ] Download + import Rajdhani + JetBrains Mono fonts
- [ ] Apply fonts via theme.tres
- [ ] Scoring particle bursts (CPUParticles2D)
- [ ] Round clear bar animation
- [ ] Background shader (etapa-specific)
- [ ] App icon (design + export sizes)

### Week 4 — Phase 5 + 6 (Monetize + Ship)
- [ ] `scripts/ad_manager.gd` stub autoload
- [ ] AdMob Android plugin integration
- [ ] Rewarded ad placements (3 locations)
- [ ] Interstitial placement (game over)
- [ ] "Remove Ads" IAP skeleton
- [ ] Android export preset (signed APK)
- [ ] Web export → itch.io page live
- [ ] GameAnalytics SDK integration

### Ongoing
- [ ] Phase 7 analytics event wiring
- [ ] Playtesting & balance (target numbers, shop prices)
- [ ] iOS build
- [ ] Daily challenge implementation
- [ ] Localization (Spanish priority, since lore is bilingual)

---

## Asset Checklist

### Audio (to be sourced)
```
assets/audio/
├── music/
│   ├── menu_theme.ogg
│   ├── game_ambient.ogg
│   └── boss_ambient.ogg
└── sfx/
    ├── tile_click.ogg
    ├── tile_deselect.ogg
    ├── tile_invalid.ogg
    ├── chain_play.ogg
    ├── score_tick.ogg
    ├── double_hit.ogg
    ├── chain_milestone.ogg
    ├── round_clear.ogg
    ├── game_over.ogg
    ├── victory.ogg
    ├── coin_gain.ogg
    ├── shop_buy.ogg
    ├── module_equip.ogg
    ├── discard.ogg
    ├── ui_hover.ogg
    ├── ui_click.ogg
    ├── boss_reveal.ogg
    ├── etapa_transition.ogg
    └── reinforcement_use.ogg
```

### Fonts (download from fonts.google.com)
```
assets/fonts/
├── Rajdhani-Bold.ttf
├── Rajdhani-Regular.ttf
├── Rajdhani-SemiBold.ttf
└── JetBrainsMono-Regular.ttf
```

### Icons & Store Assets (to be designed)
```
assets/store/
├── icon_512.png          (app icon, 512×512)
├── icon_1024.png         (iOS app icon, 1024×1024)
├── feature_graphic.png   (Google Play, 1024×500)
├── screenshot_1.png      (menu / title)
├── screenshot_2.png      (gameplay — chain being built)
├── screenshot_3.png      (shop — module purchase)
└── screenshot_4.png      (boss round warning)
```

### Module/Reinforcement Icons (you will provide)
```
assets/modules/          (40 .png files, one per module id)
assets/reinforcements/   (9 .png files, one per reinforcement id)
assets/contracts/        (7 .png files, one per contract id)
```

---

## Ad Revenue Projections (rough)

Assuming soft launch with ~500 DAU:
- Rewarded eCPM: $8–15 → ~1.5 rewarded/session → $6–11/DAU/1000
- Interstitial eCPM: $3–6 → ~0.5 shown/session → $1.5–3/DAU/1000
- Combined: ~$4–7 per 1000 DAU per day
- At 500 DAU: ~$2–3.50/day, ~$60–100/month
- At 5000 DAU: ~$600–1000/month
- "Remove Ads" IAP at $2.99, 2% conversion of 500 DAU: ~$30 first month

Scale to 50K DAU (realistic for a quality mobile roguelike with good ASO):
- ~$6K–10K/month ad revenue + IAP

---

## Notes

- All lore text in English in the code, but the game has a Spanish-speaking developer — consider adding Spanish as first localisation
- "Domination" as app name may conflict on stores — consider "DOMINATION: Chronos Engine" or similar
- Tile removal overlay (boss shop) is already implemented — verify UX feels distinct from regular shop
- Directive system adds replayability — make sure it's visible in tutorial
- Mastery contracts: tracking not yet wired to evaluation logic — complete before shipping

---

*End of DEMO_PLAN.md*
