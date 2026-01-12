extends Node2D
@onready var spine_sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	pass
	#play_animation("animation", true)
	
func random_skin():
	pass

# 播放动画函数
func play_animation(anim_name: String, loop: bool = false) -> void:
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		animation_state.set_animation(anim_name, loop, 0)

# 设置皮肤函数
# func set_skin(skin_name: String) -> void:
# 	if spine_sprite:
# 		var skeleton = spine_sprite.get_skeleton()
# 		skeleton.set_skin_by_name(skin_name)
# 		skeleton.set_to_setup_pose()

# 停止动画函数
func stop_animation(track_index: int = 0) -> void:
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		animation_state.clear_track(track_index)
		# 恢复到初始姿势
		spine_sprite.get_skeleton().set_to_setup_pose()
