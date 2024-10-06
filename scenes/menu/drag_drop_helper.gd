extends Node2D

@onready var _start: Node2D = $start
@onready var _end: Node2D = $end
@onready var _line: Line2D = $line
@onready var _sprite: Sprite2D = $sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_line.points = [_start.position, _end.position]
	_sprite.position = _start.position
	
	_start_tween()

func _start_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "position", _end.position, 3)
	tween.tween_property(_sprite, "position", _start.position, 3)
	tween.tween_callback(_start_tween)
