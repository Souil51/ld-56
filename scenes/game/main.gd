extends Node2D

class_name Main

const creature_scene = preload("res://scenes/creatures/creature.tscn")

@onready var _label: Label = $label

var _creature_count: int
var _max_creature: int = 10

func _ready() -> void:
	_creature_count = 0
	Game.creature_merged.connect(_creatured_merged)
	Game.creature_killed.connect(_creature_killed)
	
	_spawn_creature(Color.RED, Vector2(100, 100))
	_spawn_creature(Color.GREEN, Vector2(400, 100))
	_spawn_creature(Color.BLUE, Vector2(700, 100))
	pass

func _process(delta: float) -> void:
	pass

func _update_count():
	_label.text = "%s" % _creature_count

func _spawn_creature(color: Color, position: Vector2):
	_creature_count += 1
	_update_count()
	var creature_instance = creature_scene.instantiate()
	var creature = creature_instance as Creature
	creature.init_scene(color)
	creature.position = position
	add_child(creature)

func _creatured_merged(parent_1: Creature, parent_2: Creature):
	var new_r = _get_new_value(parent_1._color.r, parent_2._color.r)
	var new_g = _get_new_value(parent_1._color.g, parent_2._color.g)
	var new_b = _get_new_value(parent_1._color.b, parent_2._color.b)
	
	separate_objects(parent_1, parent_2)
	
	_spawn_creature(Color(new_r, new_g, new_b), (parent_1.global_position + parent_2.global_position) / 2)
	
	if _creature_count > _max_creature:
		parent_1.kill()
		parent_2.kill()
	else:
		parent_1.reset_effects()
		parent_2.reset_effects()
		parent_1.lose_life()
		parent_2.lose_life()

# Color merge rules
# For each compoment RGB, the rules are based on the difference between the 2 parens
# if difference < 0.33 : take one or the other
# if 0.33 < difference < 0.66 : calc the mean
# if difference > 0.66 : take one or the other and +/- (difference/4) (that allows component to be greater or lower for extremes values)
func _get_new_value(value_1: float, value_2: float):
	var new_value = 0
	var diff: float = abs(value_1 - value_2)
	if diff <= 0.33: # one of the two, random
		var rand = randi_range(0, 1)
		if rand == 0:
			new_value = value_1
		else:
			new_value = value_2
	elif diff > 0.33 and diff <= 0.66: # mean
		new_value = (value_1 + value_2) / 2
	else: # one of the two +/- quart of the difference
		var quart = diff / 4.0
		var rand = randi_range(0, 1)
		var offset = quart
		if randi_range(0, 1) == 0:
			offset *= -1
		if rand == 0:
			new_value = value_1 + offset
		else:
			new_value = value_2 + offset
	
	new_value = max(0, new_value)
	new_value = min(1, new_value)
	
	return new_value

func _creature_killed():
	_creature_count -= 1
	_update_count()
	
	if _creature_count < 3:
		_spawn_creature(Color(randf(), randf(), randf()), Vector2(randi_range(100, 500), randi_range(100, 500)))

func separate_objects(c_1: Node2D, c_2: Node2D) -> void:
	var distance_vector = (c_1.global_position - c_2.global_position)
	var distance = distance_vector.length()
	var direction = (c_1.global_position - c_2.global_position).normalized()
	
	var offset = (c_1._sprite.texture.get_height() * c_1._sprite.scale.x * sqrt(2)) - distance
	offset = direction * (offset / 2)

	c_1.global_position += offset
	c_2.global_position -= offset
