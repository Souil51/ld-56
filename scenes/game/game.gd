extends Node2D

signal creature_selected(creature: Creature)
signal creature_unselected(creature: Creature)

signal creature_merged(parent_1: Creature, parent_2: Creature)
signal creature_killed()
signal creature_trashed(creature: Creature)

enum ColorType { RED, GREEN, BLUE }

var _selected_creature: Creature

func _ready() -> void:
	creature_selected.connect(_creature_selected)
	creature_unselected.connect(_creature_unselected)

func get_selected_creature():
	return _selected_creature

func get_selected_creature_id():
	if _selected_creature == null:
		return -1
		
	return _selected_creature.get_id()

func _creature_selected(creature: Creature):
	_selected_creature = creature

func _creature_unselected(creature: Creature):
	_selected_creature = null
