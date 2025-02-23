extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ColorPickerButton.get_picker().picker_shape = 1
	%ColorPickerButton.get_picker().presets_visible = false
	%ColorPickerButton.get_picker().color_modes_visible = false
	%BlendMode.get_popup().id_pressed.connect(_on_blend_state_pressed)
	
	Global.deselect.connect(nullfy)
	Global.reinfo.connect(enable)
	Global.update_offset_spins.connect(update_offset)
	Global.update_pos_spins.connect(update_pos_spins)

func nullfy():
	if %PosXSpinBox.value_changed.is_connected(_on_pos_x_spin_box_value_changed):
		%PosXSpinBox.value_changed.disconnect(_on_pos_x_spin_box_value_changed)
		%PosYSpinBox.value_changed.disconnect(_on_pos_y_spin_box_value_changed)
		%RotSpinBox.value_changed.disconnect(_on_rot_spin_box_value_changed)
	%TintPickerButton.disabled = true
	%ColorPickerButton.disabled = true

	%EyeOption.disabled = true
	%MouthOption.disabled = true
	%SizeSpinBox.editable = false
	%SizeSpinYBox.editable = false

	%PosXSpinBox.editable = false
	%PosYSpinBox.editable = false
	%RotSpinBox.editable = false
	%RotSpinBox.editable = false
	%BlendMode.disabled = true
	%ClipChildren.disabled = true
	%Visible.disabled = true
	%ZOrderSpinbox.editable = false

	%IgnoreBounce.disabled = true
	%Physics.disabled = true
	%IsAssetCheck.disabled = true
	%IsAssetButton.disabled = true
	%RemoveAssetButton.disabled = true
	%ShouldDisappearCheck.disabled = true
	%DontHideOnToggleCheck.disabled = true
	%ShouldDisDelButton.disabled = true
	%ShouldDisRemapButton.disabled = true
	
	
	%OffsetXSpinBox.editable = false
	%OffsetYSpinBox.editable = false
	%FlipSpriteH.disabled = true
	%FlipSpriteV.disabled = true

func enable():
	%TintPickerButton.disabled = false
	%ColorPickerButton.disabled = false
	%EyeOption.disabled = false
	%MouthOption.disabled = false
	%SizeSpinBox.editable = true
	%SizeSpinYBox.editable = true

	%PosXSpinBox.editable = true
	%PosYSpinBox.editable = true
	%RotSpinBox.editable = true
	%RotSpinBox.editable = true
	%BlendMode.disabled = false
	%ClipChildren.disabled = false
	%Visible.disabled = false
	%ZOrderSpinbox.editable = true
	%EyeOption.disabled = false
	%MouthOption.disabled = false

	%IgnoreBounce.disabled = false
	%Physics.disabled = false
	
	%IsAssetCheck.disabled = false
	%IsAssetButton.disabled = false
	%RemoveAssetButton.disabled = false
	%ShouldDisappearCheck.disabled = false
	%DontHideOnToggleCheck.disabled = false

	%IsAssetButton.text = "Null"
	
	%OffsetXSpinBox.editable = true
	%OffsetYSpinBox.editable = true
	%FlipSpriteH.disabled = false
	%FlipSpriteV.disabled = false
	
	set_data()

