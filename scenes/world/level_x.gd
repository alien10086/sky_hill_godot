extends Node2D


@onready var right_room: NormalRoomUI = $RightRoom
@onready var left_room: NormalRoomUI = $LeftRoom
@onready var floorslab: Sprite2D = $Floorslab
@onready var center_room: NormalCenterRoomUI = $centerRoom
@onready var floorshelter: Sprite2D = $Floorshelter

var wall_paper_manager: WallpaperManager

func _ready() -> void:
	wall_paper_manager = WallpaperManager.get_instance()

func set_level(floor:int):
	center_room.level_number = floor
	center_room.refresh_ui()
	
func set_right_room_bg(number:int):
	
	var wall_paper_data: WallpaperData =  wall_paper_manager.get_wallpaper_by_id(number)
	right_room.input_bg = wall_paper_data.icon
	right_room.refresh_ui()
	
func set_left_room_bg(number:int):
	
	var wall_paper_data: WallpaperData = wall_paper_manager.get_wallpaper_by_id(number)
	left_room.input_bg = wall_paper_data.icon
	left_room.refresh_ui()
