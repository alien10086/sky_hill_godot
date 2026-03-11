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
@onready var left_weapon_slot: WeaponSlot = $CanvasLayer/LeftWeaponSlot
@onready var right_weapon_slot: WeaponSlot = $CanvasLayer/RightWeaponSlot
@onready var enemy_avatar: Control = $CanvasLayer/EnemyAvatar
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

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
	
	# 如果是从战斗场景回来的，恢复位置
	if player_manager.player_data.last_world_position != Vector2.ZERO:
		player.global_position = player_manager.player_data.last_world_position
		# 恢复后清空，避免下次进入主世界误触发
		player_manager.player_data.last_world_position = Vector2.ZERO
		print("恢复玩家在主世界的位置")
	
	get_tree().node_added.connect(_on_node_added)
	bag.bag_open.connect(_on_bag_open)
	bag.bag_close.connect(_on_bag_close)
	
	# 连接部位选择信号
	if attack_choice:
		attack_choice.part_selected.connect(_on_attack_part_selected)
	
	# 初始化武器栏显示
	_init_weapon_slots()
	
	# 设置相机
	#_setup_camera()
	astar.add_point(0, vip_level.get_left_mark_point())   # 左房间
	astar.add_point(1, vip_level.get_center_mark_point())
	astar.add_point(2, vip_level.get_right_mark_point())
	
	astar.connect_points(0, 1)
	astar.connect_points(2, 1)
	# 实例化3个level_x场景
	_instantiate_levels()
	
	# 自动保存一次初始状态
	player_manager.save_game()
	
	# 创建UI
	#_setup_ui()
	
	# 初始化相机位置
	if player:
		camera.position = Vector2(camera.position.x, player.global_position.y)
	


func _on_node_added(node: Node):
	if node.is_in_group("monsters"):
		if node.has_signal("monster_clicked"):
			if not node.monster_clicked.is_connected(_on_monster_clicked):
				node.monster_clicked.connect(_on_monster_clicked)

func _instantiate_levels():
	# 清除已存在的实例
	# _clear_level_instances()
	
	# 获取楼层持久化数据引用
	var floor_data = player_manager.player_data.floor_data
	
	# 创建level_x实例，垂直排列
	var floor_number = 100
	for i in range(1, 100):
		var level_instance:LevelxUI = level_x_scene.instantiate()
		var current_floor_idx = floor_number - i
		
		# 设置位置，每个实例垂直间隔 floor_height
		level_instance.position = Vector2(0, i * floor_height)
		level_instance.ui_canvas_layer = canvas_layer
		add_child(level_instance)
		level_instance.set_level(current_floor_idx)
		
		# 检查是否有保存的楼层数据
		if floor_data.has(current_floor_idx):
			var saved_data = floor_data[current_floor_idx]
			level_instance.set_right_room_bg(saved_data.right_bg)
			level_instance.set_left_room_bg(saved_data.left_bg)
			# 这里可以扩展传递更多持久化数据给 level_instance
		else:
			# 第一次生成，记录随机数据
			var left_bg = randi() % 26
			var right_bg = randi() % 26
			# 随机选择房间模板索引
			var left_template_idx = randi() % level_instance.ROOM_TEMPLATES.size()
			var right_template_idx = randi() % level_instance.ROOM_TEMPLATES.size()
			# 随机选择怪物模板索引
			var left_monster_idx = randi() % level_instance.MONSTER_TEMPLATES.size()
			var right_monster_idx = randi() % level_instance.MONSTER_TEMPLATES.size()
			
			# 保存到持久化数据中
			floor_data[current_floor_idx] = {
				"left_bg": left_bg,
				"right_bg": right_bg,
				"left_template_idx": left_template_idx,
				"right_template_idx": right_template_idx,
				"left_monster_idx": left_monster_idx,
				"right_monster_idx": right_monster_idx
			}
			
			level_instance.set_left_room_bg(left_bg)
			level_instance.set_right_room_bg(right_bg)
			
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

func _init_weapon_slots():
	var item_manager = ItemManager.get_instance()
	# 初始给玩家装备小木棍到右手
	var stick_item = item_manager.get_item_by_identity("stick")
	if right_weapon_slot and stick_item:
		right_weapon_slot.set_item_data(stick_item)
		right_weapon_slot.set_selected(true)
		player_manager.set_current_weapon(stick_item)
	
	# 连接点击信号
	if right_weapon_slot:
		right_weapon_slot.weapon_clicked.connect(_on_weapon_selected)

