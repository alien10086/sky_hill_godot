extends Node2D

@onready var spine_sprite: SpineSprite = $SpineSprite

# 战斗属性
@export var max_hp: float = 200.0
var current_hp: float = 200.0
@export var attack_power: float = 20.0

signal died
signal hp_changed(current, max)

func _ready():
	current_hp = max_hp

func take_damage(amount: float):
	current_hp -= amount
	hp_changed.emit(current_hp, max_hp)
	# 播放受击动画，如果没有 hit 动画则使用其他
	play_animation("hit", false)
	if current_hp <= 0:
		die()

func die():
	died.emit()
	play_animation("die", false)

func play_animation(anim_name: String, loop: bool = false):
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		animation_state.set_animation(anim_name, loop, 0)

func attack(target):
	play_animation("attack", false)
	# 简单处理：动画开始就造成伤害，或者可以通过 Spine 事件监听
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(target):
		target.take_damage(attack_power)
