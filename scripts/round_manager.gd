## round_manager.gd — Manages state for a single Ronda (round).
## Handles the Isolation Chamber (hand), the active chain,
## hand/discard counters, and Chronos accumulation.
class_name RoundManager
extends RefCounted

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------
signal chain_changed          # chain was modified (tile added or cleared)
signal hand_changed           # hand tiles changed (draw / discard)
signal hand_scored(result: Dictionary)  # a hand was played and scored
signal round_ended(won: bool)           # round finished (hit or missed target)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var box:               Box
var hand:              Array[Domino] = []
var current_chain:     Chain
var round_index:       int  # 0-based
var target:            int
## Total Chronos credited this round.
## Persistent chain model: this is `chain_score(current_chain) + extra_chronos`,
## refreshed each play. It is NOT a sum of per-hand scores.
var chronos:           int
## One-shot bonuses (Gold Talisman, etc.) that survive across plays.
## Added on top of the chain's computed score after each play.
var extra_chronos:     int
var hands_remaining:   int
var discards_remaining: int
var hand_size:         int
var max_hands:         int
var max_discards:      int

## Snapshot of the chain state after the previous play. Used to compute
## per-play deltas (delta_total, delta_length) for stats, ghost UI, and
## threshold-crossing rewards (e.g. CHAIN_COIN_BONUS).
var committed_chain_score:  int = 0
var committed_chain_length: int = 0

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func setup(p_box: Box, p_round_index: int,
		p_hand_size: int    = Constants.DEFAULT_HAND_SIZE,
		p_max_hands: int    = Constants.DEFAULT_HANDS_PER_ROUND,
		p_max_discards: int = Constants.DEFAULT_DISCARDS) -> void:

	box            = p_box
	round_index    = p_round_index
	target         = GameState.adjusted_target(p_round_index)
	hand_size      = p_hand_size
	max_hands      = p_max_hands
	max_discards   = p_max_discards
	hands_remaining    = max_hands
	discards_remaining = max_discards
	chronos        = 0
	extra_chronos  = 0
	committed_chain_score  = 0
	committed_chain_length = 0
	hand           = []
	current_chain  = Chain.new()

	box.replenish()
	_draw_to_full()

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------

## Attempt to move the tile at `hand_index` into the active chain.
## Returns true on success.
func try_add_to_chain(hand_index: int) -> bool:
	if hand_index < 0 or hand_index >= hand.size():
		return false

	var domino: Domino = hand[hand_index]
	if not current_chain.can_add(domino):
		return false

	hand.remove_at(hand_index)
	current_chain.add(domino)
	chain_changed.emit()
	hand_changed.emit()
	return true

## Return the most recently placed tile from the chain back to the hand.
func undo_last_chain_tile() -> bool:
	var tile: Domino = current_chain.undo()
	if tile == null:
		return false
	hand.append(tile)
	chain_changed.emit()
	hand_changed.emit()
	return true

## Score the current persistent chain, deduct one hand charge, draw new tiles.
##
## Persistent-chain model: the chain is NOT cleared between hands. Each call
## re-scores the full chain; `chronos` is set to that score (plus any
## one-shot extras) rather than accumulating. The result dict carries deltas
## so the UI and stat layer can attribute "what this play earned".
##
## Returns the scoring result dict (empty if nothing to play).
func play_chain() -> Dictionary:
	if current_chain.is_empty() or hands_remaining <= 0:
		return {}

	var result: Dictionary = Scoring.calculate(current_chain, GameState.modules)

	# Per-play deltas (what this placement contributed)
	var delta_total:  int = result["total"] - committed_chain_score
	var delta_length: int = result["length"] - committed_chain_length
	result["delta_total"]  = delta_total
	result["delta_length"] = delta_length
	result["prev_length"]  = committed_chain_length

	# Snapshot for next play and update round chronos
	committed_chain_score  = result["total"]
	committed_chain_length = result["length"]
	chronos = result["total"] + extra_chronos
	hands_remaining -= 1

	hand_scored.emit(result)
	# NOTE: chain is NOT cleared — it persists for the rest of the round.
	# We still emit chain_changed so the UI repaints (committed chain only,
	# selection has been consumed by the caller).
	chain_changed.emit()

	_draw_to_full()
	hand_changed.emit()

	if _is_over():
		round_ended.emit(did_win())

	return result

