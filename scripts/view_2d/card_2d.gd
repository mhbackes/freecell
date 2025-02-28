@tool
class_name Card2D
extends Area2D

signal move_finished(card: Card)

const Z_INDEX_INCR: int = 100

var _card: Node
var _move_delay: float = 0.0


static func make_scene(card: Card) -> Card2D:
	var node: Card2D = preload("res://scenes/card2d.tscn").instantiate()
	node.connect_model(card)
	return node


func _enter_tree() -> void:
	_set_initial_position()


func _set_initial_position() -> void:
	var rect := get_viewport_rect()
	position = Vector2(rect.get_center().x, rect.end.y)


func connect_model(card: Card) -> void:
	_card = card
	_set_card_texture(card.rank, card.suit)
	add_child(card, true)


func model() -> Card:
	return _card


func _set_card_texture(rank: int, suit: Card.Suit) -> void:
	$Sprite2D.texture.resource_local_to_scene = true
	$Sprite2D.texture.region = Rect2((rank - 1) * 241, suit * 336.8 - 0.2, 241, 337)


func _on_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		on_click_press()
		viewport.set_input_as_handled()


func on_click_press() -> void:
	if _card.current_pile() == null:
		CardDragGroup.new([self])
	else:
		_card.current_pile().pickup(_card)


func set_move_delay(delay: float) -> void:
	_move_delay = delay


func move_to(target: Vector2) -> void:
	if Engine.is_editor_hint():
		position = target
		return
	start_move_animation()
	var tween := get_tree().create_tween()
	tween.tween_interval(_move_delay)
	tween.tween_property(self, "position", target, .2).set_ease(Tween.EASE_OUT).set_trans(
		Tween.TRANS_EXPO
	)
	tween.finished.connect(end_move_animation)


func start_move_animation() -> void:
	z_index += Z_INDEX_INCR
	_card.add_to_group(Groups.MOVING_CARDS)
	input_event.disconnect(_on_input_event)


func end_move_animation() -> void:
	if z_index >= Z_INDEX_INCR:
		z_index -= Z_INDEX_INCR
	_card.remove_from_group(Groups.MOVING_CARDS)
	input_event.connect(_on_input_event)
	move_finished.emit(_card)


func play_pickup_sound() -> void:
	if not Engine.is_editor_hint():
		$PickupSound.play()


func play_drop_sound() -> void:
	if not Engine.is_editor_hint():
		$DropSound.play()


func play_slide_sound() -> void:
	if not Engine.is_editor_hint():
		$SlideSound.play()


func victory_animation() -> void:
	start_move_animation()
	var tween: Tween = get_tree().create_tween()
	var viewport_rect: Rect2 = get_viewport_rect()
	var screen_center: Vector2 = viewport_rect.get_center()
	tween.tween_property(self, "global_position", screen_center, 0.1)
	tween.tween_interval(randf_range(0.1, 0.4))
	var random_pos := Vector2(
		randf_range(viewport_rect.position.x, viewport_rect.end.x),
		randf_range(viewport_rect.position.y, viewport_rect.end.y)
	)
	tween.tween_property(self, "global_position", random_pos, randf_range(0.2, 0.4))
