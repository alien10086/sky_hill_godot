extends Control


signal bag_open
signal bag_close
@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2

var is_open:bool = false
var normal_color = Color(1.0, 1.0, 1.0)
var open_color =  Color(0.439, 0.439, 0.439)

func _on_button_pressed() -> void:
	is_open = !is_open
	
	print("123123", is_open)
	
	if is_open:
		texture_rect_2.visible = true
		texture_rect.self_modulate = open_color
		bag_open.emit()
		
	else:
		texture_rect_2.visible = false
		texture_rect.self_modulate = normal_color
		bag_close.emit()
	
