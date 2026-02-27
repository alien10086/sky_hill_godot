extends Control

func _ready():
	# 确保死亡界面能显示在最前面
	z_index = 100

func _on_restart_button_pressed():
	# 重置玩家数据
	PlayerManager.get_instance().reset_all_attributes()
	# 重新加载主场景
	get_tree().change_scene_to_file("res://scenes/main_world.tscn")
