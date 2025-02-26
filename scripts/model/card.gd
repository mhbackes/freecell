class_name Card
extends Node

enum Suit { CLUBS, DIAMONDS, HEARTS, SPADES }
const MIN_RANK = 1
const MAX_RANK = 13

var suit: Suit
var rank: int
var _current_pile: CardPile = null


func _init(r: int = 1, s: Suit = Suit.CLUBS):
	assert(r >= 1 and r <= 13)
	rank = r
	suit = s


func change_cell(pile: CardPile) -> void:
	if _current_pile:
		_current_pile.remove_top_card()
	_current_pile = pile


func current_pile() -> CardPile:
	return _current_pile


func is_red() -> bool:
	return suit == Suit.HEARTS or suit == Suit.DIAMONDS


func is_black() -> bool:
	return suit == Suit.CLUBS or suit == Suit.SPADES


func _to_string() -> String:
	return str(rank) + str(Suit.keys()[suit])


static func is_color_sequence_match(c: Card, d: Card) -> bool:
	return is_sequence_match(c, d) and c.suit == d.suit


static func is_alternate_color_sequence_match(c: Card, d: Card) -> bool:
	return is_sequence_match(c, d) and !is_same_color(c, d)


static func is_sequence_match(c: Card, d: Card) -> bool:
	return c.rank + 1 == d.rank


static func is_same_color(c: Card, d: Card) -> bool:
	return c.is_red() == d.is_red()
