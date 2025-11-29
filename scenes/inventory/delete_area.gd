extends Control

signal item_deleted(item_data:ItemData)
@onready var texture_rect: TextureRect = $TextureRect





	

# 2. 检查是否可以放置
func _can_drop_data(at_position, data)-> bool:
	# 检查数据里是否有我们定义的 "origin_node"
	if typeof(data) != TYPE_DICTIONARY or not data.has("origin_node"):
		return false
	
	# 获取物品数据
	var item_data:ItemData = data.get("item_data", null)
	
	# 如果没有物品数据，不允许放置
	if not item_data:
		return false
	
	return true
	
 #3. 处理放置逻辑
func _drop_data(at_position, data):
	var dragged_item = data["origin_node"]
	var origin_slot = data["origin_slot"]
	var dropped_item_data = data.get("item_data", null)
			
	item_deleted.emit(dropped_item_data)



func _on_mouse_entered() -> void:
	texture_rect.self_modulate = Color(1.171, 0.132, 0.379)



func _on_mouse_exited() -> void:
	texture_rect.self_modulate = Color("ffffff")
