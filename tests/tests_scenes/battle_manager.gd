extends Node2D

enum BattleState { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE }

var current_state = BattleState.START

@onready var player = $SpineFighter
#@onready var enemies = []
@onready var big_fat_monst: BigFatMonstUI = $BigFatMonst


# UI 引用
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var player_hp_label: Label = $CanvasLayer/PlayerHP

func _ready():
	# 初始化敌人列表
	
	big_fat_monst.monster_clicked.connect(_on_monster_clicked)
	big_fat_monst.died.connect(_on_monster_died)
			# 动态创建敌人的血条/标签 (可选)
	
	player.hp_changed.connect(_on_player_hp_changed)
	_start_battle()

func _on_player_hp_changed(current, max):
	player_hp_label.text = "玩家 HP: %d / %d" % [current, max]

func _start_battle():
	current_state = BattleState.PLAYER_TURN
	_update_status("玩家回合 - 请选择目标攻击")

func _on_monster_clicked(monster):
	if current_state != BattleState.PLAYER_TURN:
		return
	
	current_state = BattleState.BUSY
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
		big_fat_monst.play_animation("attack", false)
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
	_update_status("战斗胜利！")

func _battle_lose():
	current_state = BattleState.LOSE
	_update_status("战斗失败...")

func _update_status(msg: String):
	print(msg)
	if status_label:
		status_label.text = msg