func set_data():
	%ColorPickerButton.color = Global.held_sprite.dictmain.colored
	%TintPickerButton.color = Global.held_sprite.dictmain.tint
	%Visible.button_pressed = Global.held_sprite.dictmain.visible
	%ZOrderSpinbox.value = Global.held_sprite.dictmain.z_index
	%SizeSpinBox.value = Global.held_sprite.dictmain.scale.x
	%SizeSpinYBox.value = Global.held_sprite.dictmain.scale.y
	%IgnoreBounce.button_pressed = Global.held_sprite.dictmain.ignore_bounce
	%Physics.button_pressed = Global.held_sprite.dictmain.physics
	
	if Global.held_sprite.get_node("%Sprite2D").get_clip_children_mode() == 0:
		%ClipChildren.button_pressed = false
	else:
		%ClipChildren.button_pressed = true
		
	%BlendMode.text = Global.held_sprite.dictmain.blend_mode
	%OffsetXSpinBox.value = Global.held_sprite.dictmain.offset.x
	%OffsetYSpinBox.value = Global.held_sprite.dictmain.offset.y
	
	%PosXSpinBox.value = Global.held_sprite.dictmain.position.x
	%PosYSpinBox.value = Global.held_sprite.dictmain.position.y
	%RotSpinBox.value = Global.held_sprite.dictmain.rotation / 0.01745
	
	if !%PosXSpinBox.value_changed.is_connected(_on_pos_x_spin_box_value_changed):
		%PosXSpinBox.value_changed.connect(_on_pos_x_spin_box_value_changed)
		%PosYSpinBox.value_changed.connect(_on_pos_y_spin_box_value_changed)
		%RotSpinBox.value_changed.connect(_on_rot_spin_box_value_changed)
	
	%IsAssetButton.action = str(Global.held_sprite.sprite_id)
	%IsAssetCheck.button_pressed = Global.held_sprite.is_asset
	%DontHideOnToggleCheck.button_pressed = Global.held_sprite.show_only
	%ShouldDisList.clear()
	for i in Global.held_sprite.saved_keys:
		%ShouldDisList.add_item(i)
	%ShouldDisappearCheck.button_pressed = Global.held_sprite.should_disappear
	%IsAssetButton.update_key_text()
	
	if Global.held_sprite.dictmain.should_blink:
		if Global.held_sprite.dictmain.open_eyes:
			%EyeOption.select(1)
		else:
			%EyeOption.select(2)
	else:
		%EyeOption.select(0)
	
	if Global.held_sprite.dictmain.should_talk:
		if Global.held_sprite.dictmain.open_mouth:
			%MouthOption.select(1)
		else:
			%MouthOption.select(2)
	else:
		%MouthOption.select(0)
	
	if Global.held_sprite.sprite_type == "Sprite2D":
		%FlipSpriteH.button_pressed = Global.held_sprite.dictmain.flip_sprite_h
		%FlipSpriteV.button_pressed = Global.held_sprite.dictmain.flip_sprite_v
	
	elif Global.held_sprite.sprite_type == "WiggleApp":
		%FlipSpriteH.button_pressed = Global.held_sprite.dictmain.flip_h
		%FlipSpriteV.button_pressed = Global.held_sprite.dictmain.flip_v

func _on_blend_state_pressed(id):
	if Global.held_sprite:
		match id:
			0:
				Global.held_sprite.dictmain.blend_mode = "Normal"
			1:
				Global.held_sprite.dictmain.blend_mode = "Add"
			2:
				Global.held_sprite.dictmain.blend_mode = "Subtract"
			3:
				Global.held_sprite.dictmain.blend_mode = "Multiply"
				
			4:
				Global.held_sprite.dictmain.blend_mode = "Burn"
				
			5:
				Global.held_sprite.dictmain.blend_mode = "HardMix"
				
			6:
				Global.held_sprite.dictmain.blend_mode = "Cursed"
		%BlendMode.text = Global.held_sprite.dictmain.blend_mode
		Global.held_sprite.set_blend(Global.held_sprite.dictmain.blend_mode)
		Global.held_sprite.save_state(Global.current_state)

func update_pos_spins():
	%PosXSpinBox.value = Global.held_sprite.position.x
	%PosYSpinBox.value = Global.held_sprite.position.y
	%RotSpinBox.value = Global.held_sprite.rotation / 0.01745
	Global.held_sprite.save_state(Global.current_state)

func update_offset():
	%OffsetXSpinBox.value = Global.held_sprite.dictmain.offset.x
	%OffsetYSpinBox.value = Global.held_sprite.dictmain.offset.y
	update_pos_spins()

func _on_color_picker_button_color_changed(color: Color) -> void:
	Global.held_sprite.modulate = color
	Global.held_sprite.dictmain.colored = color
	Global.held_sprite.save_state(Global.current_state)

func _on_color_picker_button_focus_entered() -> void:
	Global.spinbox_held = true

func _on_color_picker_button_focus_exited() -> void:
	Global.spinbox_held = false

func _on_tint_picker_button_color_changed(ncolor: Color) -> void:
	Global.held_sprite.dictmain.tint = ncolor
	Global.held_sprite.get_node("%Sprite2D").self_modulate = ncolor
	Global.held_sprite.save_state(Global.current_state)

func _on_pos_x_spin_box_value_changed(value):
	if %PosXSpinBox.get_line_edit().has_focus():
		Global.held_sprite.dictmain.position.x = value
		Global.held_sprite.position.x = value
		Global.held_sprite.save_state(Global.current_state)

func _on_pos_y_spin_box_value_changed(value):
	if %PosYSpinBox.get_line_edit().has_focus():
		Global.held_sprite.dictmain.position.y = value
		Global.held_sprite.position.y = value
		Global.held_sprite.save_state(Global.current_state)

func _on_rot_spin_box_value_changed(value):
	Global.held_sprite.rotation = value * 0.01745
	Global.held_sprite.dictmain.rotation = value * 0.01745
	Global.held_sprite.save_state(Global.current_state)

