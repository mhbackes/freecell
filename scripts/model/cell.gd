class_name Cell
extends CardPile

func _init() -> void:
	_max_size = 1
	_max_cards_per_drop = 1
	_order = Order.ASCENDING
	_allow_drop_cards = Sequence.ANY
	_allow_pickup_cards = Sequence.ANY
	_first_card = FirstCard.ANY
	_group = Groups.CELLS
