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
	"speed": 100
}
# 信号定义
signal level_changed(new_level:int)
signal exp_changed(current_exp:int, max_exp:int)
signal skill_points_changed(points:int)
signal attribute_changed(attribute_name:String, new_value:int)
signal health_changed(current_health:int, max_health:int)
signal hunger_changed(current_hunger:int, max_hunger:int)
signal speed_changed()

# 设置等级
func set_level(new_level: int):
	player_data.level = new_level
	level_changed.emit(new_level)
	
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



# 设置饥饿度
func set_hunger(current: int, max_hunger: int = -1):
	player_data.hunger.current = clamp(current, 0, player_data.hunger.max)
	if max_hunger > 0:
		player_data.hunger.max = max_hunger
		player_data.hunger.current = min(player_data.hunger.current, player_data.hunger.max)
	hunger_changed.emit(player_data.hunger.current, player_data.hunger.max)


# 增加或减少饥饿度
func modify_hunger(amount: int):
	player_data.hunger.current = clamp(player_data.hunger.current + amount, 0, player_data.hunger.max)
	hunger_changed.emit(player_data.hunger.current, player_data.hunger.max)

func set_speed(speed_number:int):
	player_data.speed = speed_number
	speed_changed.emit()
	

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
