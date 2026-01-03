extends CharacterBody2D


@onready var front_weapone_bone_2d: Bone2D = $Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D

@onready var front_weapon_sprite_2d: Sprite2D = $Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D/frontWeaponSprite2D
@onready var back_weapon_sprite_2d: Sprite2D = $Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D/backWeaponSprite2D
@onready var back_weapon_bone_2d: Bone2D = $Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D



var weapon_manager: WeaponManager
# 武器纹理资源路径
#const WEAPON_TEXTURE_PATH = "res://resources/weapon_atlas_texture/"
# 当前显示的武器ID
var current_weapon_name:String = "backsword"
var current_weapon_data:WeaponData

#@onready var weapon_sprite: Sprite2D = $Sprite2D

# 设置指定武器
func set_weapon(weapon_name: String):
	current_weapon_name = weapon_name
	var weapon_data:WeaponData = weapon_manager.get_weapon_by_name(weapon_name)
	current_weapon_data = weapon_data
	
	refresh_weapon_show()
	
	
func refresh_weapon_show():
	var texture:AtlasTexture = current_weapon_data.load_icon()
	if not texture:
		return
		
	front_weapon_sprite_2d.texture = texture
	back_weapon_sprite_2d.texture = texture
	
	# 获取骨骼的角度（弧度）
	var front_angle = front_weapone_bone_2d.bone_angle
	var back_angle = back_weapon_bone_2d.bone_angle
	
	# 设置精灵的旋转角度，使其与骨骼角度一致
	front_weapon_sprite_2d.rotation = front_angle
	back_weapon_sprite_2d.rotation = back_angle
	
	# 如果是 AtlasTexture，我们需要根据其 region 大小来设置偏移，使武器底部对齐骨骼
	var size = texture.region.size
	# 设置偏移，使图片底部中心对齐到骨骼原点
	front_weapon_sprite_2d.offset = Vector2(0, -size.y / 2)
	back_weapon_sprite_2d.offset = Vector2(0, -size.y / 2)



func _ready():	
	weapon_manager = WeaponManager.get_instance()
	weapon_manager.load_weapons()
	
	set_weapon(current_weapon_name)
