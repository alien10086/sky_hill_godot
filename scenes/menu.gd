extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bgm_music = preload("res://assets/audio/bgm/menu_theme.wav")
var bgm_rain = preload("res://assets/audio/bgm/rain.wav")

func _ready() -> void:
	if animation_player:
		animation_player.play("light")
	
	_play_menu_audio()

func _play_menu_audio():
	# 播放主背景音乐
	if bgm_music:
		AudioManager.play_bgm(bgm_music)
	
	# 播放下雨环境音 (使用 SFX 播放器，因为它支持多轨道且我们需要它和 BGM 同时响)
	if bgm_rain:
		AudioManager.play_sfx(bgm_rain)
		
