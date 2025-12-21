extends Node2D

class_name LevelxUI


# 房间模板路径
const ROOM_TEMPLATES = [
	"res://scenes/world/normal_room_template/base_room_1.tscn",
	"res://scenes/world/normal_room_template/base_room_2.tscn",
	"res://scenes/world/normal_room_template/base_room_3.tscn",
	"res://scenes/world/normal_room_template/base_room_4.tscn"
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






var wall_paper_manager: WallpaperManager

func _ready() -> void:
	wall_paper_manager = WallpaperManager.get_instance()
	
	# 随机选择房间模板并替换左右房间
	_replace_left_room_templates()
	_replace_right_room_templates()
	

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
	left_room_parent.add_child(new_left_room)
	left_room = new_left_room
	
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
	right_room_parent.add_child(new_right_room)
	right_room = new_right_room
	
func set_right_room_bg(number:int):
	
	var wall_paper_data: WallpaperData =  wall_paper_manager.get_wallpaper_by_id(number)
	right_room.input_bg = wall_paper_data.icon
	right_room.refresh_ui()

func set_left_room_bg(number:int):
	
	var wall_paper_data: WallpaperData = wall_paper_manager.get_wallpaper_by_id(number)
	left_room.input_bg = wall_paper_data.icon
	left_room.refresh_ui()
	
func set_level(floor_number:int):
	center_room.level_number = floor_number
	center_room.refresh_ui()
	

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
	
