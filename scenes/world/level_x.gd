extends Node2D


@onready var right_room: Node2D = $RightRoom
@onready var left_room: Node2D = $LeftRoom
@onready var floorslab: Sprite2D = $Floorslab
@onready var center_room: NormalCenterRoomUI = $centerRoom
@onready var floorshelter: Sprite2D = $Floorshelter


func set_level(floor:int):
	center_room.level_number = floor
	center_room.refresh_ui()
