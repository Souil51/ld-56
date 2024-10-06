extends Node2D

signal creature_selected(creature: Creature)
signal creature_unselected(creature: Creature)

signal creature_merged(parent_1: Creature, parent_2: Creature)
signal creature_killed()
signal creature_trashed(creature: Creature)

signal bonus_release(bonus: Bonus)
signal bonus_applied(bonus: Bonus)
signal trash_release()
signal objectif_release()
signal test_objectif(creature: Creature)

signal test_result(result: ResultType)

enum ColorType { RED, GREEN, BLUE }
enum BonusType { ADD, INVERSE, BLOCK }
enum PriceType { ONE, TWO, THREE }
enum ResultType { BAD, NORMAL, GOOD }

var _selected_creature: Creature

var _audio_player: AudioStreamPlayer

func _ready() -> void:
	creature_selected.connect(_creature_selected)
	creature_unselected.connect(_creature_unselected)
	
	creature_merged.connect(_creature_merged)
	creature_trashed.connect(_creature_trashed)
	test_result.connect(_test_result)
	bonus_applied.connect(_bonus_applied)

func set_audio_player(player: AudioStreamPlayer):
	_audio_player = player

func get_selected_creature():
	return _selected_creature

func get_selected_creature_id():
	if _selected_creature == null:
		return -1
		
	return _selected_creature.get_id()

func _creature_selected(creature: Creature):
	_selected_creature = creature
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.PICK)

func _creature_unselected(creature: Creature):
	_selected_creature = null

func _creature_merged(parent_1: Creature, parent_2: Creature):
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.MERGE)
	
func _creature_trashed(creature: Creature):
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.RECYCLE)

func _bonus_applied(bonus: Bonus):
	AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.BONUS)

func _test_result(result: ResultType):
	match result:
		ResultType.BAD:
			AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.TEST_BAD)
		ResultType.NORMAL:
			AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.TEST_NORMAL)
		ResultType.GOOD:
			AudioHelper.play_sound(_audio_player, AudioHelper.Sounds.TEST_GOOD)
