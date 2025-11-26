extends Node
class_name ItemManager

# 所有物品数据
var all_items: Array[ItemData] = []
# 按身份标识索引的物品
var items_by_identity: Dictionary = {}
# 物品加载状态
var is_loaded: bool = false

var _item_data_file_path: String = "res://resources/static_data/game_items.json"

# 单例实例
static var instance: ItemManager

func _init():
	if instance == null:
		instance = self
	else:
		queue_free()
		
## 获取单例实例
static func get_instance() -> ItemManager:
	if instance == null:
		instance = ItemManager.new()
	return instance
	

## 解析物品类型字符串
func _parse_item_type(type_str: String) -> ItemData.ItemType:
	match type_str.to_lower():
		"weapon": return ItemData.ItemType.WEAPON
		"food": return ItemData.ItemType.FOOD
		"medical": return ItemData.ItemType.MEDICAL
		"material": return ItemData.ItemType.MATERIAL
		"others": return ItemData.ItemType.OTHER
		"special": return ItemData.ItemType.SPECIAL
		"storyline": return ItemData.ItemType.STORYLINE
		"upgrades": return ItemData.ItemType.UPGRADES
		_: return ItemData.ItemType.HAND
	
## 从 JSON 数据创建 ItemData 对象
func _create_item_from_json(data: Dictionary) -> ItemData:
	var item = ItemData.new()
	
	# 设置基本属性
	if data.has("id"):
		item.id = data["id"]
	
	if data.has("identity"):
		item.identity = data["identity"]
	
	if data.has("display_name"):
		item.dysplay_name = data["display_name"]
	
	if data.has("description"):
		var description = data["description"]
		if description is String:
			item.description = description
		else:
			item.description = str(description)
	
	if data.has("sprite"):
		item.sprite = data["sprite"]
	
	if data.has("type"):
		var type_str = str(data["type"]).to_lower()
		item.type = _parse_item_type(type_str)

	item.canUse = data["canUse"]

	item.can_drop = data["can_drop"]
	
	if data.has("storage"):
		item.storage = data["storage"]
	
	if data.has("size"):
		var size = data["size"]
		if size is String:
			if size.is_empty():
				item.size = 1
			else:
				item.size = int(size)
		elif size is int:
			item.size = size
		else:
			item.size = 1
	
	return item
	
## 从 JSON 文件加载所有物品数据
func load_all_items() -> Array[ItemData]:
	var items: Array[ItemData] = []
	
	# 检查文件是否存在
	if not FileAccess.file_exists(_item_data_file_path):
		print("错误: 物品数据文件不存在: ", _item_data_file_path)
		return items
	
	# 打开文件
	var file = FileAccess.open(_item_data_file_path, FileAccess.READ)
	if file == null:
		print("错误: 无法打开物品数据文件: ", _item_data_file_path)
		return items
	
	# 读取文件内容
	var json_text = file.get_as_text()
	file.close()
	
	# 解析 JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("错误: 无法解析物品数据 JSON: ", parse_result)
		return items
	
	# 获取数据数组
	var data = json.data
	if not data is Array:
		print("错误: 物品数据格式不正确，应为数组")
		return items
	
	# 创建 ItemData 对象
	for item_data in data:
		if not item_data is Dictionary:
			continue
			
		var item = _create_item_from_json(item_data)
		if item != null:
			items.append(item)
	
	print("从 JSON 加载了 ", items.size(), " 个物品")
	return items
	

## 按身份标识索引物品
func _index_items_by_identity():
	items_by_identity.clear()
	
	for item in all_items:
		if item.identity != "":
			items_by_identity[item.identity] = item

## 加载所有物品数据
func load_items():
	if is_loaded:
		return
	
	all_items = load_all_items()
	_index_items_by_identity()
	is_loaded = true
	print("已加载 ", all_items.size(), " 个物品")

			

## 根据身份标识获取物品
func get_item_by_identity(identity: String) -> ItemData:
	if not is_loaded:
		load_items()
	
	# 如果物品已缓存，直接返回
	if items_by_identity.has(identity):
		return items_by_identity[identity]
	
	# push_error("未找到身份标识为 '%s' 的物品" % identity)
	assert(false, "未找到身份标识为 '%s' 的物品" % identity)
	return null
