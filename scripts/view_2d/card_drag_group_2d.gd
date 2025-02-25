@tool
class_name CardDragGroup
extends Node2D

const Z_INDEX_INCR: int = 100

var _cards: Array[Card2D]
var _card_offsets: Array[Vector2]
var _mouse_offset: Vector2
var _pickup_position: Vector2
var _pickup_z_index: int
var _touching_cells: Array[CardPile2D]
var _closest_touching_cell: CardPile2D = null

func _init(cards: Array[Card2D]) -> void:
	_set_cards(cards)
	
func num_cards() -> int:
	return _cards.size()
	
func get_cards() -> Array[Card]:
	var c: Array[Card]
	for card in _cards:
		c.push_back(card.model() as Card)
	return c
	
func _set_cards(cards) -> void:
	assert(not cards.is_empty())
	_cards = cards
	_head().connect("body_entered", _on_head_card_body_entered)
	_head().connect("body_exited", _on_head_card_body_exited)
	_head().get_parent().add_child(self, true)
	_head().play_pickup_sound()
	_mouse_offset = _head().position - get_local_mouse_position()
	for card in _cards:
		_card_offsets.push_back(card.position - _head().position)
	_pickup_position = _head().position
	_pickup_z_index = _head().z_index
	_set_cards_z_index(cards, Z_INDEX_INCR)
	for card in get_cards():
		card.add_to_group(Groups.DRAGGING_CARDS)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		_on_click_release()
	if event is InputEventMouseMotion:
		_follow_cursor()
		
func _on_click_release() -> void:
	if _closest_touching_cell:
		_closest_touching_cell.drop_cards(self)
	else:
		cancel_drag()
	_head().play_drop_sound()
	for card in get_cards():
		card.remove_from_group(Groups.DRAGGING_CARDS)
	self.queue_free()

func _follow_cursor() -> void:
	_update_position(to_local(get_global_mouse_position()))
	_update_closest_cell()
	
func _update_position(target: Vector2) -> void:
	for i in range(_cards.size()):
		_cards[i].position = target + _card_offsets[i] + _mouse_offset
		
func _update_closest_cell() -> void:
	for cell in _touching_cells:
		cell.unhighlight()
	_closest_touching_cell = _compute_closest_touching_cell()
	if _closest_touching_cell:
		_closest_touching_cell.highlight(self)

func _compute_closest_touching_cell() -> CardPile2D:
	var min_dist: float = INF
	var min_cell: CardPile2D = null
	for cell in _touching_cells:
		var dist: float = cell.next_free_global_position() \
							  .distance_squared_to(_head().global_position)
		if dist < min_dist:
			min_dist = dist
			min_cell = cell
	return min_cell
	
func cancel_drag() -> void:
	_move_to(_pickup_position)
	_set_cards_z_index(_cards, -Z_INDEX_INCR)
	
func _move_to(target) -> void:
	for i in range(_cards.size()):
		_cards[i].move_to(target + _card_offsets[i])

func _head() -> Card2D:
	return _cards.front()
	
func _on_head_card_body_entered(body: Node2D) -> void:
	if body is CardPile2D:
		var cell = body as CardPile2D
		if cell.can_drop_cards(self):
			_touching_cells.append(cell)

func _on_head_card_body_exited(body: Node2D) -> void:
	if body is CardPile2D:
		var cell = body as CardPile2D
		cell.unhighlight()
		_touching_cells.erase(cell)
	
func _set_cards_z_index(cards: Array[Card2D], base_z_index: int):
	for card in cards:
		card.z_index += base_z_index
