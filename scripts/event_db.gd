## event_db.gd — Catalogue of Event Terminal events.
##
## The Event Terminal is the Archiver-and-others system the GDD has called
## for since v1: between certain rounds, one of the cast contacts the
## Operator with a 2-3 way asymmetric bargain. Each choice has a real
## mechanical consequence — no choice is strictly best.
##
## At most ONE event fires per Trial Cycle, gated by a 30% post-round
## roll. Events are filtered by `min_round` so a brand-new Operator
## doesn't get hit with the Master's "describe your build" prompt before
## they've even seen a Boss.
##
## Schema per entry:
##   id        — stable string, used for codex unlock + telemetry
##   speaker   — short display name shown above the body
##   title     — header line shown above the speaker
##   body      — transmission text; \n permitted, wraps at panel width
##   min_round — 0-based round_index gate (event only fires after this)
##   choices   — Array[Dictionary], each with:
##                 label   : button text
##                 effect  : effect-key string (see _apply_event_effect in main.gd)
##                 param   : int param (rarity for gain_module, coin count, etc.)
##                 outcome : flavour line shown after the choice resolves
##                 rep     : Dictionary of faction → delta. Optional;
##                           empty / missing means no rep change.
##                           Example: {"society": 1, "renegade": -1}
##
## Pure static data — no autoload needed.
class_name EventDB
extends RefCounted

static func all() -> Array[Dictionary]:
	return [
		# ── Event 1: The Archiver Observes a Flow ───────────────────────────
		{
			"id":       "archiver_observes",
			"speaker":  "THE ARCHIVER",
			"title":    "TRANSMISSION INCOMING",
			"body":
"\"Operator. I have observed your current array. One of your "
+ "Components carries an anomaly that interests me. I will compensate "
+ "you for surrendering it.\"",
			"min_round": 2,
			"choices": [
				{
					"label":   "Transfer the Component to the Archive",
					"effect":  "lose_tile_gain_module",
					"param":   Constants.Rarity.IVORY,
					"outcome": "The Archive accepts. A new Module appears in the Calibration tray.",
					"rep":     {"society": 1},
				},
				{
					"label":   "Refuse the transaction",
					"effect":  "none",
					"param":   0,
					"outcome": "The Archive notes the refusal. Nothing more.",
					"rep":     {},
				},
				{
					"label":   "Offer information instead",
					"effect":  "gain_coins",
					"param":   3,
					"outcome": "Your Cycle data is logged. The Guild deposits a small stipend.",
					"rep":     {"guild": 1},
				},
			],
		},

		# ── Event 2: The Renegade's Workbench ───────────────────────────────
		{
			"id":       "renegade_workbench",
			"speaker":  "THE RENEGADE MECHANIC",
			"title":    "OFF-CATALOGUE CONTACT",
			"body":
"\"Heard about your last Pulse. Here. Take this. Don't tell anyone "
+ "where it came from. The Master would have to file paperwork.\"",
			"min_round": 4,
			"choices": [
				{
					"label":   "Accept the gift (–2 Coins for materials)",
					"effect":  "lose_coins_gain_module",
					"param":   Constants.Rarity.CARVED,
					"outcome": "He hands it over. Two Coins for solder. Fair.",
					"rep":     {"renegade": 2},
				},
				{
					"label":   "Question its origin",
					"effect":  "none",
					"param":   0,
					"outcome": "He shrugs. \"Smart. Maybe next Cycle.\"",
					"rep":     {"society": 1},
				},
				{
					"label":   "Trade your oldest Module for an Ivory one",
					"effect":  "trade_module",
					"param":   Constants.Rarity.IVORY,
					"outcome": "A clean swap. He keeps the old gear. It belongs to him now.",
					"rep":     {"renegade": 2},
				},
			],
		},

		# ── Event 3: A Copper Guild Audit ───────────────────────────────────
		{
			"id":       "guild_audit",
			"speaker":  "THE COPPER GUILD",
			"title":    "ROUTINE COMPLIANCE AUDIT",
			"body":
"\"Operator. The Copper Guild requires verification of recent "
+ "transactions on your account. Cooperation is in your interest.\"",
			"min_round": 3,
			"choices": [
				{
					"label":   "Comply fully (–4 Coins, +1 Tool)",
					"effect":  "lose_coins_gain_tool",
					"param":   4,
					"outcome": "The Guild reciprocates with a sealed Emporium voucher.",
					"rep":     {"guild": 2},
				},
				{
					"label":   "Decline politely",
					"effect":  "none",
					"param":   0,
					"outcome": "The auditor withdraws without comment. Records remain open.",
					"rep":     {"society": 1},
				},
				{
					"label":   "Bribe the auditor (+5 Coins, –1 Module)",
					"effect":  "gain_coins_lose_module",
					"param":   5,
					"outcome": "The audit closes early. A Module quietly disappears from your slot.",
					"rep":     {"renegade": 2, "society": -1},
				},
			],
		},

		# ── Event 4: The Master's Question ──────────────────────────────────
		{
			"id":       "master_question",
			"speaker":  "THE MASTER OF THE FORGE",
			"title":    "AN OFFER FROM THE WORKSHOP",
			"body":
"\"Operator. Your build is taking shape. I have a Module that would "
+ "suit it. But I will only forge for someone who can describe what "
+ "they are building toward.\"",
			"min_round": 5,
			"choices": [
				{
					"label":   "Describe your build",
					"effect":  "gain_module",
					"param":   Constants.Rarity.BONE,
					"outcome": "He nods once. The Module is yours. Bone-tier, well-made.",
					"rep":     {"society": 1},
				},
				{
					"label":   "Stay silent",
					"effect":  "none",
					"param":   0,
					"outcome": "He sets the Module aside. \"For someone less private.\"",
					"rep":     {},
				},
				{
					"label":   "Offer a Component from your box instead",
					"effect":  "lose_tile_gain_module",
					"param":   Constants.Rarity.IVORY,
					"outcome": "He examines the tile, then hands you an Ivory Module.",
					"rep":     {"society": 2},
				},
			],
		},

		# ── Event 5: An Archive Glitch ──────────────────────────────────────
		{
			"id":       "archive_glitch",
			"speaker":  "THE ARCHIVER",
			"title":    "ARCHIVE INTEGRITY ALERT",
			"body":
"\"Da--data anomaly. Operator, the Archive's record of your current "
+ "Cycle is incom--incomplete. The Archive offers to compensate. Or "
+ "you may correct the record yourself.\"",
			"min_round": 6,
			"choices": [
				{
					"label":   "Accept compensation",
					"effect":  "gain_coins",
					"param":   6,
					"outcome": "Six Coins, in lieu of an accurate record.",
					"rep":     {"guild": 1},
				},
				{
					"label":   "Correct the record",
					"effect":  "gain_module",
					"param":   Constants.Rarity.CARVED,
					"outcome": "The Archive completes the entry. A Module is granted in thanks.",
					"rep":     {"society": 1},
				},
				{
					"label":   "Ignore the anomaly",
					"effect":  "gain_coins",
					"param":   1,
					"outcome": "Trivial deposit. The Archive moves on without you.",
					"rep":     {},
				},
			],
		},
	]

## Filter the event pool down to events whose `min_round` gate is met by
## the current round_index. Returns a fresh Array (safe to shuffle).
static func eligible(round_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for e in all():
		if int(e.get("min_round", 0)) <= round_index:
			result.append(e)
	return result
