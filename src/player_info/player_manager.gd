extends Node

class_name PlayerManager

static var instance:PlayerManager

func _init():
	if instance == null:
		instance = self
	else:
		queue_free()
		
## 获取单例实例
static func get_instance() ->PlayerManager:
	if instance == null:
		instance = PlayerManager.new()
	return instance


# 游戏模式
enum GameMode { EXPLORATION, BATTLE }
var current_mode: GameMode = GameMode.EXPLORATION

# 玩家数据
var player_data = {
	"name": "PREEY JASON",
	"level": 1,
	"current_exp": 0,
	"max_exp": 50,
	"skill_points": 0,
	"attributes": {
		"strength": 5,
		"speed": 5,
		"dexterity": 5,
		"accuracy": 5
	},
	"health": {
		"current": 100,
		"max": 100
	},
	"hunger": {
		"current": 100,
		"max": 100
	},
	"speed": 100,
	"speed_mode": 0, # 0: 正常, 1: 快速, 2: 超快
	"explored_floors": [], # 记录已探索的楼层索引 (中心区域)
	"explored_rooms": [], # 记录已探索的房间标识，格式如 "100_left", "100_right"
	"defeated_monsters": [], # 记录已击败的怪物，格式如 "100_left", "99_right"
	"floor_data": {}, # 记录楼层持久化数据，如背景索引：{floor_index: {"left_bg": 0, "right_bg": 5}}
	"last_world_position": Vector2.ZERO, # 记录进入战斗前在主世界的位置
	"current_weapon": null, # 当前装备的武器 ItemData
	"current_floor": 100, # 记录当前所在的楼层
	"attack_mode": "normal", # "normal" (直接攻击) 或 "focused" (部位选择)
	"battle_context": { # 战斗上下文
		"monster_type": "", # big_fat 或 long_arm
		"monster_scene_path": "", # 怪物的场景文件路径
		"monster_hp": 0,
		"floor_index": -1,
		"room_type": "" # "left" 或 "right"
	}
}
# 存档文件路径
const SAVE_PATH = "user://savegame.json"

# 信号定义
signal level_changed(new_level:int)
signal exp_changed(current_exp:int, max_exp:int)
signal skill_points_changed(points:int)
signal attribute_changed(attribute_name:String, new_value:int)
signal health_changed(current_health:int, max_health:int)
signal hunger_changed(current_hunger:int, max_hunger:int)
signal speed_changed()
signal floor_explored(floor_index: int)
signal room_explored(room_id: String)
signal game_mode_changed(new_mode: GameMode)
signal weapon_changed(new_weapon: ItemData)

# 设置武器
func set_current_weapon(weapon: ItemData):
	player_data.current_weapon = weapon
	weapon_changed.emit(weapon)
	print("玩家装备了武器: ", weapon.identity if weapon else "徒手")

# 设置等级
func set_level(new_level: int):
	player_data.level = new_level
	level_changed.emit(new_level)

# 记录探索过的楼层
func mark_floor_as_explored(floor_index: int):
	if not floor_index in player_data.explored_floors:
		player_data.explored_floors.append(floor_index)
		floor_explored.emit(floor_index)

# 检查楼层是否已探索
func is_floor_explored(floor_index: int) -> bool:
	return floor_index in player_data.explored_floors

# 记录探索过的房间
func mark_room_as_explored(room_id: String):
	if not room_id in player_data.explored_rooms:
		player_data.explored_rooms.append(room_id)
		room_explored.emit(room_id)

# 检查房间是否已探索
func is_room_explored(room_id: String) -> bool:
	return room_id in player_data.explored_rooms

# 增加经验值
func add_exp(exp_amount: int):
	player_data.current_exp += exp_amount
	
	# 检查是否升级
	while player_data.current_exp >= player_data.max_exp:
		player_data.current_exp -= player_data.max_exp
		player_data.level += 1
		player_data.skill_points += 1  # 升级获得技能点
		player_data.max_exp = int(player_data.max_exp * 1.5)  # 提升下一级所需经验
		level_changed.emit(player_data.level)
		skill_points_changed.emit(player_data.skill_points)
	
	exp_changed.emit(player_data.current_exp, player_data.max_exp)
	
# 设置技能点
func set_skill_points(points: int):
	player_data.skill_points = points
	skill_points_changed.emit(points)
	

# 使用技能点增加属性
func increase_attribute(attribute_name: String, amount: int = 1) -> bool:
	if player_data.skill_points >= amount:
		match attribute_name.to_lower():
			"strength", "str":
				player_data.attributes.strength += amount
				attribute_changed.emit("strength", player_data.attributes.strength)
			"speed", "spd":
				player_data.attributes.speed += amount
				attribute_changed.emit("speed", player_data.attributes.speed)
			"dexterity", "dex":
				player_data.attributes.dexterity += amount
				attribute_changed.emit("dexterity", player_data.attributes.dexterity)
			"accuracy":
				player_data.attributes.accuracy += amount
				attribute_changed.emit("accuracy", player_data.attributes.accuracy)
			_:
				print("未知的属性名: " + attribute_name)
				return false
		
		player_data.skill_points -= amount
		skill_points_changed.emit(player_data.skill_points)
		return true
	return false
	

# 直接设置属性值
func set_attribute(attribute_name: String, value: int):
	match attribute_name.to_lower():
		"strength", "str":
			player_data.attributes.strength = value
			attribute_changed.emit("strength", value)
		"speed", "spd":
			player_data.attributes.speed = value
			attribute_changed.emit("speed", value)
		"dexterity", "dex":
			player_data.attributes.dexterity = value
			attribute_changed.emit("dexterity", value)
		"accuracy":
			player_data.attributes.accuracy = value
			attribute_changed.emit("accuracy", value)
		_:
			print("未知的属性名: " + attribute_name)



