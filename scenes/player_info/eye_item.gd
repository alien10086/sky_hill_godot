extends TextureButton

const UI_EYE = preload("uid://l5pvqrq3vshh")
const UI_EYE_1 = preload("uid://c2f3bp4ife2g0")

@onready var texture_button: TextureButton = $"."


var is_open: bool = false
var inventory_manage: InventoryManage
var item_manager: ItemManager

var origin_color = Color(1.0, 1.0, 1.0)

func _ready() -> void:
	item_manager = ItemManager.get_instance()
	inventory_manage = InventoryManage.get_instance()
	texture_button.texture_normal = UI_EYE
	self_modulate = origin_color
	
	


func _on_pressed() -> void:
	texture_button.texture_normal = UI_EYE_1
	# TODO 在这里生成 随机物品
	is_open = false
	print(666)
	
	self_modulate =  Color(1.0, 1.0, 1.0, 0.561)
	
	var random_item_data =  item_manager.get_random_item()
	# todo 这里需要增加一个 对应 物品的 演示从当前 全局坐标出现 然后 飞到屏幕中间 再飞到屏幕 左下角
	
	
	
	
	inventory_manage.add_item(random_item_data.identity)
	
	
	
	
