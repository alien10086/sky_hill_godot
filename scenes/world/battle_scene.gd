extends Node2D

enum BattleState { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE, FLEE }

var current_state = BattleState.START
var current_target = null
var player_manager: PlayerManager

@onready var player = $SpineFighter
@onready var monster_container = $MonsterContainer

# UI 引用
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var avatar_hub: Control = $CanvasLayer/AvatarHub
@onready var enemy_avatar: Control = $CanvasLayer/EnemyAvatar
@onready var attack_mode_button: Button = $CanvasLayer/AttackModeButton
@onready var flee_button: Button = $CanvasLayer/FleeButton
@onready var right_weapon_slot: WeaponSlot = $CanvasLayer/RightWeaponSlot
@onready var attack_choice: Control = $CanvasLayer/AttackChoice

func _ready():
	player_manager = PlayerManager.get_instance()
	_setup_battle()
	_init_ui()
	_update_attack_mode_ui()
	_start_battle()

func _setup_battle():
	# 等待一帧确保所有子节点（特别是 SpineSprite）已初始化
	await get_tree().process_frame
	
	# 1. 初始化玩家武器
	var current_weapon = player_manager.player_data.current_weapon
	_sync_fighter_weapon(player, current_weapon)
	
	# 2. 生成怪物并根据房间方位调整站位
	var context = player_manager.player_data.battle_context
	
	# # 根据房间方位调整玩家和怪物的初始位置
	# # 默认布局：玩家在左(406)，怪物在右(1356)
	#if context.room_type == "left":
	# 	# 如果是左房间，怪物应该在左边，玩家在右边
	# 	player.position.x = 1356
		#monster_container.position.scale.x =  -1
	# 	# 转向：玩家面向左，怪物面向右
	# 	if player.has_node("SpineSprite"):
	# 		player.get_node("SpineSprite").scale.x = -1
	# 	# 注意：怪物的转向通常在怪物脚本中处理，或者这里统一处理容器 scale
	# 	monster_container.scale.x = -2 # 之前是 2, 现在反转
	# else:
	# 	# 默认右房间布局
	# 	player.position.x = 406
	# 	monster_container.position.x = 1356
	# 	if player.has_node("SpineSprite"):
	# 		player.get_node("SpineSprite").scale.x = 1
	# 	monster_container.scale.x = 2

	var monster_scene_path = ""
	if "big_fat" in context.monster_type:
		monster_scene_path = "res://scenes/npc/enemy/bigFatMonst.tscn"
	else:
		monster_scene_path = "res://scenes/npc/enemy/longArmMonst.tscn"
		
	var monster_scene = load(monster_scene_path)
	var monster = monster_scene.instantiate()
	# monster.scale.x = -1
	monster_container.add_child(monster)
	current_target = monster
	
	# 从战斗上下文同步怪物血量
	if context.monster_hp > 0:
		monster.current_hp = context.monster_hp
	
	# 初始化怪物状态
	if monster.has_method("random_skin"):
		monster.random_skin()
	
	# 连接信号
	if monster.has_signal("monster_clicked"):
		monster.monster_clicked.connect(_on_monster_clicked)
	if monster.has_signal("hp_changed"):
		monster.hp_changed.connect(_on_monster_hp_changed)

func _init_ui():
	# 初始化武器槽，显示玩家当前真实装备的武器
	var current_weapon = player_manager.player_data.current_weapon
	
	if right_weapon_slot and current_weapon:
		right_weapon_slot.set_item_data(current_weapon)
		right_weapon_slot.set_selected(true)
	
	right_weapon_slot.weapon_clicked.connect(_on_weapon_selected)
	
	# 初始化攻击模式按钮
	if attack_mode_button:
		attack_mode_button.pressed.connect(_on_attack_mode_toggle)
	
	# 初始化逃跑按钮
	if flee_button:
		flee_button.pressed.connect(_on_flee_button_pressed)
	
	# 初始化头像
	if avatar_hub:
		avatar_hub._on_health_changed(player_manager.player_data.health.current, player_manager.player_data.health.max)
	
	if enemy_avatar and current_target:
		var is_big_fat = "big_fat" in current_target.name.to_lower()
		enemy_avatar.set_avatar_type(is_big_fat)
		enemy_avatar.update_hp(current_target.current_hp, current_target.max_hp)
		
	# 连接部位选择
	if attack_choice:
		attack_choice.part_selected.connect(_on_attack_part_selected)

func _on_weapon_selected(weapon_item, _clicked_slot):
	# 只有一个武器槽，不需要处理互斥
	player_manager.set_current_weapon(weapon_item)
	_sync_fighter_weapon(player, weapon_item)
	_update_status("切换武器: " + (weapon_item.identity if weapon_item else "徒手"))

func _on_attack_mode_toggle():
	if player_manager.player_data.attack_mode == "normal":
		player_manager.player_data.attack_mode = "focused"
	else:
		player_manager.player_data.attack_mode = "normal"
	_update_attack_mode_ui()
	_update_status("攻击模式切换为: " + ("专注模式" if player_manager.player_data.attack_mode == "focused" else "普通模式"))

func _on_flee_button_pressed():
	if current_state == BattleState.PLAYER_TURN:
		_end_battle(BattleState.FLEE)

