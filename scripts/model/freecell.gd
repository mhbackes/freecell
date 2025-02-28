class_name Freecell
extends Node

signal cards_moved(cards: Array[Card])
signal victory

var _cards: Array[Card] = _make_cards()
var _cells: Array[Cell] = _make_cells()
var _cascades: Array[Cascade] = _make_cascades()
var _foundations: Array[Foundation] = _make_foundations()
var _undo_redo: UndoRedo = UndoRedo.new()


func _exit_tree() -> void:
	_undo_redo.free()


func get_cards() -> Array[Card]:
	return _cards


func get_cells() -> Array[Cell]:
	return _cells


func get_cascades() -> Array[Cascade]:
	return _cascades


func get_foundations() -> Array[Foundation]:
	return _foundations


func _make_cards() -> Array[Card]:
	var cards: Array[Card]
	for suit: Card.Suit in Card.Suit.values():
		for rank in range(Card.MIN_RANK, Card.MAX_RANK + 1):
			var card := Card.new(rank, suit)
			cards.append(card)
	return cards


func _make_cascades() -> Array[Cascade]:
	var cascades: Array[Cascade]
	for i in range(8):
		var cascade := Cascade.new()
		cascades.append(cascade)
		cascade.move_cards_request.connect(move_cards)
	return cascades


func _make_cells() -> Array[Cell]:
	var cells: Array[Cell]
	for i in range(4):
		var cell := Cell.new()
		cells.append(cell)
		cell.move_cards_request.connect(move_cards)
	return cells


func _make_foundations() -> Array[Foundation]:
	var foundations: Array[Foundation]
	for i in range(4):
		var foundation := Foundation.new()
		foundations.append(foundation)
		foundation.move_cards_request.connect(move_cards)
	return foundations


func shuffle() -> void:
	for i in range(_cards.size()):
		var j := randi_range(i, _cards.size() - 1)
		var tmp := _cards[i]
		_cards[i] = _cards[j]
		_cards[j] = tmp


func deal() -> void:
	for i in range(_cards.size()):
		_cascades[i % _cascades.size()].add_card(_cards[i])


func move_cards(cards: Array[Card], from: CardPile, to: CardPile) -> void:
	_undo_redo.create_action("move_cards")
	_undo_redo.add_do_method(Callable(to, "add_cards").bind(cards))
	_undo_redo.add_undo_method(Callable(from, "add_cards").bind(cards))
	cards_moved.emit(cards)
	_undo_redo.commit_action()


func post_card_move_checks(last_moved_card: Card) -> void:
	if try_to_move_any_to_foundation(last_moved_card):
		return
	if get_tree().get_node_count_in_group(Groups.FULL_FOUNDATIONS) == _foundations.size():
		victory.emit()


func try_to_move_any_to_foundation(last_moved_card: Card) -> bool:
	if get_tree().has_group(Groups.MOVING_CARDS) or get_tree().has_group(Groups.DRAGGING_CARDS):
		return false
	var tree: SceneTree = last_moved_card.get_tree()
	var non_empty_piles := (
		tree.get_nodes_in_group(Groups.NON_EMPTY_CELLS)
		+ tree.get_nodes_in_group(Groups.NON_EMPTY_CASCADES)
	)
	for pile: CardPile in non_empty_piles:
		if pile.top_card() != last_moved_card and try_to_move_to_foundation(pile.top_card()):
			return true
	return false


func try_to_move_to_foundation(card: Card) -> bool:
	for foundation: CardPile in get_tree().get_nodes_in_group(Groups.FOUNDATIONS):
		if foundation.can_drop_card(card):
			move_cards([card], card.current_pile(), foundation)
			card.get_parent().play_slide_sound()
			return true
	return false


func has_undo() -> bool:
	return _undo_redo.has_undo()


func has_redo() -> bool:
	return _undo_redo.has_redo()


func undo_all() -> void:
	while _undo_redo.has_undo():
		_undo_redo.undo()


func undo() -> void:
	_undo_redo.undo()


func redo() -> void:
	_undo_redo.redo()


func redo_all() -> void:
	while _undo_redo.has_redo():
		_undo_redo.redo()
