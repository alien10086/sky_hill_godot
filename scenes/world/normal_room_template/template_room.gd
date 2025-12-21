extends Node2D
class_name  TemplateRoomUI

@onready var base_room: BaseRoomUI = $BaseRoom

@export var input_bg: CompressedTexture2D

@onready var all_room_ornament: Node2D = $all_room_ornament



func _ready() -> void:
	
	refresh_ui()

func refresh_ui():
	if input_bg:
		base_room.input_bg = input_bg
		base_room.refresh_ui()
		
func set_room_ornament_offset(x_offset:float):
	all_room_ornament.position.x = all_room_ornament.position.x + x_offset
