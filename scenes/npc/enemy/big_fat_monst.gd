extends Node2D
@onready var spine_sprite: SpineSprite = $SpineSprite
@onready var area_2d: Area2D = $Area2D

signal monster_clicked(monster)

func _ready() -> void:
	area_2d.input_event.connect(_on_area_input_event)
	#_setup_clickable_area()
	# 定义可选皮肤列表
	#var skins = ["default", "chef", "empty", "police"]
	## 随机选择一个皮肤
	#var random_skin = skins[randi() % skins.size()]
	#set_skin(random_skin)
	#print("怪物初始化皮肤: ", random_skin)
	pass
	
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