func _on_weapon_selected(weapon_item, _clicked_slot):
	# 只有一个武器槽，不需要处理互斥
	# 更新全局武器状态
	player_manager.set_current_weapon(weapon_item)
	
	# 如果正在战斗中，实时切换 SpineFighter 的武器
	if player_manager.current_mode == PlayerManager.GameMode.BATTLE and player.has_node("SpineSprite"):
		_sync_fighter_weapon(player, weapon_item)
	
	print("切换了武器: ", weapon_item.identity if weapon_item else "徒手")

func _sync_fighter_weapon(fighter: Node, weapon_item: ItemData):
	if not fighter or not weapon_item:
		return
		
	# 映射 ItemData 到 SpineFighter 需要的皮肤名
	# 假设 identity 对应皮肤名，或者在 ItemData 中有皮肤信息
	var skin_name = "battle_shovel" # 默认
	match weapon_item.identity:
		"stick": skin_name = "battle_stick"
		"knife": skin_name = "battle_knife"
		"axe": skin_name = "battle_axe"
		"mace": skin_name = "battle_mace"
		"shovel": skin_name = "battle_shovel"
		"hands": skin_name = "battle_hand"
	
	if fighter.has_node("SpineSprite"):
		var spine_sprite = fighter.get_node("SpineSprite")
		var skeleton = spine_sprite.get_skeleton()
		skeleton.set_skin_by_name(skin_name)
		skeleton.set_to_setup_pose()

func _set_battle_ui_visible(is_visible: bool):
	if left_weapon_slot:
		left_weapon_slot.visible = is_visible
	if right_weapon_slot:
		right_weapon_slot.visible = is_visible
	if enemy_avatar:
		enemy_avatar.visible = is_visible

func _on_monster_clicked(monster):
	# 如果已经在战斗中，不能再次点击触发
	if player_manager.current_mode == PlayerManager.GameMode.BATTLE:
		return

	# 检查玩家是否在怪物所在的房间
	var monster_room = monster.get_parent()
	var player_global_pos = player.global_position
	
	var level_x = monster_room.get_parent()
	if not level_x is LevelxUI:
		level_x = monster_room.get_parent().get_parent()
	
	if level_x is LevelxUI:
		var rel_pos = level_x.to_local(player_global_pos)
		var in_same_room = false
		
		if monster_room.name == "LeftRoom":
			if rel_pos.x < 650: in_same_room = true
		elif monster_room.name == "RightRoom":
			if rel_pos.x > 1350: in_same_room = true
		
		if not in_same_room:
			print("玩家不在该房间内，无法攻击！")
			return

	# 设置战斗上下文
	var context = player_manager.player_data.battle_context
	context.monster_type = "big_fat" if "bigfat" in monster.name.to_lower() else "long_arm"
	context.monster_scene_path = monster.scene_file_path
	context.monster_hp = monster.current_hp
	context.floor_index = level_x.floor_index
	context.room_type = "left" if monster_room.name == "LeftRoom" else "right"
	
	# 记录进入战斗前的位置
	player_manager.player_data.last_world_position = player.global_position
	
	player_manager.set_game_mode(PlayerManager.GameMode.BATTLE)
	
	# 切换到专门的战斗场景
	print("切换到专门战斗场景，对战怪物: ", monster.name)
	SceneTransition.change_scene("res://scenes/world/battle_scene.tscn")

#func _swap_to_fighter():
	#var fighter_scene = load("res://scenes/npc/player/spineFighter.tscn")
	#var fighter = fighter_scene.instantiate()
	#
	## 记录原位置
	#var old_pos = player.global_position
	#var parent = player.get_parent()
	#
	## 移除原玩家节点，添加新战斗节点
	#parent.add_child(fighter)
	#fighter.global_position = old_pos
	#
	## 如果玩家面朝左，战斗模型也面朝左
	#if player.has_node("SpineSprite") and player.get_node("SpineSprite").scale.x < 0:
		#if fighter.has_node("SpineSprite"):
			#fighter.get_node("SpineSprite").scale.x = -1
	#
	## 更新当前武器皮肤
	#_sync_fighter_weapon(fighter, player_manager.player_data.current_weapon)
	#
	## 替换全局引用
	#var old_player = player
	#player = fighter
	#old_player.queue_free()

