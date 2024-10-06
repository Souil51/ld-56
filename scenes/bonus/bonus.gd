extends Node2D

class_name Bonus

@onready var _bonus: Sprite2D = $bonus
@onready var _inner_sprite: Sprite2D = $bonus/inner
@onready var _label: Label = $bonus/label
@onready var _label_price: Label = $bonus/label_price

@export var id: Game.BonusType
@export var price: Game.PriceType

var _is_moving: bool = false

var _offset_x: float = 0
var _offset_y: float = 0

var _offset_x_scaled: float = 0
var _offset_y_scaled: float = 0

var _initial_position: Vector2
var _initial_scale: Vector2

var _is_available: bool = false

func _ready() -> void:
	if id == Game.BonusType.ADD:
		_label.text = "+25%"
	elif id == Game.BonusType.INVERSE:
		_label.text = "Inverse"
	elif id == Game.BonusType.BLOCK:
		_label.text = "Block"
	
	if id == Game.PriceType.ONE:
		_label_price.text = "1 coin"
	elif id == Game.PriceType.TWO:
		_label_price.text = "2 coins"
	elif id == Game.PriceType.THREE:
		_label_price.text = "3 coins"
	
	_initial_position = position
	_initial_scale = scale
	
	_offset_x = _bonus.texture.get_width() / scale.x / 2
	_offset_y = _bonus.texture.get_height() / scale.y / 2
	
	_offset_x_scaled = _offset_x * scale.x
	_offset_y_scaled = _offset_y * scale.y

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
		Game.bonus_release.emit(self)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and _is_available:
		_is_moving = true
		scale = Vector2(0.15, 0.15)
		z_index = 20

func set_available():
	_inner_sprite.modulate = Color(1, 1, 1)
	_is_available = true
	
func set_not_available():
	_inner_sprite.modulate = Color(0.6, 0.6, 0.6)
	_is_available = false
