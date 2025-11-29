extends Node

class_name InventoryManage

# 单例实例
static var _instance: InventoryManage

# 库存物品字典，键为物品identity，值为InventoryItem对象
var inventory_items: Dictionary = {}

# 库存容量限制
var max_slots: int = 999  # 最大槽位数
var max_stack_size: int = 999  # 每个槽位最大堆叠数

# 信号
signal inventory_updated
signal inventory_item_added(item_identity: String, quantity: int)
signal inventory_item_removed(item_identity: String, quantity: int)

# 获取单例实例
static func get_instance() -> InventoryManage:
	if _instance == null:
		_instance = InventoryManage.new()
	return _instance

# 构造函数
func _init():
	if _instance == null:
		_instance = self
	else:
		queue_free()

# 添加物品到库存
func add_item(item_identity: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	
	# 检查库存是否已满
	if inventory_items.size() >= max_slots and not inventory_items.has(item_identity):
		print("库存已满，无法添加物品: ", item_identity)
		return false
	
	# 如果物品已存在，增加数量
	if inventory_items.has(item_identity):
		var inventory_item = inventory_items[item_identity] as InventoryItem
		var new_quantity = inventory_item.quantity + quantity
		
		# 检查是否超过堆叠上限
		if new_quantity > max_stack_size:
			print("物品数量超过堆叠上限: ", item_identity)
			return false
		
		inventory_item.set_quantity(new_quantity)
	else:
		# 创建新的库存物品
		var inventory_item = InventoryItem.new(item_identity, quantity)
		inventory_items[item_identity] = inventory_item
	
	inventory_item_added.emit(item_identity, quantity)
	inventory_updated.emit()
	return true
	


# 从库存中移除物品
func remove_item(item_identity: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	
	if not inventory_items.has(item_identity):
		print("库存中没有物品: ", item_identity)
		return false
	
	var inventory_item = inventory_items[item_identity] as InventoryItem
	
	if not inventory_item.has_quantity(quantity):
		print("物品数量不足: ", item_identity)
		return false
	
	# 如果移除后数量为0，从字典中删除
	if inventory_item.quantity == quantity:
		inventory_items.erase(item_identity)
	else:
		inventory_item.remove_quantity(quantity)
	
	inventory_item_removed.emit(item_identity, quantity)
	
	inventory_updated.emit()
	return true
	
# 获取物品对象
func get_item(item_identity: String) -> InventoryItem:
	if inventory_items.has(item_identity):
		return inventory_items[item_identity] as InventoryItem
	return null
	
# 获取所有库存物品
func get_all_items() -> Dictionary:
	return inventory_items
	
# 检查库存是否为空
func is_empty() -> bool:
	return inventory_items.is_empty()
