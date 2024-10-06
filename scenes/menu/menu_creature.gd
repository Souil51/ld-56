extends Node2D

@onready var _sprite: Sprite2D = $sprite

@export var color: Color

var _is_moving: bool = false
var _is_in_start: bool = false

var _initial_position:Vector2
var _initial_scale:Vector2

func _ready() -> void:
	_initial_position = position
	_initial_scale = scale
	
	_sprite.modulate = color

func _physics_process(delta: float) -> void:
	if _is_moving:
		var mouse_position = get_global_mouse_position() - get_parent().position
		position = Vector2(mouse_position.x, mouse_position.y)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and _is_moving:
		_is_moving = false
		position = _initial_position
		scale = _initial_scale
		if _is_in_start:
			get_parent().get_parent().creature_released.emit()
		

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		_is_moving = true
		scale = Vector2(1.2, 1.2)
		z_index = 20

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("menu_start"):
		_is_in_start = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("menu_start"):
		_is_in_start = false
