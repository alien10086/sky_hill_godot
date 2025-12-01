extends Control
@onready var work_branch_one_part: Control = $WorkBranchOnePart
@onready var work_branch_two_part: Control = $WorkBranchTwoPart


func _ready() -> void:
	work_branch_two_part.total_craft_item_selected.connect(
		work_branch_one_part._on_total_craft_item_selected)
