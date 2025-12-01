extends Control

# 当物品被选中时发出的信号
signal total_craft_item_selected(craft_data: CraftData)

const craft_scene = preload("res://scenes/craft/base_craft_item.tscn")

@onready var weapons_button: Button = $HBoxContainer/VBoxContainer/Button
@onready var food_button: Button = $HBoxContainer/VBoxContainer/Button3
@onready var medical_button: Button = $HBoxContainer/VBoxContainer/Button2
@onready var others_button: Button = $HBoxContainer/VBoxContainer/Button4
@onready var upgrades_button: Button = $HBoxContainer/VBoxContainer/Button5


@onready var grid_container: GridContainer = $HBoxContainer/ScrollContainer/GridContainer


# 当前显示的物品节点
var current_items = []

var item_manage: ItemManager
var craft_manager: CraftManager
var inventory_manager: InventoryManage

# 当前选中的类别按钮
var current_selected_button: Button

func _ready():
	item_manage = ItemManager.get_instance()
	item_manage.load_items()
	craft_manager = CraftManager.get_instance()
	craft_manager.load_recipes()
	
	inventory_manager = InventoryManage.get_instance()
	
	
	
	# 连接按钮信号
	_connect_button_signals()
	# 默认选中武器类别
	_on_category_button_pressed(CraftData.CraftCategory.WEAPONS)
	
	# 设置默认选中按钮的视觉状态
	weapons_button.button_pressed = true
	current_selected_button = weapons_button
	
# 连接按钮信号
func _connect_button_signals():
	food_button.pressed.connect(_on_category_button_pressed.bind(CraftData.CraftCategory.FOOD))
	medical_button.pressed.connect(_on_category_button_pressed.bind(CraftData.CraftCategory.MEDICAL))
	others_button.pressed.connect(_on_category_button_pressed.bind(CraftData.CraftCategory.OTHERS))
	upgrades_button.pressed.connect(_on_category_button_pressed.bind(CraftData.CraftCategory.UPGRADES))
	weapons_button.pressed.connect(_on_category_button_pressed.bind(CraftData.CraftCategory.WEAPONS))
	
# 处理类别按钮点击
func _on_category_button_pressed(category: CraftData.CraftCategory):
	# 获取当前点击的按钮
	var clicked_button: Button
	match category:
		CraftData.CraftCategory.FOOD:
			clicked_button = food_button
		CraftData.CraftCategory.MEDICAL:
			clicked_button = medical_button
		CraftData.CraftCategory.OTHERS:
			clicked_button = others_button
		CraftData.CraftCategory.UPGRADES:
			clicked_button = upgrades_button
		CraftData.CraftCategory.WEAPONS:
			clicked_button = weapons_button
	# 如果点击的是已选中的按钮，不做任何操作
	if clicked_button == current_selected_button:
		return
		
	# 重置之前选中的按钮状态
	if current_selected_button:
		current_selected_button.button_pressed = false
		
	# 设置新选中的按钮状态
	clicked_button.button_pressed = true
	current_selected_button = clicked_button
	
	# 清除当前显示的物品
	_clear_item_display()
	# 显示该类别的物品
	_show_category_items(category)

func _show_category_items(category: CraftData.CraftCategory):
	var recipes = craft_manager.get_recipes_by_category(category)
	for recipe in recipes:
		var result_id = recipe.result_identity
		var item_data = item_manage.get_item_by_identity(result_id)
		if item_data:
			# 创建BaseGameItem实例
			var craft_instance:BaseCraftItemUI = craft_scene.instantiate()
			grid_container.add_child(craft_instance)
			craft_instance.input_item_data = item_data
			craft_instance.input_craft_data = recipe
			craft_instance.craft_item_selected.connect(_on_craft_item_selected)
			# 更新结果物品显示
			craft_instance._from_init_item_data()
			#_update_result_item(craft_data)
			current_items.append(craft_instance)

func _on_craft_item_selected(craft_data: CraftData):
	total_craft_item_selected.emit(craft_data)

	
	
# 清除物品显示
func _clear_item_display():
	for item in current_items:
		item.queue_free()
	current_items.clear()
	
