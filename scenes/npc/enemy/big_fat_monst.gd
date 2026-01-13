extends Node2D
@onready var spine_sprite: SpineSprite = $SpineSprite
@onready var area_2d: Area2D = $Area2D

const ENEMY_AVATAR = preload("res://scenes/npc/enemy/enemy_avatar.tscn")

# 战斗属性
@export var max_hp: float = 100.0
var current_hp: float = 100.0
@export var attack_power: float = 10.0

var hp_ui: Control

signal monster_clicked(monster)
signal died(monster)
signal hp_changed(current, max)

func _ready() -> void:
	current_hp = max_hp
	_setup_hp_ui()
	area_2d.input_event.connect(_on_area_input_event)

func _setup_hp_ui():
	hp_ui = ENEMY_AVATAR.instantiate()
	add_child(hp_ui)
	hp_ui.scale = Vector2(0.5, 0.5) # UI 默认很大，缩放一下
	hp_ui.position = Vector2(-150, -450) # 怪物头顶
	hp_ui.set_avatar_type(true) # Big Fat
	hp_ui.update_hp(current_hp, max_hp)

func take_damage(amount: float):
	current_hp -= amount
	if hp_ui:
		hp_ui.update_hp(current_hp, max_hp)
	hp_changed.emit(current_hp, max_hp)
	play_animation("hit", false)
	if current_hp <= 0:
		die()

func die():
	died.emit(self)
	play_animation("die", false)
	# 可以等待动画结束后 queue_free()
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func random_skin():
	var skins = ["default", "chef", "empty", "police"]
	# 随机选择一个皮肤
	var random_skin = skins[randi() % skins.size()]
	set_skin(random_skin)
	print("怪物初始化皮肤: ", random_skin)
	
	#play_animation("attcak", true)

#func _setup_clickable_area():
	#var area = Area2D.new()
	#var collision = CollisionShape2D.new()
	#var shape = RectangleShape2D.new()
	#shape.size = Vector2(150, 200) # 根据怪物大小调整
	#collision.shape = shape
	#area.add_child(collision)
	#add_child(area)
	#area.input_pickable = true
	#area.input_event.connect(_on_area_input_event)

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		monster_clicked.emit(self)

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

# 停止动画函数
func stop_animation(track_index: int = 0) -> void:
	if spine_sprite:
		var animation_state = spine_sprite.get_animation_state()
		animation_state.clear_track(track_index)
		# 恢复到初始姿势
		spine_sprite.get_skeleton().set_to_setup_pose()
