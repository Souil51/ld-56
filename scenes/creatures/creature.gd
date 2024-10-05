extends Node2D

class_name Creature

@onready var _sprite: Sprite2D = $sprite
@onready var _label: Label = $label
@onready var _red_color: Sprite2D = $colors/red/color
@onready var _green_color: Sprite2D = $colors/green/color
@onready var _blue_color: Sprite2D = $colors/blue/color
@onready var _animation: AnimationPlayer = $animation
@onready var _line: Line2D = $line

@export var _color: Color
@export var _max_life: int

var _id: int
var _life: int

var _offset_x: float = 0
var _offset_y: float = 0

var _offset_x_scaled: float = 0
var _offset_y_scaled: float = 0

var _base_color_scale: float
var _is_moving: bool

var _mouse_in: bool = false
var _hover_creatures: Array = []
var _is_in_trash: bool = false

var _nearest: Creature

func _ready() -> void:
	_id = randi_range(0, 1000000)
	_life = _max_life
	Game.creature_selected.connect(_creature_selected)
	
	_offset_x = _sprite.texture.get_width() / _sprite.scale.x / 2
	_offset_y = _sprite.texture.get_height() / _sprite.scale.y / 2
	
	_offset_x_scaled = _offset_x * scale.x
	_offset_y_scaled = _offset_y * scale.y
	
	_sprite.modulate = _color
	_base_color_scale = _red_color.scale.y
	
	set_colors(_color)
	_update_text()
	
func _process(delta: float) -> void:
	if _hover_creatures.size() > 0 and _is_moving:
		_line.visible = true
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
		if _is_in_trash:
			Game.creature_trashed.emit(self)
			kill()
		
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
	pass

func _on_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("creature") and _is_moving:
		_hover_creatures.push_back(area.get_parent())
		if _hover_creatures.size() == 1:
			_sprite.modulate = _sprite.modulate.darkened(0.5)
	elif area.is_in_group("trash"):
		_is_in_trash = true

func _on_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("creature") and _is_moving:
		_hover_creatures.erase(area.get_parent())
		if _hover_creatures.size() == 0:
			_sprite.modulate = _color
	elif area.is_in_group("trash"):
		_is_in_trash = false

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
