class_name CardPile2D
extends StaticBody2D

enum PileGrowthDirection { STACK, DOWN, UP, LEFT, RIGHT }

@export var pile_growth_direction: PileGrowthDirection
var _card_pile: CardPile
var _pile_offset: Vector2


func _ready() -> void:
	if get_parent() is Control:
		# Note: control nodes only know their global position after rendering the first frame
		call_deferred("_update_shape_when_control_child")
	_pile_offset = compute_pile_offset(pile_growth_direction)


func connect_model(card_pile: CardPile) -> void:
	_card_pile = card_pile
	_card_pile.card_added.connect(_on_card_pile_card_added)
	_card_pile.card_removed.connect(_on_card_pile_card_removed)
	_card_pile.picked_up_cards.connect(_on_card_pile_picked_up_cards)
	add_child(_card_pile, true)


func model() -> CardPile:
	return _card_pile


func _update_shape_when_control_child() -> void:
	var parent_size: Vector2 = get_parent().size
	var viewport_size: Vector2 = get_viewport_rect().size
	var s: float = max(parent_size.x / viewport_size.x, parent_size.y / viewport_size.y)
	self.scale = Vector2(s, s)
	self.global_position = get_parent().get_global_rect().get_center()
	_pile_offset = compute_pile_offset(pile_growth_direction)


func compute_pile_offset(dir: PileGrowthDirection) -> Vector2:
	var pile_offset_x: float = $Highlight.texture.get_width() * .12 / scale.x
	var pile_offset_y: float = $Highlight.texture.get_height() * .12 / scale.y
	match dir:
		PileGrowthDirection.STACK:
			return Vector2.ZERO
		PileGrowthDirection.DOWN:
			return Vector2(0, pile_offset_y)
		PileGrowthDirection.UP:
			return Vector2(0, -pile_offset_y)
		PileGrowthDirection.LEFT:
			return Vector2(-pile_offset_x, 0)
		PileGrowthDirection.RIGHT:
			return Vector2(pile_offset_x, 0)
	return Vector2.ZERO


func next_free_position() -> Vector2:
	return $Highlight.position


func next_free_global_position() -> Vector2:
	return $Highlight.global_position


func highlight(g: CardDragGroup) -> void:
	if can_drop_cards(g):
		$Highlight.show()


func can_drop_cards(g: CardDragGroup) -> bool:
	return _card_pile.can_drop_cards(g.get_cards())


func drop_cards(g: CardDragGroup) -> void:
	unhighlight()
	_card_pile.request_add_cards(g.get_cards())


func unhighlight() -> void:
	$Highlight.hide()


func _on_card_pile_card_added(card: Card) -> void:
	var card2d: Card2D = card.get_parent()
	card2d.z_index = $Highlight.z_index
	card2d.reparent(self)
	card2d.move_to(next_free_position())
	card2d.scale = Vector2(1, 1)
	$Highlight.position += _pile_offset
	$CollisionShape2D.position += _pile_offset
	$Highlight.z_index += 1


func _on_card_pile_card_removed(_card: Card) -> void:
	$Highlight.position -= _pile_offset
	$CollisionShape2D.position -= _pile_offset
	$Highlight.z_index -= 1


func _on_card_pile_picked_up_cards(cards: Array[Card]) -> void:
	var cards2d: Array[Card2D]
	for card in cards:
		if card.is_in_group(Groups.MOVING_CARDS):
			return
		cards2d.push_back(card.get_parent() as Card2D)
	CardDragGroup.new(cards2d)


func disable_pickup() -> void:
	if _card_pile.picked_up_cards.is_connected(_on_card_pile_picked_up_cards):
		_card_pile.picked_up_cards.disconnect(_on_card_pile_picked_up_cards)


func enable_pickup() -> void:
	if not _card_pile.picked_up_cards.is_connected(_on_card_pile_picked_up_cards):
		_card_pile.picked_up_cards.connect(_on_card_pile_picked_up_cards)
