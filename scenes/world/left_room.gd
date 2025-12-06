extends Control

@onready var background: TextureRect = $background

@export var input_background: CompressedTexture2D = null


func _ready() -> void:
	
	pass
	
	

func _update_all():
	if input_background:
		background.texture = input_background
		
