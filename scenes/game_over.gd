extends Control

func _ready():
	# 确保死亡界面能显示在最前面
	z_index = 100

func _on_restart_button_pressed():
	# 重置玩家数据
	PlayerManager.get_instance().reset_all_attributes()
	# 返回主菜单
	SceneTransition.change_scene("res://scenes/menu.tscn")
