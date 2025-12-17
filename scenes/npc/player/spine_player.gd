extends CharacterBody2D

# 移动相关变量
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 100.0
@onready var sprite_2d: Sprite2D = $Sprite2D



# 动画相关变量
@onready var animation_player = $AnimationPlayer

@export var my_astar:MyAstar
var current_path_point_list: Array = [] # 存储当前路径点

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
		current_path_point_list = []
		var world_position = get_global_mouse_position()

		if world_position.x > sprite_2d.global_position.x:
			sprite_2d.flip_h = false
		elif world_position.x < sprite_2d.global_position.x:
			sprite_2d.flip_h = true
			
		current_path_point_list = my_astar.find_path_from_player_to_mouse(self.global_position, world_position)
		
		
		# 回退到直接移动
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
		return
	
	# 如果没有路径点，停止移动
	if current_path_point_list.size() == 0:
		stop_movement()
		return
	
	# 获取当前目标点（列表中的第一个点）
	var current_target = current_path_point_list[0]
	
	# 计算到当前目标点的方向和距离
	var direction = (current_target - global_position).normalized()
	var distance = global_position.distance_to(current_target)
	
	# 如果距离很小，认为已到达该点，从列表中移除
	if distance < 5.0:
		current_path_point_list.remove_at(0)  # 消费掉当前点
		# 如果还有剩余点，继续移动；否则停止
		if current_path_point_list.size() == 0:
			stop_movement()
		return
	
	# 移动到当前目标点
	velocity = direction * move_speed
	move_and_slide()

# 停止移动
func stop_movement():
	is_moving = false
	velocity = Vector2.ZERO
	
	# 停止动画
	if animation_player:
		animation_player.stop()
	
