extends Node2D

class_name LevelxUI

@export var ui_canvas_layer:CanvasLayer

# 房间模板路径
const ROOM_TEMPLATES = [
	"res://scenes/world/normal_room_template/base_room_1.tscn",
	"res://scenes/world/normal_room_template/base_room_2.tscn",
	"res://scenes/world/normal_room_template/base_room_3.tscn",
	"res://scenes/world/normal_room_template/base_room_4.tscn"
]

# 怪物模板路径
const MONSTER_TEMPLATES = [
	"res://scenes/npc/enemy/bigFatMonst.tscn",
	"res://scenes/npc/enemy/longArmMonst.tscn"
]

@onready var left_room: TemplateRoomUI = $leftRoom
@onready var right_room: TemplateRoomUI = $rightRoom
@onready var center_room: Node2D = $CenterRoom
@onready var left_marker_2d: Marker2D = $leftMarker2D
@onready var center_marker_2d: Marker2D = $centerMarker2D0
@onready var right_marker_2d: Marker2D = $rightMarker2D

@onready var center_marker_2d_1: Marker2D = $centerMarker2D1
@onready var center_marker_2d_2: Marker2D = $centerMarker2D2
@onready var center_marker_2d_3: Marker2D = $centerMarker2D3
@onready var center_marker_2d_4: Marker2D = $centerMarker2D4

@onready var fog_of_war: Sprite2D = $blackbackgroundSprite
@onready var left_room_fog: Sprite2D = $leftRoomBlackBackGround
@onready var right_room_fog: Sprite2D = $rightRoomBlackBackGround

@onready var center_area_2d: Area2D = $centerArea2D
@onready var right_area_2d: Area2D = $rightArea2D
@onready var left_area_2d: Area2D = $leftArea2D

var floor_index: int = -1
var player_manager: PlayerManager
var wall_paper_manager: WallpaperManager

func _ready() -> void:
	player_manager = PlayerManager.get_instance()
	wall_paper_manager = WallpaperManager.get_instance()
	
	player_manager.floor_explored.connect(_on_floor_explored)
	player_manager.room_explored.connect(_on_room_explored)
	
	# 初始化迷雾状态
	_update_fog_visibility()
	
	# 连接触发器信号
	_connect_triggers()

func _update_fog_visibility():
	if floor_index != -1:
		if fog_of_war:
			fog_of_war.visible = !player_manager.is_floor_explored(floor_index)
		if left_room_fog:
			left_room_fog.visible = !player_manager.is_room_explored(str(floor_index) + "_left")
		if right_room_fog:
			right_room_fog.visible = !player_manager.is_room_explored(str(floor_index) + "_right")
		print("$$$")
		print(player_manager.player_data.explored_rooms, player_manager.player_data.explored_floors)
		print("当前楼层:", floor_index, "是否探索:", player_manager.is_floor_explored(floor_index))
		print("当前左房间:", str(floor_index) + "_left", "是否探索:", player_manager.is_room_explored(str(floor_index) + "_left"))
		print("当前右房间:", str(floor_index) + "_right", "是否探索:", player_manager.is_room_explored(str(floor_index) + "_right"))
		print("$$$")
func _on_floor_explored(idx: int):
	if idx == floor_index:
		_update_fog_visibility()

func _on_room_explored(room_id: String):
	if room_id.begins_with(str(floor_index)):
		_update_fog_visibility()

func _connect_triggers():
	if center_area_2d:
		center_area_2d.body_entered.connect(func(body): _on_area_entered(body, "center"))
	if left_area_2d:
		left_area_2d.body_entered.connect(func(body): _on_area_entered(body, "left"))
	if right_area_2d:
		right_area_2d.body_entered.connect(func(body): _on_area_entered(body, "right"))

func _on_area_entered(body: Node2D, type: String):
	if not body is CharacterBody2D or floor_index == -1:
		return
		
	match type:
		"center":
			player_manager.mark_floor_as_explored(floor_index)
		"left":
			player_manager.mark_room_as_explored(str(floor_index) + "_left")
		"right":
			player_manager.mark_room_as_explored(str(floor_index) + "_right")

func _setup_exploration_trigger():
	# 该函数已过时，逻辑并入 _connect_triggers，使用场景中预设的 Area2D
	pass

func _on_player_entered(body: Node2D):
	# 该函数已过时，逻辑并入 _on_area_entered
	pass

