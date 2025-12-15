extends Node2D
@onready var label: Label = $Label
@onready var move_button: Button = $MoveButton
@onready var center_marker: Sprite2D = $CenterMarker

@export var level_number: int

# 房间中心位置
var room_center: Vector2


func _ready() -> void:
	refresh_ui()
	# 计算房间中心位置
	room_center = Vector2(500, 100)
	
	# 更新中心标记位置
	update_center_marker()
	
	# 连接按钮信号
	if move_button:
		move_button.pressed.connect(_on_move_button_pressed)
	
	# 启用输入处理
	set_process_input(true)
		
func refresh_ui():
	if level_number:
		label.text = str(level_number)
		
# 更新中心标记位置
func update_center_marker():
	if center_marker:
		center_marker.position = room_center
		
# 处理输入事件
func _input(event):
	# 检查是否是鼠标左键点击
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 更新房间中心为鼠标点击位置
		room_center = event.position
		update_center_marker()
		print("房间中心更新为: ", room_center)
		
# 按钮点击事件处理
func _on_move_button_pressed():
	# 获取玩家节点
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 调用玩家的移动到目标位置方法
		player.move_to_position(room_center)
		print("玩家移动到: ", room_center)
