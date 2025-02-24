extends Node

@onready var mc_anim = %MouthClosedAnim
@onready var mo_anim = %MouthOpenAnim
@onready var contain = Global.sprite_container
# Called when the node enters the scene tree for the first time.
func _ready():
	%LightColor.get_picker().picker_shape = 1
	%LightColor.get_picker().presets_visible = false
	%LightColor.get_picker().color_modes_visible = false
	
	Global.slider_values.connect(set_slider_data)
	held_sprite_is_null()
	Global.connect("reinfo", reinfo)
	Global.connect("reinfoanim", reinfoanim)
	
	Global.deselect.connect(held_sprite_is_null)
	

	mo_anim.get_popup().connect("id_pressed",_on_mo_anim_state_pressed)
	mc_anim.get_popup().connect("id_pressed",_on_mc_anim_state_pressed)
	%SquishAmount.get_node("%SliderValue").value_changed.connect(_on_squish_amount_changed)
	%SquishAmount.get_node("%SpinBoxValue").value_changed.connect(_on_squish_amount_changed)
	
	%BlinkChanceSlider.value = 10

func set_slider_data(data):
	%BlinkChanceSlider.value = data.blink_chance
	%BlinkSpeedSlider.value = data.blink_speed
	


#region Update Slider info
func held_sprite_is_null():
	%Name.editable = false
	%Name.text = ""

	%WiggleCheck.disabled = true
	%AutoWagCheck.disabled = true

	%WiggleWidthSpin.editable = false
	%WiggleLengthSpin.editable = false
	%WiggleSubDSpin.editable = false
	%WAGravityX.editable = false
	%WAGravityY.editable = false
	%ClosedLoopCheck.disabled = true
	%AdvancedLipSync.disabled = true
	%AnimationReset.disabled = true
	%AnimationOneShot.disabled = true
	
	%TipSpin.editable = false
	
	%RSSlider.editable = false
	%FollowParentEffect.disabled = true
	%FollowWiggleAppTip.disabled = true
	%XoffsetSpinBox.editable = false
	%YoffsetSpinBox.editable = false



func held_sprite_is_true():
	get_parent().get_parent().get_node("TopUI/%DeselectButton").show()
	%Name.editable = true

	%WiggleCheck.disabled = false
	%FollowParentEffect.disabled = false
	%XoffsetSpinBox.editable = true
	%YoffsetSpinBox.editable = true
	
	%AdvancedLipSync.disabled = false
	if Global.held_sprite.sprite_type == "WiggleApp":

		%WiggleWidthSpin.editable = true
		%WiggleLengthSpin.editable = true
		%WiggleSubDSpin.editable = true
		%WAGravityX.editable = true
		%WAGravityY.editable = true
		%ClosedLoopCheck.disabled = false
		%AutoWagCheck.disabled = false
	
	%AnimationOneShot.disabled = false
	%AnimationReset.disabled = false
	
	%TipSpin.editable = true
	
	%RSSlider.editable = true
	
	%FollowWiggleAppTip.disabled = false


func _on_mo_anim_state_pressed(id):
	contain.mouth_open = id
	match id:
		0:
			contain.current_mo_anim = "Idle"
		1:
			contain.current_mo_anim = "Bouncy"
		2:
			contain.current_mo_anim = "Wavy"
		3:
			contain.current_mo_anim = "One Bounce"
		4:
			contain.current_mo_anim = "Wobble"
		5:
			contain.current_mo_anim = "Squish"
		6:
			contain.current_mo_anim = "Float"
			
	mo_anim.text = contain.current_mo_anim
	
	contain.save_state(Global.current_state)

func _on_mc_anim_state_pressed(id):
	contain.mouth_closed = id
	match id:
		0:
			contain.current_mc_anim = "Idle"
		1:
			contain.current_mc_anim = "Bouncy"
		2:
			contain.current_mc_anim = "Wavy"
			
		3:
			contain.current_mc_anim = "One Bounce"
			
		4:
			contain.current_mc_anim = "Wobble"
			
		5:
			contain.current_mc_anim = "Squish"
			
		6:
			contain.current_mc_anim = "Float"
			
	mc_anim.text = contain.current_mc_anim
	contain.save_state(Global.current_state)

