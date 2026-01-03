extends CharacterBody2D


@onready var front_weapone_bone_2d: Bone2D = $Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D

@onready var front_weapon_sprite_2d: Sprite2D = $Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D/frontWeaponSprite2D
@onready var back_weapon_sprite_2d: Sprite2D = $Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D/backWeaponSprite2D
@onready var back_weapon_bone_2d: Bone2D = $Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D



var weapon_manager: WeaponManager
# 武器纹理资源路径
#const WEAPON_TEXTURE_PATH = "res://resources/weapon_atlas_texture/"
# 当前显示的武器ID
var current_weapon_name:String = "bat"
var current_weapon_data:WeaponData

#@onready var weapon_sprite: Sprite2D = $Sprite2D

# 设置指定武器
func set_weapon(weapon_name: String):
	current_weapon_name = weapon_name
	var weapon_data:WeaponData = weapon_manager.get_weapon_by_name(weapon_name)
	current_weapon_data = weapon_data
	
	refresh_weapon_show()
	
	
func refresh_weapon_show():
	var texture = current_weapon_data.load_icon()
		#if texture:
	front_weapon_sprite_2d.texture = texture
	back_weapon_sprite_2d.texture = texture
		
		# 获取纹理的尺寸信息
	#var texture_height = texture.region.size.y
	#var texture_width = texture.region.size.x
		
	# 设置精灵位置，使图片底端对齐到(0,0)
	#weapon_sprite.position = Vector2(0, -texture_height)
		
	# 设置精灵中心点为底部中心
	#weapon_sprite.offset = Vector2(texture_width / 2, texture_height)
		



func _ready():	
	weapon_manager = WeaponManager.get_instance()
	weapon_manager.load_weapons()
	
	set_weapon(current_weapon_name)
