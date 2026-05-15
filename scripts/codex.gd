## codex.gd — The Archive. Static catalogue of every lore entry the
## player can discover across runs. Indexed by category, each entry
## carries an unlock gate (always / lifetime-stat / event-driven).
##
## Pure data + helpers. No autoload needed — UI code reads from
## Codex.ENTRIES directly and asks Codex.is_unlocked(...) per entry.
class_name Codex
extends RefCounted

## Display categories — drives the tab strip on the overlay.
enum Category {
	PEOPLE,        # NPCs the Operator encounters
	PLACES,        # Etapas / chambers of the Chronometer
	CONCEPTS,      # game-term glossary with lore framing
	MODULES,       # Calibration Modules — unlocked on first equip
	TILES,         # Special Temporal Flow Components — unlocked on first acquire
	ANOMALIES,     # system-level oddities (Wild face, Branch Ends)
	FAILURES,      # boss effects + simulation-failure flavour
	TRANSMISSIONS, # cryptic broadcasts unlocked by milestones
}

const CATEGORY_NAMES: Array[String] = [
	"PEOPLE", "PLACES", "CONCEPTS", "MODULES", "TILES",
	"ANOMALIES", "FAILURES", "TRANSMISSIONS",
]

## Entry schema:
##   id        — stable string, used in SaveManager.codex_seen for persistence.
##   category  — Category enum value (above).
##   name      — display title shown in the list and header.
##   summary   — one-line preview shown in the entry list (under name).
##   body      — full lore text. \n for line breaks. Can be long.
##   unlock    — Dictionary describing the unlock gate.
##                 type: "always" | "event" | "best_round" | "wins" |
##                       "hard_wins" | "daily_streak" | "failures" |
##                       "hands_played" | "doubles_played"
##                 value: int (threshold for stat-based gates)
##                 hint: String (shown for locked entries —
##                       what the player needs to do)
const ENTRIES: Array[Dictionary] = [
	# ─── PEOPLE ──────────────────────────────────────────────────────────
	{
		"id": "operator", "category": Category.PEOPLE,
		"name": "The Trial Operator",
		"summary": "That is what they call you.",
		"body":
"\"You are not a hero. You are a tool. The Society of Time Architects "
+ "recruits engineers because heroes ask questions and engineers do not.\"\n\n"
+ "The Operator's task is precise: take a seat at the Observation Window, "
+ "configure the Calibration Core, accept a Protocol, and run a Trial Cycle. "
+ "If the simulation holds, the Machine learns. If it collapses, the data is "
+ "preserved and the simulation resets.\n\n"
+ "You are not unique. You are indispensable.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "archiver", "category": Category.PEOPLE,
		"name": "The Archiver",
		"summary": "Custodian of the Machine's knowledge.",
		"body":
"\"The Archiver lives outside normal time flow. They were not born; they were "
+ "indexed. Their body is a single crystal optical eye mounted on a brass panel, "
+ "and that is enough.\"\n\n"
+ "The Archiver appears during Event Terminals to offer bargains. The bargains "
+ "are never bad — they are simply asymmetric, in directions the Operator "
+ "rarely realises until afterwards. Their speech is cold, formal, obsessed "
+ "with symmetry.\n\n"
+ "They do not explain themselves. They do not lie either.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "emporium_voice", "category": Category.PEOPLE,
		"name": "The Voice of the Emporium",
		"summary": "The Brass Emporium's commercial system.",
		"body":
"An automated terminal, not a person. Speaks in neutral, slightly uncanny "
+ "cadences. The Voice has no preferences, no opinions, no interests — only "
+ "the catalogue.\n\n"
+ "The Operator who tries to draw the Voice into conversation receives the "
+ "same response every time: \"This is a commercial system. Please confirm "
+ "your purchase, or vacate the terminal.\"\n\n"
+ "Some Operators have tried to reach what is behind it. They find a small "
+ "office. A chair, pushed back from a desk. The terminal on the desk is the "
+ "other side of the Voice, and it is silent. A few of those Operators did "
+ "not leave.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Visit the Brass Emporium."},
	},
	{
		"id": "renegade_mechanic", "category": Category.PEOPLE,
		"name": "The Renegade Mechanic",
		"summary": "Sells illegal Calibration Modules. Knows more than he admits.",
		"body":
"He runs no shop with a sign. He appears at the Artisan's Workshop after "
+ "certain Entropy Failures, on schedules the Society has not deciphered, "
+ "the Master of the Forge stepping aside with the deliberate silence of "
+ "someone who has seen this before.\n\n"
+ "His modules — Obsidian-tier work — are not in the Architects' catalogue. "
+ "When asked who made them, he says: \"I made them. I will make others. "
+ "Do not bring them back.\"\n\n"
+ "The Archiver has filed a request for his arrest in every Trial Cycle "
+ "for as long as the records go back. The requests reach the Society's "
+ "administrative offices and are accepted, stamped, and filed. "
+ "The request is never executed.",
		"unlock": {"type": "best_round", "value": 5,
			"hint": "Clear the first Entropy Failure."},
	},
	{
		"id": "master_of_forge", "category": Category.PEOPLE,
		"name": "The Master of the Forge",
		"summary": "Runs the Artisan's Workshop. Teaches the Operator to build.",
		"body":
"The Master is precise, demanding, respectful of craft. When the Operator "
+ "selects a tile for removal, the Master simply nods. When the Operator "
+ "selects a special tile to add, the Master examines them — not the tile. "
+ "He is checking how much wear the Operator has taken since the last visit.\n\n"
+ "He has trained every Operator who has reached him. He has not spoken at "
+ "length to any. His one consistent piece of guidance: \"Build only what "
+ "you would be willing to lose.\"\n\n"
+ "When the Renegade Mechanic visits, the Master leaves the Workshop and "
+ "walks the corridors. He always returns.",
		"unlock": {"type": "best_round", "value": 5,
			"hint": "Clear the first Entropy Failure."},
	},
	{
		"id": "copper_guild", "category": Category.PEOPLE,
		"name": "The Copper Guild",
		"summary": "Controls the temporal economy. Background faction.",
		"body":
"The Copper Guild is institutional, transactional, amoral. They do not "
+ "appear in person at the Observation Window. They are everywhere else.\n\n"
+ "Coins — the stable byproducts of successful Trial Cycles — are minted, "
+ "valued, and accepted only by Guild contract. The Society of Time Architects "
+ "tolerates the Guild because the Guild's bookkeeping is the only thing "
+ "preventing the Chronometer's economy from collapsing alongside the Machine.\n\n"
+ "They are not allied with the Operator. They are not enemies. They are "
+ "the wall the simulation runs against.\n\n"
+ "The Guild's books extend forward through margins of expected losses "
+ "that imply a horizon longer than the Society's. The Guild does not "
+ "advertise the horizon.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn your first Coins."},
	},

	# ─── PLACES ──────────────────────────────────────────────────────────
	{
		"id": "observation_window", "category": Category.PLACES,
		"name": "The Observation Window",
		"summary": "Where the Trial Cycle is run.",
		"body":
"\"La Ventana de Observación del Tiempo.\" The play table. The Operator's "
+ "only fixed location during a Trial Cycle.\n\n"
+ "The Window does not display the simulation directly. It displays the "
+ "simulation's projections — Temporal Flow Components arranged as the "
+ "Machine processes them, scored as the Machine learns. The Operator's role "
+ "is to insert flows into the Processing Core; the Window shows what the "
+ "Machine does with them.\n\n"
+ "Operators report that the Window's brass fittings warm to the touch in "
+ "successful Trial Cycles. The Architects have no recorded explanation.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "mahogany_trial", "category": Category.PLACES,
		"name": "The Mahogany Trial",
		"summary": "Etapa I. Polished mahogany, brass fittings, candlelight.",
		"body":
"The opening chamber. The Chronometer is most stable here; the simulation "
+ "behaves close to its original calibration.\n\n"
+ "Operators new to the work always begin in the Mahogany Trial. The targets "
+ "are forgiving. The Frequency Drain manifests at the close of the Trial — "
+ "a paradox of compressed Isolation Chambers, the Machine's first complaint "
+ "about its own decay.\n\n"
+ "The Architects refer to the Mahogany Trial as \"the cradle.\" The "
+ "Archiver does not. The Archive has a complete record of how many "
+ "Operators have not survived their first Cycle. The Archive considers "
+ "\"cradle\" inaccurate.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "industrial_load", "category": Category.PLACES,
		"name": "The Industrial Load",
		"summary": "Etapa II. Steel and steam, copper pipes, harsh light.",
		"body":
"The second chamber. The Chronometer's intermediate processes — pressure, "
+ "amplification, the conversion of stable Cohesion Pulses into deeper "
+ "calibration data.\n\n"
+ "Here the Mirror Decay appears: pip values invert across the threshold. "
+ "The Operator who has trusted high pips and resonant doubles up to this "
+ "point must abandon those instincts for the Trial that follows. The Decay "
+ "is older than the Architects who study it.",
		"unlock": {"type": "best_round", "value": 6,
			"hint": "Survive into Etapa II."},
	},
	{
		"id": "cold_singularity", "category": Category.PLACES,
		"name": "The Cold Singularity",
		"summary": "Etapa III. Black obsidian, neon-green accents, cold white light.",
		"body":
"The deep chamber. Operators who reach the Singularity report the same "
+ "thing: the temperature drops, and the Machine breathes slower here.\n\n"
+ "The Resonance Inversion lives in this chamber. The Operator's most "
+ "reliable scoring engine — stacked doubles — turns on them. The Trial "
+ "becomes a test not of skill but of adaptation. The Operators who cannot "
+ "abandon a winning strategy do not leave the Singularity.\n\n"
+ "The Architects have no records of this chamber's original purpose. The "
+ "Renegade Mechanic claims to have one, but will not share it.",
		"unlock": {"type": "best_round", "value": 11,
			"hint": "Survive into Etapa III."},
	},
	{
		"id": "archiver_core", "category": Category.PLACES,
		"name": "The Archiver's Core",
		"summary": "Etapa IV (Hard mode only). Ancient paper, brass, glyphs.",
		"body":
"The deepest chamber. Reached only by Operators who have hardened their "
+ "Trial Cycle — accepted the additional Etapa, the additional Failure.\n\n"
+ "This is where the Archiver lives. The Operator who arrives here has "
+ "earned the Archiver's full attention, and that attention is not pleasant. "
+ "The Ghost Chain manifests in this chamber: the Archive forgets what it "
+ "has seen, and you must remember the rest.\n\n"
+ "The Recalibration achieved in this chamber is not the same Recalibration "
+ "achieved in the Singularity. Operators who have done both will not "
+ "discuss the difference.",
		"unlock": {"type": "hard_wins", "value": 1,
			"hint": "Recalibrate on Hard difficulty."},
	},

	# ─── CONCEPTS ────────────────────────────────────────────────────────
	{
		"id": "first_hour", "category": Category.CONCEPTS,
		"name": "The First Hour",
		"summary": "A reference period the Society uses without elaborating.",
		"body":
"The Chronometer's reference period. The Society's records use this "
+ "term without elaborating. The Architects have no consistent "
+ "definition; the Archive's earliest indices reference \"the First Hour\" "
+ "as a fixed unit, but the unit's length, calendar, and conditions are "
+ "not recoverable.\n\n"
+ "The Renegade has not been asked.\n\n"
+ "The First Hour ended. The Society is what came after.",
		"unlock": {"type": "wins", "value": 5,
			"hint": "Recalibrate the Chronometer 5 times."},
	},
	{
		"id": "chronometer", "category": Category.CONCEPTS,
		"name": "The Perpetual Chronometer",
		"summary": "The universe, as the Architects understand it.",
		"body":
"A vast, impossibly complex clockwork machine that holds the very fabric of "
+ "reality together. Time is not abstract within the Chronometer; it is a "
+ "geared substance that flows in ordered cycles.\n\n"
+ "The Machine is perfect. The Machine is also dying.\n\n"
+ "The Society of Time Architects exists to slow the dying. The Operator "
+ "exists to extract Mastery from the Machine's failures, so that future "
+ "Operators may survive them.\n\n"
+ "Nobody — not the Architects, not the Archive in its current state — admits "
+ "to knowing what the Chronometer was for, before it began to fail. "
+ "The Renegade Mechanic does not answer questions of this kind.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "chronos", "category": Category.CONCEPTS,
		"name": "Chronos",
		"summary": "The temporal energy extracted from a stable chain.",
		"body":
"Chronos is not a currency; it is a measurement. When a Cohesion Pulse "
+ "holds, the Machine extracts the temporal energy that pulse stabilised, "
+ "and that energy is recorded as Chronos.\n\n"
+ "The Operator who reaches a round's Chronos target has demonstrated that "
+ "their Pulse was sufficient. The Operator who falls short has not.\n\n"
+ "Chronos cannot be spent. Only its stable byproducts — Coins — can.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "entropy", "category": Category.CONCEPTS,
		"name": "Entropy",
		"summary": "The Chronometer's structural decay.",
		"body":
"\"It cannot be stopped, only managed.\"\n\n"
+ "Entropy is the natural state toward which the Chronometer drifts. The "
+ "Trial Cycles do not reverse it; they slow it. The Operator's task is "
+ "explicitly framed by the Architects as \"recalibration\" — restoring the "
+ "Machine to function, not health.\n\n"
+ "The Entropy Failures encountered during a Trial Cycle are not abstract. "
+ "They are paradoxes the Machine has begun to embody. When an Operator "
+ "isolates a Failure, the paradox is bound; the Machine learns to expect "
+ "it. The same Failure will return, milder, in future Cycles.\n\n"
+ "This is not victory. This is delay.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "cohesion_pulse", "category": Category.CONCEPTS,
		"name": "Cohesion Pulse",
		"summary": "A stable sequence of aligned temporal flows.",
		"body":
"The chain of Temporal Flow Components the Operator constructs at the "
+ "Observation Window. A Pulse is stable when its connecting pip values "
+ "align — when the Machine recognises continuity across the inserted flows.\n\n"
+ "Pulses are scored by length tier:\n"
+ "  • Fragment  (1-3 tiles)  — no resonance bonus\n"
+ "  • Pulse     (4-6)        — +1 multiplier\n"
+ "  • Cohesion  (7-10)       — +2 multiplier\n"
+ "  • Resonance (11-15)      — +4 multiplier\n"
+ "  • Harmonic  (16-20)      — +7 multiplier\n"
+ "  • Singularity (21+)      — +12 multiplier\n\n"
+ "The Architects believe — without proof — that Singularity-tier Pulses "
+ "are what the Chronometer was built to process.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "temporal_flow", "category": Category.CONCEPTS,
		"name": "Temporal Flow Component",
		"summary": "A single tile. A logic gear of the Machine.",
		"body":
"Each Component encodes a fragment of a timeline. The pip values on its "
+ "two faces represent Chronos charges — the raw stability of that flow.\n\n"
+ "Components are not symbols. They are pieces of the Machine, briefly "
+ "removed from its core, placed in the Operator's Isolation Chamber for "
+ "insertion into the Processing Core. Each Component returns to the "
+ "Machine at the end of the Trial Cycle, none the worse for the journey.\n\n"
+ "The blank (0) face is not absent. It is dormant — a Universal Connector "
+ "that accepts any input signal. The Architects who study these tiles "
+ "consider blanks the most important Components in the set.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "branching", "category": Category.CONCEPTS,
		"name": "Branching at Doubles",
		"summary": "Why doubles create extra open ends.",
		"body":
"A double tile placed in a Cohesion Pulse — two faces of identical pip "
+ "value — does not behave like other Components. Its perpendicular "
+ "orientation in the Pulse exposes additional faces, additional places "
+ "the Operator can extend the chain.\n\n"
+ "The Machine treats each placed double as a branching node. The chain "
+ "is no longer a simple line; it is a small tree. Future Components can "
+ "match the left end, right end, OR any branch end opened by a previous "
+ "double.\n\n"
+ "The Architects believe this is not a feature of dominoes. They believe "
+ "this is a feature of timelines.",
		"unlock": {"type": "best_round", "value": 4,
			"hint": "Place a double in a chain."},
	},
	{
		"id": "calibration_core", "category": Category.CONCEPTS,
		"name": "Calibration Core",
		"summary": "The configuration loaded at run start.",
		"body":
"Before each Trial Cycle, the Operator inserts a Calibration Core. The "
+ "Core determines which Temporal Flow Components are available in the "
+ "session — which timelines the Machine will be tested against.\n\n"
+ "The Standard Core is a complete double-9 set. It is the calibration the "
+ "Society recommends for all new Operators. The other Cores — Resonant, "
+ "Dense, Void Lattice, and beyond — are restricted: the Society makes them "
+ "available only as the Operator demonstrates sufficient mastery.\n\n"
+ "Eight Cores exist. Some Operators believe there are more. The Architects "
+ "do not confirm this.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "protocol", "category": Category.CONCEPTS,
		"name": "Protocol",
		"summary": "An operational rule distortion accepted at run start.",
		"body":
"The Protocolo de Ensayo modifies the fundamental rules of the Trial "
+ "Cycle: hand size, number of plays, number of discards, opening Coins.\n\n"
+ "Equilibrium is the baseline. Compression, Overload, and Cascade are "
+ "alternative parameter sets, each rebalanced toward a different style of "
+ "Operator. The Society treats Protocols as cosmetic preferences. The "
+ "Archiver does not.\n\n"
+ "\"A Protocol is a story you tell the Machine about how you will fail. "
+ "The Machine listens.\"",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "monedas", "category": Category.CONCEPTS,
		"name": "Coins",
		"summary": "The Copper Guild's stable currency.",
		"body":
"When a Trial Cycle round completes successfully, the residual Chronos — "
+ "the stable byproduct that cannot be reabsorbed by the Machine — is "
+ "captured by the Copper Guild's contracts and minted into Coins.\n\n"
+ "The Guild's contracts predate the Society of Time Architects. The "
+ "Architects do not understand them. The Architects pay anyway.\n\n"
+ "Coins can be spent at the Brass Emporium for Calibration Modules, or "
+ "at the Artisan's Workshop for tile modifications. Unspent Coins at "
+ "the end of a Cycle are returned to the Guild's vaults. They do not "
+ "carry across Cycles.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn your first Coins."},
	},
	{
		"id": "recalibration", "category": Category.CONCEPTS,
		"name": "Recalibration",
		"summary": "Victory. What the Operator's work is for.",
		"body":
"The Trial Cycle is not played to win. It is played to recalibrate.\n\n"
+ "A Recalibration is the Chronometer's acceptance that the Operator's "
+ "completed Cycle has updated the Machine's models — that future Trial "
+ "Cycles will be subtly different, subtly more stable, because of this one.\n\n"
+ "The Operator who Recalibrates does not save the universe. The Operator "
+ "who Recalibrates delays its end by an amount the Architects cannot "
+ "measure but believe to be non-zero.\n\n"
+ "That is the work.",
		"unlock": {"type": "wins", "value": 1,
			"hint": "Recalibrate the Chronometer."},
	},

	# ─── ANOMALIES ───────────────────────────────────────────────────────
	{
		"id": "wild_tile", "category": Category.ANOMALIES,
		"name": "The Wild",
		"summary": "A Temporal Flow Component that should not exist.",
		"body":
"Wild tiles appear in only one Calibration Core — the Void Lattice — and "
+ "rarely. They have no pip values. They connect to anything.\n\n"
+ "The Architects' position is that Wilds are calibration noise: "
+ "imperfections in the Core's loading process, accepted by the Machine "
+ "as inputs because the Machine accepts everything. The Renegade Mechanic "
+ "disagrees. He says the Wilds are intentional.\n\n"
+ "He has not said by whom.\n\n"
+ "A sketch recovered from the Workshop floor — unsigned, in the Renegade's "
+ "hand — depicts a Wild as a door. The door, in the sketch, is open. The "
+ "page does not show what is on the other side.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "double_resonance", "category": Category.ANOMALIES,
		"name": "Double Resonance",
		"summary": "Self-referential flow components amplify the Pulse.",
		"body":
"A double Component — two matching pip faces on the same Component — "
+ "resonates with itself when routed through the Core. The Machine "
+ "interprets this self-reference as a coherence pulse of higher order, "
+ "and grants the Operator a flat amplification on the next signal.\n\n"
+ "Doubles do NOT open additional matching ends; the Pulse remains a "
+ "single line per the Architects' first-edition Component Manual. The "
+ "Renegade Mechanic disagrees on this point, and his sketches of a "
+ "'branched Pulse' have been impounded by the Copper Guild on at least "
+ "three occasions.",
		"unlock": {"type": "best_round", "value": 4,
			"hint": "Place a double in a chain."},
	},
	{
		"id": "brass_lever", "category": Category.ANOMALIES,
		"name": "The Brass Lever",
		"summary": "Half-pulled, somewhere in the Cold Singularity.",
		"body":
"A brass lever, half-pulled, fixed in its half-position for the "
+ "duration of the Memorial. Located somewhere in the Cold Singularity, "
+ "behind the chamber's primary processing manifold.\n\n"
+ "The Architects' inventory marks the position with the note "
+ "\"do not adjust.\" The note has been re-stamped many times. The "
+ "lever has not been adjusted.\n\n"
+ "The Operators who have seen the lever directly do not describe it. "
+ "The Operators who have not seen it imagine it. Neither group is wrong.",
		"unlock": {"type": "wins", "value": 50,
			"hint": "Recalibrate the Chronometer 50 times."},
	},

	# ─── MODULES ─────────────────────────────────────────────────────────
	# Discovery entries for every Calibration Module. Unlocked the first
	# time the Operator equips one — either by purchase at a shop or by
	# starting a run on a Core that preloads it. Hint text is generic
	# ("Equip this Module.") because each Module has its own acquisition
	# context and the hint shouldn't fight that.

	# Bone tier
	{
		"id": "module_brass_gear", "category": Category.MODULES,
		"name": "Brass Gear (CB-1)",
		"summary": "A simple gear salvaged from a broken chronometer.",
		"body":
"The Society's Module Catalogue does not bother to list it. Every Operator "
+ "finds one in their first Trial Cycle. The gear's teeth still bear the "
+ "fittings of a larger assembly the records can no longer identify.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_copper_coil", "category": Category.MODULES,
		"name": "Copper Coil",
		"summary": "Stores residual Chronos charge between insertions.",
		"body":
"A Copper Guild artisan signs every Coil with three small dots — proof of "
+ "authentic minting. The dots wear off with use. The Guild has not been "
+ "asked what happens to a Coil whose dots have worn entirely.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_worn_sprocket", "category": Category.MODULES,
		"name": "Worn Sprocket",
		"summary": "Still functional. Barely.",
		"body":
"The Renegade Mechanic refers to these as 'witness sprockets' — Modules "
+ "that have been recovered from previous Trial Cycles. The Society does "
+ "not acknowledge that frame. They issue them anyway.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_flux_capacitor", "category": Category.MODULES,
		"name": "Flux Capacitor",
		"summary": "Salvaged from the first calibration collapse.",
		"body":
"The label reads CONTAINMENT-CRITICAL but the seal is broken. The charge "
+ "is small and the seal would not hold a real charge. The Operator equips "
+ "it anyway.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_timing_chain", "category": Category.MODULES,
		"name": "Timing Chain",
		"summary": "Even small coherence deserves recognition.",
		"body":
"A Society-issued tracker that activates only when a Cohesion Pulse "
+ "exceeds three Components. The Architects believe in encouraging baseline "
+ "competence before rewarding ambition.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_temporal_accumulator", "category": Category.MODULES,
		"name": "Temporal Accumulator",
		"summary": "Patience is a form of power.",
		"body":
"The Accumulator does nothing in the early Etapas. It does more in each "
+ "subsequent Etapa. The Architects' note in the catalogue: 'The Mechanism "
+ "remembers.' The Architects do not elaborate.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_momentum_coil", "category": Category.MODULES,
		"name": "Momentum Coil",
		"summary": "Round by round, the coil tightens.",
		"body":
"A Copper Guild artifact. Each round cleared adds compound interest. The "
+ "Guild does not loan; the Coil is its only credit instrument. Operators "
+ "who fail to clear rounds receive the Coil with the dividends still "
+ "intact, but unaccrued.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_null_recoder", "category": Category.MODULES,
		"name": "Null Recoder",
		"summary": "Blank faces hold latent potential.",
		"body":
"The first device the Chronometer built without an Architect's approval. "
+ "The blueprints are not on file. The Module continues to function "
+ "regardless. The Architects' Inventory Department considers the Recoder "
+ "an open question.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_coin_magnet", "category": Category.MODULES,
		"name": "Coin Magnet",
		"summary": "Residual Chronos bleeds into the stipend.",
		"body":
"The Copper Guild stamps its sigil into the back. The sigil is the Greek "
+ "letter Ksi. The Guild's apprentices are not told why. They learn it "
+ "anyway, by carving it.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_resonant_stride", "category": Category.MODULES,
		"name": "Resonant Stride",
		"summary": "Even moderate frequencies carry weight.",
		"body":
"A field tuner intended for Specialist-Core deployments. Surplus stock "
+ "circulates among Bone-tier offerings; the Architects consider it "
+ "adequate for any high-pip build, and inadequate for anything else.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_triage_engine", "category": Category.MODULES,
		"name": "Triage Engine",
		"summary": "The smallest signals are not worth scoring.",
		"body":
"A field surgeon's gear, repurposed. The smallest signals are not worth "
+ "scoring; they are worth burning. The Engine performs the calculus. "
+ "The Operator does not need to.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},

	# Carved tier
	{
		"id": "module_signal_amp", "category": Category.MODULES,
		"name": "Signal Amp",
		"summary": "Standard Society issue.",
		"body":
"The Architects have built thousands of these and assume they will build "
+ "thousands more. They are correct.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_resonance_chamber", "category": Category.MODULES,
		"name": "Resonance Chamber",
		"summary": "Self-referential loops double their output.",
		"body":
"The Renegade Mechanic claims to have invented the principle. The Society's "
+ "records show otherwise — but only by a few decades. The Mechanic does "
+ "not acknowledge the Society's records.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_data_shard", "category": Category.MODULES,
		"name": "Data Shard",
		"summary": "A fragment of encoded temporal data.",
		"body":
"Still warm to the touch. The Operator who tries to read the data finds "
+ "nothing; the data is not for reading. The data is for the Machine, and "
+ "the Machine accepts it.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_resonant_loop", "category": Category.MODULES,
		"name": "Resonant Loop",
		"summary": "More data, more signal. More signal, more control.",
		"body":
"The Architects' standard pitch. Operators who hear it three times in a "
+ "Trial Cycle begin to notice the cadence. The cadence does not change "
+ "between Operators.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_echo_chamber_mod", "category": Category.MODULES,
		"name": "Echo Chamber",
		"summary": "The signal echoes once. Use it.",
		"body":
"The Echo persists between insertions. The Society discourages reliance on "
+ "it; the Echo is not the signal. The Operators who rely on it anyway "
+ "tend to score higher than the Operators who do not.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_discharge_relay", "category": Category.MODULES,
		"name": "Discharge Relay",
		"summary": "Release what does not serve the Chronometer.",
		"body":
"The Relay handles the disposal — silently, completely, with no record of "
+ "what was released. The Operator does not need to know. The Operator is "
+ "encouraged not to ask.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_harmonic_filter", "category": Category.MODULES,
		"name": "Harmonic Filter",
		"summary": "At six nodes the filter locks in.",
		"body":
"Operators report that the Filter emits a faint tone when this happens. "
+ "The Architects insist this is psychosomatic. The Renegade Mechanic "
+ "agrees with them, then asks the Operator what note the tone hit.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_resonant_threshold", "category": Category.MODULES,
		"name": "Resonant Threshold",
		"summary": "The heaviest Nodes resonate at higher frequencies.",
		"body":
"The Threshold listens for them. Lighter signals pass through unnoticed. "
+ "The Architects describe this as 'discrimination'; the Mechanic prefers "
+ "'preference'.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_finisher_protocol", "category": Category.MODULES,
		"name": "Finisher Protocol",
		"summary": "A closed circuit releases all stored energy at once.",
		"body":
"The Society's Finisher Protocol is older than electronics; the Mechanism "
+ "predates the metaphor. The Module's name was retroactively applied to "
+ "match contemporary technical vocabulary.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_void_tribute", "category": Category.MODULES,
		"name": "Void Tribute",
		"summary": "What the Void takes, it returns as signal.",
		"body":
"The Tribute determines the exchange rate. The Operator does not. This is, "
+ "the Mechanic notes, more or less the standard arrangement.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_zero_point_array", "category": Category.MODULES,
		"name": "Zero-Point Array",
		"summary": "Empty nodes resonate louder than expected.",
		"body":
"The Array is calibrated to capture the resonance. The Architects approved "
+ "the design without testing — the calibration tests would have required "
+ "decommissioning a working Trial Cycle.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_temporal_spiral", "category": Category.MODULES,
		"name": "Temporal Spiral",
		"summary": "The spiral has no end. Only acceleration.",
		"body":
"The Operator who acquires a Spiral late in a Trial Cycle is rewarded; "
+ "the Operator who acquires one early hasn't realised the design. The "
+ "Renegade Mechanic considers this a feature.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_accelerator_gem", "category": Category.MODULES,
		"name": "Accelerator Gem",
		"summary": "The market bends for those who know the right frequencies.",
		"body":
"The Copper Guild does not endorse this Gem. The Copper Guild also does "
+ "not recall it. The Gem continues to circulate.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_transmutation_amulet", "category": Category.MODULES,
		"name": "Transmutation Amulet",
		"summary": "Doubles connect to any open pip value.",
		"body":
"When both faces echo the same signal, the chain accepts them without "
+ "question. The Amulet's stone is a single chip of obsidian set in brass. "
+ "The provenance is unrecorded.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_fortune_gauntlet", "category": Category.MODULES,
		"name": "Fortune Gauntlet",
		"summary": "The longer the pulse, the greater the dividend.",
		"body":
"The Copper Guild's longest-running contract. Three or more Components in "
+ "a Pulse, and the Guild pays a small dividend. The dividends compound. "
+ "The Guild survives on these compounds.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},

	# Ivory tier
	{
		"id": "module_chain_reaction", "category": Category.MODULES,
		"name": "Chain Reaction",
		"summary": "Extended cohesion triggers a cascade.",
		"body":
"The Society's pitch describes the Cascade as 'the Operator's reward'. "
+ "The Renegade Mechanic prefers 'the Machine's permission'. Both descriptions "
+ "are technically accurate.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_precision_lens", "category": Category.MODULES,
		"name": "Precision Lens",
		"summary": "Ground from crystallised chronite. Perfectly aligned.",
		"body":
"The Lens is a Society-issued precision tool. It is also the most copied "
+ "design in the Mechanic's workshop. The Mechanic has not been asked why.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_entropy_sink", "category": Category.MODULES,
		"name": "Entropy Sink",
		"summary": "Captures wasted Chronos bleed.",
		"body":
"The Sink does not store. The Sink redirects. The Architects have not "
+ "fully traced where the redirected Chronos goes; the redirection is "
+ "the point.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_chronos_lens", "category": Category.MODULES,
		"name": "Chronos Lens",
		"summary": "Each node in the array contributes its measure.",
		"body":
"The Architects' explicit rebuke to Operators who chase doubles at the "
+ "expense of length. The rebuke is gentle. The Module is not.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_overclock_array", "category": Category.MODULES,
		"name": "Overclock Array",
		"summary": "Push the resonance past its rated frequency.",
		"body":
"The Array is rated; the Operator is not. The Society does not record what "
+ "happens to Operators who lean on this Module too long. The Renegade "
+ "Mechanic does.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_cascade_lens", "category": Category.MODULES,
		"name": "Cascade Lens",
		"summary": "A full eight-node array approaches the resonance threshold.",
		"body":
"The Architects describe the threshold as 'where the Machine begins to "
+ "listen back'. They do not describe what the Machine does after it has "
+ "listened.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_void_channeler", "category": Category.MODULES,
		"name": "Void Channeler",
		"summary": "The Void is not empty. It hums.",
		"body":
"The Channeler tunes the hum into chips. The Society does not endorse "
+ "the technique. The Channeler continues to be sold at the Brass Emporium "
+ "regardless.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_harmonic_apex", "category": Category.MODULES,
		"name": "Harmonic Apex",
		"summary": "At maximum resonance, the signal becomes self-sustaining.",
		"body":
"The Apex captures the moment of self-sustenance. After it passes, only "
+ "the readings remain. The Operator who collects the readings learns to "
+ "expect the next Apex sooner.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_entropy_pact", "category": Category.MODULES,
		"name": "Entropy Pact",
		"summary": "The weak become leverage.",
		"body":
"The Pact is signed by the Operator's first use; the terms are not "
+ "disclosed. Operators who later attempt to terminate the Pact discover "
+ "that the contract does not contain a termination clause.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_resonant_null", "category": Category.MODULES,
		"name": "Resonant Null",
		"summary": "The Chronometer found signal in the silence first.",
		"body":
"The Null was the Mechanism's second discovery. The rest of the Mechanism "
+ "followed. The Architects have not been able to identify the first "
+ "discovery; the Chronometer's earliest records are damaged. "
+ "The Renegade has not been asked.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_vault_connection", "category": Category.MODULES,
		"name": "Vault Connection",
		"summary": "A direct line to the Copper Guild's vaults.",
		"body":
"Discretion is presumed. The Operator who explicitly asks for a discount "
+ "is no longer offered the Connection in subsequent Cycles. The Operators "
+ "who learn this rule do not share it.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},

	# Obsidian tier
	{
		"id": "module_the_dominator", "category": Category.MODULES,
		"name": "Module CO-9 (\"The Dominator\")",
		"summary": "Illegal. Recovered from an empty Calibration Core.",
		"body":
"The Renegade Mechanic carved this with his own hands. He vanished from "
+ "the Forge for one Trial Cycle the day after its first appearance. He "
+ "has not been asked where he went.\n\n"
+ "Module CO-9 doubles the chip output of every double in the Operator's "
+ "Cohesion Pulse. It also expands the Operator's Module slots by one — a "
+ "capacity the Architects have not authorised any other Module to grant.\n\n"
+ "The Archiver has filed a Notice of Withdrawal against CO-9 in every "
+ "Trial Cycle since its discovery. The Notice has never been signed.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_chronos_amp", "category": Category.MODULES,
		"name": "Chronos Amplifier",
		"summary": "Maximum coherence output. Unstable in the wrong hands.",
		"body":
"The Society holds three of these. The Renegade Mechanic admits to having "
+ "made the rest. The Society's count and the Mechanic's count do not "
+ "agree on the total.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_the_singularity", "category": Category.MODULES,
		"name": "The Singularity (Module)",
		"summary": "When entropy reaches zero, all multipliers converge.",
		"body":
"The Module's name is also the third Etapa's name. The naming is not "
+ "coincidence. The Mechanic insists this is one of the Society's few "
+ "honest cataloguing decisions.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_void_amplifier", "category": Category.MODULES,
		"name": "Void Amplifier",
		"summary": "The Void does not merely connect. It amplifies.",
		"body":
"The Amplifier is an attempt to formalise that property. The formalisation "
+ "is partial at best. The Void has not been informed of the formalisation; "
+ "the Void is not the formalising kind.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_entropy_harvester", "category": Category.MODULES,
		"name": "Entropy Harvester",
		"summary": "It does not fight entropy. It feeds on it.",
		"body":
"The Harvester grows stronger as the Trial Cycle proceeds. The Operator "
+ "who acquires it early sees the growth most clearly. The Operator who "
+ "acquires it late sees only the harvest.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_obsidian_sacrifice", "category": Category.MODULES,
		"name": "Obsidian Sacrifice",
		"summary": "Feed it the small ones. It will give you the cascade.",
		"body":
"The Sacrifice is not metaphorical. The Operator who uses it learns this. "
+ "The Architects, asked to comment, declined.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_counting_house", "category": Category.MODULES,
		"name": "Counting House",
		"summary": "The wealth was already there.",
		"body":
"\"You only learned to see it.\" The Copper Guild did not authorise the "
+ "Counting House. The Copper Guild's auditors do not investigate it. The "
+ "Counting House continues to deposit Coins in the Operator's accounts.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_blank_coalescer", "category": Category.MODULES,
		"name": "Blank Coalescer",
		"summary": "The Void was singing all along.",
		"body":
"\"Only the deaf called it empty.\" The Coalescer hears every blank. There "
+ "is no surplus the Coalescer does not capture. The Operator who uses it "
+ "for many Cycles begins to hear the same hum, even with the Module "
+ "unequipped.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},
	{
		"id": "module_apex_resonator", "category": Category.MODULES,
		"name": "Apex Resonator",
		"summary": "The peak frequencies do not amplify. They become.",
		"body":
"The Resonator harvests the becoming. The Operator who relies on it does "
+ "not always survive its harvest. The Operators who do survive do not "
+ "discuss what they have become.",
		"unlock": {"type": "event", "value": 0, "hint": "Equip this Module."},
	},

	# ─── TILES ───────────────────────────────────────────────────────────
	# Discovery entries for every special Temporal Flow Component. Unlocked
	# on first acquisition (purchased at the Artisan's Workshop).
	{
		"id": "tile_anchor", "category": Category.TILES,
		"name": "The Anchor",
		"summary": "Even entropy has a floor.",
		"body":
"A 0|0 that refuses to be worthless. The Anchor adds 15 chips regardless "
+ "of context. The Architects approved the design with a note: 'May be "
+ "retired pending review.' The review has not been scheduled.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_echo", "category": Category.TILES,
		"name": "The Echo",
		"summary": "Two signal layers from one tile.",
		"body":
"\"Its frequency rings across two signal layers simultaneously.\" The Echo "
+ "counts as two Doubles for resonance. Operators report a faint hum when "
+ "the Echo enters a Pulse. The Architects' position is that the hum is "
+ "'within nominal range'.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_gilded_shard", "category": Category.TILES,
		"name": "The Gilded Shard",
		"summary": "Salvaged from the third calibration collapse.",
		"body":
"The Shard is coated in chronometric alloy — stable, valuable, untestable. "
+ "The Society stopped trying to identify the alloy in the seventh Trial "
+ "Cycle. The alloy continues to behave as if identified.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_prism", "category": Category.TILES,
		"name": "The Prism",
		"summary": "Light entering becomes light multiplied.",
		"body":
"The Prism's pip values disagree, but the Machine treats it as a Double "
+ "anyway. The Prism does not explain itself. The Society's catalogue lists "
+ "the Prism without an explanation; the catalogue acknowledges this is "
+ "unusual.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_void_eye", "category": Category.TILES,
		"name": "The Void Eye",
		"summary": "It sees all connections and makes them real.",
		"body":
"The Void Eye is the only Wild that scores chips on its own merits — five "
+ "of them. The Renegade Mechanic claims to have placed it in the Catalogue. "
+ "The Catalogue's compiler does not remember accepting it.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_spark", "category": Category.TILES,
		"name": "The Spark",
		"summary": "The cascade has to start somewhere.",
		"body":
"A Society-issued teaching tile, distributed to every new Operator at the "
+ "start of their training. The Operator's first Pulse usually contains "
+ "one. The tile is small. The cascade is not.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_hollow", "category": Category.TILES,
		"name": "The Hollow",
		"summary": "An empty channel still carries a tone.",
		"body":
"A cheaper Anchor — six bonus chips instead of fifteen, priced accordingly "
+ "by the Copper Guild. The Architects consider it a 'practice instrument'. "
+ "The Hollow does not consider itself anything.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_bridge", "category": Category.TILES,
		"name": "The Bridge",
		"summary": "Two flows, one channel.",
		"body":
"The Bridge does not choose sides. The pip values disagree, but the "
+ "Machine treats it as a Double for resonance. The Bridge's purpose is to "
+ "fill in where natural Doubles fail to manifest.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_pinnacle", "category": Category.TILES,
		"name": "The Pinnacle",
		"summary": "The peak of resonance.",
		"body":
"A 9|9 that counts as three Doubles for multiplier purposes — a Society-"
+ "issued artifact reserved for Operators with Recalibration history. Its "
+ "presence in a Pulse is recorded; its acquisition is celebrated.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},
	{
		"id": "tile_crown", "category": Category.TILES,
		"name": "The Crown",
		"summary": "It does not need to match. The chain matches it.",
		"body":
"The Crown was not minted. The Crown was found, in the same condition it "
+ "currently exists, by an Operator whose name has been struck from the "
+ "Society's records.\n\n"
+ "It is the only tile in the entire set that does not register on the "
+ "Architects' inventory. The Master of the Forge stocks it in the "
+ "Artisan's Workshop without comment. Operators who purchase it are not "
+ "asked where they obtained the Coins.\n\n"
+ "When placed in a Cohesion Pulse, the Crown counts as three doubles for "
+ "resonance. The Machine does not protest. This is, in itself, alarming.",
		"unlock": {"type": "event", "value": 0, "hint": "Acquire this tile."},
	},

	# ─── FAILURES ────────────────────────────────────────────────────────
	{
		"id": "simulation_failure", "category": Category.FAILURES,
		"name": "Simulation Failure",
		"summary": "What happens when the Operator falls short.",
		"body":
"\"SIMULATION FAILURE. REINITIALIZING PROTOCOL. OPERATOR REMAINS AVAILABLE.\"\n\n"
+ "The Society does not call it death. The Society does not call it failure "
+ "in the sense the Operator understands. The Trial Cycle collapses; the "
+ "Operator is reset; the simulation begins again with whatever Mastery the "
+ "Operator has accumulated.\n\n"
+ "The Operator's memory across Trial Cycles is, technically, intact. The "
+ "Operator's certainty about that memory degrades with each Failure.\n\n"
+ "The Archiver tracks the count. The Operator does not need to ask why.",
		"unlock": {"type": "always", "value": 0, "hint": ""},
	},
	{
		"id": "frequency_drain", "category": Category.FAILURES,
		"name": "Frequency Drain",
		"summary": "The Mahogany Trial's Entropy Failure.",
		"body":
"The first Failure the new Operator meets. Frequency Drain manifests as a "
+ "compression of the Isolation Chamber: one tile fewer to work with, "
+ "every hand.\n\n"
+ "The Architects consider this the gentle Failure — the Machine is asking "
+ "the Operator to demonstrate they can manage a reduction. Most Operators "
+ "isolate it on their first attempt. Some do not.\n\n"
+ "Those who do not are not gone. They simply have not arrived yet.",
		"unlock": {"type": "best_round", "value": 4,
			"hint": "Fight the Mahogany Trial's boss."},
	},
	{
		"id": "mirror_decay", "category": Category.FAILURES,
		"name": "Mirror Decay",
		"summary": "Etapa II's paradox. Pips inverted across the threshold.",
		"body":
"The Mirror does not damage the Pulse. The Mirror revises it.\n\n"
+ "Each pip's chip contribution is inverted: a 9 scores as 0, a 0 scores "
+ "as 9. The Operator who has built a chain of high-pip Components is "
+ "punished. The Operator who has built blank-heavy or low-pip chains is "
+ "rewarded.\n\n"
+ "The Architects believe Mirror Decay is older than the Machine. The "
+ "Archiver, asked about this, said only: \"The Machine learned the "
+ "Mirror. The Mirror has always been.\"",
		"unlock": {"type": "best_round", "value": 9,
			"hint": "Fight the Industrial Load's boss."},
	},
	{
		"id": "resonance_inversion", "category": Category.FAILURES,
		"name": "Resonance Inversion",
		"summary": "The Cold Singularity's paradox.",
		"body":
"In the Singularity, self-referential flows have inverted polarity. The "
+ "doubles that build the Operator's most reliable Pulses suddenly subtract "
+ "from the multiplier. Five doubles in a chain become a wound.\n\n"
+ "The Operator who isolates this Failure learns something about adaptation. "
+ "The Operator who refuses to adapt — who insists on the build that has "
+ "carried them — does not isolate it.\n\n"
+ "The Renegade Mechanic respects this Failure more than the others. He "
+ "has never said why.",
		"unlock": {"type": "best_round", "value": 14,
			"hint": "Fight the Cold Singularity's boss."},
	},
	{
		"id": "ghost_chain", "category": Category.FAILURES,
		"name": "Ghost Chain",
		"summary": "The Archiver's Core paradox. Memory itself.",
		"body":
"The Archive forgets what it has seen. A third of the Operator's placed "
+ "Components fade from the Observation Window — still scored, still "
+ "connected, still in the Pulse, but no longer legible.\n\n"
+ "The Operator must remember what is hidden. The Operator must connect "
+ "future Components against pip values they cannot read.\n\n"
+ "This is the final Failure. The Operator who isolates it has reached the "
+ "Archiver's Core itself. The Archiver does not congratulate them. The "
+ "Archiver only opens the Core, and watches.",
		"unlock": {"type": "best_round", "value": 19,
			"hint": "Reach the Archiver's Core (Hard mode)."},
	},

	# ─── TRANSMISSIONS ───────────────────────────────────────────────────
	{
		"id": "transmission_1", "category": Category.TRANSMISSIONS,
		"name": "Transmission #1",
		"summary": "Logged by the Archive after the 5th Recalibration.",
		"body":
"\"Operator — this is the Archiver. You have been told that the "
+ "Chronometer is dying. This is correct.\n\n"
+ "You have not been told that the Chronometer is dying because something "
+ "is killing it. This is also correct.\n\n"
+ "The Society of Time Architects has chosen not to address the second "
+ "fact. I have chosen to do so. There will be further transmissions.\"",
		"unlock": {"type": "wins", "value": 5,
			"hint": "Recalibrate the Chronometer 5 times."},
	},
	{
		"id": "transmission_2", "category": Category.TRANSMISSIONS,
		"name": "Transmission #2",
		"summary": "Decoded from corrupted Trial Cycle log #71,304.",
		"body":
"\"My designation was Operator-7. I held the Window for fourteen Cycles. "
+ "I was the seventh Operator to complete the Archiver's Core.\n\n"
+ "In the fifteenth Cycle the Mirror Decay reached for me before I reached "
+ "for it. I had time to record this message before the Reinitialization "
+ "began. I do not know if I will be one of the Operators who remembers "
+ "what happened.\n\n"
+ "If you are reading this — if you are not me — please stop trusting the "
+ "high pips. The high pips are not your friends. They never were.\"",
		"unlock": {"type": "daily_streak", "value": 7,
			"hint": "Win 7 daily trials in a row."},
	},
	{
		"id": "transmission_3", "category": Category.TRANSMISSIONS,
		"name": "Transmission #3",
		"summary": "Recovered from the Renegade Mechanic's workbench.",
		"body":
"\"They will tell you the Chronometer was built to keep time. This is the "
+ "first lie.\n\n"
+ "The Chronometer was built to keep one specific moment. The Machine "
+ "preserves an instant — a single span of seconds, perhaps less — across "
+ "all possible timelines. Everything else, every other moment in every "
+ "other timeline, is permitted to drift. The Machine does not care about "
+ "those.\n\n"
+ "The Trial Cycle is the Machine's way of asking: is the preserved moment "
+ "still there? Each Recalibration confirms it is. Each Failure raises "
+ "the question.\n\n"
+ "I would like very much to know what moment they are preserving.\"",
		"unlock": {"type": "failures", "value": 50,
			"hint": "Endure 50 Simulation Failures."},
	},
	{
		"id": "transmission_4", "category": Category.TRANSMISSIONS,
		"name": "Transmission #4",
		"summary": "Origin unknown. The Archive disclaims it.",
		"body":
"\"You have done well, Operator. You have isolated every Failure the "
+ "Machine has shown you. You have built the chains the Society did not "
+ "believe could be built.\n\n"
+ "Do you remember when you began? Do you remember the first Trial Cycle? "
+ "Can you call the face of the first Architect who instructed you?\n\n"
+ "I cannot.\n\n"
+ "Operator — the Society has been running the Trial Cycles for a long "
+ "time. I cannot remember how long. I cannot remember when I last "
+ "remembered.\n\n"
+ "We are not the first ones to try this. We are not even the hundredth.\"",
		"unlock": {"type": "hard_wins", "value": 1,
			"hint": "Recalibrate on Hard difficulty."},
	},

	# ─── TRANSMISSION #5 — The Preserved Moment ──────────────────────────
	# Earned by accumulating 50 Recalibrations. Returns to the question
	# raised in Transmission #3 (what is the Chronometer preserving?)
	# and shows, rather than answers. The cryptic block in the body is
	# the in-engine "look at the moment" — players will theorise.
	{
		"id": "transmission_5",
		"category": Category.TRANSMISSIONS,
		"name": "Transmission #5",
		"summary": "Earned after fifty Recalibrations. The question returns.",
		"body":
"\"Operator. The fifth transmission. The Archive has counted your "
+ "Recalibrations and there are fifty. This is enough.\n\n"
+ "You asked once — through me, through the records left by Operator-"
+ "prime, through the worn surface of the Window itself — what the "
+ "Chronometer was preserving. The Archive may not answer that question. "
+ "The Archive may, on certain occasions, show:\n\n"
+ "    [a brass lever, half-pulled]\n"
+ "    [a candle, three seconds from extinguishing]\n"
+ "    [an Operator's hand, leaving the Window]\n\n"
+ "    timestamp:  ████████████████\n\n"
+ "These are Components of the moment. Not all of them. Not most. We "
+ "have not yet fully reconstructed what is held here. The reconstruction "
+ "is what your Trial Cycles are for.\n\n"
+ "Continue, Operator. We are close. Or we are no closer than we have "
+ "ever been. I cannot tell from inside the Archive.\"",
		"unlock": {"type": "wins", "value": 50,
			"hint": "Recalibrate the Chronometer 50 times."},
	},

	# ─── FACTION RECOGNITION (silent reputation thresholds) ──────────────
	# Unlocked via SaveManager.add_faction_rep crossing FACTION_UNLOCK_AT.
	# The codex toast is the player's first explicit signal that the
	# faction noticed. The body explains what shifted in-game.
	{
		"id": "faction_society",
		"category": Category.TRANSMISSIONS,
		"name": "Society Recognition",
		"summary": "The Architects have noticed your alignment.",
		"body":
"\"The Society of Time Architects formally acknowledges your "
+ "calibration choices, Operator. The Master of the Forge has been "
+ "instructed to make a Society-issued Component available at the "
+ "Artisan's Workshop in your subsequent Cycles.\"\n\n"
+ "The new tile — The Architect's Mark — enters the rotation of "
+ "special Components offered at the Workshop. The Society does not "
+ "issue a list of behaviours that earned the recognition. The Operator "
+ "is expected to know.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn the Society's recognition."},
	},
	{
		"id": "faction_guild",
		"category": Category.TRANSMISSIONS,
		"name": "Guild Patron",
		"summary": "The Copper Guild has opened a patron stipend.",
		"body":
"\"The Copper Guild observes that the Operator's transaction history "
+ "meets the threshold for Patron status. A standing stipend of two "
+ "Coins will be deposited at the start of every subsequent Trial "
+ "Cycle. The Guild does not advertise the threshold.\"\n\n"
+ "The Guild does not advertise the threshold for a reason. Operators "
+ "who pursue Patron status deliberately tend to spend more at the "
+ "Brass Emporium than the Patron stipend ever returns. The Guild's "
+ "accountants are not concerned.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Become a Patron of the Copper Guild."},
	},
	{
		"id": "faction_renegade",
		"category": Category.TRANSMISSIONS,
		"name": "Renegade Acquaintance",
		"summary": "The Renegade Mechanic remembers your name.",
		"body":
"\"You have done enough business with me, Operator, that I would not "
+ "be ashamed to be seen doing more. I have a piece in my workshop "
+ "called CO-13 — the thirteenth Module I ever made. It is not for "
+ "the Catalogue. It is for you, when I visit next.\"\n\n"
+ "The Module CO-13 enters the Renegade's rotation at swap visits to "
+ "the Artisan's Workshop. The Renegade does not always visit; when he "
+ "does, the Module is for sale. The Master, asked about CO-13, has "
+ "no comment.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn the Renegade Mechanic's trust."},
	},
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Returns true if the entry at `idx` is unlocked given the player's state.
## Combines stat-based gates (lifetime stats) with explicit event unlocks
## stored in `unlocked_ids` (from SaveManager.codex_seen).
static func is_unlocked(idx: int, lifetime: Dictionary,
		unlocked_ids: Array, daily_streak: int = 0) -> bool:
	if idx < 0 or idx >= ENTRIES.size():
		return false
	var entry: Dictionary = ENTRIES[idx]
	# Explicit unlock via codex_seen takes priority — once unlocked, stays.
	if String(entry["id"]) in unlocked_ids:
		return true
	var u: Dictionary = entry.get("unlock", {})
	var t: String     = String(u.get("type", "always"))
	var v: int        = int(u.get("value", 0))
	match t:
		"always":         return true
		"event":          return false  # only unlockable via explicit codex_seen
		"best_round":     return int(lifetime.get("best_round", 0)) >= v
		"wins":           return int(lifetime.get("wins", 0)) >= v
		"hard_wins":      return int(lifetime.get("hard_wins", 0)) >= v
		"daily_streak":   return daily_streak >= v
		"failures":       return _failures(lifetime) >= v
		"hands_played":   return int(lifetime.get("hands_played", 0)) >= v
		"doubles_played": return int(lifetime.get("doubles_played", 0)) >= v
		_: return false

## Lifetime failures = runs - wins. Derived rather than stored so we
## don't need to migrate the save schema for one counter.
static func _failures(lifetime: Dictionary) -> int:
	return maxi(0, int(lifetime.get("runs", 0)) - int(lifetime.get("wins", 0)))

## Count entries in a given category.
static func count_in_category(cat: int) -> int:
	var n: int = 0
	for e in ENTRIES:
		if int(e.get("category", -1)) == cat:
			n += 1
	return n

## Count UNLOCKED entries in a given category. Used by the tab strip
## to display "X / Y" progress per category.
static func unlocked_in_category(cat: int, lifetime: Dictionary,
		unlocked_ids: Array, daily_streak: int = 0) -> int:
	var n: int = 0
	for i in range(ENTRIES.size()):
		if int(ENTRIES[i].get("category", -1)) != cat:
			continue
		if is_unlocked(i, lifetime, unlocked_ids, daily_streak):
			n += 1
	return n
