extends Node

class_name AudioManager

## 背景音乐播放器
var bgm_player: AudioStreamPlayer
## 音效播放器池
var sfx_pool: Array[AudioStreamPlayer] = []
## 音效池大小
var pool_size: int = 12

func _ready():
	_setup_audio_nodes()

## 初始化音频节点
func _setup_audio_nodes():
	# 配置背景音乐播放器
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	bgm_player.name = "BGMPlayer"
	add_child(bgm_player)
	
	# 配置音效池
	for i in range(pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		p.name = "SFXPlayer_" + str(i)
		add_child(p)
		sfx_pool.append(p)

## 播放背景音乐
## @param stream 音频资源
func play_bgm(stream: AudioStream):
	if bgm_player.stream == stream and bgm_player.playing:
		return
	
	bgm_player.stream = stream
	bgm_player.play()

## 停止背景音乐
func stop_bgm():
	bgm_player.stop()

## 播放音效
## @param stream 音频资源
## @param volume_db 音量偏移
func play_sfx(stream: AudioStream, volume_db: float = 0.0):
	if stream == null:
		return
		
	# 寻找空闲的播放器
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.play()
			return
	
	# 如果池满了，强制使用第一个
	var first_player = sfx_pool[0]
	first_player.stream = stream
	first_player.volume_db = volume_db
	first_player.play()

## 设置总线音量
## @param bus_name 总线名称 ("Master", "Music", "SFX")
## @param value 0.0 到 1.0 的线性音量
func set_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		AudioServer.set_bus_mute(bus_index, value <= 0)
