extends Node2D
class_name  TemplateRoomUI

@onready var base_room: BaseRoomUI = $BaseRoom

@export var input_bg: CompressedTexture2D


func _ready() -> void:
	
	refresh_ui()

func refresh_ui():
	if input_bg:
		base_room.input_bg = input_bg
		base_room.refresh_ui()
