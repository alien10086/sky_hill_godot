extends Control
@onready var panel: Panel = $Panel
@onready var big_fat_monst_ui: Control = $big_fat_monst_ui
@onready var long_arm_monst_ui: Control = $long_arm_monst_ui


func show_monst_ui(monst_ui_name:String):
	
	if monst_ui_name == "big_fat_monst":
		big_fat_monst_ui.visible = true
		long_arm_monst_ui.visible = false
	elif monst_ui_name == "long_arm_monst":
		big_fat_monst_ui.visible = false
		long_arm_monst_ui.visible = true
		
		
