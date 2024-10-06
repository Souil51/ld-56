extends Node2D

class_name BonusManager

@onready var _red_color: Sprite2D = $colors/red/color
@onready var _green_color: Sprite2D = $colors/green/color
@onready var _blue_color: Sprite2D = $colors/blue/color

@onready var _bonus_1: Bonus = $store/bonus_1
@onready var _bonus_2: Bonus = $store/bonus_2
@onready var _bonus_3: Bonus = $store/bonus_3

@onready var _label_store_points: Label = $store/label

var _r_bonus: float = 0
var _g_bonus: float = 0
var _b_bonus: float = 0

var _base_color_scale: float
var _bonus_filled_count: int = 0

func _ready() -> void:
	Game.creature_trashed.connect(_creature_trashed)
	Game.bonus_applied.connect(_bonus_applied)
	
	_base_color_scale = _red_color.scale.y
	
	set_colors(Color(_r_bonus, _g_bonus, _b_bonus))
	_update_store_points()
	
func _creature_trashed(c: Creature):
	_r_bonus = min(1, _r_bonus + c._color.r)
	if _r_bonus == 1:
		if _bonus_filled_count < 5:
			_bonus_filled_count += 1
		_r_bonus = 0
		
	_g_bonus = min(1, _g_bonus + c._color.g)
	if _g_bonus == 1:
		if _bonus_filled_count < 5:
			_bonus_filled_count += 1
		_g_bonus = 0
		
	_b_bonus = min(1, _b_bonus + c._color.b)
	if _b_bonus == 1:
		if _bonus_filled_count < 5:
			_bonus_filled_count += 1
		_b_bonus = 0
		
	_update_store_points()
	set_colors(Color(_r_bonus, _g_bonus, _b_bonus))

func _update_store_points():
	_label_store_points.text = "%s" % _bonus_filled_count

func _bonus_applied(b: Bonus):
	match b.id:
		Game.BonusType.ADD:
			_bonus_filled_count -= 1
		Game.BonusType.INVERSE:
			_bonus_filled_count -= 2
		Game.BonusType.BLOCK:
			_bonus_filled_count -= 3
	
	_update_store_points()
	_update_store()

func set_colors(color: Color):
	set_one_color(Game.ColorType.RED, color.r8)
	set_one_color(Game.ColorType.GREEN, color.g8)
	set_one_color(Game.ColorType.BLUE, color.b8)
	
	_update_store()

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

func _update_store():
	if _bonus_filled_count > 0:
		_bonus_1.set_available()
	else: 
		_bonus_1.set_not_available()
		
	if _bonus_filled_count > 1:
		_bonus_2.set_available()
	else: 
		_bonus_2.set_not_available()
	
	if _bonus_filled_count > 2:
		_bonus_3.set_available()
	else: 
		_bonus_3.set_not_available()
