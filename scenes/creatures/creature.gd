extends Node2D

class_name Creature

@onready var _sprite: Sprite2D = $sprite
@onready var _label: Label = $label

@onready var _red_color: Sprite2D = $colors/red/color
@onready var _red_background: Sprite2D = $colors/red/background
@onready var _red_lock: Sprite2D = $colors/red/lock

@onready var _green_color: Sprite2D = $colors/green/color
@onready var _green_background: Sprite2D = $colors/green/background
@onready var _green_lock: Sprite2D = $colors/green/lock

@onready var _blue_color: Sprite2D = $colors/blue/color
@onready var _blue_background: Sprite2D = $colors/blue/background
@onready var _blue_lock: Sprite2D = $colors/blue/lock

@onready var _animation: AnimationPlayer = $animation
@onready var _line: Line2D = $line
@onready var _colors: Node2D = $colors

@export var _color: Color
@export var _max_life: int

var _id: int
var _life: int

var _offset_x: float = 0
var _offset_y: float = 0

var _offset_x_scaled: float = 0
var _offset_y_scaled: float = 0

var _initial_colors_position: Vector2
var _initial_colors_scale: Vector2

var _initial_sprite_scale: Vector2

var _base_color_scale: float
var _is_moving: bool

var _mouse_in: bool = false
var _hover_creatures: Array = []
var _is_in_trash: bool = false
var _is_in_objectif:bool = false

var _nearest: Creature

var _bonus_on_colors = {}
var blocked_colors = {}

func _ready() -> void:
	_id = randi_range(0, 1000000)
	_life = _max_life
	_initial_sprite_scale = _sprite.scale
	
	_initial_colors_position = _colors.position
	_initial_colors_scale = _colors.scale
	
	blocked_colors[Game.ColorType.RED] = false
	blocked_colors[Game.ColorType.GREEN] = false
	blocked_colors[Game.ColorType.BLUE] = false
	
	_bonus_on_colors[Game.ColorType.RED] = false
	_bonus_on_colors[Game.ColorType.GREEN] = false
	_bonus_on_colors[Game.ColorType.BLUE] = false
	
	Game.creature_selected.connect(_creature_selected)
	Game.bonus_release.connect(_bonus_released)
	Game.trash_release.connect(_trash_release)
	Game.objectif_release.connect(_objectif_release)
	
	_offset_x = _sprite.texture.get_width() / _sprite.scale.x / 2
	_offset_y = _sprite.texture.get_height() / _sprite.scale.y / 2
	
	_offset_x_scaled = _offset_x * scale.x
	_offset_y_scaled = _offset_y * scale.y
	
	_base_color_scale = _red_color.scale.y
	
	set_colors(_color)
	_update_text()
	
func _process(delta: float) -> void:
	if _hover_creatures.size() > 0 and _is_moving:
		_line.visible = false
		var pos = get_nearest_object().global_position - global_position
		_line.points = [Vector2(_offset_x, _offset_y + (20 * _offset_y_scaled)), Vector2((pos.x / scale.x) + _offset_x, (pos.y / scale.y) + _offset_y + (20 * _offset_y_scaled))]
	else:
		_line.visible = false
		
	_update_nearest()
	
func _physics_process(delta: float) -> void:
	if _is_moving:
		var mouse_position = get_global_mouse_position()
		position = Vector2(mouse_position.x - _offset_x_scaled, mouse_position.y - (20 * _offset_y_scaled))

func init_scene(color: Color):
	_color = color

func get_id():
	return _id

func _update_text():
	_label.text = "%s" % _life

func lose_life():
	_life -= 1
	_update_text()
	
	if _life == 0:
		kill()

func kill():
	queue_free()
	Game.creature_killed.emit()

func set_colors(color: Color):
	set_one_color(Game.ColorType.RED, color.r8)
	set_one_color(Game.ColorType.GREEN, color.g8)
	set_one_color(Game.ColorType.BLUE, color.b8)
	
	_sprite.modulate = _color

