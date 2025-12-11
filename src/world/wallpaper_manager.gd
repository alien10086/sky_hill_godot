extends Node

class_name WallpaperManager

# 单例实例
static var instance: WallpaperManager

# 所有墙纸数据
var all_wallpapers: Array[WallpaperData] = []
# 墙纸加载状态
var is_loaded: bool = false

func _init():
	if instance == null:
		instance = self
	else:
		queue_free()
		
# 获取单例实例
static func get_instance() -> WallpaperManager:
	if instance == null:
		instance = WallpaperManager.new()
	return instance
	

# 加载所有墙纸数据（硬编码）
func load_wallpapers():
	if is_loaded:
		return
	
	# 硬编码加载所有墙纸
	for i in range(26):  # 0-25
		var wallpaper = WallpaperData.new()
		wallpaper.id = i
		wallpaper.name = "墙纸 " + str(i)
		wallpaper.texture_path = "res://assets/sprites/world_items/normal_room/wallpaper/wallpaper_" + str(i) + ".png"
		wallpaper.icon = load(wallpaper.texture_path) as CompressedTexture2D
		all_wallpapers.append(wallpaper)
	
	is_loaded = true
	print("已加载 ", all_wallpapers.size(), " 个墙纸")
	

# 根据ID获取墙纸
func get_wallpaper_by_id(id: int) -> WallpaperData:
	if not is_loaded:
		load_wallpapers()
	
	if id >= 0 and id < all_wallpapers.size():
		return all_wallpapers[id]
	
	print("警告: 未找到ID为 ", id, " 的墙纸")
	return null
