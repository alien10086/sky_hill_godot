extends Node2D
class_name  MyAstar

var astar = AStar2D.new()
var highlighted_point = -1  # 当前高亮的节点ID
var highlight_scale = 1.0  # 高亮缩放比例
var highlight_timer = 0.0  # 高亮动画计时器


func _ready():
	z_index = 100 # 确保在大多数物体之上
	z_as_relative = false # 设置为非相对层级，强制置顶
	# 启用输入处理
	set_process_input(true)
	set_process(true)
	
func add_point(point_name:int, pos:Vector2):
	astar.add_point(point_name, pos)
	
func connect_points(id:int, to_id:int):
	astar.connect_points(id, to_id)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 鼠标左键点击，找到最近的节点
		var mouse_pos = get_global_mouse_position()
		var nearest_point = find_nearest_point(mouse_pos)
		if nearest_point != -1:
			highlighted_point = nearest_point
			highlight_timer = 0.0
			print("点击到最近的节点: ", nearest_point, " 位置: ", astar.get_point_position(nearest_point))

func find_nearest_point(mouse_pos: Vector2) -> int:
	"""找到距离鼠标位置最近的AStar节点"""
	if astar.get_point_count() == 0:
		return -1
	
	var nearest_id = -1
	var min_distance = INF
	
	var points = astar.get_point_ids()
	for p in points:
		var p_pos = astar.get_point_position(p)
		var distance = mouse_pos.distance_to(p_pos)
		if distance < min_distance:
			min_distance = distance
			nearest_id = p
	
	return nearest_id

func _process(delta):
	# 更新高亮动画
	if highlighted_point != -1:
		highlight_timer += delta
		# 使用正弦波创建脉冲效果
		highlight_scale = 1.0 + 0.3 * sin(highlight_timer * 8.0)
		queue_redraw()

func _draw():
	#draw_rect(Rect2(0, 0, 1000, 1000), Color.RED) # 测试用
	if astar.get_point_count() == 0:
		return

	var points = astar.get_point_ids()
	for p in points:
		var p_pos = astar.get_point_position(p)
		
		# 绘制点：蓝色代表房间，红色代表楼梯
		var color = Color.CORNFLOWER_BLUE
		if p % 10 == 1: # 逻辑：ID末尾为1的是楼梯
			color = Color.INDIAN_RED
		
		# 如果是高亮的节点，使用更大的半径和更亮的颜色
		var radius = 32.0
		var draw_color = color
		
		if p == highlighted_point:
			radius *= highlight_scale  # 放大显示
			# 让颜色更亮
			draw_color = color.lerp(Color.WHITE, 0.3)
			# 绘制外圈光晕效果
			draw_circle(p_pos, radius + 10.0, Color(color, 0.3))
		
		draw_circle(p_pos, radius, draw_color)
		
		# 2. 在圆点旁边画出它的 ID 数字
		# 参数含义：字体, 位置, 文本内容, 对齐方式, 宽度限制(-1为不限), 字体大小
		draw_string(ThemeDB.fallback_font, p_pos + Vector2(10, -10), str(p), HORIZONTAL_ALIGNMENT_LEFT, -1, 50)
		
		# 绘制连线
		var connections = astar.get_point_connections(p)
		for c in connections:
			var c_pos = astar.get_point_position(c)
			# 绘制从当前点到连接点的线
			var line_color = Color(1, 1, 1, 0.5)
			var line_width = 8.0
			
			# 如果这条线连接到高亮节点，让线条也更明显
			if p == highlighted_point or c == highlighted_point:
				line_color = Color.WHITE
				line_width = 12.0
			
			draw_line(p_pos, c_pos, line_color, line_width)
