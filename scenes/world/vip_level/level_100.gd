extends Control

@onready var top: TextureRect = $top

# 图片列表
var image_paths = [
	"res://assets/sprites/world_items/vip0.png",
	"res://assets/sprites/world_items/vip1.png"
]

# 当前图片索引
var current_image_index = 0

# 定时器
var timer: Timer

func _ready():
	# 创建定时器
	timer = Timer.new()
	timer.wait_time = 3.0  # 5秒
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# 启动定时器
	timer.start()
	
	# 设置初始图片
	_update_image()

func _on_timer_timeout():
	# 切换到下一张图片
	current_image_index = (current_image_index + 1) % image_paths.size()
	_update_image()

func _update_image():
	# 加载并设置新图片
	var texture = load(image_paths[current_image_index])
	if texture:
		top.texture = texture
