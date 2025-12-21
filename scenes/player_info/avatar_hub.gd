extends Control

var avater_textures = [
	"res://assets/ui/player_info/ui_head_heart_01.png",
	"res://assets/ui/player_info/ui_head_heart_02.png",
	"res://assets/ui/player_info/ui_head_heart_03.png",
	"res://assets/ui/player_info/ui_head_heart_04.png",
	#"res://assets/ui/player_info/ui_head_hunger_01.png"
]
@onready var hunger_progress_bar: TextureProgressBar = $HungerHub/TextureProgressBar
@onready var hunger_label: Label = $HungerHub/Label

@onready var health_progress_bar: TextureProgressBar = $HeartHub/TextureProgressBar
@onready var health_label: Label = $HeartHub/Label
@onready var texture_rect_2: TextureRect = $Head/TextureRect2
@onready var upgrade_control: Control = $UpgradeControl


var player_manager: PlayerManager

func _ready() -> void:
	player_manager = PlayerManager.get_instance()
	# 连接信号
	connect_signals()
	# 初始化UI显示
	update_all_ui()
	

func connect_signals():
	if player_manager == null:
		return
		
	player_manager.health_changed.connect(_on_health_changed)
	player_manager.hunger_changed.connect(_on_hunger_changed)
	
func _on_health_changed(current_health: int, max_health: int):
	health_label.text = str(current_health) + "/" + str(max_health)
	var health_percentage = 0.0
	if max_health > 0:
		health_percentage = float(current_health) / float(max_health) * 100.0
	health_progress_bar.value = health_percentage
	# 根据血量更新头像
	update_avatar_by_health(health_percentage)
	

func _on_hunger_changed(current_hunger: int, max_hunger: int):
	hunger_label.text = str(current_hunger) + "/" + str(max_hunger)
	var hunger_percentage = 0.0
	if max_hunger > 0:
		hunger_percentage = float(current_hunger) / float(max_hunger) * 100.0
	hunger_progress_bar.value = hunger_percentage
	
# 根据血量更新头像
func update_avatar_by_health(health_percentage: float):
	var avatar_index = 0
	
	# 根据血量百分比决定头像索引，血量越低，索引越高
	if health_percentage > 75:
		avatar_index = 0  # ui_head_heart_01.png
	elif health_percentage > 50:
		avatar_index = 1  # ui_head_heart_02.png
	elif health_percentage > 25:
		avatar_index = 2  # ui_head_heart_03.png
	else:
		avatar_index = 3  # ui_head_heart_04.png
	
	# 加载并设置头像纹理
	var texture = load(avater_textures[avatar_index])
	if texture:
		texture_rect_2.texture = texture
		

# 更新所有UI显示
func update_all_ui():
	if player_manager == null:
		return
		
	var player_data = player_manager.get_player_data()
	
	# 更新生命值和饥饿度
	_on_health_changed(player_data.health.current, player_data.health.max)
	_on_hunger_changed(player_data.hunger.current, player_data.hunger.max)
	
	# 更新头像
	var health_percentage = 0.0
	if player_data.health.max > 0:
		health_percentage = float(player_data.health.current) / float(player_data.health.max) * 100.0
	update_avatar_by_health(health_percentage)
	
	if player_data.skill_points > 0 :
		upgrade_control.visible = true
	else:
		upgrade_control.visible = false
		
		
	
	
