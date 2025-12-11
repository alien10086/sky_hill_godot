extends Node2D


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
	
func set_level(floor:int):
	center_room.level_number = floor
	center_room.refresh_ui()
	
