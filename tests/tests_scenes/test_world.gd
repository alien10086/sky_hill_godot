extends Node2D

@export var debug_mode: bool = true
# 镜头控制变量
@onready var camera: Camera2D = $Camera2D
@onready var player = $SpinePlayer

var zoom_level: float = 1.0
var min_zoom: float = 0.01  # 修改为更小的最小缩放级别
var max_zoom: float = 3.0
var zoom_speed: float = 0.1
var pan_speed: float = 500.0
var is_dragging: bool = false
var drag_start_position: Vector2
var floor_height: int = 420

# 相机跟随参数
var follow_player: bool = true
var follow_smoothness: float = 0.1  # 跟随平滑度

# 场景实例化
var level_x_scene = preload("res://scenes/world/level_x.tscn")
var level_instances = []

# UI元素
var zoom_in_button: Button
var zoom_out_button: Button
var reset_button: Button
var regenerate_button: Button
var zoom_label: Label
@onready var astar: MyAstar = $astar
@onready var vip_level: VipLevelUI = $VipLevel


#var astar = AStar2D.new()

func _ready():
	# 设置相机
	#_setup_camera()
	astar.add_point(0, vip_level.get_left_mark_point())   # 左房间
	astar.add_point(1, vip_level.get_center_mark_point())
	astar.add_point(2, vip_level.get_right_mark_point())
	
	astar.connect_points(0, 1)
	astar.connect_points(2, 1)
	# 实例化3个level_x场景
	_instantiate_levels()
	
	# 创建UI
	_setup_ui()
	
	# 设置初始相机位置为玩家位置
	if player:
		camera.position = Vector2(camera.position.x, player.global_position.y)

func _instantiate_levels():
	# 清除已存在的实例
	_clear_level_instances()
	
	# 创建3个level_x实例，垂直排列
	var floor_number = 100
	for i in range(1, 100):  # 创建3个实例
		var level_instance:LevelxUI = level_x_scene.instantiate()
		# 设置位置，每个实例垂直间隔575像素
		level_instance.position = Vector2(0, i * floor_height)
		add_child(level_instance)
		level_instance.set_level(floor_number - i)
		level_instance.set_right_room_bg(randi() % 26)  # 随机生成0-25的数字
		level_instance.set_left_room_bg(randi() % 26)   # 随机生成0-25的数字
		level_instances.append(level_instance)
		
		var left_id = i * 10 + 0
		var stair_id = i * 10 + 1
		var stair_bottom_id_1 = i * 10 + 2
		var stair_bottom_id_2 = i * 10 + 3
		var stair_bottom_id_3 = i * 10 + 4
		var stair_bottom_id_4 = i * 10 + 5
		var right_id = i * 10 + 6
		# 2. 添加点到 AStar (Vector2 需要替换为你地图上的真实坐标)
		astar.add_point(left_id, level_instance.get_left_mark_point())   # 左房间
		astar.add_point(stair_id, level_instance.get_center_mark_point())  # 楼梯间
		astar.add_point(right_id, level_instance.get_right_mark_point())  # 右房间
		#var stair_id = i * 10 + 1
		var stairs_bottom_2_top_point_list:Array = level_instance.get_stairs_bottom_2_top_point_list()
		for each_index in range(stairs_bottom_2_top_point_list.size()):
			astar.add_point(i * 10 + 2 + each_index, stairs_bottom_2_top_point_list[each_index]) 
		
		astar.connect_points(stair_id, stair_bottom_id_1)
		astar.connect_points(stair_bottom_id_1, stair_bottom_id_2)
		astar.connect_points(stair_bottom_id_2, stair_bottom_id_3)
		astar.connect_points(stair_bottom_id_3, stair_bottom_id_4)
	
		# 3. 建立层内连接 (双向连接)
		astar.connect_points(left_id, stair_id)
		astar.connect_points(right_id, stair_id)
		# 4. 建立层间连接 (如果不是第一层，将本层楼梯连接到上一层楼梯)
		if i > 0:
			var prev_stair_id = (i - 1) * 10 + 1
			astar.connect_points(stair_bottom_id_4, prev_stair_id)
			
	queue_redraw()
			#
