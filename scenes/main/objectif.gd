extends Node2D

var _is_moving: bool = false
var _initial_position: Vector2
var _initial_scale: Vector2

func _ready() -> void:
	_initial_position = position
	_initial_scale = scale
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if _is_moving:
		var mouse_position = get_global_mouse_position() - get_parent().position
		position = Vector2(mouse_position.x, mouse_position.y)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and _is_moving:
		_is_moving = false
		position = _initial_position
		scale = _initial_scale
		Game.objectif_release.emit()

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		_is_moving = true
		scale = Vector2(0.3, 0.3)
		z_index = 20