func reinfo():
	held_sprite_is_null()
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		await get_tree().create_timer(0.01).timeout
		held_sprite_is_true()
		%Name.text = Global.held_sprite.treeitem.get_node("%NameLabel").text
		%AdvancedLipSync.button_pressed = Global.held_sprite.dictmain.advanced_lipsync
		if Global.held_sprite.sprite_type == "Sprite2D":
			%WiggleStuff.show()
			%WiggleAppStuff.hide()
			%WiggleCheck.button_pressed = Global.held_sprite.dictmain.wiggle
			%FollowParentEffect.button_pressed = Global.held_sprite.dictmain.follow_parent_effects
			%XoffsetSpinBox.value = Global.held_sprite.dictmain.wiggle_rot_offset.x
			%YoffsetSpinBox.value = Global.held_sprite.dictmain.wiggle_rot_offset.y

		elif Global.held_sprite.sprite_type == "WiggleApp":
			%WiggleStuff.hide()
			%WiggleAppStuff.show()
			%WiggleWidthSpin.value = Global.held_sprite.dictmain.width
			%WiggleLengthSpin.value = Global.held_sprite.dictmain.segm_length
			%WiggleSubDSpin.value = Global.held_sprite.dictmain.subdivision
			%WAGravityX.value = Global.held_sprite.dictmain.wiggle_gravity.x
			%WAGravityY.value = Global.held_sprite.dictmain.wiggle_gravity.y
			%ClosedLoopCheck.button_pressed = Global.held_sprite.dictmain.wiggle_closed_loop
			%AutoWagCheck.button_pressed = Global.held_sprite.dictmain.auto_wag

		if Global.held_sprite.get_parent() is WigglyAppendage2D:
			%TipSpin.max_value = Global.held_sprite.get_parent().points.size() -1
			
		
		%TipSpin.value = Global.held_sprite.dictmain.tip_point
		
		
		%AnimationReset.button_pressed = Global.held_sprite.dictmain.should_reset
		%AnimationOneShot.button_pressed = Global.held_sprite.dictmain.one_shot
		
		%Rainbow.button_pressed = Global.held_sprite.dictmain.rainbow
		%"Self-Rainbow Only".button_pressed = Global.held_sprite.dictmain.rainbow_self
		%RSSlider.value = Global.held_sprite.dictmain.rainbow_speed
		
		%FollowWiggleAppTip.button_pressed = Global.held_sprite.dictmain.follow_wa_tip



func reinfoanim():
	mc_anim.text = contain.current_mc_anim
	mo_anim.text = contain.current_mo_anim
	%ShouldSquish.button_pressed = contain.should_squish
	%SquishAmount.get_node("%SliderValue").value = contain.squish_amount


func _on_name_text_submitted(new_text):
	Global.held_sprite.treeitem.get_node("%NameLabel").text = new_text
	Global.held_sprite.sprite_name = new_text
	Global.held_sprite.save_state(Global.current_state)
	Global.spinbox_held = false
	%Name.release_focus()


func _on_animation_reset_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.should_reset = toggled_on
		Global.held_sprite.save_state(Global.current_state)


func _on_rs_slider_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.rainbow_speed = value
		Global.held_sprite.save_state(Global.current_state)



func _on_blink_speed_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.blink_speed = %BlinkSpeedSlider.value
		%BlinkSpeedLabel.text = "Blink Speed : " + str(snappedf(%BlinkSpeedSlider.value, 0.1))


func _on_blink_speed_slider_value_changed(value):
	%BlinkSpeedLabel.text = "Blink Speed : " + str(snappedf(value, 0.1))
	Global.settings_dict.blink_speed = value



func _on_wiggle_check_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.wiggle = toggled_on
		Global.held_sprite.get_node("%Sprite2D").material.set_shader_parameter("wiggle", toggled_on)
		Global.held_sprite.save_state(Global.current_state)


func _on_xoffset_spin_box_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.wiggle_rot_offset.x = value
		Global.held_sprite.get_node("%Sprite2D").material.set_shader_parameter("rotation_offset", Vector2(value, Global.held_sprite.get_node("%Sprite2D").material.get_shader_parameter("rotation_offset").y))
		Global.held_sprite.save_state(Global.current_state)

func _on_yoffset_spin_box_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.wiggle_rot_offset.y = value
		Global.held_sprite.get_node("%Sprite2D").material.set_shader_parameter("rotation_offset", Vector2(Global.held_sprite.get_node("%Sprite2D").material.get_shader_parameter("rotation_offset").x, value))
		Global.held_sprite.save_state(Global.current_state)

# -------------------------------------------------

func _on_follow_wiggle_app_tip_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.follow_wa_tip = toggled_on
		if toggled_on:
			%HBox34.show()
			%MiniFWBSlider.show()
			%MaxFWBSlider.show()
		if not toggled_on:
			%HBox34.hide()
			%MiniFWBSlider.hide()
			%MaxFWBSlider.hide()
			Global.held_sprite.get_node("Pos").position = Vector2(0,0)
		Global.held_sprite.save_state(Global.current_state)
		

