extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0
@onready var sprite_2d: Sprite2D = $Sprite2D



# 动画相关变量
@onready var animation_player = $AnimationPlayer

# 音效资源
var sfx_walk = preload("res://assets/audio/sfx/walk.wav")
var sfx_stairs_up = preload("res://assets/audio/sfx/walk_stairs_up.wav")
var sfx_stairs_down = preload("res://assets/audio/sfx/walk_stairs_down.wav")

# 脚步声控制
var footstep_timer = 0.0
var footstep_interval = 0.4 # 每 0.4 秒播放一次脚步声，可根据 move_speed 调整

@export var my_astar:MyAstar
var current_path_point_list: Array = [] # 存储当前路径点

var player_manager: PlayerManager

func _ready():
	player_manager = PlayerManager.get_instance()
	
	player_manager.speed_changed.connect(_on_speed_changed)
	# 初始化时停止所有动画
	if animation_player:
		animation_player.stop()
	
	
	
	# 启用输入处理，以便接收鼠标点击事件
	#set_process_input(true)
	
func _on_speed_changed():
	var player_data = player_manager.get_player_data()
	move_speed = player_data.speed

func take_damage(amount: float):
	player_manager.modify_health(-amount)
	play_animation("hit", false)
	if player_manager.player_data.health.current <= 0:
		die()

func die():
	play_animation("die", false)
	# 处理死亡逻辑...

func play_animation(anim_name: String, loop: bool = false):
	if animation_player and animation_player.has_animation(anim_name):
		if loop:
			animation_player.play(anim_name)
		else:
			animation_player.play(anim_name)
			# 如果是非循环动画，可以等待播放完成
	elif anim_name == "hit":
		# 如果没有 hit 动画，可以做一个变红效果
		var tween = create_tween()
		sprite_2d.modulate = Color.RED
		tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.2)

func attack(target):
	# 暂时用 walk 动画代替攻击，直到有真正的攻击帧动画
	if animation_player.has_animation("attack"):
		play_animation("attack", false)
	else:
		# 做一个向前的位移效果代表攻击
		var original_pos = sprite_2d.position
		var tween = create_tween()
		var direction = 1.0 if not sprite_2d.flip_h else -1.0
		tween.tween_property(sprite_2d, "position", original_pos + Vector2(50 * direction, 0), 0.1)
		tween.tween_property(sprite_2d, "position", original_pos, 0.1)
	
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(target) and target.has_method("take_damage"):
		return true # 返回 true 表示触发了攻击逻辑
	return false

func _unhandled_input(event):
	# 如果在战斗模式下，禁止点击地面移动
	if PlayerManager.get_instance().current_mode == PlayerManager.GameMode.BATTLE:
		return

	#if event is InputEventMouseButton and event.pressed:
	#print("UI没挡住我，我点到了游戏世界！")
#func _input(event):
	# 检查是否是鼠标左键点击事件
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取鼠标在世界坐标中的位置
		print("UI没挡住我，我点到了游戏世界！")
		var world_position = get_global_mouse_position()
		
		# 如果正在移动，找到合适的路径起点
		var path_start_position = global_position
		if is_moving and current_path_point_list.size() > 0:
			# 计算当前位置到最后一个路径点的距离
			var distance_to_last_point = global_position.distance_to(current_path_point_list[0])
			# 如果玩家已经接近当前目标点（距离 < 20），使用下一个点作为起点
			if distance_to_last_point < 20.0 and current_path_point_list.size() > 1:
				path_start_position = current_path_point_list[1]
			else:
				# 否则使用当前位置作为起点，但A*会找到最近的节点
				path_start_position = current_path_point_list[0]
		
		# 停止当前移动并清空旧路径
		stop_movement()
		current_path_point_list = []
		
		# 从新起点到目标位置查找路径
		current_path_point_list = my_astar.find_path_from_player_to_mouse(path_start_position, world_position)
		
		# 开始新的路径移动
		move_to_position_direct()



# 开始路径点消费移动
func move_to_position_direct():
	# 如果没有路径点，不开始移动
	if current_path_point_list.size() == 0:
		return
	
	is_moving = true
	
	# 播放跑步动画
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")
	
		
func _process(delta: float) -> void:
	move_to_target(delta)



# 向目标位置移动（消费路径点）
func move_to_target(delta):
	if not is_moving:
		footstep_timer = 0.0 # 停止移动时重置计时器
		return
	
	# 处理脚步声计时
	footstep_timer -= delta
	
	# 如果没有路径点，停止移动
	if current_path_point_list.size() == 0:
		stop_movement()
		return
	
	# 获取当前目标点（列表中的第一个点）
	var current_target = current_path_point_list[0]
	
	# 计算到当前目标点的方向和距离
	var direction = (current_target - global_position).normalized()
	
	# 播放脚步声
	if footstep_timer <= 0:
		_play_footstep_sfx(direction)
		footstep_timer = footstep_interval
	
	var distance = global_position.distance_to(current_target)
	
	# 根据移动方向设置精灵翻转
	if direction.x > 0:
		sprite_2d.flip_h = false  # 向右移动，不翻转
	elif direction.x < 0:
		sprite_2d.flip_h = true   # 向左移动，翻转
	
	# 如果距离很小，认为已到达该点，从列表中移除
	if distance < 5.0:
		current_path_point_list.remove_at(0)  # 消费掉当前点
		# 如果还有剩余点，继续移动；否则停止
		if current_path_point_list.size() == 0:
			stop_movement()
		return
	
	# 使用delta计算移动距离，确保帧率无关
	var move_distance = move_speed * delta
	var new_position = global_position + direction * move_distance
	
	# 检查是否会越过目标点
	if global_position.distance_to(current_target) <= move_distance:
		# 直接到达目标点
		global_position = current_target
		current_path_point_list.remove_at(0)
		if current_path_point_list.size() == 0:
			stop_movement()
	else:
		# 正常移动
		global_position = new_position

# 停止移动
func stop_movement():
	is_moving = false
	velocity = Vector2.ZERO
	footstep_timer = 0.0
	
	# 停止动画
	if animation_player:
		animation_player.stop()

## 播放脚步声逻辑
func _play_footstep_sfx(dir: Vector2):
	# 根据 Y 轴分量判断移动类型
	# 如果 Y 轴移动明显（大于 X 轴的一定比例），认为是爬楼梯
	if abs(dir.y) > 0.5:
		if dir.y < 0:
			AudioManager.play_sfx(sfx_stairs_up)
		else:
			AudioManager.play_sfx(sfx_stairs_down)
	else:
		AudioManager.play_sfx(sfx_walk)
	