#func _draw():
	##draw_rect(Rect2(0, 0, 1000, 1000), Color.RED) # 测试用
	#if not debug_mode or astar.get_point_count() == 0:
		#return
#
	#var points = astar.get_point_ids()
	#for p in points:
		#var p_pos = astar.get_point_position(p)
		#
		## 绘制点：蓝色代表房间，红色代表楼梯
		#var color = Color.CORNFLOWER_BLUE
		#if p % 10 == 1: # 逻辑：ID末尾为1的是楼梯
			#color = Color.INDIAN_RED
		#
		#draw_circle(p_pos, 8.0, color)
		#
		## 绘制连线
		#var connections = astar.get_point_connections(p)
		#for c in connections:
			#var c_pos = astar.get_point_position(c)
			## 绘制从当前点到连接点的线
			#draw_line(p_pos, c_pos, Color(1, 1, 1, 0.5), 2.0)

func _clear_level_instances():
	# 清除所有已存在的实例
	for instance in level_instances:
		if is_instance_valid(instance):
			instance.queue_free()
	level_instances.clear()

#func _setup_camera():
	# 创建相机
	#camera = Camera2D.new()
	#add_child(camera)
	#camera.enabled = true
	
	# 设置初始位置和缩放
	#camera.position = initial_camera_position
	#zoom_level = initial_zoom_level
	#camera.zoom = Vector2(zoom_level, zoom_level)

func _setup_ui():
	# 创建UI容器
	var ui_container = VBoxContainer.new()
	ui_container.position = Vector2(10, 10)
	add_child(ui_container)
	
	# 创建缩放控制容器
	var zoom_container = HBoxContainer.new()
	ui_container.add_child(zoom_container)
	
	# 创建放大按钮
	zoom_in_button = Button.new()
	zoom_in_button.text = "放大 (+)"
	zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	zoom_container.add_child(zoom_in_button)
	
	# 创建缩小按钮
	zoom_out_button = Button.new()
	zoom_out_button.text = "缩小 (-)"
	zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	zoom_container.add_child(zoom_out_button)
	
	# 创建重置按钮
	reset_button = Button.new()
	reset_button.text = "重置 (R)"
	reset_button.pressed.connect(_on_reset_pressed)
	ui_container.add_child(reset_button)
	
	# 创建重新生成按钮
	regenerate_button = Button.new()
	regenerate_button.text = "重新生成楼层"
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	ui_container.add_child(regenerate_button)
	
	# 创建缩放级别标签
	zoom_label = Label.new()
	zoom_label.text = "缩放: %.1fx" % zoom_level
	ui_container.add_child(zoom_label)
	
	# 创建操作提示
	var help_label = Label.new()
	help_label.text = "使用鼠标滚轮缩放，按住鼠标右键拖动平移"
	ui_container.add_child(help_label)

func _process(delta):
	# 相机跟随玩家Y轴
	if follow_player and player and camera:
		var target_y = player.global_position.y
		var current_camera_y = camera.position.y
		# 使用平滑插值更新相机Y坐标
		camera.position.y = lerp(current_camera_y, target_y, follow_smoothness)

func _unhandled_input(event):
	# 鼠标滚轮缩放
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
			else:
				is_dragging = false
	
	# 鼠标右键拖动平移
	if event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_position
		camera.position -= delta / camera.zoom.x
		drag_start_position = event.position
	
	# 键盘快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_PLUS or event.keycode == KEY_EQUAL:
			_zoom_in()
		elif event.keycode == KEY_MINUS:
			_zoom_out()
		elif event.keycode == KEY_R:
			_reset_camera()

func _zoom_in():
	zoom_level = min(zoom_level + zoom_speed, max_zoom)
	camera.zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_label()

func _zoom_out():
	zoom_level = max(zoom_level - zoom_speed, min_zoom)
	camera.zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_label()

func _reset_camera():
	#camera.position = initial_camera_position
	#zoom_level = initial_zoom_level
	camera.zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_label()

func _update_zoom_label():
	if zoom_label:
		zoom_label.text = "缩放: %.1fx" % zoom_level

func _on_zoom_in_pressed():
	_zoom_in()

func _on_zoom_out_pressed():
	_zoom_out()

func _on_reset_pressed():
	_reset_camera()

func _on_regenerate_pressed():
	_instantiate_levels()
