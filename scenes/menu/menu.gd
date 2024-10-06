extends Node2D

class_name Menu

signal creature_released()

@onready var _last_score_panel: Node2D = $last_score
@onready var _last_score_label: Label = $last_score/label

var _similarity: int = -1
var _merges_count: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	creature_released.connect(_creature_released)
	pass # Replace with function body.

func _init_scene(similarity: int, merges_count: int):
	_similarity = similarity
	_merges_count = merges_count
	
	_last_score_panel.visible = true
	_last_score_label.text = "You got %s %% similiraty with %s merges" % [similarity, merges_count] 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _creature_released():
	print("MENU - creature released in start")
