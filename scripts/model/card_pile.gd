class_name CardPile
extends Node

signal move_cards_request(cards: Array[Card], from: CardPile, to: CardPile)
signal card_added(card: Card)
signal card_removed(card: Card)
signal picked_up_cards(cards: Array[Card])

enum Sequence { ANY, COLOR_SEQUENCE, ALTERNATE_COLOR_SEQUENCE }
enum Order { ASCENDING, DESCENDING }
enum FirstCard { ANY, ACE }

const MAX_INT: int = 9223372036854775807

var _max_size: int = MAX_INT
var _max_cards_per_drop: int = MAX_INT
var _order: Order = Order.ASCENDING
var _allow_drop_cards: Sequence = Sequence.ANY
var _allow_pickup_cards: Sequence = Sequence.ANY
var _first_card: FirstCard = FirstCard.ANY
var _group: StringName
var _held_cards: Array[Card]


func _ready() -> void:
	add_to_group(Groups.CARD_PILES)
	add_to_group(_group)
	add_to_group(Groups.empty(_group))


func is_empty() -> bool:
	return _held_cards.is_empty()


func top_card() -> Card:
	return _held_cards.back()


func request_add_cards(cards: Array[Card]) -> void:
	assert(not cards.is_empty())
	move_cards_request.emit(cards, cards.front().current_pile(), self)


func add_cards(cards: Array[Card]) -> void:
	for card: Card in cards:
		add_card(card)


func add_card(card: Card) -> void:
	card.change_cell(self)
	_held_cards.append(card)
	if _held_cards.size() == 1:
		add_to_group(Groups.non_empty(_group))
		remove_from_group(Groups.empty(_group))
	if _held_cards.size() == _max_size:
		add_to_group(Groups.full(_group))
	card_added.emit(card)


func remove_top_card() -> void:
	var card: Card = _held_cards.pop_back()
	if _held_cards.is_empty():
		add_to_group(Groups.empty(_group))
		remove_from_group(Groups.non_empty(_group))
	remove_from_group(Groups.full(_group))
	card_removed.emit(card)


func can_drop_card(card: Card) -> bool:
	return can_drop_cards([card])


func can_drop_cards(cards: Array[Card]) -> bool:
	return (
		cards.front().current_pile() != self
		and cards.size() <= _max_cards_per_drop
		and cards.size() + _held_cards.size() <= _max_size
		and can_drop_bottom_card(cards.front())
		and cards.size() <= max_num_cards_moved(true)
	)


func can_drop_bottom_card(card: Card) -> bool:
	if _held_cards.is_empty():
		return _first_card == FirstCard.ANY or card.rank == 1
	var pile_top_card: Card = _held_cards.back()
	var low_card: Card = pile_top_card if _order == Order.ASCENDING else card
	var high_card: Card = card if _order == Order.ASCENDING else pile_top_card
	match _allow_drop_cards:
		Sequence.ANY:
			return true
		Sequence.COLOR_SEQUENCE:
			return Card.is_color_sequence_match(low_card, high_card)
		Sequence.ALTERNATE_COLOR_SEQUENCE:
			return Card.is_alternate_color_sequence_match(low_card, high_card)
	return false


func pickup(card: Card) -> void:
	var start := _held_cards.find(card)
	if start < 0:
		return
	var cards := _held_cards.slice(start)
	if can_pickup(cards):
		picked_up_cards.emit(cards)


func can_pickup(cards: Array[Card]) -> bool:
	if cards.size() > max_num_cards_moved():
		return false
	match _allow_pickup_cards:
		Sequence.ANY:
			return true
		Sequence.COLOR_SEQUENCE:
			return is_pile_color_sequence(cards)
		Sequence.ALTERNATE_COLOR_SEQUENCE:
			return is_pile_alternate_color_sequence(cards)
	return false


func max_num_cards_moved(drop_here: bool = false) -> int:
	var empty_target := drop_here and _held_cards.is_empty() and not is_in_group(Groups.FOUNDATIONS)
	var max_cards_moved: int = (num_empty_cells() + 1) * (2 ** num_empty_cascades() as int)
	@warning_ignore("integer_division")
	return max_cards_moved / 2 if empty_target else max_cards_moved


func is_pile_color_sequence(cards: Array[Card]) -> bool:
	for i in range(cards.size() - 1):
		var low_card := cards[i] if _order == Order.ASCENDING else cards[i + 1]
		var high_card := cards[i + 1] if _order == Order.ASCENDING else cards[i]
		if not Card.is_color_sequence_match(low_card, high_card):
			return false
	return true


func is_pile_alternate_color_sequence(cards: Array[Card]) -> bool:
	for i in range(cards.size() - 1):
		var low_card: Card = cards[i] if _order == Order.ASCENDING else cards[i + 1]
		var high_card: Card = cards[i + 1] if _order == Order.ASCENDING else cards[i]
		if not Card.is_alternate_color_sequence_match(low_card, high_card):
			return false
	return true


func num_empty_cascades() -> int:
	return get_tree().get_node_count_in_group(Groups.EMPTY_CASCADES)


func num_empty_cells() -> int:
	return get_tree().get_node_count_in_group(Groups.EMPTY_CELLS)


func highest_card() -> Card:
	if _held_cards.is_empty():
		return null
	var highest: Card = _held_cards.front()
	for card in _held_cards:
		if card.rank > highest.rank:
			highest = card
	return highest
