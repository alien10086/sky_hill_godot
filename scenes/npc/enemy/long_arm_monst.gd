extends Node2D
@onready var spine_sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	pass
	#play_animation("animation", true)

# 播放动画函数
func play_animation(anim_name: String, loop: bool = false) -> void:
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		animation_state.set_animation(anim_name, loop, 0)
