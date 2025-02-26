class_name LongPressButton
extends Button

signal long_pressed

@export var long_press_duration: float = 1.0
@export var vibration_duration_ms: int = 100
var _timer := Timer.new()


func _ready() -> void:
	_timer.one_shot = true
	_timer.timeout.connect(_long_press_timeout)
	add_child(_timer)


func _on_button_down() -> void:
	_timer.start(long_press_duration)


func _on_button_up() -> void:
	_timer.stop()


func _long_press_timeout() -> void:
	Input.vibrate_handheld(vibration_duration_ms)
	long_pressed.emit()
