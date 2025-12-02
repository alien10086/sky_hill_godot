extends Control

@onready var result_craft_item: BaseCraftItemUI = $resultCraftItem
@onready var base_craft_item_1: BaseCraftItemUI = $BaseCraftItem1
@onready var base_craft_item_2: BaseCraftItemUI = $BaseCraftItem2
@onready var base_craft_item_3: BaseCraftItemUI = $BaseCraftItem3
@onready var base_craft_item_4: BaseCraftItemUI = $BaseCraftItem4

@onready var craft_build_button: Control = $CraftBuildButton
@onready var craft_delete_button: Control = $CraftDeleteButton


# 当前选中的合成配方
var current_craft_data: CraftData
var item_manage: ItemManager
var craft_manager: CraftManager
var inventory_manager: InventoryManage

func _ready() -> void:
	item_manage = ItemManager.get_instance()
	item_manage.load_items()
	craft_manager = CraftManager.get_instance()
	craft_manager.load_recipes()
	inventory_manager = InventoryManage.get_instance()
	
	craft_build_button.build_now_craft.connect(_on_build_now_craft)
	craft_delete_button.delete_now_craft.connect(_on_delete_now_craft)

func _on_delete_now_craft():
	current_craft_data = null
	hide_craft()

	
func _on_build_now_craft():
	
	if current_craft_data:
	
		var can_craft_flag:bool = craft_manager.can_craft(current_craft_data, inventory_manager.get_all_items())
		if can_craft_flag:
			inventory_manager.add_item(current_craft_data.result_identity)
			# TODO 这里需要增加 删除合成素材的能力
			
			
	
	
	pass
	

func _on_total_craft_item_selected(craft_data: CraftData):
	hide_craft()
	current_craft_data = craft_data
	show_craft()
	
func hide_craft():
	result_craft_item.visible = false
	base_craft_item_1.visible = false
	base_craft_item_2.visible = false
	base_craft_item_3.visible = false
	base_craft_item_4.visible = false
	
	
func show_craft():
	if !current_craft_data:
		return 
		
	var result_item_data =  item_manage.get_item_by_identity( current_craft_data.result_identity)
	result_craft_item.input_item_data = result_item_data
	result_craft_item.input_craft_data = current_craft_data
	result_craft_item.visible = true
	result_craft_item._from_init_item_data()
	
	var identity_1_item_data =  item_manage.get_item_by_identity( current_craft_data.identity_1)
	base_craft_item_1.input_item_data = identity_1_item_data
	base_craft_item_1.input_craft_data = current_craft_data
	base_craft_item_1.visible = true
	base_craft_item_1._from_init_item_data()
	
	if current_craft_data.identity_2:
	
		var identity_2_item_data =  item_manage.get_item_by_identity( current_craft_data.identity_2)
		base_craft_item_2.input_item_data = identity_2_item_data
		base_craft_item_2.input_craft_data = current_craft_data
		base_craft_item_2.visible = true
		base_craft_item_2._from_init_item_data()
		
	if current_craft_data.identity_3:
	
		var identity_3_item_data =  item_manage.get_item_by_identity( current_craft_data.identity_3)
		base_craft_item_3.input_item_data = identity_3_item_data
		base_craft_item_3.input_craft_data = current_craft_data
		base_craft_item_3.visible = true
		base_craft_item_3._from_init_item_data()
		
	if current_craft_data.identity_4:
		
		var identity_4_item_data =  item_manage.get_item_by_identity( current_craft_data.identity_4)
		base_craft_item_4.input_item_data = identity_4_item_data
		base_craft_item_4.input_craft_data = current_craft_data
		base_craft_item_4.visible = true
		base_craft_item_4._from_init_item_data()
	
	

	
	
	
	
	
	
