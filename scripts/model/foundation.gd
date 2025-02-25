class_name Foundation
extends CardPile

func _init() -> void:
	_max_size = 13
	_max_cards_per_drop = 1
	_order = Order.ASCENDING
	_allow_drop_cards = Sequence.COLOR_SEQUENCE
	_allow_pickup_cards = Sequence.COLOR_SEQUENCE
	_first_card = FirstCard.ACE
	_group = Groups.FOUNDATIONS
