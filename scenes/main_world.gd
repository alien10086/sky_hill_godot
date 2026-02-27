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
@onready var bag: Control = $CanvasLayer/Bag
@onready var backpack: Control = $CanvasLayer/Backpack
@onready var panel: Panel = $CanvasLayer/Panel
@onready var attack_choice: Control = $CanvasLayer/AttackChoice

var player_manager: PlayerManager
var current_target_monster = null

@onready var astar: MyAstar = $astar
@onready var vip_level: VipLevelUI = $VipLevel
@onready var canvas_layer: CanvasLayer = $CanvasLayer



#var astar = AStar2D.new()
func _on_bag_open():
	backpack.visible = true
	panel.visible = true
	# 确保背景面板不会拦截本该传递给背包的鼠标事件
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _on_bag_close():
	backpack.visible = false
	panel.visible = false
	


func _ready():
	player_manager = PlayerManager.get_instance()
	get_tree().node_added.connect(_on_node_added)
	bag.bag_open.connect(_on_bag_open)
	bag.bag_close.connect(_on_bag_close)
	
	# 连接部位选择信号
	if attack_choice:
		attack_choice.part_selected.connect(_on_attack_part_selected)
	
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
	#_setup_ui()
	
	# 设置初始相机位置为玩家位置
	if player:
		camera.position = Vector2(camera.position.x, player.global_position.y)

func _on_node_added(node: Node):
	if node.is_in_group("monsters"):
		if node.has_signal("monster_clicked"):
			if not node.monster_clicked.is_connected(_on_monster_clicked):
				node.monster_clicked.connect(_on_monster_clicked)

func _instantiate_levels():
	# 清除已存在的实例
	_clear_level_instances()
	
	# 创建3个level_x实例，垂直排列
	var floor_number = 100
	for i in range(1, 100):  # 创建3个实例
		var level_instance:LevelxUI = level_x_scene.instantiate()
		# 设置位置，每个实例垂直间隔575像素
		level_instance.position = Vector2(0, i * floor_height)
		level_instance.ui_canvas_layer =  canvas_layer
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
		astar.connect_points(left_id, stair_bottom_id_1)
		astar.connect_points(right_id, stair_id)
		# 4. 建立层间连接 (如果不是第一层，将本层楼梯连接到上一层楼梯)
		if i == 1:
			var prev_stair_id = (i - 1) * 10 + 1
			astar.connect_points(stair_bottom_id_4, prev_stair_id)
			
		if i > 1:
			var prev_stair_id = (i - 1) * 10 + 2
			astar.connect_points(stair_bottom_id_4, prev_stair_id)
			
	queue_redraw()

func _on_monster_clicked(monster):
	# 如果已经在战斗中，不能再次点击触发（或者处理战斗中的目标切换，这里先简单化）
	if player_manager.current_mode == PlayerManager.GameMode.BATTLE:
		return

	# 检查玩家是否在怪物所在的房间
	var monster_room = monster.get_parent()
	var player_global_pos = player.global_position
	
	# 获取房间的矩形区域（基于其子节点或 Marker2D）
	# 这里简单判断玩家和怪物是否在同一个 LevelX 实例下，且 X 轴距离在房间范围内
	var level_x = monster_room.get_parent()
	if not level_x is LevelxUI:
		# 如果怪物的直接父级不是房间节点，尝试往上找
		level_x = monster_room.get_parent().get_parent()
	
	if level_x is LevelxUI:
		var rel_pos = level_x.to_local(player_global_pos)
		var in_same_room = false
		
		# 根据怪物房间名称判断玩家是否在对应区域
		if monster_room.name == "LeftRoom":
			# 左房间范围大约在 X: 0-600
			if rel_pos.x < 650:
				in_same_room = true
		elif monster_room.name == "RightRoom":
			# 右房间范围大约在 X: 1400+
			if rel_pos.x > 1350:
				in_same_room = true
		
		if not in_same_room:
			print("玩家不在该房间内，无法攻击！")
			return

	current_target_monster = monster
	player_manager.set_game_mode(PlayerManager.GameMode.BATTLE)
	
	# 停止玩家移动
	if player.has_method("stop_movement"):
		player.stop_movement()
	
	print("点击了怪物: ", monster.name)
	attack_choice.visible = true
	# 根据怪物的脚本名或属性判断显示哪个 UI
	if "big_fat_monst" in monster.name.to_lower() or "bigfatmonst" in monster.name.to_lower():
		attack_choice.show_monst_ui("big_fat_monst")
	elif "long_arm_monst" in monster.name.to_lower() or "longarmmonst" in monster.name.to_lower():
		attack_choice.show_monst_ui("long_arm_monst")

func _on_attack_part_selected(hit_chance: float, damage_multiplier: float):
	if current_target_monster:
		_execute_battle_turn(current_target_monster, hit_chance, damage_multiplier)

