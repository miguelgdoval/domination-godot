## ad_manager.gd — Ad integration stub.
## Autoloaded as "AdManager".
##
## All methods are no-ops until the AdMob plugin is installed.
## Replace the stub bodies with real SDK calls when integrating:
##   Android: github.com/Poing-Studios/godot-admob-android
##   iOS:     github.com/Poing-Studios/godot-admob-ios
##
## Usage:
##   AdManager.show_rewarded("extra_discard", func(earned): if earned: ...)
##   AdManager.show_interstitial()
extends Node

# ---------------------------------------------------------------------------
# Ad unit IDs  (replace with real IDs from AdMob dashboard)
# ---------------------------------------------------------------------------
## ⚠ These are Google test IDs. Replace before going live.
const REWARDED_ID_ANDROID     := "ca-app-pub-3940256099942544/5224354917"
const INTERSTITIAL_ID_ANDROID := "ca-app-pub-3940256099942544/1033173712"
const REWARDED_ID_IOS         := "ca-app-pub-3940256099942544/1712485313"
const INTERSTITIAL_ID_IOS     := "ca-app-pub-3940256099942544/4411468910"

# ---------------------------------------------------------------------------
# Placement labels (used for analytics tracking)
# ---------------------------------------------------------------------------
const PLACEMENT_EXTRA_DISCARD  := "extra_discard"
const PLACEMENT_EXTRA_HAND     := "extra_hand"
const PLACEMENT_SHOP_REROLL    := "shop_reroll"
const PLACEMENT_REVIVE         := "revive"
const PLACEMENT_GAME_OVER      := "game_over"
const PLACEMENT_SHOP_VISIT     := "shop_visit"

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _sdk_available:    bool = false
var _rewarded_ready:   bool = false
var _interstitial_ready: bool = false
var _pending_callback: Callable = Callable()
var _pending_placement: String = ""

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func _ready() -> void:
	_detect_sdk()
	if _sdk_available:
		_init_sdk()

func _detect_sdk() -> void:
	# Check if the AdMob plugin node is present (injected by the Godot plugin)
	_sdk_available = Engine.has_singleton("AdMob")

func _init_sdk() -> void:
	# Wire up AdMob singleton signals here when the plugin is installed.
	# Example (plugin-specific API — verify with your chosen plugin):
	# var admob = Engine.get_singleton("AdMob")
	# admob.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	# admob.rewarded_ad_earned_reward.connect(_on_rewarded_earned)
	# admob.rewarded_ad_failed_to_load.connect(_on_rewarded_failed)
	# admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	# admob.interstitial_ad_closed.connect(_on_interstitial_closed)
	# _load_rewarded()
	# _load_interstitial()
	pass

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Show a rewarded ad for the given placement.
## callback(earned: bool) is called when the ad completes (true) or fails/skips (false).
## Does nothing if ads are removed or SDK is unavailable.
func show_rewarded(placement: String, callback: Callable) -> void:
	if SaveManager.is_ads_removed():
		# Ads removed — grant the reward automatically
		callback.call(true)
		return
	if not _sdk_available or not _rewarded_ready:
		# No SDK or ad not loaded — do not grant reward; notify UI gracefully
		callback.call(false)
		return
	_pending_callback  = callback
	_pending_placement = placement
	# _do_show_rewarded()  ← uncomment and implement when SDK is present

## Show an interstitial ad (between natural breaks).
## Safe to call even when no ad is loaded — silently skips.
func show_interstitial() -> void:
	if SaveManager.is_ads_removed():
		return
	if not _sdk_available or not _interstitial_ready:
		return
	# _do_show_interstitial()  ← uncomment and implement when SDK is present

## Returns true if a rewarded ad is currently loaded and ready to show.
func is_rewarded_ready() -> bool:
	if SaveManager.is_ads_removed():
		return true   # treat "removed" as always-ready (reward is granted directly)
	return _sdk_available and _rewarded_ready

## Returns true if ads have been removed via IAP.
func ads_removed() -> bool:
	return SaveManager.is_ads_removed()

# ---------------------------------------------------------------------------
# SDK callbacks (wire these to the plugin's signals in _init_sdk)
# ---------------------------------------------------------------------------
func _on_rewarded_loaded() -> void:
	_rewarded_ready = true

func _on_rewarded_earned(_type: String, _amount: int) -> void:
	_rewarded_ready = false
	if _pending_callback.is_valid():
		_pending_callback.call(true)
	_pending_callback  = Callable()
	_pending_placement = ""
	_load_rewarded()   # pre-load next ad immediately

func _on_rewarded_failed(_error_code: int) -> void:
	_rewarded_ready = false
	if _pending_callback.is_valid():
		_pending_callback.call(false)
	_pending_callback  = Callable()
	_pending_placement = ""

func _on_interstitial_loaded() -> void:
	_interstitial_ready = true

func _on_interstitial_closed() -> void:
	_interstitial_ready = false
	_load_interstitial()  # pre-load next

# ---------------------------------------------------------------------------
# Internal loaders
# ---------------------------------------------------------------------------
func _load_rewarded() -> void:
	if not _sdk_available:
		return
	# var admob = Engine.get_singleton("AdMob")
	# var id = REWARDED_ID_ANDROID if OS.get_name() == "Android" else REWARDED_ID_IOS
	# admob.load_rewarded_ad(id)
	pass

func _load_interstitial() -> void:
	if not _sdk_available:
		return
	# var admob = Engine.get_singleton("AdMob")
	# var id = INTERSTITIAL_ID_ANDROID if OS.get_name() == "Android" else INTERSTITIAL_ID_IOS
	# admob.load_interstitial_ad(id)
	pass
