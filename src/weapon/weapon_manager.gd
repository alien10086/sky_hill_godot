extends Node
class_name WeaponManager

# 所有武器数据
var all_weapons: Array[WeaponData] = []
# 按名称索引的武器
var weapons_by_name: Dictionary = {}
# 武器加载状态
var is_loaded: bool = false

var _weapon_data_file_path: String = "res://resources/static_data/weapons.json"

# 单例实例
static var instance: WeaponManager

func _init():
	if instance == null:
		instance = self
	else:
		queue_free()

## 获取单例实例
static func get_instance() -> WeaponManager:
	if instance == null:
		instance = WeaponManager.new()
	return instance

## 从 JSON 数据创建 WeaponData 对象
func _create_weapon_from_json(data: Dictionary) -> WeaponData:
	var weapon = WeaponData.new()
	
	if data.has("name"):
		weapon.name = data["name"]
	
	if data.has("skill"):
		weapon.skill = data["skill"]
	
	if data.has("skill_border"):
		weapon.skill_border = int(data["skill_border"])
	
	if data.has("weapon_type"):
		weapon.weapon_type = data["weapon_type"]
	
	if data.has("damage_min"):
		weapon.damage_min = int(data["damage_min"])
	
	if data.has("damage_max"):
		weapon.damage_max = int(data["damage_max"])
	
	if data.has("dex"):
		weapon.dex_num = int(data["dex"])
	
	if data.has("str"):
		weapon.str_num = int(data["str"])
	
	if data.has("spd"):
		weapon.spd_num = int(data["spd"])
	
	return weapon

## 从 JSON 文件加载所有武器数据
func load_all_weapons() -> Array[WeaponData]:
	var weapons: Array[WeaponData] = []
	
	# 检查文件是否存在
	if not FileAccess.file_exists(_weapon_data_file_path):
		print("错误: 武器数据文件不存在: ", _weapon_data_file_path)
		return weapons
	
	# 打开文件
	var file = FileAccess.open(_weapon_data_file_path, FileAccess.READ)
	if file == null:
		print("错误: 无法打开武器数据文件: ", _weapon_data_file_path)
		return weapons
	
	# 读取文件内容
	var json_text = file.get_as_text()
	file.close()
	
	# 解析 JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("错误: 无法解析武器数据 JSON: ", parse_result)
		return weapons
	
	# 获取数据数组
	var data = json.data
	if not data is Array:
		print("错误: 武器数据格式不正确，应为数组")
		return weapons
	
	# 创建 WeaponData 对象
	for weapon_data in data:
		if not weapon_data is Dictionary:
			continue
			
		var weapon = _create_weapon_from_json(weapon_data)
		if weapon != null:
			weapons.append(weapon)
	
	print("从 JSON 加载了 ", weapons.size(), " 个武器")
	return weapons

## 按名称索引武器
func _index_weapons_by_name():
	weapons_by_name.clear()
	
	for weapon in all_weapons:
		if weapon.name != "":
			weapons_by_name[weapon.name] = weapon

## 加载所有武器数据
func load_weapons():
	if is_loaded:
		return
	
	all_weapons = load_all_weapons()
	_index_weapons_by_name()
	is_loaded = true
	print("已加载 ", all_weapons.size(), " 个武器")



## 根据名称获取武器
func get_weapon_by_name(name: String) -> WeaponData:
	if not is_loaded:
		load_weapons()
	
	if weapons_by_name.has(name):
		return weapons_by_name[name]
	
	push_error("未找到名称为 '%s' 的武器" % name)
	assert(false, "未找到名称为 '%s' 的武器" % name)
	return null
