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
	ANOMALIES,     # rare tiles, illegal modules, paradoxes
	FAILURES,      # boss effects + simulation-failure flavour
	TRANSMISSIONS, # cryptic broadcasts unlocked by milestones
}

const CATEGORY_NAMES: Array[String] = [
	"PEOPLE", "PLACES", "CONCEPTS", "ANOMALIES", "FAILURES", "TRANSMISSIONS",
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
+ "Some Operators have tried to reach what is behind it. None have reported "
+ "what they found.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Visit the Brass Emporium."},
	},
	{
		"id": "renegade_mechanic", "category": Category.PEOPLE,
		"name": "The Renegade Mechanic",
		"summary": "Sells illegal Calibration Modules. Knows more than he admits.",
		"body":
"He runs no shop with a sign. He appears at the Artisan's Workshop after "
+ "every Entropy Failure, the Master of the Forge stepping aside with the "
+ "deliberate silence of someone who has seen this before.\n\n"
+ "His modules — Obsidian-tier work — are not in the Architects' catalogue. "
+ "When asked who made them, he says: \"I made them. I will make others. "
+ "Do not bring them back.\"\n\n"
+ "The Archiver has filed a request for his arrest in every Trial Cycle "
+ "for as long as the records go back. The request is never executed.",
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
+ "selects a special tile to add, the Master examines them — not the tile.\n\n"
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
+ "Monedas — the stable byproducts of successful Trial Cycles — are minted, "
+ "valued, and accepted only by Guild contract. The Society of Time Architects "
+ "tolerates the Guild because the Guild's bookkeeping is the only thing "
+ "preventing the Chronometer's economy from collapsing alongside the Machine.\n\n"
+ "They are not allied with the Operator. They are not enemies. They are "
+ "the wall the simulation runs against.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn your first Monedas."},
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
+ "Archiver does not.",
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
+ "Nobody — not the Architects, not the Archiver, not the Renegade — knows "
+ "what the Chronometer was for, before it began to fail.",
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
+ "Chronos cannot be spent. Only its stable byproducts — Monedas — can.",
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
+ "Cycle: hand size, number of plays, number of discards, opening Monedas.\n\n"
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
		"name": "Monedas",
		"summary": "The Copper Guild's stable currency.",
		"body":
"When a Trial Cycle round completes successfully, the residual Chronos — "
+ "the stable byproduct that cannot be reabsorbed by the Machine — is "
+ "captured by the Copper Guild's contracts and minted into Monedas.\n\n"
+ "The Guild's contracts predate the Society of Time Architects. The "
+ "Architects do not understand them. The Architects pay anyway.\n\n"
+ "Monedas can be spent at the Brass Emporium for Calibration Modules, or "
+ "at the Artisan's Workshop for tile modifications. Unspent Monedas at "
+ "the end of a Cycle are returned to the Guild's vaults. They do not "
+ "carry across Cycles.",
		"unlock": {"type": "event", "value": 0,
			"hint": "Earn your first Monedas."},
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
+ "He has not said by whom.",
		"unlock": {"type": "always", "value": 0,
			"hint": ""},
	},
	{
		"id": "the_crown", "category": Category.ANOMALIES,
		"name": "The Crown",
		"summary": "An Obsidian-tier Wild. A signature.",
		"body":
"The Crown was not minted. The Crown was found, in the same condition it "
+ "currently exists, by an Operator whose name has been struck from the "
+ "Society's records.\n\n"
+ "It is the only tile in the entire set that does not register on the "
+ "Architects' inventory. The Master of the Forge stocks it in the Artisan's "
+ "Workshop without comment. Operators who purchase it are not asked where "
+ "they obtained the Monedas.\n\n"
+ "When placed in a Cohesion Pulse, the Crown counts as three doubles for "
+ "resonance. The Machine does not protest. This is, in itself, alarming.",
		"unlock": {"type": "best_round", "value": 10,
			"hint": "Reach Etapa II."},
	},
	{
		"id": "the_dominator", "category": Category.ANOMALIES,
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
		"unlock": {"type": "best_round", "value": 5,
			"hint": "Reach the Artisan's Workshop."},
	},
	{
		"id": "extra_ends", "category": Category.ANOMALIES,
		"name": "Branch Ends",
		"summary": "Open pip values created by doubles in the Pulse.",
		"body":
"When a double is placed in a Cohesion Pulse, the Machine treats its "
+ "perpendicular faces as new open ends — additional pip values future "
+ "Components may match against. The Architects have catalogued this "
+ "behaviour for centuries and consider it a basic rule of Pulse extension.\n\n"
+ "Branches are not visible in the Cohesion Pulse the same way the main "
+ "chain is visible. They sit slightly outside ordinary spatial intuition. "
+ "The Observation Window represents them as floating badges above the "
+ "Pulse — a representation, not the thing itself.\n\n"
+ "The Renegade Mechanic claims the Machine had Branch logic centuries "
+ "before the rules of dominoes were codified.",
		"unlock": {"type": "best_round", "value": 4,
			"hint": "Place a double in a chain."},
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
