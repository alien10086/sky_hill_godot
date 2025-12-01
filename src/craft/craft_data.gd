extends Node
class_name CraftData

enum CraftCategory {
	WEAPONS,    # 武器
	FOOD,        # 食物
	MEDICAL,     # 医疗物品
	OTHERS,      # 其他物品
	UPGRADES,     # 升级物品
}

# 基础属性（对应 craft.json 表）
@export var id: int = 0                      # 配方ID
@export var identity_1: String = ""          # 材料物品1
@export var identity_2: String = ""          # 材料物品2
@export var identity_3: String = ""          # 材料物品3
@export var identity_4: String = ""          # 材料物品4
@export var result_identity: String = ""      # 结果物品
@export var category: CraftCategory = CraftCategory.OTHERS  # 合成类别
@export var need_home: bool = false         # 是否需要在家
@export var is_known: bool = true           # 是否已知
@export var need: String = ""               # 需要的设备



# 获取所有材料物品身份标识
func get_material_identities() -> Array[String]:
	var identities: Array[String] = []
	
	if not identity_1.is_empty():
		identities.append(identity_1)
	if not identity_2.is_empty():
		identities.append(identity_2)
	if not identity_3.is_empty():
		identities.append(identity_3)
	if not identity_4.is_empty():
		identities.append(identity_4)
	
	return identities

# 获取材料数量
func get_material_count() -> int:
	var count = 0
	if not identity_1.is_empty():
		count += 1
	if not identity_2.is_empty():
		count += 1
	if not identity_3.is_empty():
		count += 1
	if not identity_4.is_empty():
		count += 1
	return count
	
# 检查是否包含指定材料
func has_material(identity: String) -> bool:
	return identity == identity_1 or identity == identity_2 or identity == identity_3 or identity == identity_4


# 获取类别名称
func get_category_name() -> String:
	match category:
		CraftCategory.WEAPONS: return "weapons"
		CraftCategory.MEDICAL: return "medical"
		CraftCategory.OTHERS: return "others"
		CraftCategory.UPGRADES: return "upgrades"
		CraftCategory.FOOD: return "food"
		_: return "unknown"
