extends Node2D

@onready var spine_sprite: SpineSprite = $SpineSprite

# 战斗属性
@export var max_hp: float = 200.0
var current_hp: float = 200.0
@export var attack_power: float = 20.0

var current_weapon: WeaponData = null
var player_manager: PlayerManager

signal died
signal hp_changed(current, max)

func _ready():
	current_hp = max_hp
	player_manager = PlayerManager.get_instance()

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
	
	# 计算动态伤害
	var damage = calculate_damage()
	
	# 简单处理：动画开始就造成伤害，或者可以通过 Spine 事件监听
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(target):
		print("玩家发动攻击，造成伤害: %.1f" % damage)
		target.take_damage(damage)

## 计算当前伤害
func calculate_damage() -> float:
	if current_weapon == null:
		return attack_power # 无武器时使用基础攻击力
	
	# 1. 基础武器伤害（随机范围）
	var base_damage = randf_range(current_weapon.damage_min, current_weapon.damage_max)
	
	# 2. 玩家属性加成
	var attr_bonus = 0.0
	if player_manager:
		var attrs = player_manager.player_data.attributes
		match current_weapon.skill:
			"str":
				attr_bonus = attrs.strength * 1.5
			"dex":
				attr_bonus = attrs.dexterity * 1.5
			"spd":
				attr_bonus = attrs.speed * 1.5
			_:
				attr_bonus = attrs.strength * 1.0 # 默认加成
	
	return base_damage + attr_bonus

## 切换武器
func change_weapon(weapon: WeaponData):
	if not weapon:
		return
	
	current_weapon = weapon
	
	# 1. 切换 Spine 皮肤
	if spine_sprite:
		var skeleton = spine_sprite.get_skeleton()
		# 假设武器名对应 Spine 中的皮肤名
		skeleton.set_skin_by_name(weapon.name)
		skeleton.set_to_setup_pose()
	
	# 2. 更新基础攻击力（作为备份或显示用）
	attack_power = (weapon.damage_min + weapon.damage_max) / 2.0
	print("切换武器: %s, 武器伤害范围: %d-%d, 关联属性: %s" % [weapon.name, weapon.damage_min, weapon.damage_max, weapon.skill])
