extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rain_system: Node2D = $RainSystem
@onready var new_game_button: Button = %NewGameButton
@onready var exit_button: Button = %ExitButton

var bgm_music = preload("res://assets/audio/bgm/menu_theme.wav")
var bgm_rain = preload("res://assets/audio/bgm/rain.wav")

func _ready() -> void:
	if animation_player:
		animation_player.play("light")
	
	if rain_system:
		rain_system.visible = true
	
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	_play_menu_audio()

func _on_new_game_pressed():
	# 停止菜单背景音乐和环境音
	AudioManager.stop_all()
	# 重置玩家数据并进入游戏主场景
	PlayerManager.get_instance().reset_all_attributes()
	get_tree().change_scene_to_file("res://scenes/main_world.tscn")

func _on_exit_pressed():
	# 退出游戏
	get_tree().quit()

func _play_menu_audio():
	# 播放主背景音乐
	if bgm_music:
		AudioManager.play_bgm(bgm_music)
	
	# 播放下雨环境音 (使用 SFX 播放器，因为它支持多轨道且我们需要它和 BGM 同时响)
	if bgm_rain:
		AudioManager.play_sfx(bgm_rain)
		
