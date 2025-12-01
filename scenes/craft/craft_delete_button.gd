extends Control

# 定义删除信号
signal delete_now_craft
@onready var texture_rect: TextureRect = $TextureRect


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 发出删除信号
		delete_now_craft.emit()
	


func _on_mouse_entered() -> void:
	texture_rect.self_modulate = Color(1.91, 1.91, 1.91)


func _on_mouse_exited() -> void:
	texture_rect.self_modulate =Color("ffffff")
	
