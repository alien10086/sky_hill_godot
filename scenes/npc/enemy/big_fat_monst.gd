extends Node2D
@onready var spine_sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	set_skin("chef") # 测试设置皮肤
	play_animation("attcak", true)

# 设置皮肤函数
func set_skin(skin_name: String) -> void:
	if spine_sprite:
		var skeleton = spine_sprite.get_skeleton()
		skeleton.set_skin_by_name(skin_name)
		skeleton.set_to_setup_pose()

# 播放动画函数
func play_animation(anim_name: String, loop: bool = false) -> void:
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		#animation_state.set_animation_by_name(anim_name, loop, 0)
		#animation_state.set_time_scale(0.5)
		animation_state.set_animation(anim_name, loop, 0)
