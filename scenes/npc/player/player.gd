extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0

# 动画相关变量
@onready var animation_player = $AnimationPlayer

func _ready():
	# 初始化时停止所有动画
	if animation_player:
		animation_player.stop()

func _physics_process(delta):
	# 如果正在移动，继续向目标移动
	if is_moving:
		move_to_target(delta)

# 移动到指定位置
func move_to_position(pos):
	target_position = pos
	is_moving = true
	
	# 播放跑步动画
	if animation_player and animation_player.has_animation("run"):
		animation_player.play("run")

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
