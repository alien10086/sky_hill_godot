extends Control
class_name  BaseCraftItemUI

# 当物品被选中时发出的信号
signal craft_item_selected(craft_data: CraftData)

@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


@export var input_craft_data: CraftData
@export var input_item_data: ItemData
@export var input_text: String

func _from_init_item_data():

	var texture:CompressedTexture2D = input_item_data.load_icon()
	texture_rect.texture = texture
	if input_text:
		label.text = input_text
	else:
		label.text = ""


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 发出选中信号，传递合成数据
			craft_item_selected.emit(input_craft_data)
