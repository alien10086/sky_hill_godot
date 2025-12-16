extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0
var facing_right = true  # 记录当前朝向，默认朝右
#@onready var sprite_2d: Sprite2D = $Sprite2D

# 动画相关变量
@onready var animation_player = $AnimationPlayer

func _ready():
	# 初始化时停止所有动画
	if animation_player:
		animation_player.stop()
	
	# 确保角色初始朝右
	scale.x = 1.0
	facing_right = true
	
	# 启用输入处理，以便接收鼠标点击事件
	set_process_input(true)

func _input(event):
	# 检查是否是鼠标左键点击事件
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取鼠标在世界坐标中的位置
		var world_position = get_global_mouse_position()
		# 只根据x轴位置判断转向
		if world_position.x > global_position.x:
			# 鼠标在玩家右边
			if not facing_right:
				scale.x = 1.0
				facing_right = true
		else:
			# 鼠标在玩家左边
			if facing_right:
				scale.x = -1.0
				facing_right = false
		# 开始移动到该位置
		move_to_position(world_position)
		

func _physics_process(delta):
	# 如果正在移动，继续向目标移动
	if is_moving:
		move_to_target(delta)

# 移动到指定位置
func move_to_position(pos):
	target_position = pos
	is_moving = true
	
	# 播放跑步动画
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")

# 向目标位置移动
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
	
	# 移动 - 不再在移动过程中翻转，翻转逻辑只在点击时处理
	velocity = direction * move_speed
	move_and_slide()

# 停止移动
func stop_movement():
	is_moving = false
	velocity = Vector2.ZERO
	
	# 停止动画
	if animation_player:
		animation_player.stop()