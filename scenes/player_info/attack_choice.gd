extends Control
@onready var panel: Panel = $Panel
@onready var big_fat_monst_ui: Control = $big_fat_monst_ui
@onready var long_arm_monst_ui: Control = $long_arm_monst_ui
@onready var big_fat_texture_button: TextureButton = $big_fat_monst_ui/TextureButton
@onready var big_fat_texture_button_2: TextureButton = $big_fat_monst_ui/TextureButton2
@onready var long_arm_texture_button: TextureButton = $long_arm_monst_ui/TextureButton
@onready var long_arm_texture_button_2: TextureButton = $long_arm_monst_ui/TextureButton2

signal part_selected(hit_chance: float, damage_multiplier: float)

func _ready():
	# 连接按钮点击信号
	big_fat_texture_button.pressed.connect(func(): _on_part_clicked(0.5, 2.0))
	big_fat_texture_button_2.pressed.connect(func(): _on_part_clicked(0.9, 1.0))
	
	long_arm_texture_button.pressed.connect(func(): _on_part_clicked(0.4, 2.5))
	long_arm_texture_button_2.pressed.connect(func(): _on_part_clicked(0.8, 1.0))

func _on_part_clicked(hit_chance: float, damage_multiplier: float):
	part_selected.emit(hit_chance, damage_multiplier)

func show_monst_ui(monst_ui_name:String):
	
	if monst_ui_name == "big_fat_monst":
		big_fat_monst_ui.visible = true
		long_arm_monst_ui.visible = false
	elif monst_ui_name == "long_arm_monst":
		big_fat_monst_ui.visible = false
		long_arm_monst_ui.visible = true
		
		
