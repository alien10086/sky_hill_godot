extends Control

class_name WeaponSlot
signal item_dropped(old_item:ItemData, new_item:ItemData)

@onready var base_game_item: BaseGameItemUI = $BaseGameItem
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var texture_rect: TextureRect = $TextureRect


@export var input_item_data: ItemData

func  _ready() -> void:
	
	if input_item_data:
		base_game_item.input_item_data = input_item_data
		base_game_item.input_text = ""
		
	
func  show_plus():
	base_game_item.visible = false
	label.visible = false
	label_2.visible = false
	rich_text_label.visible = false
	texture_rect.visible = true

func _on_item_drag_started():
	print("开始拖动物品: ")
	show_plus()

func show_normal():
	base_game_item.visible = true
	label.visible = true
	label_2.visible = true
	rich_text_label.visible = true
	texture_rect.visible = false
	
func _on_item_drag_succeed(item_data:ItemData):
	print("拖拽成功", item_data.identity)
	show_normal()

	
func _on_item_drag_cancel():
	print("取消拖拽")
	show_normal()
	

# 2. 检查是否可以放置
func _can_drop_data(at_position, data)-> bool:
	# 检查数据里是否有我们定义的 "origin_node"
	if typeof(data) != TYPE_DICTIONARY or not data.has("origin_node"):
		return false
	
	# 获取物品数据
	var item_data:ItemData = data.get("item_data", null)
	
	# 如果没有物品数据，不允许放置
	if not item_data:
		return false
	
	# 只允许放置武器类型的物品
	return item_data.type == ItemData.ItemType.WEAPON
	
# 3. 处理放置逻辑
func _drop_data(at_position, data):
	var dragged_item = data["origin_node"]
	var origin_slot = data["origin_slot"]
	var dropped_item_data = data.get("item_data", null)
			
	item_dropped.emit(input_item_data, dropped_item_data)
	# 更新武器槽的物品数据
	set_item_data(dropped_item_data)
	
# 设置物品数据
func set_item_data(data: ItemData):
	input_item_data = data
	if data:
		base_game_item.input_item_data = data
		base_game_item.input_text = ""
		base_game_item.init_from_input_item_data()
		# 设置物品图标
		#texture_rect.texture = data.load_icon()
		# 显示物品名称
		label.text =  input_item_data.display_name
		label_2.text = input_item_data.display_name
		rich_text_label.text = data.display_name
	else:
		# 清空显示
		label.text = ""
		label_2.text = ""
		rich_text_label.text = ""
	
	show_normal() 
	
