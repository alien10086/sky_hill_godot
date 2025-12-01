extends Control

@onready var texture_rect: TextureRect = $TextureRect

signal build_now_craft



func _on_mouse_entered() -> void:
	texture_rect.self_modulate = Color(1.91, 1.91, 1.91)


func _on_mouse_exited() -> void:
	texture_rect.self_modulate =Color("ffffff")



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		build_now_craft.emit()
