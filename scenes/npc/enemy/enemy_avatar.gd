extends Control


const BIG_FAT_HEAD_UI = preload("uid://ual3ckersvco")
const LONG_ARM_HEAD_UI = preload("uid://dts2ldlvrljo8")

@onready var texture_rect_2: TextureRect = $Head/TextureRect2
@onready var label: Label = $HeartHub/Label
@onready var progress_bar: TextureProgressBar = $HeartHub/TextureProgressBar

func update_hp(current: float, max_val: float):
	if label:
		label.text = "%d/%d" % [current, max_val]
	if progress_bar:
		progress_bar.max_value = max_val
		progress_bar.value = current

func set_avatar_type(is_big_fat: bool):
	if texture_rect_2:
		texture_rect_2.texture = BIG_FAT_HEAD_UI if is_big_fat else LONG_ARM_HEAD_UI
