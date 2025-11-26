extends Node

# 预加载场景和资源
const BASE_GAME_ITEM_SCENE = preload("res://scenes/game_items/base_game_item.tscn")
@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

# 物品数据
var game_items_data: Array = []
var item_instances: Array = []
var item_manager: ItemManager

func _ready():
	# 初始化 ItemManager
	item_manager = ItemManager.get_instance()
	if not item_manager:
		push_error("无法获取 ItemManager 实例")
		return
	
	# 确保 ItemManager 已加载物品数据
	if not item_manager.is_loaded:
		item_manager.load_items()
	
	# 实例化所有物品
	_instantiate_all_items()
	
	print("测试场景初始化完成，共加载 ", item_instances.size(), " 个物品")
	
# 实例化所有物品
func _instantiate_all_items():
	print("开始实例化游戏物品...")
	
	for item_data_instance in item_manager.all_items:

		if item_data_instance == null:
			continue
		
		# 实例化UI场景
		var item_ui_instance:BaseGameItemUI = BASE_GAME_ITEM_SCENE.instantiate()
		
		item_ui_instance.input_item_data = item_data_instance

		
		# 添加到容器
		grid_container.add_child(item_ui_instance)
		item_ui_instance.init_from_input_item_data()
		item_instances.append(item_ui_instance)

	
	print("成功实例化 ", item_instances.size(), " 个游戏物品UI")
