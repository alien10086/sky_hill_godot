extends Node2D

@onready var bag: Control = $CanvasLayer/Bag
@onready var backpack: Control = $CanvasLayer/Backpack
@onready var panel: Panel = $CanvasLayer/Panel

var inventory_manage: InventoryManage
var weapon_manager: WeaponManager

func _ready():
	inventory_manage = InventoryManage.get_instance()
	weapon_manager = WeaponManager.get_instance()
	
	# 加载武器并添加到背包
	weapon_manager.load_weapons()
	for weapon in weapon_manager.all_weapons:
		inventory_manage.add_item(weapon.name, 1)
	
	pass

func _on_bag_open(): 
	backpack.visible = true 
	panel.visible = true 
	
func _on_bag_close(): 
	backpack.visible = false 
	panel.visible = false 
