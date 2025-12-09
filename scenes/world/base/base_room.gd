extends Node2D
class_name NormalRoomUI

@onready var bg_sprite_2d: Sprite2D = $BgSprite2D
@onready var filter_sprite_2d: Sprite2D = $FilterSprite2D


@export var input_bg: CompressedTexture2D

func _ready() -> void:
	
	refresh_ui()
	
func refresh_ui():
	if input_bg:
		bg_sprite_2d.texture = input_bg
		#bg_sprite_2d.scale.y
