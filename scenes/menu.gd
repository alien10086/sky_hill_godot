extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rain_system: Node2D = $RainSystem
@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
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
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		# 检查是否有存档，没有则隐藏“继续”按钮
		var pm = PlayerManager.get_instance()
		if not pm.has_save_file():
			continue_button.visible = false
			
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	_play_menu_audio()

func _on_new_game_pressed():
	# 停止菜单背景音乐和环境音
	AudioManager.stop_all()
	# 删除旧存档并重置数据
	var pm = PlayerManager.get_instance()
	pm.delete_save_file()
	pm.reset_all_attributes()
	get_tree().change_scene_to_file("res://scenes/main_world.tscn")

func _on_continue_pressed():
	# 停止菜单背景音乐和环境音
	AudioManager.stop_all()
	# 加载存档
	var pm = PlayerManager.get_instance()
	if pm.load_game():
		get_tree().change_scene_to_file("res://scenes/main_world.tscn")
	else:
		print("加载失败，进入新游戏")
		_on_new_game_pressed()

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
		
