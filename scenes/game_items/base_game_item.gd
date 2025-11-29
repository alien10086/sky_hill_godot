extends Control
class_name  BaseGameItemUI
signal  item_drag_started
signal  item_drag_cancel
signal  item_drag_ended(item_data:ItemData)

var is_being_dragged:bool = false

var _pos: Vector2 = Vector2(50, 50)

@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2
@onready var label: Label = $Label
@export var input_item_data: ItemData
@export var input_text: String

var is_hovered: bool = false
var item_manager:ItemManager

func _ready() -> void:
	item_manager = ItemManager.get_instance()
	#var temp_item_data:ItemData = item_manager.get_item_by_identity("coin")
	#texture_rect.texture = temp_item_data.load_icon()
	#label.text = temp_item_data.identity
	#if input_text != null:
		#label.text = input_text
	init_from_input_item_data()
		
	

func init_from_input_item_data():
	if input_item_data:
		texture_rect.texture = input_item_data.load_icon()
		label.text = input_item_data.identity
	if input_text != null:
		label.text = input_text
	
		

func _update_hovered_bottom_border_visibility():
	if is_hovered:
		texture_rect_2.visible = true
	else:
		texture_rect_2.visible = false
		


func _on_mouse_entered() -> void:
	print(123)
	is_hovered = true
	_update_hovered_bottom_border_visibility()
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	print(456)
	is_hovered = false
	_update_hovered_bottom_border_visibility()
	pass # Replace with function body.
	

# 1. 当鼠标在这个控件上按下并移动时触发
func _get_drag_data(at_position):
	
	var data = {
		"origin_node": self,
		"origin_slot": get_parent(),
		"item_data": input_item_data
	}
	
	#if input_item_data:
	item_drag_started.emit()
	
	# 设置拖拽预览（即鼠标下面跟着的那个半透明图标）
	var preview:BaseGameItemUI = duplicate()
	preview.modulate.a = 0.5   # 让它半透明
	var c = Control.new()
	c.add_child(preview)
	preview.position = Vector2.ZERO - _pos
	set_drag_preview(c)
	return data 
	
# 当系统发生某些事件时，Godot 会自动调用这个函数
func _notification(what):
	match what:
		# 1. 检测到拖拽开始
		NOTIFICATION_DRAG_BEGIN:
			# 获取当前视口中正在被拖拽的数据
			var data = get_viewport().gui_get_drag_data()
			if data is Dictionary and data.get("origin_node") == self:
				is_being_dragged = true
			else:
				pass
				
		# 2. 检测到拖拽结束（无论是松开鼠标取消，还是成功放入槽位）
		NOTIFICATION_DRAG_END:
			if is_being_dragged:
				is_being_dragged = false # 重置状态
				if is_drag_successful():
					item_drag_ended.emit(input_item_data)
				else:
					item_drag_cancel.emit()
		
	
	
