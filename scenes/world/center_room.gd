extends Node2D
@onready var label: Label = $Label

@export var level_number: int
@onready var move_button: Button = $MoveButton

# 房间中心位置
var room_center: Vector2


func _ready() -> void:
	refresh_ui()
	# 计算房间中心位置
	room_center = Vector2(500, 100)
	
	# 连接按钮信号
	if move_button:
		move_button.pressed.connect(_on_move_button_pressed)
		
func refresh_ui():
	if level_number:
		label.text = str(level_number)
		
# 按钮点击事件处理
func _on_move_button_pressed():
	# 获取玩家节点
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 调用玩家的移动到目标位置方法
		player.move_to_position(room_center)
		

	
