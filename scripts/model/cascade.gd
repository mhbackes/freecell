class_name Cascade
extends CardPile

func _init() -> void:
	_max_size = MAX_INT
	_max_cards_per_drop = MAX_INT
	_order = Order.DESCENDING
	_allow_drop_cards = Sequence.ALTERNATE_COLOR_SEQUENCE
	_allow_pickup_cards = Sequence.ALTERNATE_COLOR_SEQUENCE
	_first_card = FirstCard.ANY
	_group = Groups.CASCADES