func set_one_color(colorType: Game.ColorType, value: int):
	if value > 255:
		value = 255
	elif value < 0:
		value = 0
		
	var color: float = float(value) / float(255)
	if colorType == Game.ColorType.RED:
		_red_color.scale.y = _base_color_scale * color
	elif colorType == Game.ColorType.GREEN:
		_green_color.scale.y = _base_color_scale * color
	else:
		_blue_color.scale.y = _base_color_scale * color

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and _is_moving:
		_is_moving = false
		Game.creature_unselected.emit(self)
		if _nearest != null:
			Game.creature_merged.emit(self, _nearest)
		_nearest = null

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and Game.get_selected_creature() == null:
		_is_moving = true
		z_index = 10
		Game.creature_selected.emit(self)

func _on_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("creature") and _is_moving:
		_hover_creatures.push_back(area.get_parent())
		if _hover_creatures.size() == 1:
			_sprite.modulate = _sprite.modulate.darkened(0.5)
	elif area.is_in_group("trash"):
		_is_in_trash = true
		_sprite.scale *= 1.4
	elif area.is_in_group("objectif"):
		_is_in_objectif = true
		_sprite.scale *= 1.4
	elif area.is_in_group("mouse"):
		_sprite.scale *= 1.1

func _on_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("creature") and _is_moving:
		_hover_creatures.erase(area.get_parent())
		if _hover_creatures.size() == 0:
			_sprite.modulate = _color
	elif area.is_in_group("trash"):
		_is_in_trash = false
		_sprite.scale = _initial_sprite_scale
	elif area.is_in_group("objectif"):
		_is_in_objectif = false
		_sprite.scale = _initial_sprite_scale
	elif area.is_in_group("mouse"):
		_sprite.scale /= 1.1

func _update_nearest():
	var new_nearest = get_nearest_object()
	if new_nearest == null:
		if _nearest != null:
			_nearest.reset_effects()
			_nearest = null
	else:
		if _nearest == null or _nearest != new_nearest:
			if _nearest != null:
				_nearest.reset_effects()
			_nearest = new_nearest
			_nearest.set_darker()

func _creature_selected(creature: Creature):
	if creature.get_id() != _id:
		z_index = 0
		
func set_darker():
	_sprite.modulate = _sprite.modulate.darkened(0.5)

func reset_effects():
	_sprite.modulate = _color
	_line.points = []
	_line.visible = false
	_hover_creatures.clear()
	_nearest = null