func _on_wiggle_width_spin_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.width = value
		Global.held_sprite.get_node("%Sprite2D").width = value
		Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_length_spin_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.segm_length = value
		Global.held_sprite.get_node("%Sprite2D").segment_length = value
		Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_sub_d_spin_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.subdivision = value
		Global.held_sprite.get_node("%Sprite2D").subdivision = value
		Global.held_sprite.save_state(Global.current_state)

func _on_follow_parent_effect_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.follow_parent_effects = toggled_on
		Global.held_sprite.save_state(Global.current_state)
		


#endregion

#region Advanced-LipSync
func _on_advanced_lip_sync_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.advanced_lipsync = toggled_on
		if Global.held_sprite.sprite_type == "Sprite2D":
			Global.held_sprite.dictmain.animation_speed = 1
			if toggled_on:
				Global.held_sprite.get_node("%Sprite2D").hframes = 6
			else:
				Global.held_sprite.get_node("%Sprite2D").hframes = 1
			Global.held_sprite.advanced_lipsyc()
			Global.held_sprite.get_node("%Sprite2D/Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT
			Global.held_sprite.save_state(Global.current_state)
		%AnimationFramesSlider.editable = !toggled_on
		%AnimationSpeedSlider.editable = !toggled_on
		

func _on_advanced_lip_sync_mouse_entered():
	%AdvancedLipSyncLabel.show()

func _on_advanced_lip_sync_mouse_exited():
	%AdvancedLipSyncLabel.hide()

#endregion


func _on_animation_one_shot_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.one_shot = toggled_on
		Global.held_sprite.played_once = false
		if Global.held_sprite.img_animated:
			Global.held_sprite.get_node("%Sprite2D").texture.diffuse_texture.one_shot = toggled_on
			if Global.held_sprite.get_node("%Sprite2D").texture.normal_texture != null:
				Global.held_sprite.get_node("%Sprite2D").texture.normal_texture.one_shot = toggled_on
		Global.held_sprite.save_state(Global.current_state)

func _on_mini_rotation_level_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.rLimitMin = value
		Global.held_sprite.save_state(Global.current_state)

func _on_max_rotation_level_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.rLimitMax = value
		Global.held_sprite.save_state(Global.current_state)



func _on_wa_gravity_x_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		if Global.held_sprite.sprite_type == "WiggleApp":
			Global.held_sprite.dictmain.wiggle_gravity.x = value
			Global.held_sprite.get_node("%Sprite2D").gravity.x = value
			Global.held_sprite.save_state(Global.current_state)

func _on_wa_gravity_y_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		if Global.held_sprite.sprite_type == "WiggleApp":
			Global.held_sprite.dictmain.wiggle_gravity.y = value
			Global.held_sprite.get_node("%Sprite2D").gravity.y = value
			Global.held_sprite.save_state(Global.current_state)

func _on_tip_spin_value_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.tip_point = value
		Global.held_sprite.save_state(Global.current_state)

func _on_closed_loop_check_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		if Global.held_sprite.sprite_type == "WiggleApp":
			Global.held_sprite.dictmain.wiggle_closed_loop = toggled_on
			Global.held_sprite.get_node("%Sprite2D").closed = toggled_on
			Global.held_sprite.save_state(Global.current_state)

func on_wag_speed_changed(value):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.wag_speed = value
		Global.held_sprite.save_state(Global.current_state)

func _on_auto_wag_check_toggled(toggled_on):
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.dictmain.auto_wag = toggled_on
		if toggled_on:
			%MinimumCurve.show()
			%MaxmumCurve.show()
			%WagFreqBSlider.show()
			%WiggleAppsCurveBSlider.hide()
		if !toggled_on:
			Global.held_sprite.get_node("%Sprite2D").curvature = Global.held_sprite.dictmain.wiggle_curve
			%MinimumCurve.hide()
			%MaxmumCurve.hide()
			%WagFreqBSlider.hide()
			%WiggleAppsCurveBSlider.show()
			
		Global.held_sprite.save_state(Global.current_state)

func _on_name_focus_entered() -> void:
	Global.spinbox_held = true

func _on_name_focus_exited() -> void:
	Global.spinbox_held = false

func _on_should_squish_toggled(toggled_on: bool) -> void:
	contain.should_squish = toggled_on
	contain.save_state(Global.current_state)

func _on_squish_amount_changed(value : float):
	contain.squish_amount = value
	contain.save_state(Global.current_state)


func _on_blink_chance_slider_value_changed(value: float) -> void:
	%BlinkChanceLabel.text = "Blink Chance : " + str(value)
	Global.settings_dict.blink_chance = value
	
