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
var chronos:           int  # accumulated this round
var hands_remaining:   int
var discards_remaining: int
var hand_size:         int
var max_hands:         int
var max_discards:      int

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

## Score the current chain, deduct one hand charge, draw new tiles.
## Returns the scoring result dict (empty dict if no chain to play).
func play_chain() -> Dictionary:
	if current_chain.is_empty() or hands_remaining <= 0:
		return {}

	var result: Dictionary = Scoring.calculate(current_chain, GameState.modules)
	chronos += result["total"]
	hands_remaining -= 1

	current_chain.clear()
	chain_changed.emit()
	hand_scored.emit(result)

	_draw_to_full()
	hand_changed.emit()

	if _is_over():
		round_ended.emit(did_win())

	return result

## Discard tiles at the given indices (into the box), draw replacements.
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
	_draw_to_full()
	hand_changed.emit()
	return true

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

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------
func _draw_to_full() -> void:
	var needed: int = hand_size - hand.size()
	if needed > 0 and not box.is_empty():
		hand.append_array(box.draw(needed))

func _is_over() -> bool:
	return hands_remaining <= 0 or chronos >= target