func _update_attack_mode_ui():
	if attack_mode_button:
		if player_manager.player_data.attack_mode == "focused":
			attack_mode_button.text = "专注攻击模式"
			attack_mode_button.modulate = Color.GOLD
		else:
			attack_mode_button.text = "普通攻击模式"
			attack_mode_button.modulate = Color.WHITE

func _sync_fighter_weapon(fighter, weapon_item):
	if not fighter or not weapon_item: return
	var skin_name = weapon_item.identity.to_lower()
	
	# # 统一映射逻辑，确保 identity 能匹配到 Spine 皮肤
	# var id = weapon_item.identity.to_lower()
	# skin_name = 
	# match id:
	# 	"stick", "wooden_stick": skin_name = "battle_stick"
	# 	"knife", "kitchen_knife": skin_name = "battle_knife"
	# 	"axe", "fire_axe": skin_name = "battle_axe"
	# 	"mace": skin_name = "battle_mace"
	# 	"shovel": skin_name = "battle_shovel"
	# 	"hands": skin_name = "battle_hand"
	# 	_: 
	# 		# 如果没有直接匹配，尝试使用 identity 原名
	# 		skin_name = "battle_" + id
	
	if fighter.has_node("SpineSprite"):
		var spine_sprite = fighter.get_node("SpineSprite")
		var skeleton = spine_sprite.get_skeleton()
		if skeleton:
			# 检查皮肤是否存在，如果不存在则回退到默认
			if skeleton.get_data().find_skin(skin_name):
				skeleton.set_skin_by_name(skin_name)
			else:
				print("警告: 未找到 Spine 皮肤: ", skin_name, " 使用默认皮肤")
				skeleton.set_skin_by_name("battle_hand")
			skeleton.set_to_setup_pose()

func _start_battle():
	current_state = BattleState.PLAYER_TURN
	_update_status("你的回合 - 请开始攻击")
	
	if player_manager.player_data.attack_mode == "focused":
		attack_choice.visible = true
		var monster_type = "big_fat_monst" if "big_fat" in current_target.name.to_lower() else "long_arm_monst"
		attack_choice.show_monst_ui(monster_type)
	else:
		attack_choice.visible = false
		# 普通模式下，可以通过点击怪物或者点击某个“攻击”按钮来触发攻击
		# 这里假设点击怪物即触发攻击，或者提示玩家点击怪物
		_update_status("普通攻击模式 - 请点击怪物进行攻击")

func _on_attack_part_selected(hit_chance, damage_multiplier):
	if current_state != BattleState.PLAYER_TURN: return
	_execute_player_attack(hit_chance, damage_multiplier)

func _execute_player_attack(hit_chance, damage_multiplier):
	current_state = BattleState.BUSY
	attack_choice.visible = false
	
	# 播放攻击动画
	await player.attack(current_target)
	
	var is_hit = randf() <= hit_chance
	if is_hit:
		var damage = 15.0 * damage_multiplier # 基础伤害
		current_target.take_damage(damage)
		_update_status("命中！造成 %.0f 伤害" % damage)
	else:
		_update_status("落空了！")
		
	await get_tree().create_timer(0.8).timeout
	
	if not is_instance_valid(current_target) or current_target.current_hp <= 0:
		_end_battle(BattleState.WIN)
	else:
		_enemy_turn()

func _enemy_turn():
	current_state = BattleState.ENEMY_TURN
	_update_status("怪物回合...")
	
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(current_target):
		current_target.play_animation("attcak", false)
		await get_tree().create_timer(0.5).timeout
		var damage = current_target.attack_power
		player_manager.modify_health(-damage)
		avatar_hub._on_health_changed(player_manager.player_data.health.current, player_manager.player_data.health.max)
		
		if player_manager.player_data.health.current <= 0:
			_end_battle(BattleState.LOSE)
			return
			
	await get_tree().create_timer(1.0).timeout
	_start_battle()

func _on_monster_clicked(_monster):
	if current_state != BattleState.PLAYER_TURN: return
	
	if player_manager.player_data.attack_mode == "normal":
		# 普通模式直接攻击，命中率 80%，伤害倍率 1.0
		_execute_player_attack(0.8, 1.0)

func _on_monster_hp_changed(current, max_val):
	if enemy_avatar:
		enemy_avatar.update_hp(current, max_val)

func _end_battle(state):
	current_state = state
	attack_choice.visible = false
	
	if state == BattleState.WIN:
		_update_status("战斗胜利！")
		# 记录怪物已被击败（可以根据 context.room_type 移除 MainWorld 中的怪物）
	elif state == BattleState.LOSE:
		_update_status("你被打败了...")
		# 已经在 PlayerManager 处理了死亡跳转
		return
	elif state == BattleState.FLEE:
		_update_status("成功逃跑！")
		
	await get_tree().create_timer(1.5).timeout
	player_manager.set_game_mode(PlayerManager.GameMode.EXPLORATION)
	get_tree().change_scene_to_file("res://scenes/main_world.tscn")

func _update_status(msg):
	status_label.text = msg
	print(msg)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_state == BattleState.PLAYER_TURN:
			_end_battle(BattleState.FLEE)