func _replace_left_room_templates():
	# 随机选择一个房间模板
	var random_template_index = randi() % ROOM_TEMPLATES.size()
	var template_path = ROOM_TEMPLATES[random_template_index]
	var room_scene =  load(template_path)
	
	# 替换左房间
	var left_room_parent = left_room.get_parent()
	var left_room_position = left_room.position
	left_room.queue_free()
	var new_left_room = room_scene.instantiate()
	new_left_room.name = "LeftRoom"
	new_left_room.position = left_room_position
	new_left_room.ui_canvas_layer = ui_canvas_layer
	left_room_parent.add_child(new_left_room)
	new_left_room.set_room_ornament_offset(-80)
	left_room = new_left_room
	
	# 生成怪物
	_spawn_monster_with_persistence(new_left_room, "left")
	
func _replace_right_room_templates():
	# 随机选择一个房间模板
	var random_template_index = randi() % ROOM_TEMPLATES.size()
	var template_path = ROOM_TEMPLATES[random_template_index]
	var room_scene = load(template_path)
	
	# 替换右房间
	var right_room_parent = right_room.get_parent()
	var right_room_position = right_room.position
	right_room.queue_free()
	var new_right_room = room_scene.instantiate()
	new_right_room.name = "RightRoom"
	new_right_room.position = right_room_position
	new_right_room.ui_canvas_layer = ui_canvas_layer
	right_room_parent.add_child(new_right_room)
	new_right_room.set_room_ornament_offset(80)
	right_room = new_right_room
	
	# 生成怪物
	_spawn_monster_with_persistence(new_right_room, "right")

func _spawn_monster_with_persistence(room_node: Node2D, side: String):
	var monster_id = str(floor_index) + "_" + side
	
	# 检查是否已击败
	if player_manager.is_monster_defeated(monster_id):
		# 如果已击败，显示骷髅头图标
		_show_defeated_icon(room_node)
		return
		
	# 如果没击败，正常生成
	_spawn_random_monster_in_room(room_node)

func _show_defeated_icon(room_node: Node2D):
	var skull_tex = load("res://assets/ui/enemy/skull_head.png")
	if skull_tex:
		var sprite = Sprite2D.new()
		sprite.texture = skull_tex
		sprite.scale = Vector2(0.2, 0.2) # 根据图标大小缩放
		room_node.add_child(sprite)
		sprite.position = Vector2(200, -100) # 悬浮在怪物原位置上方
		
		# 添加一个简单的呼吸悬浮效果
		var tween = create_tween().set_loops()
		tween.tween_property(sprite, "position:y", sprite.position.y - 20, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite, "position:y", sprite.position.y, 1.0).set_trans(Tween.TRANS_SINE)

func _spawn_random_monster_in_room(room_node: Node2D):
	# VIP 楼层 (100层) 不会出现怪物
	if floor_index == 99:
		print("VIP 楼层不生成怪物")
		return
		
	# 随机选择一个怪物模板
	var random_monster_index = randi() % MONSTER_TEMPLATES.size()
	var monster_path = MONSTER_TEMPLATES[random_monster_index]
	var monster_scene = load(monster_path)
	
	# 实例化怪物
	var monster = monster_scene.instantiate()
	monster.add_to_group("monsters")
	# 将怪物添加到房间中
	room_node.add_child(monster)
	
	monster.random_skin()
	
	#random_skin
	
	# 设置怪物的初始位置（通常在房间中心或指定位置）
	# 这里假设房间内有一个默认的中心点或者我们手动设置一个位置
	monster.position = Vector2(200, 0) # 这里的坐标可能需要根据房间内部结构调整

func set_right_room_bg(number:int):
	
	var wall_paper_data: WallpaperData =  wall_paper_manager.get_wallpaper_by_id(number)
	right_room.input_bg = wall_paper_data.icon
	right_room.refresh_ui()

func set_left_room_bg(number:int):
	
	var wall_paper_data: WallpaperData = wall_paper_manager.get_wallpaper_by_id(number)
	left_room.input_bg = wall_paper_data.icon
	left_room.refresh_ui()
	
func set_level(floor_number:int):
	floor_index = floor_number
	center_room.level_number = floor_number
	center_room.refresh_ui()
	_update_fog_visibility()
	
	# 设置楼层后生成房间和怪物
	_replace_left_room_templates()
	_replace_right_room_templates()

	

func get_left_mark_point() -> Vector2:
	return left_marker_2d.global_position
	
func get_center_mark_point() -> Vector2:
	return center_marker_2d.global_position
	
func get_right_mark_point() -> Vector2:
	return right_marker_2d.global_position
	
func get_stairs_bottom_2_top_point_list()->Array:
	return [
		center_marker_2d_1.global_position,
		center_marker_2d_2.global_position,
		center_marker_2d_3.global_position,
		center_marker_2d_4.global_position,
	]
	
