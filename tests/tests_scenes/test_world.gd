extends Node2D

# 镜头控制变量
#var camera: Camera2D
@onready var camera: Camera2D = $Camera2D

var zoom_level: float = 1.0
var min_zoom: float = 0.5
var max_zoom: float = 3.0
var zoom_speed: float = 0.1
var pan_speed: float = 500.0
var is_dragging: bool = false
var drag_start_position: Vector2

## 初始镜头设置
#@export var initial_camera_position: Vector2 = Vector2(500, 300)  # 默认初始位置
#@export var initial_zoom_level: float = 1.0  # 默认初始缩放级别

# UI元素
var zoom_in_button: Button
var zoom_out_button: Button
var reset_button: Button
var zoom_label: Label

func _ready():
	# 设置相机
	#_setup_camera()
	
	# 创建UI
	_setup_ui()

#func _setup_camera():
	# 创建相机
	#camera = Camera2D.new()
	#add_child(camera)
	#camera.enabled = true
	
	# 设置初始位置和缩放
	#camera.position = initial_camera_position
	#zoom_level = initial_zoom_level
	#camera.zoom = Vector2(zoom_level, zoom_level)

func _setup_ui():
	# 创建UI容器
	var ui_container = VBoxContainer.new()
	ui_container.position = Vector2(10, 10)
	add_child(ui_container)
	
	# 创建缩放控制容器
	var zoom_container = HBoxContainer.new()
	ui_container.add_child(zoom_container)
	
	# 创建放大按钮
	zoom_in_button = Button.new()
	zoom_in_button.text = "放大 (+)"
	zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	zoom_container.add_child(zoom_in_button)
	
	# 创建缩小按钮
	zoom_out_button = Button.new()
	zoom_out_button.text = "缩小 (-)"
	zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	zoom_container.add_child(zoom_out_button)
	
	# 创建重置按钮
	reset_button = Button.new()
	reset_button.text = "重置 (R)"
	reset_button.pressed.connect(_on_reset_pressed)
	ui_container.add_child(reset_button)
	
	# 创建缩放级别标签
	zoom_label = Label.new()
	zoom_label.text = "缩放: %.1fx" % zoom_level
	ui_container.add_child(zoom_label)
	
	# 创建操作提示
	var help_label = Label.new()
	help_label.text = "使用鼠标滚轮缩放，按住鼠标右键拖动平移"
	ui_container.add_child(help_label)

func _unhandled_input(event):
	# 鼠标滚轮缩放
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
	
	# 鼠标右键拖动平移
	if event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_position
		camera.position -= delta / camera.zoom.x
		drag_start_position = event.position
	
	# 键盘快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_PLUS or event.keycode == KEY_EQUAL:
			_zoom_in()
		elif event.keycode == KEY_MINUS:
			_zoom_out()
		elif event.keycode == KEY_R:
			_reset_camera()

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
