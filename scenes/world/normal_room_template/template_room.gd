extends Node2D
class_name  TemplateRoomUI

@onready var base_room: BaseRoomUI = $BaseRoom

@export var input_bg: CompressedTexture2D

@onready var all_room_ornament: Node2D = $all_room_ornament

@onready var canvas_layer: CanvasLayer = $CanvasLayer


#const UI_EYE = preload("uid://l5pvqrq3vshh")
#const UI_EYE_1 = preload("uid://c2f3bp4ife2g0")
const EYE_ITEM_SCENE = preload("uid://bg7o0ifyuignl")



var room_ornament_children: Array[Node] = []

func _ready() -> void:
	_get_all_room_ornament_children()
	_gen_items()
	
	refresh_ui()

func refresh_ui():
	if input_bg:
		base_room.input_bg = input_bg
		base_room.refresh_ui()
		
func set_room_ornament_offset(x_offset:float):
	all_room_ornament.position.x = all_room_ornament.position.x + x_offset

# 获取all_room_ornament下的所有子节点
func _get_all_room_ornament_children():
	if all_room_ornament:
		for i in range(all_room_ornament.get_child_count()):
			room_ornament_children.append(all_room_ornament.get_child(i))
	#return children
	
func _gen_items():
	
	for each_room_ornament in room_ornament_children:
		var texture_size = each_room_ornament.texture.get_size()
		if texture_size.x > 70 or  texture_size.y > 70:
			
			var eye_scene = EYE_ITEM_SCENE.instantiate()

			eye_scene.global_position = each_room_ornament.global_position
			
	
			canvas_layer.add_child(eye_scene)
	
