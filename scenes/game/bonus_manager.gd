extends Node2D

class_name BonusManager

@onready var _red_color: Sprite2D = $colors/red/color
@onready var _green_color: Sprite2D = $colors/green/color
@onready var _blue_color: Sprite2D = $colors/blue/color

@onready var _bonus_1: Sprite2D = $store/bonus_1
@onready var _bonus_2: Sprite2D = $store/bonus_2
@onready var _bonus_3: Sprite2D = $store/bonus_3

var _r_bonus: float = 0
var _r_bonus_available: bool = false
var _g_bonus: float = 0
var _g_bonus_available: bool = false
var _b_bonus: float = 0
var _b_bonus_available: bool = false

var _base_color_scale: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.creature_trashed.connect(_creature_trashed)
	
	_base_color_scale = _red_color.scale.y
	
	set_colors(Color(_r_bonus, _g_bonus, _b_bonus))
	
func _creature_trashed(c: Creature):
	_r_bonus = min(100, _r_bonus + c._color.r)
	_g_bonus += min(100, _g_bonus + c._color.g)
	_b_bonus += min(100, _b_bonus + c._color.b)
	set_colors(Color(_r_bonus, _g_bonus, _b_bonus))

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
	var bonus_filled_count = 0
	if _r_bonus >= 1:
		_r_bonus = 1
		bonus_filled_count += 1
	if _g_bonus >= 1:
		_r_bonus = 1
		bonus_filled_count += 1
	if _g_bonus >= 1:
		_r_bonus = 1
		bonus_filled_count += 1
		
	if bonus_filled_count > 0:
		_bonus_1.modulate = Color(0.6, 0.6, 0.6)
		_r_bonus_available = true
	else: 
		_bonus_1.modulate = Color(0, 0, 0)
		_r_bonus_available = false
		
	if bonus_filled_count > 1:
		_bonus_2.modulate = Color(0.6, 0.6, 0.6)
		_g_bonus_available = true
	else: 
		_bonus_2.modulate = Color(0, 0, 0)
		_g_bonus_available = false
		
	if bonus_filled_count > 2:
		_bonus_3.modulate = Color(0.6, 0.6, 0.6)
		_b_bonus_available = true
	else: 
		_bonus_3.modulate = Color(0, 0, 0)
		_b_bonus_available = false
