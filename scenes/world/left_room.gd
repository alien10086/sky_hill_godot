extends Control

@onready var background: TextureRect = $background

@export var input_background: CompressedTexture2D = null

# 壁纸路径和文件数量
const WALLPAPER_PATH = "res://assets/sprites/world_items/normal_room/wallpaper/"
const WALLPAPER_COUNT = 26  # wallpaper_0.png 到 wallpaper_25.png

# 家具图片路径和对应的文件数量
const FURNITURE_CATEGORIES = {
	"Sofa": {
		"path": "res://assets/sprites/world_items/home_furniture2/Sofa/",
		"count": 35  # Sofa_0.png 到 Sofa_34.png
	},
	"Shelf": {
		"path": "res://assets/sprites/world_items/home_furniture2/Shelf/",
		"count": 53  # Shelf_0.png 到 Shelf_52.png
	},
	"light": {
		"path": "res://assets/sprites/world_items/home_furniture2/light/",
		"count": 46  # light_0.png 到 light_45.png
	},
	"flower": {
		"path": "res://assets/sprites/world_items/home_furniture2/flower/",
		"count": 10  # flower_0.png 到 flower_9.png
	},
	"electronics": {
		"path": "res://assets/sprites/world_items/home_furniture2/electronics/",
		"count": 26  # electronics_0.png 到 electronics_25.png
	},
	"decoration": {
		"path": "res://assets/sprites/world_items/home_furniture2/decoration/",
		"count": 46  # decoration_0.png 到 decoration_45.png
	},
	"Chair": {
		"path": "res://assets/sprites/world_items/home_furniture2/Chair/",
		"count": 12  # Chair_0.png 到 Chair_11.png
	},
	"Cabinet": {
		"path": "res://assets/sprites/world_items/home_furniture2/Cabinet/",
		"count": 53  # Cabinet_0.png 到 Cabinet_52.png
	}
}

# 存储生成的家具TextureRect
var furniture_items: Array[TextureRect] = []

func _ready() -> void:
	# 更新背景
	_update_all()
	
	# 随机生成5-6个家具
	_generate_random_furniture()
	
func _generate_random_furniture():
	# 随机生成5-6个家具
	var furniture_count = randi_range(5, 6)
	
	for i in range(furniture_count):
		# 随机选择一个家具类别
		var categories = FURNITURE_CATEGORIES.keys()
		var selected_category = categories[randi() % categories.size()]
		var category_data = FURNITURE_CATEGORIES[selected_category]
		
		# 随机选择一个图片索引
		var random_index = randi() % category_data.count
		var file_name = selected_category + "_" + str(random_index) + ".png"
		var texture_path = category_data.path + file_name
		
		# 加载纹理
		var texture = load(texture_path)
		if not texture:
			# 如果加载失败，尝试下一个索引
			continue
			
		# 创建TextureRect
		var furniture_rect = TextureRect.new()
		furniture_rect.texture = texture
		furniture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		furniture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		
		# 随机位置和大小
		#var random_x = randi_range(50, size.x - 150)
		#var random_y = randi_range(100, size.y - 150)
		#var random_scale = randf_range(0.3, 0.8)
		
		furniture_rect.position = Vector2(10, 10)
		furniture_rect.scale = Vector2(1, 1)
		
		# 添加到场景
		add_child(furniture_rect)
		furniture_items.append(furniture_rect)
		
		# 确保家具在背景之上
		furniture_rect.z_index = 1

func _update_all():
	# 如果没有指定背景，则随机选择一个壁纸
	if not input_background:
		var random_wallpaper_index = randi() % WALLPAPER_COUNT
		var wallpaper_path = WALLPAPER_PATH + "wallpaper_" + str(random_wallpaper_index) + ".png"
		var wallpaper_texture = load(wallpaper_path)
		if wallpaper_texture:
			background.texture = wallpaper_texture
	else:
		# 使用指定的背景
		background.texture = input_background
