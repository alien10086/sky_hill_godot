extends Control

@onready var slow_texture_button: TextureButton = $HBoxContainer/slowTextureButton
@onready var fast_texture_button: TextureButton = $HBoxContainer/fastTextureButton
@onready var super_fast_texture_button: TextureButton = $HBoxContainer/superFastTextureButton
const UI_FAST_2_BUTTON_0 = preload("uid://8cfij4noajsm")
const UI_FAST_2_BUTTON_1 = preload("uid://dpfrupgle8jvr")
const UI_FAST_BUTTON_0 = preload("uid://1ytkq301e13c")
const UI_FAST_BUTTON_1 = preload("uid://baus3hqyevude")
const UI_SLOW_BUTTON_0 = preload("uid://baf1ig1tphx5f")
const UI_SLOW_BUTTON_1 = preload("uid://djqvkr5u61pl5")
const SPEED_CONTRAL = preload("uid://cjhfdy0lw625t")

# 当前选中的速度模式
var current_speed_mode: int = 0  # 0: 正常, 1: 快速, 2: 超快

var player_manager: PlayerManager

func _ready() -> void:
	player_manager = PlayerManager.get_instance()
	slow_texture_button.pressed.connect(_on_normal_button_pressed)
	fast_texture_button.pressed.connect(_on_fast_button_pressed)
	super_fast_texture_button.pressed.connect(_on_super_fast_button_pressed)
	_update_speed_button_states()

func _update_speed_button_states():
	slow_texture_button.texture_normal = UI_SLOW_BUTTON_0
	fast_texture_button.texture_normal = UI_FAST_BUTTON_0
	super_fast_texture_button.texture_normal = UI_FAST_2_BUTTON_0
	
	match  current_speed_mode:
		0:
			slow_texture_button.texture_normal = UI_SLOW_BUTTON_1
		1:
			fast_texture_button.texture_normal = UI_FAST_BUTTON_1
		2:
			super_fast_texture_button.texture_normal = UI_FAST_2_BUTTON_1
			

func _set_speed_mode(mode:int):
	if current_speed_mode == mode:
		return
	
	current_speed_mode = mode
	_update_speed_button_states()
	match mode:
		0:
			player_manager.set_speed(100)
			
		1:
			player_manager.set_speed(200)
		2:
			player_manager.set_speed(300)
			
# 速度控制按钮响应函数
func _on_normal_button_pressed():
	_set_speed_mode(0)

func _on_fast_button_pressed():
	_set_speed_mode(1)

func _on_super_fast_button_pressed():
	_set_speed_mode(2)
		
	
		
