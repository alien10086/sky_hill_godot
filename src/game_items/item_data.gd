extends Resource

class_name ItemData

enum ItemType {
	WEAPON,      # 武器
	FOOD,        # 食物
	MEDICAL,     # 医疗物品
	MATERIAL,    # 材料
	OTHER,       # 其他物品
	SPECIAL,     # 特殊物品
	STORYLINE,   # 故事线物品
	UPGRADES,    # 升级物品
	HAND         # 手
}


# 基础属性（对应 game_items 表）
@export var id: int = 0                      # 主键
@export var identity: String = ""                # 物品ID
@export var canUse: bool = false             # 是否可使用
@export var storage: String = ""              # 存储类型
@export var sprite: String = ""              # 精灵图
@export var display_name: String = ""        # 显示名称
@export var type: ItemType = ItemType.OTHER  # 物品类型
@export var can_drop: bool = true            # 是否可丢弃
@export var drop_percent: float = 0.0       # 丢弃概率
@export var description: String = ""         # 物品描述
@export var size: int = 1       

# 缓存的图标纹理（运行时加载）
var icon: CompressedTexture2D = null

var base_sprite_path: String = "res://assets/sprites/game_items/" 


## 加载图标纹理（延迟加载）
func load_icon() -> CompressedTexture2D:

	if icon == null:
		var path
		if sprite == "":
			path = base_sprite_path + "stick.png"
		else:
			path = base_sprite_path + "%s.png" % sprite
		if ResourceLoader.exists(path):
			icon = load(path)
	return icon          
