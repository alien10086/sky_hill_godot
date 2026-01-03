extends SpineSprite

var weapon_manager: WeaponManager


func _ready():
	weapon_manager = WeaponManager.get_instance()
	weapon_manager.load_weapons()
	var anim_state = get_animation_state()
	# anim_state.set_time_scale(0.5)
	# # 播放动画
	# anim_state.set_animation("attack", true, 0)
	
	# 开始武器轮播
	_start_weapon_carousel()

func _start_weapon_carousel():
	var weapons = weapon_manager.all_weapons
	for weapon in weapons:
		# 切换武器皮肤
		# 假设皮肤名称和武器名称一致，如果不一致需要根据实际情况修改
		get_skeleton().set_skin_by_name(weapon.name)
		get_skeleton().set_to_setup_pose()
		var anim_state = get_animation_state()
		anim_state.set_time_scale(0.5)
		anim_state.set_animation("attack", true, 0)
		print("当前武器: ", weapon.name)
		
		# 播放 3 秒
		await get_tree().create_timer(3.0).timeout
		
		# 停止（切换到默认或空皮肤）1 秒
		get_animation_state().set_time_scale(0) # 停止动画播放
		get_skeleton().set_skin_by_name("default")
		get_skeleton().set_to_setup_pose()
		print("休息 0.2 秒...")
		await get_tree().create_timer(0.2).timeout
	
	print("所有武器轮播结束")


# func _input(event):
# 	if event.is_action_pressed("change_weapon"):
# 		# 直接按名称切换皮肤
# 		get_skeleton().set_skin_by_name("sword_01")
# 		# 刷新到初始姿势（很重要，否则可能不显示图片）
# 		get_skeleton().set_to_setup_pose()
