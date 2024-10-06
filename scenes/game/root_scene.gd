extends Node2D

class_name RootScene

@onready var _audio_player: AudioStreamPlayer = $audio_player
@onready var _main_audio_player: AudioStreamPlayer = $main_audio_player

const main_scene = preload("res://scenes/main/main.tscn")

signal end_game(similarity: int, merges_count: int)

@onready var _menu: Menu = $menu_root

var _game: Node2D

func _ready() -> void:
	_menu.creature_released.connect(_start_game)
	end_game.connect(_end_game)

func _process(delta: float) -> void:
	pass

func _start_game():
	_menu.visible = false
	_game = main_scene.instantiate()
	add_child(_game)
	
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.START)
	_main_audio_player.play()

func _end_game(similarity: int, merges_count: int):
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.END)
	_main_audio_player.stop()
	remove_child(_game)
	_game.queue_free()
	_menu.visible = true
	_menu._init_scene(similarity, merges_count)
