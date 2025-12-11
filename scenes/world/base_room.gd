extends Node2D
class_name BaseRoomUI

@onready var bg_sprite_2d: Sprite2D = $BgSprite2D

@export var input_bg: CompressedTexture2D


func _ready() -> void:
	
	refresh_ui()

func refresh_ui():
	if input_bg:
		bg_sprite_2d.texture = input_bg
