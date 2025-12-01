extends Node
class_name CraftManager

# 合成配方加载状态
var is_loaded: bool = false

var _craft_data_file_path: String = "res://resources/static_data/craft.json"

# 单例实例
static var instance: CraftManager

# 按类别分类的配方
var recipes_by_category: Dictionary = {}
# 所有合成配方数据
var all_recipes: Array[CraftData] = []

# 按结果物品身份标识索引的配方
var recipes_by_result: Dictionary = {}


func _init():
	if instance == null:
		instance = self
	else:
		queue_free()
		
## 获取单例实例
static func get_instance() -> CraftManager:
	if instance == null:
		instance = CraftManager.new()
	return instance
	

## 从 JSON 文件加载所有合成配方数据
func load_all_recipes() -> Array[CraftData]:
	var recipes: Array[CraftData] = []
	
	# 检查文件是否存在
	if not FileAccess.file_exists(_craft_data_file_path):
		print("错误: 合成配方数据文件不存在: ", _craft_data_file_path)
		return recipes
	
	# 打开文件
	var file = FileAccess.open(_craft_data_file_path, FileAccess.READ)
	if file == null:
		print("错误: 无法打开合成配方数据文件: ", _craft_data_file_path)
		return recipes
	
	# 读取文件内容
	var json_text = file.get_as_text()
	file.close()
	
	# 解析 JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("错误: 无法解析合成配方数据 JSON: ", parse_result)
		return recipes
	
	# 获取数据数组
	var data = json.data
	if not data is Array:
		print("错误: 合成配方数据格式不正确，应为数组")
		return recipes
	
	# 创建 CraftData 对象
	for recipe_data in data:
		if not recipe_data is Dictionary:
			continue
			
		var recipe = _create_recipe_from_json(recipe_data)
		if recipe != null:
			recipes.append(recipe)
	
	print("从 JSON 加载了 ", recipes.size(), " 个合成配方")
	return recipes
	

## 从 JSON 数据创建 CraftData 对象
func _create_recipe_from_json(data: Dictionary) -> CraftData:
	var recipe = CraftData.new()
	
	# 设置基本属性
	if data.has("id"):
		recipe.id = data["id"]
	
	if data.has("identity_1"):
		recipe.identity_1 = data["identity_1"]
	
	if data.has("identity_2"):
		recipe.identity_2 = data["identity_2"]
	
	if data.has("identity_3"):
		recipe.identity_3 = data["identity_3"]
	
	if data.has("identity_4"):
		recipe.identity_4 = data["identity_4"]
	
	if data.has("result_identity"):
		recipe.result_identity = data["result_identity"]
	
	if data.has("category"):
		var category_str = str(data["category"]).to_lower()
		recipe.category = _parse_craft_category(category_str)
	
	if data.has("need_home"):
		var need_home = data["need_home"]
		if need_home is bool:
			recipe.need_home = need_home
		elif need_home is String:
			recipe.need_home = need_home.to_lower() == "true"
		else:
			recipe.need_home = false
	
	if data.has("is_known"):
		var is_known = data["is_known"]
		if is_known is bool:
			recipe.is_known = is_known
		elif is_known is String:
			recipe.is_known = is_known.to_lower() == "true"
		else:
			recipe.is_known = true
	
	if data.has("need"):
		recipe.need = data["need"]
	
	return recipe
	
## 解析合成类别字符串
func _parse_craft_category(category_str: String) -> CraftData.CraftCategory:
	match category_str.to_lower():
		"food": return CraftData.CraftCategory.FOOD
		"weapons": return CraftData.CraftCategory.WEAPONS
		"medical": return CraftData.CraftCategory.MEDICAL
		"others": return CraftData.CraftCategory.OTHERS
		"upgrades": return CraftData.CraftCategory.UPGRADES
		_: return CraftData.CraftCategory.OTHERS
		
## 加载所有合成配方数据
func load_recipes():
	if is_loaded:
		return
	
	all_recipes = load_all_recipes()
	_index_recipes_by_category()
	_index_recipes_by_result()
	is_loaded = true
	print("已加载 ", all_recipes.size(), " 个合成配方")
	

## 按类别索引配方
func _index_recipes_by_category():
	recipes_by_category.clear()
	
	# 初始化所有类别
	recipes_by_category[CraftData.CraftCategory.FOOD] = []
	recipes_by_category[CraftData.CraftCategory.WEAPONS] = []
	recipes_by_category[CraftData.CraftCategory.MEDICAL] = []
	recipes_by_category[CraftData.CraftCategory.OTHERS] = []
	recipes_by_category[CraftData.CraftCategory.UPGRADES] = []
	
	# 按类别分类
	for recipe in all_recipes:
		recipes_by_category[recipe.category].append(recipe)
		
## 按结果物品身份标识索引配方
func _index_recipes_by_result():
	recipes_by_result.clear()
	
	for recipe in all_recipes:
		if recipe.result_identity != "":
			recipes_by_result[recipe.result_identity] = recipe
			
## 获取所有配方
func get_all_recipes() -> Array[CraftData]:
	if not is_loaded:
		load_recipes()
	return all_recipes
	
## 根据类别获取配方
func get_recipes_by_category(category: CraftData.CraftCategory) -> Array:
	if not is_loaded:
		load_recipes()
	var recipes = recipes_by_category.get(category, [])
	return recipes
	
## 获取武器配方
func get_weapon_recipes() -> Array[CraftData]:
	return get_recipes_by_category(CraftData.CraftCategory.WEAPONS)

## 获取医疗配方
func get_medical_recipes() -> Array[CraftData]:
	return get_recipes_by_category(CraftData.CraftCategory.MEDICAL)

## 获取其他配方
func get_other_recipes() -> Array[CraftData]:
	return get_recipes_by_category(CraftData.CraftCategory.OTHERS)

## 获取升级配方
func get_upgrade_recipes() -> Array[CraftData]:
	return get_recipes_by_category(CraftData.CraftCategory.UPGRADES)

## 获取食物配方
func get_food_recipes() -> Array[CraftData]:
	return get_recipes_by_category(CraftData.CraftCategory.FOOD)
	

## 检查是否可以进行合成
func can_craft(recipe: CraftData, available_items: Dictionary) -> bool:
	if recipe == null:
		return false
	
	var required_materials = recipe.get_material_identities()
	
	# 检查是否有足够的材料
	#for material in required_materials:
		#aterial in item:
			#var count = 0
		#for item in available_items:
			#if m	
				#pass
				#
			#if item == material:
				#count += 1
		#
		## 简单实现：每种材料至少需要一个
		#if count < 1:
			#return false
	
	return true