func get_nearest_object() -> Creature:
	var nearest_object: Node2D = null
	var min_distance: float = INF

	for obj in _hover_creatures:
		if obj is Creature:
			var distance = self.global_position.distance_to(obj.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_object = obj

	return nearest_object


func _on_timer_timeout() -> void:
	_change_animation()
	if not _is_moving:
		_move()

func _change_animation():
	var value = randi_range(0, 3)
	if value == 0:
		var animation_index = randi_range(0, 3)
		if animation_index == 0:
			_animation.play("eyes_blink")
		elif animation_index == 1:
			_animation.play("smile")
		elif animation_index == 2:
			_animation.play("arms_move")
		elif animation_index == 3:
			_animation.play("shroom")
	else:
		_animation.play("RESET")
		
func _move():
	var value = randi_range(0, 3)
	if value == 0:
		var random_angle = randf() * PI * 2
		var random_direction = Vector2(cos(random_angle), sin(random_angle))
		var normalized_direction = random_direction.normalized()
		var new_position = position + (normalized_direction * 100)
		
		if new_position.x > get_viewport().size.x - (_sprite.texture.get_width() / _sprite.scale.x):
			new_position.x = get_viewport().size.x - (_sprite.texture.get_width() / _sprite.scale.x)
		if new_position.x < _sprite.texture.get_width() / _sprite.scale.x:
			new_position.x = _sprite.texture.get_width() / _sprite.scale.x
		if new_position.y > get_viewport().size.y - (_sprite.texture.get_height() / _sprite.scale.y):
			new_position.y = get_viewport().size.y - (_sprite.texture.get_height() / _sprite.scale.y)
		if new_position.y < (_sprite.texture.get_height() / _sprite.scale.y) + 150:
			new_position.y = (_sprite.texture.get_height() / _sprite.scale.y) + 150
		
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", new_position, 1)
		
		var rotation_dir = randi_range(0, 1)
		if rotation_dir == 0:
			rotation_dir = 1
		
		var tween_rot = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
		tween_rot.tween_property(self, "rotation_degrees", 5 * rotation_dir, 0.25)
		tween_rot.tween_property(self, "rotation_degrees", 0, 0.25)
		tween_rot.tween_property(self, "rotation_degrees", -5 * rotation_dir, 0.25)
		tween_rot.tween_property(self, "rotation_degrees", 0, 0.25)

func _on_bonus_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("bonus"):
		_colors.scale = Vector2(2, 2)
		_colors.position.x -= _red_background.texture.get_width() * 0.5

func _on_bonus_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("bonus"):
		_colors.scale = _initial_colors_scale
		_colors.position = _initial_colors_position
		_reset_color_selection()

func _on_area_2d_red_entered(area: Area2D) -> void:
	_on_area_2d_color_entered(area, Game.ColorType.RED)

func _on_area_2d_red_exited(area: Area2D) -> void:
	_on_area_2d_color_exited(area, Game.ColorType.RED)

func _on_area_2d_green_entered(area: Area2D) -> void:
	_on_area_2d_color_entered(area, Game.ColorType.GREEN)

func _on_area_2d_green_exited(area: Area2D) -> void:
	_on_area_2d_color_exited(area, Game.ColorType.GREEN)

func _on_area_2d_blue_entered(area: Area2D) -> void:
	_on_area_2d_color_entered(area, Game.ColorType.BLUE)

func _on_area_2d_blue_exited(area: Area2D) -> void:
	_on_area_2d_color_exited(area, Game.ColorType.BLUE)

func _on_area_2d_color_entered(area: Area2D, color: Game.ColorType):
	if area.is_in_group("bonus"):
		print("bonus enter on color %s" % color)
		_bonus_on_colors[color] = true
		if color == Game.ColorType.RED:
			_red_background.modulate = Color.WHITE
		elif color == Game.ColorType.GREEN:
			_green_background.modulate = Color.WHITE
		elif color == Game.ColorType.BLUE:
			_blue_background.modulate = Color.WHITE
	
func _on_area_2d_color_exited(area: Area2D, color: Game.ColorType):
	if area.is_in_group("bonus"):
		print("bonus exit on color %s" % color)
		var bonus: Bonus = area.get_parent().get_parent()
		_bonus_on_colors[color] = false
		if color == Game.ColorType.RED:
			_red_background.modulate = Color.BLACK
		elif color == Game.ColorType.GREEN:
			_green_background.modulate = Color.BLACK
		elif color == Game.ColorType.BLUE:
			_blue_background.modulate = Color.BLACK

func _reset_color_selection():
	_red_background.modulate = Color.BLACK
	_green_background.modulate = Color.BLACK
	_blue_background.modulate = Color.BLACK

func _bonus_released(bonus: Bonus):
	var bonus_applied = false
	if _bonus_on_colors[Game.ColorType.RED]:
		_color.r = _apply_bonus(bonus, _color.r, Game.ColorType.RED)
		bonus_applied = true
	elif _bonus_on_colors[Game.ColorType.GREEN]:
		_color.g = _apply_bonus(bonus, _color.g, Game.ColorType.GREEN)
		bonus_applied = true
	elif _bonus_on_colors[Game.ColorType.BLUE]:
		_color.b = _apply_bonus(bonus, _color.b, Game.ColorType.BLUE)
		bonus_applied = true
	
	set_colors(_color)
	if bonus_applied:
		Game.bonus_applied.emit(bonus)

func _apply_bonus(bonus: Bonus, value: float, color: Game.ColorType):
	match bonus.id:
		Game.BonusType.ADD:
			value = min(1, value + 0.25)
		Game.BonusType.INVERSE:
			value = 1 - value
		Game.BonusType.BLOCK:
			blocked_colors[color] = true
			match color:
				Game.ColorType.RED:
					_red_lock.visible = true
				Game.ColorType.GREEN:
					_green_lock.visible = true
				Game.ColorType.BLUE:
					_blue_lock.visible = true
	return value

func bonus_used():
	blocked_colors[Game.ColorType.RED] = false
	_red_lock.visible = false
	blocked_colors[Game.ColorType.GREEN] = false
	_green_lock.visible = false
	blocked_colors[Game.ColorType.BLUE] = false
	_blue_lock.visible = false

func _trash_release():
	if _is_in_trash:
		Game.creature_trashed.emit(self)
		kill()

func _objectif_release():
	if _is_in_objectif:
		Game.test_objectif.emit(self)