## Discard tiles at the given indices, draw replacements, with TARGETED
## RE-DRAW: for each tile discarded, if the box still contains any tile
## that legally fits the current chain's open ends, one such fit is
## promoted to the top of the draw pile. This way "discard to fish for a
## connection" actually fishes — the player isn't discarding into a
## random redraw under the persistent-chain mechanic.
##
## If the chain is empty (every tile fits) or the box has no fitting
## tiles, behaves like a normal discard with random replacements.
##
## Returns false if no discards remain or indices list is empty.
func discard(indices: Array) -> bool:
	if discards_remaining <= 0 or indices.is_empty():
		return false

	# Remove in descending order to preserve index validity
	var sorted: Array = indices.duplicate()
	sorted.sort()
	sorted.reverse()
	for i in sorted:
		if i >= 0 and i < hand.size():
			hand.remove_at(i)

	discards_remaining -= 1
	_promote_fitting_tiles_to_top(indices.size())
	_draw_to_full()
	hand_changed.emit()
	return true

## Look at the current draw pile and surface up to `count` tiles that fit
## the chain's open ends so they get drawn first. No-op if the chain is
## empty (any tile fits anyway) or the box is empty.
func _promote_fitting_tiles_to_top(count: int) -> void:
	if current_chain == null or current_chain.is_empty() or count <= 0:
		return
	if box == null or box.is_empty():
		return
	# Snapshot the entire draw pile in a randomised order so we don't
	# always promote the same fitting tile from the top.
	var pile: Array = box.peek(box.draw_pile_size())
	pile.shuffle()
	var promoted: int = 0
	for tile in pile:
		if promoted >= count:
			break
		if current_chain.can_add(tile):
			box.promote_to_top(tile)
			promoted += 1

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------
func can_play() -> bool:
	return not current_chain.is_empty() and hands_remaining > 0

func can_discard() -> bool:
	return discards_remaining > 0

func did_win() -> bool:
	return chronos >= target

func is_finished() -> bool:
	return _is_over()

func hands_used() -> int:
	return max_hands - hands_remaining

func unused_hands() -> int:
	return hands_remaining

## Player explicitly locks in the current chain when target is already
## reached, ending the round early and banking remaining hands as the
## per-unused-hand Moneda bonus. No-op if the target hasn't been reached.
func stand() -> bool:
	if chronos < target:
		return false
	# End the round here; preserve hands_remaining so unused-hand monedas
	# count correctly.
	round_ended.emit(true)
	return true

## Consume a hand without playing anything — used when the player has
## no tile that can legally extend the chain and can't fix it via discard
## (e.g. zero discards left, or the box is empty). Prevents softlock.
##
## Decrements hands_remaining, draws back to full, emits the same chain /
## hand-change signals as a normal play, and ends the round if it was
## the last hand.
func pass_hand() -> bool:
	if hands_remaining <= 0:
		return false
	hands_remaining -= 1
	_draw_to_full()
	hand_changed.emit()
	if _is_over():
		round_ended.emit(did_win())
	return true

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------
func _draw_to_full() -> void:
	var needed: int = hand_size - hand.size()
	if needed > 0 and not box.is_empty():
		hand.append_array(box.draw(needed))

## Round naturally ends when the player runs out of hands. The win check
## happens at that point (chronos vs target). The player can also choose
## to stand early once the target is reached (see `stand()`).
func _is_over() -> bool:
	return hands_remaining <= 0

