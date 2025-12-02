extends Control

const  slot_scene = preload("res://scenes/game_items/base_game_item.tscn")

@onready var delete_area: Control = $DeleteArea

@onready var grid_container: GridContainer = $GridContainer
@onready var left_weapon_slot: WeaponSlot = $LeftWeaponSlot
@onready var right_weapon_slot: WeaponSlot = $RightWeaponSlot



var item_manager: ItemManager
var inventory_manage: InventoryManage
# 库存物品UI字典
var inventory_item_slots: Dictionary = {}



func _on_inventory_updated():
	_update_inventory_display()

func _ready() -> void:
	inventory_manage = InventoryManage.get_instance()
	item_manager = ItemManager.get_instance()
	inventory_manage.inventory_updated.connect(_on_inventory_updated)
	
	delete_area.item_deleted.connect(_on_item_deleted)
	# 确保ItemManager加载物品数据
	item_manager.load_items()
	
	# 初始化武器栏
	_setup_weapon_slots()
	# 添加测试武器
	#_add_test_weapons()
	# 初始显示库存物品
	_update_inventory_display()
	
# 添加测试武器
func _add_test_weapons():
	# 添加一些测试武器到背包
	var test_weapons = [
		"chain_sword",     # ID 61
		"hammersword",     # ID 62
		"star_knife",      # ID 63
		"lighting_rod",    # ID 64
		"footcrusher",     # ID 65
		"arc_katarrh",     # ID 66
		"rapier",          # ID 67
		"scythe",           # ID 68
		"pancakes"
	]
	
	# 检查库存是否为空，如果为空则添加测试武器
	if inventory_manage.is_empty():
		for weapon_id in test_weapons:
			inventory_manage.add_item(weapon_id, 1)
			print("已添加测试武器: ", weapon_id)

func _on_item_deleted(item_data:ItemData):
	inventory_manage.remove_item(item_data.identity, 1)
	

# 处理武器槽的物品放置
func _on_weapon_slot_item_dropped(
	old_item_data: ItemData,
	new_item_data: ItemData
	):
	print("old_item_data: ", old_item_data, " new_item_data: ", new_item_data)
	#print("武器装备: ", old_item_data.display_name, " 到 ", weapon_slot.name)

	if old_item_data:
		if old_item_data.identity == "hands":
			pass
		else:
			inventory_manage.add_item(old_item_data.identity, 1)
	
	if new_item_data:
		# 从库存中移除装备的武器
		#var inventory_manager = InventoryManager.get_instance()
		inventory_manage.remove_item(new_item_data.identity, 1)
	
	# 更新库存显示
	_update_inventory_display()


func _setup_weapon_slots():
	left_weapon_slot.item_dropped.connect(_on_weapon_slot_item_dropped)
	right_weapon_slot.item_dropped.connect(_on_weapon_slot_item_dropped)
	# 初始化武器槽显示
	_update_weapon_slot(left_weapon_slot, null)
	_update_weapon_slot(right_weapon_slot, null)
	
# 更新武器槽显示
func _update_weapon_slot(slot: WeaponSlot, item_data: ItemData):
	if item_data:
		slot.set_item_data(item_data)
	else:
		var hands_item_data = item_manager.get_item_by_identity("hands")
		slot.set_item_data(hands_item_data)
		#slot.set_item_data(null)
	
# 清除库存显示
func _clear_inventory_display():
	# 清除所有子节点
	for child in grid_container.get_children():
		child.queue_free()
	
	# 清空槽位字典
	inventory_item_slots.clear()


# 更新库存显示
func _update_inventory_display():
	# 清除现有的物品槽位
	_clear_inventory_display()
	
	# 获取所有库存物品
	var inventory_items = inventory_manage.get_all_items()
	
	# 为每个物品创建槽位
	for item_identity in inventory_items:
		var inventory_item = inventory_items[item_identity] as InventoryItem
		_create_inventory_item_slot(inventory_item)
		
# 创建库存物品槽位
func _create_inventory_item_slot(inventory_item: InventoryItem):
	# 获取物品数据
	var item_data = item_manager.get_item_by_identity(inventory_item.identity)
	
	if not item_data:
		print("未找到物品数据: ", inventory_item.identity)
		return
	
	# 创建槽位
	var slot: BaseGameItemUI = slot_scene.instantiate()
	grid_container.add_child(slot)
	
	# 设置物品数据和数量
	slot.input_item_data = item_data
	slot.input_text = str(inventory_item.quantity)
	
	slot.init_from_input_item_data()
	
	slot.item_drag_started.connect(left_weapon_slot._on_item_drag_started)
	slot.item_drag_started.connect(right_weapon_slot._on_item_drag_started)
	slot.item_drag_cancel.connect(left_weapon_slot._on_item_drag_cancel)
	slot.item_drag_cancel.connect(right_weapon_slot._on_item_drag_cancel)
	slot.item_drag_ended.connect(left_weapon_slot._on_item_drag_succeed)
	slot.item_drag_ended.connect(right_weapon_slot._on_item_drag_succeed)
	# 保存槽位引用
	inventory_item_slots[inventory_item.identity] = slot
	

	
	
