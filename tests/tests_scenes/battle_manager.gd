extends Node2D

enum BattleState { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE }

var current_state = BattleState.START

@onready var player = $SpineFighter
#@onready var enemies = []
@onready var big_fat_monst: BigFatMonstUI = $BigFatMonst


# UI 引用
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var player_hp_label: Label = $CanvasLayer/PlayerHP
@onready var avatar_hub: Control = $CanvasLayer/AvatarHub
@onready var enemy_avatar: Control = $CanvasLayer/EnemyAvatar

@onready var left_weapon_slot: WeaponSlot = $CanvasLayer/LeftWeaponSlot
@onready var right_weapon_slot: WeaponSlot = $CanvasLayer/RightWeaponSlot


func _ready():
	_set_weapon_slots_visible(false) # 初始隐藏
	left_weapon_slot.open_fighter_model()
	right_weapon_slot.open_fighter_model()
	# 初始化敌人列表
	# 加载并给玩家换一个武器
	var wm = WeaponManager.get_instance()
	var weapons = wm.load_all_weapons()
	if not weapons.is_empty():
		# 初始化武器槽数据以便测试切换
		var item_manager = ItemManager.get_instance()
		var stick_item = item_manager.get_item_by_identity("stick")
		var knife_item = item_manager.get_item_by_identity("knife")
		
		if stick_item:
			left_weapon_slot.set_item_data(stick_item)
			left_weapon_slot.set_selected(true) # 默认选中左手
		if knife_item:
			right_weapon_slot.set_item_data(knife_item)
			right_weapon_slot.set_selected(false) # 右手不选中
			
		# 这里默认给玩家换第一个武器
		player.change_weapon(weapons[10])
	
	big_fat_monst.monster_clicked.connect(_on_monster_clicked)
	big_fat_monst.died.connect(_on_monster_died)
	# 连接怪物血量改变信号到 UI
	big_fat_monst.hp_changed.connect(_on_monster_hp_changed)
	
	# 随机设置怪物皮肤
	big_fat_monst.random_skin()
	
	# 初始化 UI 显示
	if enemy_avatar:
		enemy_avatar.set_avatar_type(true) # Big Fat
		enemy_avatar.update_hp(big_fat_monst.current_hp, big_fat_monst.max_hp)
	
	player.hp_changed.connect(_on_player_hp_changed)
	# 初始化玩家 UI
	if avatar_hub:
		avatar_hub._on_health_changed(player.current_hp, player.max_hp)
	
	# 连接武器槽点击信号
	left_weapon_slot.weapon_clicked.connect(_on_weapon_selected)
	right_weapon_slot.weapon_clicked.connect(_on_weapon_selected)
		
	_start_battle()

func _on_weapon_selected(weapon: WeaponData, clicked_slot: WeaponSlot):
	if weapon:
		# 处理互斥逻辑：取消另一个槽位的选中状态
		if clicked_slot == left_weapon_slot:
			right_weapon_slot.set_selected(false)
		else:
			left_weapon_slot.set_selected(false)
			
		player.change_weapon(weapon)
		_update_status("切换武器: " + weapon.name)

func _on_player_hp_changed(current, max_val):
	player_hp_label.text = "玩家 HP: %d / %d" % [current, max_val]
	if avatar_hub:
		avatar_hub._on_health_changed(current, max_val)

func _on_monster_hp_changed(current, max_val):
	if enemy_avatar:
		enemy_avatar.update_hp(current, max_val)

func _start_battle():
	current_state = BattleState.PLAYER_TURN
	_set_weapon_slots_visible(true) # 玩家回合开始，显示武器槽
	_update_status("玩家回合 - 请选择目标攻击")

func _on_monster_clicked(monster):
	if current_state != BattleState.PLAYER_TURN:
		return
	
	current_state = BattleState.BUSY
	_set_weapon_slots_visible(false) # 开始攻击动作，隐藏武器槽
	_update_status("正在攻击 " + monster.name)
	
	# 玩家攻击
	await player.attack(monster)
	
	# 检查是否胜利
	if big_fat_monst.current_hp <= 0 :
		_battle_win()
	else:
		# 切换到敌人回合
		await get_tree().create_timer(1.0).timeout
		_enemy_turn()

func _enemy_turn():
	current_state = BattleState.ENEMY_TURN
	_update_status("敌人回合...")
	
	#for enemy in enemies:
	if is_instance_valid(big_fat_monst):
		_update_status(big_fat_monst.name + " 正在攻击玩家")
		big_fat_monst.play_animation("attcak", false)
		await get_tree().create_timer(0.5).timeout
		player.take_damage(big_fat_monst.attack_power)
		await get_tree().create_timer(1.0).timeout
		
		if player.current_hp <= 0:
			_battle_lose()
			return
	
	# 回到玩家回合
	_start_battle()

func _on_monster_died(monster):
	#if monster in enemies:
	#enemies.erase(monster)
	pass

func _battle_win():
	current_state = BattleState.WIN
	_set_weapon_slots_visible(false)
	_update_status("战斗胜利！")

func _battle_lose():
	current_state = BattleState.LOSE
	_set_weapon_slots_visible(false)
	_update_status("战斗失败...")

func _update_status(msg: String):
	print(msg)
	if status_label:
		status_label.text = msg

func _set_weapon_slots_visible(visible: bool):
	if left_weapon_slot:
		left_weapon_slot.visible = visible
	if right_weapon_slot:
		right_weapon_slot.visible = visible
