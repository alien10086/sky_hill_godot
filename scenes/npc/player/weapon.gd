extends Node2D

# 武器纹理资源路径
const WEAPON_TEXTURE_PATH = "res://resources/weapon_atlas_texture/"

# 当前显示的武器ID
var current_weapon_id = 0
@onready var weapon_sprite: Sprite2D = $Sprite2D


func _ready():	
	# 加载默认武器
	load_weapon(28)

# 加载指定ID的武器纹理
func load_weapon(weapon_id: int):
	var texture_path = WEAPON_TEXTURE_PATH + str(weapon_id) + ".tres"
	var texture = load(texture_path)
	
	if texture:
		weapon_sprite.texture = texture
		
		# 获取纹理的尺寸信息
		var texture_height = texture.region.size.y
		var texture_width = texture.region.size.x
		
		# 设置精灵位置，使图片底端对齐到(0,0)
		weapon_sprite.position = Vector2(0, -texture_height)
		
		# 设置精灵中心点为底部中心
		#weapon_sprite.offset = Vector2(texture_width / 2, texture_height)
		
		current_weapon_id = weapon_id
		print("加载武器 ID: ", weapon_id, " 尺寸: ", texture_width, "x", texture_height)
	else:
		print("无法加载武器纹理: ", texture_path)

# 切换到下一个武器
func next_weapon():
	var next_id = (current_weapon_id + 1) % 72  # 假设有72个武器(0-71)
	load_weapon(next_id)

# 切换到上一个武器
func previous_weapon():
	var prev_id = (current_weapon_id - 1) % 72
	if prev_id < 0:
		prev_id = 71
	load_weapon(prev_id)

# 设置指定武器
func set_weapon(weapon_id: int):
	if weapon_id >= 0 and weapon_id < 72:
		load_weapon(weapon_id)
