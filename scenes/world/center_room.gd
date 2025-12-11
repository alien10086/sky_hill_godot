extends Node2D
@onready var label: Label = $Label

@export var level_number: int

func _ready() -> void:
	refresh_ui()
		
func refresh_ui():
	if level_number:
		label.text = str(level_number)
	
