extends Control

@onready var resume_button: Button = %ResumeButton
@onready var quit_to_menu_button: Button = %QuitToMenuButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	quit_to_menu_button.pressed.connect(_on_quit_to_menu_pressed)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			# 这里需要检查是否有其他 UI 打开，这部分逻辑还是留在 main_world.gd 比较好
			# 或者由 main_world.gd 调用 show_menu()
			pass

func show_menu():
	get_tree().paused = true
	visible = true

func _resume():
	get_tree().paused = false
	visible = false

func _on_resume_pressed():
	_resume()

func _on_quit_to_menu_pressed():
	# 确保保存
	PlayerManager.get_instance().save_game()
	get_tree().paused = false
	AudioManager.stop_all()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
