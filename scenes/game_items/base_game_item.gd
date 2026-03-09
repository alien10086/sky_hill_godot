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

var sfx_chewing = preload("res://assets/audio/sfx/chewing.wav")

func _ready() -> void:
	item_manager = ItemManager.get_instance()
	#var temp_item_data:ItemData = item_manager.get_item_by_identity("coin")
	#texture_rect.texture = temp_item_data.load_icon()
	#label.text = temp_item_data.identity
	#if input_text != null:
		#label.text = input_text
	init_from_input_item_data()
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 确保子节点不会拦截鼠标事件，让父节点处理点击和拖拽
	if panel: panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if texture_rect: texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if texture_rect_2: texture_rect_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label: label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# 支持左键或右键点击食用食物
		if (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.pressed:
			print("点击了物品: ", input_item_data.identity if input_item_data else "未知")
			if input_item_data and input_item_data.type == ItemData.ItemType.FOOD:
				print("尝试食用食物: ", input_item_data.identity)
				# 播放进食音效 (咀嚼声)
				if sfx_chewing:
					AudioManager.play_sfx(sfx_chewing)
				
				# 暂时硬编码增加 20 饥饿度
				PlayerManager.get_instance().modify_hunger(20)
				# 从库存中移除
				InventoryManage.get_instance().remove_item(input_item_data.identity, 1)
				# 消耗事件，防止触发拖拽
				accept_event()
		
	

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
func _get_drag_data(_at_position):
	
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
		
	
	
