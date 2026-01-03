extends Node2D

@onready var bag: Control = $CanvasLayer/Bag
@onready var backpack: Control = $CanvasLayer/Backpack
@onready var panel: Panel = $CanvasLayer/Panel

@onready var inventory_area = $CanvasLayer/Backpack/InventoryArea
@onready var player_weapon_front = $FightPlayer/Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D/Weapon
@onready var player_weapon_back = $FightPlayer/Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D/Weapon

@onready var player2_weapon_front = $FightPlayer2/Skeleton2D/RootBone2D/bodyBone2D/frontBone2D/frontBone2D2/frontWeaponeBone2D/Weapon
@onready var player2_weapon_back = $FightPlayer2/Skeleton2D/RootBone2D/bodyBone2D/backBone2D/backBone2D2/backWeaponBone2D/Weapon

var inventory_manage: InventoryManage
var weapon_manager: WeaponManager

func _ready():
	inventory_manage = InventoryManage.get_instance()
	weapon_manager = WeaponManager.get_instance()
	
	# 加载武器并添加到背包
	weapon_manager.load_weapons()
	for weapon in weapon_manager.all_weapons:
		inventory_manage.add_item(weapon.name, 1)
	
	# 连接武器槽信号
	inventory_area.left_weapon_slot.item_dropped.connect(_on_left_weapon_dropped)
	inventory_area.right_weapon_slot.item_dropped.connect(_on_right_weapon_dropped)
	
	pass

func _on_left_weapon_dropped(_old_item: ItemData, new_item: ItemData):
	if new_item:
		player_weapon_front.set_weapon(new_item.identity)
		player2_weapon_front.set_weapon(new_item.identity)

func _on_right_weapon_dropped(_old_item: ItemData, new_item: ItemData):
	if new_item:
		player_weapon_back.set_weapon(new_item.identity)
		player2_weapon_back.set_weapon(new_item.identity)

func _on_bag_open(): 
	backpack.visible = true 
	panel.visible = true 
	
func _on_bag_close(): 
	backpack.visible = false 
	panel.visible = false 
