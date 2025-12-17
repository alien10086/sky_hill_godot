extends Node2D

class_name VipLevelUI
@onready var left_marker_2d: Marker2D = $leftMarker2D
@onready var center_marker_2d: Marker2D = $centerMarker2D
@onready var right_marker_2d: Marker2D = $rightMarker2D

func get_left_mark_point() -> Vector2:
	return left_marker_2d.global_position
	
func get_center_mark_point() -> Vector2:
	return center_marker_2d.global_position
	
func get_right_mark_point() -> Vector2:
	return right_marker_2d.global_position
