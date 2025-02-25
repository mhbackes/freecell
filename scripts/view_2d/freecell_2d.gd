@tool
class_name Freecell2DNew
extends Control

@onready var _freecell: Freecell = Freecell.new()
var _cascades: Array[Cascade2D]
var _cells: Array[Cell2D]
var _foundations: Array[Foundation2D]
var _cards: Array[Card2D]

func _ready() -> void:
	get_viewport().physics_object_picking_sort = true
	_cascades.assign(find_children("Cascade2D*", "Cascade2D"))
	_foundations.assign(find_children("Foundation2D*", "Foundation2D"))
	_cells.assign(find_children("Cell2D*", "Cell2D"))
	connect_model(_freecell)
	_freecell.shuffle()
	call_deferred("deal")

func connect_model(freecell: Freecell) -> void:
	for card in freecell.get_cards():
		var card2d := Card2D.make_scene(card)
		_cards.append(card2d)
		add_child(card2d, true)
	for i in range(_cascades.size()):
		_cascades[i].connect_model(freecell._cascades[i])
	for i in range(_cells.size()):
		_cells[i].connect_model(freecell._cells[i])
	for i in range(_foundations.size()):
		_foundations[i].connect_model(freecell._foundations[i])
	_freecell.cards_moved.connect(_on_cards_moved)
	_freecell.victory.connect(_on_victory)
	add_child(_freecell, true)

func _on_cards_moved(cards: Array[Card]) -> void:
	assert(not cards.is_empty())
	cards.front().get_parent().move_finished.connect(_on_card_finished_moving, 
													 ConnectFlags.CONNECT_ONE_SHOT)
	
func _on_card_finished_moving(last_moved_card: Card) -> void:
	update_undo_redo_buttons()
	_freecell.post_card_move_checks(last_moved_card)
	
func _on_victory() -> void:
	enable_undo(false)
	enable_redo(false)
	$VictorySound.play()
	for card2d in _cards:
		card2d.victory_animation()
		
func deal() -> void:
	$DealSound.play()
	for i in range(_freecell._cards.size()):
		_freecell._cards[i].get_parent().set_move_delay(0.02 * i)
	_freecell.deal()
	for card2d in _cards:
		card2d.set_move_delay(0)
				
func new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/freecell_2d.tscn")

func undo_all() -> void:
	_freecell.undo_all()
	update_undo_redo_buttons()

func undo() -> void:
	_freecell.undo()
	update_undo_redo_buttons()

func redo() -> void:
	_freecell.redo()
	update_undo_redo_buttons()

func redo_all() -> void:
	_freecell.redo_all()
	update_undo_redo_buttons()
	
func update_undo_redo_buttons() -> void:
	enable_undo(_freecell.has_undo())
	enable_redo(_freecell.has_redo())

func enable_undo(value: bool):
	$AspectRatioContainer/VSplitContainer/HUD/Buttons/UndoAll.set_disabled(not value)
	$AspectRatioContainer/VSplitContainer/HUD/Buttons/Undo.set_disabled(not value)
	
func enable_redo(value: bool):
	$AspectRatioContainer/VSplitContainer/HUD/Buttons/Redo.set_disabled(not value)
	$AspectRatioContainer/VSplitContainer/HUD/Buttons/RedoAll.set_disabled(not value)
