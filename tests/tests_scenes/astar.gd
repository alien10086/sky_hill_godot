extends Node2D
class_name  MyAstar

var astar = AStar2D.new()


func _ready():
	z_index = 100 # 确保在大多数物体之上
	z_as_relative = false # 设置为非相对层级，强制置顶
	
func add_point(point_name:int, pos:Vector2):
	astar.add_point(point_name, pos)
	
func connect_points(id:int, to_id:int):
	astar.connect_points(id, to_id)
			
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
		
		draw_circle(p_pos, 32.0, color)
		# 2. 在圆点旁边画出它的 ID 数字
		# 参数含义：字体, 位置, 文本内容, 对齐方式, 宽度限制(-1为不限), 字体大小
		draw_string(ThemeDB.fallback_font, p_pos + Vector2(10, -10), str(p), HORIZONTAL_ALIGNMENT_LEFT, -1, 50)
		
		# 绘制连线
		var connections = astar.get_point_connections(p)
		for c in connections:
			var c_pos = astar.get_point_position(c)
			# 绘制从当前点到连接点的线
			draw_line(p_pos, c_pos, Color(1, 1, 1, 0.5), 8.0)
