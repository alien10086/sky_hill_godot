extends Resource

class_name InventoryItem

# 物品唯一标识符
var identity: String
# 物品数量
var quantity: int

# 构造函数
func _init(item_identity: String = "", item_quantity: int = 1):
	identity = item_identity
	quantity = item_quantity

# 设置物品数量
func set_quantity(new_quantity: int) -> void:
	quantity = max(0, new_quantity)

# 增加物品数量
func add_quantity(amount: int) -> void:
	quantity += amount
	
# 减少物品数量
func remove_quantity(amount: int) -> bool:
	if quantity >= amount:
		quantity -= amount
		return true
	return false
	
# 检查是否有足够的数量
func has_quantity(amount: int) -> bool:
	return quantity >= amount