func _swap_to_explorer():
	var explorer_scene = load("res://scenes/npc/player/spine_player.tscn")
	var explorer = explorer_scene.instantiate()
	
	# 记录位置
	var old_pos = player.global_position
	var parent = player.get_parent()
	
	parent.add_child(explorer)
	explorer.global_position = old_pos
	
	# 替换全局引用
	var old_fighter = player
	player = explorer
	old_fighter.queue_free()

func _on_attack_part_selected(hit_chance: float, damage_multiplier: float):
	if current_target_monster:
		_execute_battle_turn(current_target_monster, hit_chance, damage_multiplier)

func _execute_battle_turn(monster, hit_chance: float, damage_multiplier: float):
	# 隐藏选择 UI，暂时隐藏武器栏
	attack_choice.visible = false
	left_weapon_slot.visible = false
	right_weapon_slot.visible = false
	
	# 1. 玩家攻击动画
	if player.has_method("attack"):
		await player.attack(monster)
	
	# 计算并造成伤害
	var is_hit = randf() <= hit_chance
	if is_hit:
		var damage = 10.0 * damage_multiplier # 基础伤害
		print("玩家攻击命中，造成伤害: ", damage)
		if monster.has_method("take_damage"):
			monster.take_damage(damage)
		
		# 更新敌人头像血量
		if enemy_avatar:
			enemy_avatar.update_hp(monster.current_hp, monster.max_hp)
	else:
		print("玩家攻击落空！")
	
	# 检查怪物是否死亡
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(monster) or monster.current_hp <= 0:
		_end_battle(true)
		return
	
	# 2. 怪物反击
	print("怪物开始反击...")
	if monster.has_method("play_animation"):
		monster.play_animation("attcak", false)
	
	await get_tree().create_timer(0.5).timeout
	var monster_damage = 10.0
	if monster.get("attack_power"):
		monster_damage = monster.attack_power
		
	if player.has_method("take_damage"):
		player.take_damage(monster_damage)
	
	print("玩家受到伤害: ", monster_damage)
	
	# 检查玩家是否死亡
	if player_manager.player_data.health.current <= 0:
		_end_battle(false)
		return
	
	# 3. 回到攻击选择
	await get_tree().create_timer(0.5).timeout
	attack_choice.visible = true
	left_weapon_slot.visible = true
	right_weapon_slot.visible = true
	print("请选择下一次攻击部位")

func _end_battle(is_win: bool):
	attack_choice.visible = false
	_set_battle_ui_visible(false)
	player_manager.set_game_mode(PlayerManager.GameMode.EXPLORATION)
	
	# 战斗结束，换回探索模型
	_swap_to_explorer()
	
	current_target_monster = null
	if is_win:
		print("战斗胜利！回到探索模式")
	else:
		print("战斗失败... 回到探索模式 (这里可能需要处理死亡逻辑)")

func _unhandled_input(event: InputEvent) -> void:
	# 1. 处理退出/关闭 UI 的全局快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			# 如果暂停菜单已经打开，由 PauseMenu 自己处理（或者这里统一处理）
			if pause_menu.visible:
				pause_menu._resume()
				return

			if attack_choice.visible:
				attack_choice.visible = false
				return # 消费该事件
			if backpack.visible:
				_on_bag_close() # 使用现有的关闭逻辑
				return # 消费该事件
			
			# 如果没有其他 UI 打开，则打开暂停菜单
			pause_menu.show_menu()
			return

	# 2. 如果背包打开，拦截所有针对游戏世界的输入（如相机缩放、拖拽）
	if backpack.visible:
		return
		
	# 3. 鼠标滚轮缩放
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
	
	# 4. 鼠标右键拖动平移
	if event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_position
		camera.position -= delta / camera.zoom.x
		drag_start_position = event.position
	
	# 5. 键盘快捷键
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
	
	# 重置 AStar
	astar.clear()
	# 重新添加 VIP 层的点
	astar.add_point(0, vip_level.get_left_mark_point())
	astar.add_point(1, vip_level.get_center_mark_point())
	astar.add_point(2, vip_level.get_right_mark_point())
	astar.connect_points(0, 1)
	astar.connect_points(2, 1)

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
