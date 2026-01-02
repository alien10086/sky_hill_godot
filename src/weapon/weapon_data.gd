extends Resource

class_name WeaponData

var name: String = "stick"
var skill: String = "dex"
var skill_border: int = 5
var weapon_type: String = "cold"
var damage_min: int = 2
var damage_max: int = 3
var dex_num: int = 5
var str_num: int = 0
var spd_num: int = 0

# 缓存的图标纹理（运行时加载）
var icon: AtlasTexture = null
var base_sprite_path: String = "res://resources/weapon_atlas_texture/"

## 加载图标纹理（延迟加载）
func load_icon() -> AtlasTexture:
	if icon == null:
		var path = base_sprite_path + "%s.tres" % name
		icon = load(path)

	return icon
