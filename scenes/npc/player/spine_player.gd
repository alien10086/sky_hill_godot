extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0
@onready var sprite_2d: Sprite2D = $Sprite2D



# 动画相关变量
@onready var animation_player = $AnimationPlayer

@export var my_astar:MyAstar

func _ready():
	# 初始化时停止所有动画
	if animation_player:
		animation_player.stop()
	
	
	
	# 启用输入处理，以便接收鼠标点击事件
	set_process_input(true)

func _input(event):
	# 检查是否是鼠标左键点击事件
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取鼠标在世界坐标中的位置
		var world_position = get_global_mouse_position()

		if world_position.x > sprite_2d.global_position.x:
			sprite_2d.flip_h = false
		elif world_position.x < sprite_2d.global_position.x:
			sprite_2d.flip_h = true
		
		
		# 回退到直接移动
		move_to_position_direct(world_position)



# 直接移动到指定位置（原始方法）
func move_to_position_direct(pos):
	target_position = pos
	is_moving = true
	
	# 播放跑步动画
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")
		
func _process(delta: float) -> void:
	move_to_target(delta)



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
	