# 设置生命值
func set_health(current: int, max_health: int = -1):
	player_data.health.current = clamp(current, 0, player_data.health.max)
	if max_health > 0:
		player_data.health.max = max_health
		player_data.health.current = min(player_data.health.current, player_data.health.max)
	health_changed.emit(player_data.health.current, player_data.health.max)


# 增加或减少生命值
func modify_health(amount: int):
	player_data.health.current = clamp(player_data.health.current + amount, 0, player_data.health.max)
	health_changed.emit(player_data.health.current, player_data.health.max)
	
	# 检查死亡
	if player_data.health.current <= 0:
		_on_player_death()

func _on_player_death():
	print("玩家死亡，跳转到结算场景")
	# 检查是否在场景树中，如果在，可以使用 SceneTree 的 timer
	if is_inside_tree():
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		# 如果不在场景树中（可能是刚初始化或单例模式问题），直接跳转
		# 或者通过主循环获取场景树
		Engine.get_main_loop().change_scene_to_file("res://scenes/game_over.tscn")



# 设置饥饿度
func set_hunger(current: int, max_hunger: int = -1):
	var old_hunger = player_data.hunger.current
	player_data.hunger.current = clamp(current, 0, player_data.hunger.max)
	if max_hunger > 0:
		player_data.hunger.max = max_hunger
		player_data.hunger.current = min(player_data.hunger.current, player_data.hunger.max)
	
	hunger_changed.emit(player_data.hunger.current, player_data.hunger.max)
	
	# 如果饥饿度增加（吃食物），播放音效
	if player_data.hunger.current > old_hunger:
		_play_after_food_sfx()

# 增加或减少饥饿度
func modify_hunger(amount: int):
	var old_hunger = player_data.hunger.current
	player_data.hunger.current = clamp(player_data.hunger.current + amount, 0, player_data.hunger.max)
	hunger_changed.emit(player_data.hunger.current, player_data.hunger.max)
	
	# 如果饥饿度增加（吃食物），播放音效
	if player_data.hunger.current > old_hunger:
		_play_after_food_sfx()

# 设置游戏模式
func set_game_mode(new_mode: GameMode):
	if current_mode != new_mode:
		current_mode = new_mode
		game_mode_changed.emit(new_mode)
		print("游戏模式切换为: ", "战斗模式" if new_mode == GameMode.BATTLE else "探索模式")

# 记录击败怪物
func mark_monster_as_defeated(monster_id: String):
	if not player_data.defeated_monsters.has(monster_id):
		player_data.defeated_monsters.append(monster_id)
		print("怪物已击败: ", monster_id)
		save_game() # 自动存档

# 检查怪物是否已击败
func is_monster_defeated(monster_id: String) -> bool:
	return player_data.defeated_monsters.has(monster_id)

## --- 存档系统 ---

# 保存游戏
func save_game():
	# 处理不能直接序列化的 Vector2
	var data_to_save = player_data.duplicate(true)
	data_to_save.last_world_position = {
		"x": player_data.last_world_position.x,
		"y": player_data.last_world_position.y
	}
	
	# 如果有武器，目前只记录 identity，加载时再重新获取数据对象
	if data_to_save.current_weapon:
		data_to_save.current_weapon_id = data_to_save.current_weapon.identity
		data_to_save.erase("current_weapon")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_to_save)
		file.store_string(json_string)
		file.close()
		print("游戏已保存到: ", SAVE_PATH)

# 加载游戏
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("未找到存档文件")
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var loaded_data = json.data
			
			# 恢复 Vector2
			if loaded_data.has("last_world_position"):
				player_data.last_world_position = Vector2(
					loaded_data.last_world_position.x,
					loaded_data.last_world_position.y
				)
			
			# 恢复武器
			if loaded_data.has("current_weapon_id"):
				var weapon_id = loaded_data.current_weapon_id
				var item_manager = ItemManager.get_instance()
				if item_manager:
					player_data.current_weapon = item_manager.get_item_by_identity(weapon_id)
			
			# 合并其他简单数据
			for key in loaded_data.keys():
				if key != "last_world_position" and key != "current_weapon_id":
					player_data[key] = loaded_data[key]
			
			print("存档加载成功")
			return true
	return false

# 检查是否存在存档
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# 删除存档
func delete_save_file():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("存档已删除")

func _play_after_food_sfx():
	var sfx = load("res://assets/audio/sfx/after_food.wav")
	if sfx:
		AudioManager.play_sfx(sfx)

func set_speed(speed_number:int):
	player_data.speed = speed_number
	speed_changed.emit()

func set_speed_mode(mode: int):
	player_data.speed_mode = mode
	match mode:
		0: set_speed(100)
		1: set_speed(200)
		2: set_speed(300)
	print("游戏速度模式设置为: ", mode)
	

# 获取玩家数据
func get_player_data():
	return player_data.duplicate(true)
	
# 重置所有属性为默认值
func reset_all_attributes():
	set_level(1)
	player_data.current_exp = 0
	player_data.max_exp = 50
	set_skill_points(0)
	set_attribute("strength", 5)
	set_attribute("speed", 5)
	set_attribute("dexterity", 5)
	set_attribute("accuracy", 5)
	set_health(100, 100)
	set_hunger(100, 100)
	set_speed_mode(0) # 重置速度模式为正常
	player_data.defeated_monsters = []
	player_data.floor_data = {}
	player_data.explored_rooms = []
	player_data.explored_floors = []
	print("重置所有持久化游戏数据")
