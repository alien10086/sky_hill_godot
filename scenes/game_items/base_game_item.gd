extends Control
class_name  BaseGameItemUI
@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2
@onready var label: Label = $Label
@export var input_item_data: ItemData

var is_hovered: bool = false
var item_manager:ItemManager

func _ready() -> void:
	item_manager = ItemManager.get_instance()
	var temp_item_data:ItemData = item_manager.get_item_by_identity("coin")
	texture_rect.texture = temp_item_data.load_icon()
	label.text = temp_item_data.identity

func init_from_input_item_data():
	if input_item_data:
		texture_rect.texture = input_item_data.load_icon()
		label.text = input_item_data.identity
		

func _update_hovered_bottom_border_visibility():
	if is_hovered:
		texture_rect_2.visible = true
	else:
		texture_rect_2.visible = false
		


func _on_mouse_entered() -> void:
	print(123)
	is_hovered = true
	_update_hovered_bottom_border_visibility()
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	print(456)
	is_hovered = false
	_update_hovered_bottom_border_visibility()
	pass # Replace with function body.
