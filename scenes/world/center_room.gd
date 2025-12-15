extends Node2D
@onready var label: Label = $Label
@onready var move_button: Button = $MoveButton
@onready var center_marker: Sprite2D = $CenterMarker

@export var level_number: int


func _ready() -> void:
	refresh_ui()
	# 计算房间中心位置
	
	## 连接按钮信号
	#if move_button:
		#move_button.pressed.connect(_on_move_button_pressed)
	
		
func refresh_ui():
	if level_number:
		label.text = str(level_number)
		
		
# # 处理输入事件
# func _input(event):
# 	# 检查是否是鼠标左键点击
# 	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
# 		# 更新房间中心为鼠标点击位置
# 		move_here(event.position)
		
# # 按钮点击事件处理
# func move_here(position):
# 	# 获取玩家节点
# 	var player = get_tree().get_first_node_in_group("player")
# 	if player:
# 		# 调用玩家的移动到目标位置方法
# 		player.move_to_position(position)
# 		print("玩家移动到: ", position)