func _execute_battle_turn(monster, hit_chance: float, damage_multiplier: float):
	# 隐藏选择 UI
	attack_choice.visible = false
	
	# 1. 玩家攻击
	var is_hit = randf() <= hit_chance
	if is_hit:
		var damage = 10.0 * damage_multiplier # 基础伤害先定为 10
		print("玩家攻击命中，造成伤害: ", damage)
		if monster.has_method("take_damage"):
			monster.take_damage(damage)
	else:
		print("玩家攻击落空！")
	
	# 检查怪物是否死亡
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(monster):
		_end_battle(true)
		return
	
	# 2. 怪物反击 (如果还没死)
	print("怪物开始反击...")
	if monster.has_method("play_animation"):
		monster.play_animation("attcak", false)
	
	await get_tree().create_timer(0.5).timeout
	var monster_damage = 10.0 # 基础怪物伤害
	if monster.get("attack_power"):
		monster_damage = monster.attack_power
		
	player_manager.modify_health(-monster_damage)
	print("玩家受到伤害: ", monster_damage)
	
	# 检查玩家是否死亡
	if player_manager.player_data.health.current <= 0:
		_end_battle(false)
		return
	
	# 3. 回到攻击选择或结束战斗 (这里简单处理为一轮后可以继续选择或逃跑)
	# 如果想做逃跑，可以加个逃跑按钮，或者 ESC 退出
	await get_tree().create_timer(0.5).timeout
	attack_choice.visible = true
	print("请选择下一次攻击部位")

func _end_battle(is_win: bool):
	attack_choice.visible = false
	player_manager.set_game_mode(PlayerManager.GameMode.EXPLORATION)
	current_target_monster = null
	if is_win:
		print("战斗胜利！回到探索模式")
	else:
		print("战斗失败... 回到探索模式 (这里可能需要处理死亡逻辑)")

func _unhandled_input(event: InputEvent) -> void:
	# 1. 优先处理战斗模式下的 ESC 逃跑逻辑
	if event.is_action_pressed("ui_cancel"):
		if player_manager.current_mode == PlayerManager.GameMode.BATTLE:
			_end_battle(false)
			print("玩家选择了逃跑，回到探索模式")
			return # 消费该事件

	# 2. 处理退出/关闭 UI 的全局快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if attack_choice.visible:
				attack_choice.visible = false
				return # 消费该事件
			if backpack.visible:
				_on_bag_close() # 使用现有的关闭逻辑
				return # 消费该事件

	# 3. 如果背包打开，拦截所有针对游戏世界的输入（如相机缩放、拖拽）
	if backpack.visible:
		return
		
	# 4. 鼠标滚轮缩放
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
	
	# 5. 鼠标右键拖动平移
	if event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_position
		camera.position -= delta / camera.zoom.x
		drag_start_position = event.position
	
	# 6. 键盘快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_PLUS or event.keycode == KEY_EQUAL:
			_zoom_in()
		elif event.keycode == KEY_MINUS:
			_zoom_out()
		elif event.keycode == KEY_R:
			_reset_camera()

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

#func _setup_ui():
	## 创建UI容器
	#var ui_container = VBoxContainer.new()
	#ui_container.position = Vector2(10, 10)
	#add_child(ui_container)
	#
	## 创建缩放控制容器
	#var zoom_container = HBoxContainer.new()
	#ui_container.add_child(zoom_container)
	#
	## 创建放大按钮
	#zoom_in_button = Button.new()
	#zoom_in_button.text = "放大 (+)"
	#zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	#zoom_container.add_child(zoom_in_button)
	#
	## 创建缩小按钮
	#zoom_out_button = Button.new()
	#zoom_out_button.text = "缩小 (-)"
	#zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	#zoom_container.add_child(zoom_out_button)
	#
	## 创建重置按钮
	#reset_button = Button.new()
	#reset_button.text = "重置 (R)"
	#reset_button.pressed.connect(_on_reset_pressed)
	#ui_container.add_child(reset_button)
	#
	## 创建重新生成按钮
	#regenerate_button = Button.new()
	#regenerate_button.text = "重新生成楼层"
	#regenerate_button.pressed.connect(_on_regenerate_pressed)
	#ui_container.add_child(regenerate_button)
	#
	## 创建缩放级别标签
	#zoom_label = Label.new()
	#zoom_label.text = "缩放: %.1fx" % zoom_level
	#ui_container.add_child(zoom_label)
	#
	## 创建操作提示
	#var help_label = Label.new()
	#help_label.text = "使用鼠标滚轮缩放，按住鼠标右键拖动平移"
	#ui_container.add_child(help_label)

func _process(_delta):
	# 相机跟随玩家Y轴
	if follow_player and player and camera:
		var target_y = player.global_position.y
		var current_camera_y = camera.position.y
		# 使用平滑插值更新相机Y坐标
		camera.position.y = lerp(current_camera_y, target_y, follow_smoothness)

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
