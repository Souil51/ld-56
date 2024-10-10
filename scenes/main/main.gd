extends Node2D

class_name Main

const creature_scene = preload("res://scenes/creatures/creature.tscn")

@onready var _label: Label = $label
@onready var _label_best_try: Label = $objectif/label_best_try
@onready var _label_merge_count: Label = $objectif/label_merge_count
@onready var _label_tries: Label = $objectif/label_tries
@onready var _objectif_color_sprite: Sprite2D = $objectif/objectif_root/sprite
@onready var _audio_player: AudioStreamPlayer = $audio_player
@onready var _mouse_area: Area2D = $mouse_area

var _creature_count: int
var _max_creature: int = 10

var _objectif_color: Color

var _best_try_score: int = 0
var _merge_count: int = 0
var _tries_left: int = 3

func _ready() -> void:
	Game.set_audio_player(_audio_player)
	
	_creature_count = 0
	Game.creature_merged.connect(_creatured_merged)
	Game.creature_killed.connect(_creature_killed)
	Game.test_objectif.connect(_test_objectif)
	
	_update_tries_label()
	_update_merge_count_label()
	_update_best_try_label()
	
	_spawn_creature(Color.RED, Vector2(100, 200))
	_spawn_creature(Color.GREEN, Vector2(400, 200))
	_spawn_creature(Color.BLUE, Vector2(700, 200))
	
	_init_random_objectif()
	
	
	
func _process(delta: float) -> void:
	_mouse_area.position = get_global_mouse_position()

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
	var parent_blocked = get_parent_blocked(parent_1, parent_2, Game.ColorType.RED)
	if parent_blocked != null:
		new_r = parent_blocked._color.r
		
	var new_g = _get_new_value(parent_1._color.g, parent_2._color.g)
	parent_blocked = get_parent_blocked(parent_1, parent_2, Game.ColorType.GREEN)
	if parent_blocked != null:
		new_g = parent_blocked._color.g
		
	var new_b = _get_new_value(parent_1._color.b, parent_2._color.b)
	parent_blocked = get_parent_blocked(parent_1, parent_2, Game.ColorType.BLUE)
	if parent_blocked != null:
		new_b = parent_blocked._color.b
	
	parent_1.bonus_used()
	parent_2.bonus_used()
	
	separate_objects(parent_1, parent_2)
	
	_merge_count += 1
	_update_merge_count_label()
	
	_spawn_creature(Color(new_r, new_g, new_b), (parent_1.global_position + parent_2.global_position) / 2)
	
	if _creature_count > _max_creature:
		parent_1.kill()
		parent_2.kill()
	else:
		parent_1.reset_effects()
		parent_2.reset_effects()
		parent_1.lose_life()
		parent_2.lose_life()

func get_parent_blocked(parent_1: Creature, parent_2: Creature, color: Game.ColorType) -> Creature:
	if parent_1.blocked_colors[color] && parent_2.blocked_colors[color]:
		var rand = randi_range(0, 1)
		if rand == 0:
			return parent_1
		else:
			return parent_2
	elif parent_1.blocked_colors[color]:
		return parent_1
	elif parent_2.blocked_colors[color]:
		return parent_2
	
	return null

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

func _init_random_objectif():
	_init_objectif(Color(randf(), randf(), randf()))

func _init_objectif(color: Color):
	_objectif_color = color
	_objectif_color_sprite.self_modulate = color

func _test_objectif(c: Creature):
	var similarity = ColorHelper.calculate_similarity(c._color, _objectif_color)
	
	if int(similarity) > _best_try_score:
		_best_try_score = int(similarity)
		
	var test_result = Game.ResultType.NORMAL
	if similarity < 33:
		test_result = Game.ResultType.BAD
	elif similarity > 75:
		test_result = Game.ResultType.GOOD
		
	Game.test_result.emit(test_result)
		
	_tries_left -= 1
	
	_update_best_try_label()
	_update_tries_label()
	
	if _tries_left == 0:
		var root_scene = get_parent() as RootScene
		if root_scene != null:
			root_scene.end_game.emit(_best_try_score, _merge_count)

func _update_tries_label():
	if _tries_left == 1:
		_label_tries.text = "1 try left"
	else:
		_label_tries.text = "%s tries left" % _tries_left
	
func _update_best_try_label():
	if _tries_left == 3:
		_label_best_try.text = "Best try : - %"
	else:
		_label_best_try.text = "Best try : " + str(_best_try_score) + " %"
	
func _update_merge_count_label():
	if _merge_count == 1:
		_label_merge_count.text = "1 merge"
	else:
		_label_merge_count.text = "%s" % _merge_count
