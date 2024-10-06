extends Node2D

@export var scale_start: Vector2 = Vector2(1.3, 1.3)
@export var scale_end: Vector2 = Vector2(.8, .8)

func _ready() -> void:
	_start_tween()

func _start_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", scale_start, 2)
	tween.tween_property(self, "scale", scale_end, 2)
	tween.tween_callback(_start_tween)
