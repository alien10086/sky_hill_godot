extends CanvasLayer

# 添加类名有助于 IDE 识别
class_name SceneTransitionManager

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false

func change_scene(target_scene_path: String):
	# 1. 播放淡出动画（变黑）
	color_rect.visible = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	# 2. 切换场景
	get_tree().change_scene_to_file(target_scene_path)
	
	# 3. 播放淡入动画（变亮）
	animation_player.play("fade_in")
	await animation_player.animation_finished
	color_rect.visible = false
