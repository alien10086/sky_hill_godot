extends TextureButton

const UI_EYE = preload("uid://l5pvqrq3vshh")
const UI_EYE_1 = preload("uid://c2f3bp4ife2g0")

@onready var texture_button: TextureButton = $"."
@export var ui_canvas_layer:MainCanvasLayerUI

var is_open: bool = false
var inventory_manage: InventoryManage
var item_manager: ItemManager

var origin_color = Color(1.0, 1.0, 1.0)

func _ready() -> void:
	item_manager = ItemManager.get_instance()
	item_manager.load_items()
	inventory_manage = InventoryManage.get_instance()
	texture_button.texture_normal = UI_EYE
	self_modulate = origin_color
	
func get_layer_center() -> Vector2:
	# get_viewport() 会返回该节点所属的视口
	# get_visible_rect() 返回视口在屏幕上的可见矩形范围
	return ui_canvas_layer.center_marker_2d.global_position
	#var center = ui_canvas_layer.get_viewport().get_visible_rect().size / 2
	#center.y = center.y - 300
	
	#return center

func get_layer_left_bottom_center() -> Vector2:
	# get_viewport() 会返回该节点所属的视口
	# get_visible_rect() 返回视口在屏幕上的可见矩形范围
	#var center = ui_canvas_layer.get_viewport().get_visible_rect().size / 2
	#center.x = center.x - 1000
	#center.y = center.y  + 200
	return ui_canvas_layer.bag_marker_2d_2.global_position


func _on_pressed() -> void:
	texture_button.texture_normal = UI_EYE_1
	# TODO 在这里生成 随机物品
	is_open = false
	print(666)
	
	self_modulate =  Color(1.0, 1.0, 1.0, 0.561)
	
	var random_item_data: ItemData =  item_manager.get_random_item()
	# 创建物品图标并执行飞行动画
	var item_icon = TextureRect.new()
	item_icon.texture = random_item_data.load_icon() 
	item_icon.global_position = global_position  
	item_icon.size = Vector2(64, 64)  # 设置合适的图标大小
	item_icon.z_index = 100
	# 添加到场景根节点
	ui_canvas_layer.add_child(item_icon)
	#get_parent().get_parent().add_child(item_icon)
	# 获取屏幕中间和左下角位置
	#var screen_center = Vector2(ui_canvas_layer.custom_viewport.size.x / 2, ui_canvas_layer.custom_viewport.size.y / 2 - 300)
	#var screen_bottom_left = get_layer_center() Vector2(0, get_viewport_rect().size.y - 300)  # 左下角，稍微留点边距
	#screen_bottom_left
	# 创建Tween动画
	var tween = create_tween()
	#
	# 第一阶段：飞到屏幕中间
	tween.tween_property(item_icon, "global_position", get_layer_center(), 1.5) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
	
	# 第二阶段：飞到左下角
	tween.tween_property(item_icon, "global_position", get_layer_left_bottom_center(), 1) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN)
	
	# 动画结束后添加到库存并清理图标
	tween.tween_callback(func():
		inventory_manage.add_item(random_item_data.identity)
		item_icon.queue_free()
	)
	
	
	
	
