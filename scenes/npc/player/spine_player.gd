extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0
@onready var sprite_2d: Sprite2D = $Sprite2D

# NavigationAgent2D导航代理
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# 动画相关变量
@onready var animation_player = $AnimationPlayer

func _ready():
	# 初始化时停止所有动画
	if animation_player:
		animation_player.stop()
	
	# 确保角色初始朝右
	# scale.x = 1.0
	
	# 初始化导航代理
	if navigation_agent:
		# NavigationAgent2D参数设置说明
		# path_desired_distance: 路径点之间的期望距离（单位：像素）
		# 当角色距离下一个路径点小于这个值时，会认为已经到达该路径点
		# 值越大，角色会更早地转向下一个路径点，路径看起来更平滑
		# 值越小，角色会更精确地沿着路径移动
		navigation_agent.path_desired_distance = 10.0
		
		# target_desired_distance: 到达目标的期望距离（单位：像素）
		# 当角色距离最终目标小于这个值时，会认为已经到达目标位置
		# 值越大，角色会在距离目标较远时就停止移动
		# 值越小，角色会更精确地到达目标位置
		navigation_agent.target_desired_distance = 5.0
		
		# radius: 角色的碰撞半径（单位：像素）
		# 用于避障计算，确保角色不会撞到障碍物
		# 值应该与角色的实际大小相匹配
		navigation_agent.radius = 16.0
		
		# max_speed: 角色的最大移动速度（单位：像素/秒）
		# 限制角色移动的最大速度，防止移动过快
		# 通常与角色的move_speed保持一致
		navigation_agent.max_speed = move_speed
		
		# 可选：设置避障参数（如果需要更智能的避障）
		# navigation_agent.avoidance_enabled = true  # 启用避障
		# navigation_agent.avoidance_layers = 1     # 避障层
		# navigation_agent.avoidance_mask = 1     # 避障掩码
		
		# 可选：设置时间预测参数
		# navigation_agent.time_horizon = 5.0     # 时间预测范围（秒）
		# navigation_agent.max_neighbors = 10     # 最大邻居数量
		
		# 可选：设置路径优化参数
		# navigation_agent.simplify_path = true   # 简化路径
		# navigation_agent.simplify_epsilon = 1.0   # 简化精度
		
		# 连接导航信号
		connect_navigation_signals()
	
	# 启用输入处理，以便接收鼠标点击事件
	set_process_input(true)

func connect_navigation_signals():
	"""连接导航代理的信号"""
	if navigation_agent:
		# 连接速度计算完成信号
		navigation_agent.velocity_computed.connect(_on_velocity_computed)
		
		# 连接路径重新计算信号
		navigation_agent.path_changed.connect(_on_path_changed)
		
		# 连接导航完成信号
		navigation_agent.navigation_finished.connect(_on_navigation_finished)

func _input(event):
	# 检查是否是鼠标左键点击事件
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取鼠标在世界坐标中的位置
		var world_position = get_global_mouse_position()
		
		# 使用导航寻路
		if navigation_agent:
			move_to_position_with_navigation(world_position)
		else:
			# 回退到直接移动
			move_to_position_direct(world_position)

func _physics_process(delta):
	# 如果正在移动且导航代理可用
	if is_moving and navigation_agent and not navigation_agent.is_navigation_finished():
		# 获取下一个路径点
		var next_path_position = navigation_agent.get_next_path_position()
		print("下一个路径点: ", next_path_position)
		# 计算移动方向
		var direction = (next_path_position - global_position).normalized()
		
		# 根据移动方向翻转角色
		if direction.x > 0:
			sprite_2d.flip_h = false
		elif direction.x < 0:
			sprite_2d.flip_h = true
		
		# 设置速度并请求导航计算
		var desired_velocity = direction * move_speed
		navigation_agent.set_velocity(desired_velocity)
		
	# elif is_moving:
	# 	# 回退到直接移动
	# 	move_to_target(delta)

# 使用NavigationAgent2D导航到指定位置
func move_to_position_with_navigation(target_pos):
	if navigation_agent:
		# 设置目标位置
		navigation_agent.set_target_position(target_pos)
		target_position = target_pos
		is_moving = true
		
		# 播放跑步动画
		if animation_player and animation_player.has_animation("walk"):
			animation_player.play("walk")

# 直接移动到指定位置（原始方法）
func move_to_position_direct(pos):
	target_position = pos
	is_moving = true
	
	# 只根据x轴位置判断转向
	if pos.x > global_position.x:
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true
	
	# 播放跑步动画
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")

# 获取当前导航路径（用于调试显示）
func get_current_path() -> PackedVector2Array:
	"""获取当前导航路径"""
	if navigation_agent:
		# Godot 4.3中NavigationAgent2D获取路径的正确方法
		# 使用get_current_navigation_path()或get_navigation_path()
		if navigation_agent.has_method("get_current_navigation_path"):
			return navigation_agent.get_current_navigation_path()
		elif navigation_agent.has_method("get_navigation_path"):
			return navigation_agent.get_navigation_path()
		else:
			# 如果以上方法都不存在，返回空路径
			print("警告：NavigationAgent2D没有可用的路径获取方法")
	return PackedVector2Array()

# 导航信号回调函数
func _on_velocity_computed(safe_velocity):
	"""导航代理计算完成后的速度应用"""
	velocity = safe_velocity
	move_and_slide()

func _on_path_changed():
	"""导航路径改变时的回调"""
	print("导航路径已更新，路径点数: ", get_current_path().size())

func _on_navigation_finished():
	"""导航完成时的回调"""
	print("导航完成，到达目标位置")
	stop_movement()

# 向目标位置移动（原始方法）
func move_to_target(delta):
	if not is_moving:
		return
	
	# 计算方向
	var direction = (target_position - global_position).normalized()
	
	# 计算距离
	var distance = global_position.distance_to(target_position)
	
	# 如果距离很小，认为已到达目标
	if distance < 5.0:
		stop_movement()
		return
	
	# 移动
	velocity = direction * move_speed
	move_and_slide()

# 停止移动
func stop_movement():
	is_moving = false
	velocity = Vector2.ZERO
	
	# 停止动画
	if animation_player:
		animation_player.stop()
	
	# 如果导航代理可用，停止导航
	if navigation_agent:
		navigation_agent.set_target_position(global_position)