func _on_visible_toggled(toggled_on):
	if toggled_on:
		Global.held_sprite.dictmain.visible = true
		Global.held_sprite.visible = true
	else:
		Global.held_sprite.dictmain.visible = false
		Global.held_sprite.visible = false
	Global.held_sprite.treeitem.update_visib_buttons()
	Global.held_sprite.save_state(Global.current_state)

func _on_z_order_spinbox_value_changed(value):
	Global.held_sprite.dictmain.z_index = value
	Global.held_sprite.get_node("%Wobble").z_index = value
	Global.held_sprite.save_state(Global.current_state)

func _on_ignore_bounce_toggled(toggled_on):
	Global.held_sprite.dictmain.ignore_bounce = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_physics_toggled(toggled_on):
	Global.held_sprite.dictmain.physics = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_size_spin_y_box_value_changed(value):
	Global.held_sprite.dictmain.scale.y = value
	Global.held_sprite.scale.y = value
	Global.held_sprite.save_state(Global.current_state)

func _on_size_spin_box_value_changed(value):
	Global.held_sprite.dictmain.scale.x = value
	Global.held_sprite.scale.x = value
	Global.held_sprite.save_state(Global.current_state)

func _on_offset_y_spin_box_value_changed(value):
	if %OffsetYSpinBox.get_line_edit().has_focus():
		var of = Global.held_sprite.dictmain.offset.y - value
		Global.held_sprite.dictmain.position.y += of
		Global.held_sprite.position.y = Global.held_sprite.dictmain.position.y
		
		Global.held_sprite.dictmain.offset.y = value
		Global.held_sprite.get_node("%Sprite2D").position.y = Global.held_sprite.dictmain.offset.y
		Global.held_sprite.save_state(Global.current_state)
		update_pos_spins()

func _on_offset_x_spin_box_value_changed(value):
	if %OffsetXSpinBox.get_line_edit().has_focus():
		var of = Global.held_sprite.dictmain.offset.x - value
		Global.held_sprite.dictmain.position.x += of
		Global.held_sprite.position.x = Global.held_sprite.dictmain.position.x
		
		Global.held_sprite.dictmain.offset.x = value
		Global.held_sprite.get_node("%Sprite2D").position.x = Global.held_sprite.dictmain.offset.x
		Global.held_sprite.save_state(Global.current_state)
		update_pos_spins()

func _on_flip_sprite_h_toggled(toggled_on: bool) -> void:
	if Global.held_sprite.sprite_type == "Sprite2D":
		Global.held_sprite.dictmain.flip_sprite_h = toggled_on
		Global.held_sprite.get_node("%Sprite2D").flip_h = toggled_on
		Global.held_sprite.save_state(Global.current_state)
	elif Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.dictmain.flip_h = toggled_on
		if Global.held_sprite.dictmain.flip_h:
			Global.held_sprite.get_node("%AppendageFlip").scale.x = -1
		else:
			Global.held_sprite.get_node("%AppendageFlip").scale.x = 1
		Global.held_sprite.save_state(Global.current_state)

func _on_flip_sprite_v_toggled(toggled_on: bool) -> void:
	if Global.held_sprite.sprite_type == "Sprite2D":
		Global.held_sprite.dictmain.flip_sprite_v = toggled_on
		Global.held_sprite.get_node("%Sprite2D").flip_v = toggled_on
		Global.held_sprite.save_state(Global.current_state)
		
	elif Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.dictmain.flip_v = toggled_on
		if Global.held_sprite.dictmain.flip_v:
			Global.held_sprite.get_node("%AppendageFlip").scale.y = -1
		else:
			Global.held_sprite.get_node("%AppendageFlip").scale.y = 1
		Global.held_sprite.save_state(Global.current_state)


func _on_clip_children_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.held_sprite.get_node("%Sprite2D").set_clip_children_mode(2)
		Global.held_sprite.dictmain.clip = 2
	else:
		Global.held_sprite.get_node("%Sprite2D").set_clip_children_mode(0)
		Global.held_sprite.dictmain.clip = 0
	Global.held_sprite.save_state(Global.current_state)

func _on_eye_option_item_selected(index: int) -> void:
	match index:
		0:
			Global.held_sprite.dictmain.should_blink = false
		1:
			Global.held_sprite.dictmain.should_blink = true
			Global.held_sprite.dictmain.open_eyes = true
		2:
			Global.held_sprite.dictmain.should_blink = true
			Global.held_sprite.dictmain.open_eyes = false

func _on_mouth_option_item_selected(index: int) -> void:
	match index:
		0:
			Global.held_sprite.dictmain.should_talk = false
		1:
			Global.held_sprite.dictmain.should_talk = true
			Global.held_sprite.dictmain.open_mouth = true
		2:
			Global.held_sprite.dictmain.should_talk = true
			Global.held_sprite.dictmain.open_mouth = false
