extends Node

@onready var x_amp = %XAmpBSlider.get_node("SliderValue")
@onready var x_freq = %XFBSlider.get_node("SliderValue")
@onready var y_amp = %YAmpBSlider.get_node("SliderValue")
@onready var y_freq = %YFBSlider.get_node("SliderValue")

@onready var rot = %RotationLevelBSlider.get_node("SliderValue")
@onready var blend = %BlendMode
@onready var clip = %ClipChildren
@onready var color = %ColorPickerButton
@onready var vis = %Visible
@onready var zord = %ZOrderSpinbox
@onready var checke = %CheckEye
@onready var checkm = %CheckMouth
@onready var eyeop = %EyeOpen
@onready var mouthop = %MouthOpen
@onready var mc_anim = %MouthClosedAnim
@onready var mo_anim = %MouthOpenAnim
@onready var contain = get_tree().get_root().get_node("Main/SubViewportContainer/SubViewport/Node2D/Origin/SpritesContainer")
# Called when the node enters the scene tree for the first time.
func _ready():
	color.get_picker().picker_shape = 1
	color.get_picker().presets_visible = false
	color.get_picker().color_modes_visible = false
	
	%LightColor.get_picker().picker_shape = 1
	%LightColor.get_picker().presets_visible = false
	%LightColor.get_picker().color_modes_visible = false
	
	
	held_sprite_is_null()
	%LayerViewBG.connect("sprite_info", reinfo)
	Global.connect("reinfo", reinfo)
	Global.connect("reinfoanim", reinfoanim)
	blend.get_popup().connect("id_pressed",_on_blend_state_pressed)
	mo_anim.get_popup().connect("id_pressed",_on_mo_anim_state_pressed)
	mc_anim.get_popup().connect("id_pressed",_on_mc_anim_state_pressed)
	

	%XAmpBSlider.get_node("SliderValue").value_changed.connect(_on_x_amp_slider_value_changed)
	%XFBSlider.get_node("SliderValue").value_changed.connect(_on_xf_slider_value_changed)
	%YAmpBSlider.get_node("SliderValue").value_changed.connect(_on_y_amp_slider_value_changed)
	%YFBSlider.get_node("SliderValue").value_changed.connect(_on_yf_slider_value_changed)
	
	%StretchBSlider.get_node("SliderValue").value_changed.connect(_on_stretch_slider_value_changed)
	%RotationLevelBSlider.get_node("SliderValue").value_changed.connect(_on_rotation_level_value_changed)
	%RotationSpeedBSlider.get_node("SliderValue").value_changed.connect(_on_rotation_speed_value_changed)
	
	%FMxBSlider.get_node("SliderValue").value_changed.connect(_on_f_mx_slider_value_changed)
	%FMYBSlider.get_node("SliderValue").value_changed.connect(_on_fmy_slider_value_changed)
	
	%MiniRotationLevelBSlider.get_node("SliderValue").value_changed.connect(_on_mini_rotation_level_value_changed)
	%MaxRotationLevelBSlider.get_node("SliderValue").value_changed.connect(_on_max_rotation_level_value_changed)
	
	%WiggleAmpBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_amp_slider_value_changed)
	%WiggleFreqBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_freq_slider_value_changed)
	
	%WiggleAppSegmBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_app_segm_slider_value_changed)
	%WiggleAppsCurveBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_apps_curve_slider_value_changed)
	%WiggleAppsStiffBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_apps_stiff_slider_value_changed)
	%WiggleAppsMaxAngleBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_apps_max_angle_slider_value_changed)
	%WiggleAppsPhysStiffBSlider.get_node("SliderValue").value_changed.connect(_on_wiggle_apps_phys_stiff_slider_value_changed)
	%WagSpeedBSlider.get_node("SliderValue").value_changed.connect(on_wag_speed_changed)
	%MinimumCurve.get_node("SliderValue").value_changed.connect(on_wag_minicurve_changed)
	%MaxmumCurve.get_node("SliderValue").value_changed.connect(on_wag_maxcurve_changed)
	%WagFreqBSlider.get_node("SliderValue").value_changed.connect(on_wag_freq_changed)
	
	%DragBSlider.get_node("SliderValue").value_changed.connect(on_drag_changed)
	
	
	%MiniFWBSlider.get_node("SliderValue").value_changed.connect(on_mini_fw_changed)
	%MaxFWBSlider.get_node("SliderValue").value_changed.connect(on_max_fw_changed)
	
	

	
	


#region Update Slider info
func held_sprite_is_null():
	if %PosXSpinBox.value_changed.is_connected(_on_pos_x_spin_box_value_changed):
		%PosXSpinBox.value_changed.disconnect(_on_pos_x_spin_box_value_changed)
		%PosYSpinBox.value_changed.disconnect(_on_pos_y_spin_box_value_changed)
	x_amp.editable = false
	
	x_freq.editable = false
	
	y_amp.editable = false
	y_freq.editable = false
	%StretchBSlider.get_node("SliderValue").editable = false
	%StretchBSlider.get_node("SpinBoxValue").editable = false
	
	%AnimationFramesSlider.editable = false
	%AnimationSpeedSlider.editable = false
	%SizeSpinBox.editable = false
	%SizeSpinYBox.editable = false
	%ReplaceButton.disabled = true
	%DuplicateButton.disabled = true
	%DeleteButton.disabled = true
	%PosXSpinBox.editable = false
	%PosYSpinBox.editable = false
	%RotSpinBox.editable = false
	
	%RotationLevelBSlider.get_node("SpinBoxValue").editable = false
	
	%XAmpBSlider.get_node("SpinBoxValue").editable = false
	%XFBSlider.get_node("SpinBoxValue").editable = false
	%YAmpBSlider.get_node("SpinBoxValue").editable = false
	%YFBSlider.get_node("SpinBoxValue").editable = false
	
	%Name.editable = false
	%Name.text = ""
	color.disabled = true
	rot.editable = false
	blend.disabled = true
	clip.disabled = true
	vis.disabled = true
	checke.disabled = true
	checkm.disabled = true
	eyeop.disabled = true
	mouthop.disabled = true
	zord.editable = false
	%IgnoreBounce.disabled = true
	%Physics.disabled = true
	
	%WiggleCheck.disabled = true
	%WigglePhysicsCheck.disabled = true
	%WiggleAmpBSlider.get_node("SliderValue").editable = false
	
	%WiggleAmpBSlider.get_node("SpinBoxValue").editable = false
	%WiggleFreqBSlider.get_node("SliderValue").editable = false
	%WiggleFreqBSlider.get_node("SpinBoxValue").editable = false
	%XoffsetSpinBox.editable = false
	%YoffsetSpinBox.editable = false
	
	
	%WiggleAppSegmBSlider.get_node("SliderValue").editable = false
	%WiggleAppSegmBSlider.get_node("SpinBoxValue").editable = false
	%WiggleAppsCurveBSlider.get_node("SliderValue").editable = false
	%WiggleAppsCurveBSlider.get_node("SpinBoxValue").editable = false
	%WiggleAppsStiffBSlider.get_node("SliderValue").editable = false
	%WiggleAppsStiffBSlider.get_node("SpinBoxValue").editable = false
	%WiggleAppsMaxAngleBSlider.get_node("SliderValue").editable = false
	%WiggleAppsMaxAngleBSlider.get_node("SpinBoxValue").editable = false
	%WiggleAppsPhysStiffBSlider.get_node("SliderValue").editable = false
	%WiggleAppsPhysStiffBSlider.get_node("SpinBoxValue").editable = false
	%WagSpeedBSlider.get_node("SliderValue").editable = false
	%WagSpeedBSlider.get_node("SpinBoxValue").editable = false
	
	%MinimumCurve.get_node("SliderValue").editable = false
	%MinimumCurve.get_node("SpinBoxValue").editable = false
	%MaxmumCurve.get_node("SliderValue").editable = false
	%MaxmumCurve.get_node("SpinBoxValue").editable = false
	%AutoWagCheck.disabled = true
	%WagFreqBSlider.get_node("SliderValue").editable = false
	%WagFreqBSlider.get_node("SpinBoxValue").editable = false
	
	
	
	%WiggleWidthSpin.editable = false
	%WiggleLengthSpin.editable = false
	%WiggleSubDSpin.editable = false
	%WAGravityX.editable = false
	%WAGravityY.editable = false
	%ClosedLoopCheck.disabled = true
	
	
	%AdvancedLipSync.disabled = true
	
	%FMxBSlider.get_node("SliderValue").editable = false
	%FMxBSlider.get_node("SpinBoxValue").editable = false
	%FMYBSlider.get_node("SliderValue").editable = false
	%FMYBSlider.get_node("SpinBoxValue").editable = false
	
	%ShouldRotCheck.disabled = true
	%RotationSpeedBSlider.get_node("SliderValue").editable = false
	%RotationSpeedBSlider.get_node("SpinBoxValue").editable = false

	%CurrentSelectedNormal.texture = null
	%CurrentSelected.texture = null
	
	%AnimationReset.disabled = true
	%AnimationOneShot.disabled = true
	
	%Rainbow.disabled = true
	%"Self-Rainbow Only".disabled = true
	%RSSlider.editable = false
	%FollowParentEffect.disabled = true
	%FollowWiggleAppTip.disabled = true
	
	%MiniRotationLevelBSlider.get_node("SliderValue").editable = false
	%MiniRotationLevelBSlider.get_node("SpinBoxValue").editable = false
	%MaxRotationLevelBSlider.get_node("SliderValue").editable = false
	%MaxRotationLevelBSlider.get_node("SpinBoxValue").editable = false
	%IsAssetCheck.disabled = true
	%IsAssetButton.disabled = true
	%RemoveAssetButton.disabled = true
	%ShouldDisappearCheck.disabled = true
	%ShouldDisDelButton.disabled = true
	%ShouldDisRemapButton.disabled = true
	%OffsetXSpinBox.editable = false
	%OffsetYSpinBox.editable = false
	%TipSpin.editable = false
	
	%DragBSlider.get_node("SliderValue").editable = false
	%DragBSlider.get_node("SpinBoxValue").editable = false
	
	%MiniFWBSlider.get_node("SliderValue").editable = false
	%MiniFWBSlider.get_node("SpinBoxValue").editable = false
	
	%MaxFWBSlider.get_node("SliderValue").editable = false
	%MaxFWBSlider.get_node("SpinBoxValue").editable = false
	%FlipSpriteH.disabled = true
	%FlipSpriteV.disabled = true
	


func held_sprite_is_true():
	%DeselectButton.show()
	x_amp.editable = true
	x_freq.editable = true
	
	y_amp.editable = true
	y_freq.editable = true
	
	%RotationLevelBSlider.get_node("SpinBoxValue").editable = true
	
	%XAmpBSlider.get_node("SpinBoxValue").editable = true
	%XFBSlider.get_node("SpinBoxValue").editable = true
	%YAmpBSlider.get_node("SpinBoxValue").editable = true
	%YFBSlider.get_node("SpinBoxValue").editable = true
	
	%StretchBSlider.get_node("SliderValue").editable = true
	%StretchBSlider.get_node("SpinBoxValue").editable = true
	
	if not Global.held_sprite.dictmain.advanced_lipsync:
		if Global.held_sprite.sprite_type == "Sprite2D" && not Global.held_sprite.img_animated:
			%AnimationFramesSlider.editable = true
			%AnimationSpeedSlider.editable = true
	else:
		%AnimationFramesSlider.editable = false
		%AnimationSpeedSlider.editable = false
		
	%SizeSpinBox.editable = true
	%SizeSpinYBox.editable = true
	%ReplaceButton.disabled = false
	%DuplicateButton.disabled = false
	%DeleteButton.disabled = false
	
	%Name.editable = true
	color.disabled = false
	rot.editable = true
	blend.disabled = false
	clip.disabled = false
	
	%PosXSpinBox.editable = true
	%PosYSpinBox.editable = true
	%RotSpinBox.editable = true
	
	vis.disabled = false
	checke.disabled = false
	checkm.disabled = false
	eyeop.disabled = false
	mouthop.disabled = false
	zord.editable = true
	%IgnoreBounce.disabled = false
	%Physics.disabled = false
	
	%WiggleCheck.disabled = false
	%WigglePhysicsCheck.disabled = false
	%WiggleAmpBSlider.get_node("SliderValue").editable = true
	%WiggleAmpBSlider.get_node("SpinBoxValue").editable = true
	%WiggleFreqBSlider.get_node("SliderValue").editable = true
	%WiggleFreqBSlider.get_node("SpinBoxValue").editable = true
	%FollowParentEffect.disabled = false
	%XoffsetSpinBox.editable = true
	%YoffsetSpinBox.editable = true
	
	%AdvancedLipSync.disabled = false
	
	%ShouldRotCheck.disabled = false
	%RotationSpeedBSlider.get_node("SliderValue").editable = true
	%RotationSpeedBSlider.get_node("SpinBoxValue").editable = true
	
	if Global.held_sprite.sprite_type == "WiggleApp":
		%WiggleAppSegmBSlider.get_node("SliderValue").editable = true
		%WiggleAppSegmBSlider.get_node("SpinBoxValue").editable = true
		%WiggleAppsCurveBSlider.get_node("SliderValue").editable = true
		%WiggleAppsCurveBSlider.get_node("SpinBoxValue").editable = true
		%WiggleAppsStiffBSlider.get_node("SliderValue").editable = true
		%WiggleAppsStiffBSlider.get_node("SpinBoxValue").editable = true
		%WiggleAppsMaxAngleBSlider.get_node("SliderValue").editable = true
		%WiggleAppsMaxAngleBSlider.get_node("SpinBoxValue").editable = true
		%WiggleAppsPhysStiffBSlider.get_node("SliderValue").editable = true
		%WiggleAppsPhysStiffBSlider.get_node("SpinBoxValue").editable = true
		%WiggleWidthSpin.editable = true
		%WiggleLengthSpin.editable = true
		%WiggleSubDSpin.editable = true
		%WAGravityX.editable = true
		%WAGravityY.editable = true
		%ClosedLoopCheck.disabled = false
		
		%WagSpeedBSlider.get_node("SliderValue").editable = true
		%WagSpeedBSlider.get_node("SpinBoxValue").editable = true

		%MinimumCurve.get_node("SliderValue").editable = true
		%MinimumCurve.get_node("SpinBoxValue").editable = true
		%MaxmumCurve.get_node("SliderValue").editable = true
		%MaxmumCurve.get_node("SpinBoxValue").editable = true
		%AutoWagCheck.disabled = false
		%WagFreqBSlider.get_node("SliderValue").editable = true
		%WagFreqBSlider.get_node("SpinBoxValue").editable = true
		
		
		
		
	else:
		%WiggleAppSegmBSlider.get_node("SliderValue").editable = false
		%WiggleAppSegmBSlider.get_node("SpinBoxValue").editable = false
		%WiggleAppsCurveBSlider.get_node("SliderValue").editable = false
		%WiggleAppsCurveBSlider.get_node("SpinBoxValue").editable = false
		%WiggleAppsStiffBSlider.get_node("SliderValue").editable = false
		%WiggleAppsStiffBSlider.get_node("SpinBoxValue").editable = false
		%WiggleAppsMaxAngleBSlider.get_node("SliderValue").editable = false
		%WiggleAppsMaxAngleBSlider.get_node("SpinBoxValue").editable = false
		%WiggleAppsPhysStiffBSlider.get_node("SliderValue").editable = false
		%WiggleAppsPhysStiffBSlider.get_node("SpinBoxValue").editable = false
		
		%FlipSpriteH.disabled = false
		%FlipSpriteV.disabled = false
		
	%OffsetXSpinBox.editable = true
	%OffsetYSpinBox.editable = true
	
		
	
	%FMxBSlider.get_node("SliderValue").editable = true
	%FMxBSlider.get_node("SpinBoxValue").editable = true
	%FMYBSlider.get_node("SliderValue").editable = true
	%FMYBSlider.get_node("SpinBoxValue").editable = true
	
	
	if !Global.held_sprite.is_apng:
		%AnimationOneShot.disabled = false
	%AnimationReset.disabled = false
	
	
	%Rainbow.disabled = false
	%"Self-Rainbow Only".disabled = false
	%RSSlider.editable = true
	
	%FollowWiggleAppTip.disabled = false
	
	%MiniRotationLevelBSlider.get_node("SliderValue").editable = true
	%MiniRotationLevelBSlider.get_node("SpinBoxValue").editable = true
	%MaxRotationLevelBSlider.get_node("SliderValue").editable = true
	%MaxRotationLevelBSlider.get_node("SpinBoxValue").editable = true
	
	%IsAssetCheck.disabled = false
	%IsAssetButton.disabled = false
	%RemoveAssetButton.disabled = false
	%ShouldDisappearCheck.disabled = false
	%TipSpin.editable = true
	%IsAssetButton.text = "Null"
	
	%DragBSlider.get_node("SliderValue").editable = true
	%DragBSlider.get_node("SpinBoxValue").editable = true
	
	%MiniFWBSlider.get_node("SliderValue").editable = true
	%MiniFWBSlider.get_node("SpinBoxValue").editable = true
	
	%MaxFWBSlider.get_node("SliderValue").editable = true
	%MaxFWBSlider.get_node("SpinBoxValue").editable = true
	

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
		blend.text = Global.held_sprite.dictmain.blend_mode
		Global.held_sprite.set_blend(Global.held_sprite.dictmain.blend_mode)
		Global.held_sprite.save_state(Global.current_state)

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
	held_sprite_is_true()
	x_amp.value = Global.held_sprite.dictmain.xAmp
	x_freq.value = Global.held_sprite.dictmain.xFrq
	
	y_amp.value = Global.held_sprite.dictmain.yAmp
	y_freq.value = Global.held_sprite.dictmain.yFrq
	
	rot.value = Global.held_sprite.dictmain.rdragStr
	vis.button_pressed = Global.held_sprite.dictmain.visible
	
	checke.button_pressed = Global.held_sprite.dictmain.should_blink
	eyeop.button_pressed = Global.held_sprite.dictmain.open_eyes
	
	checkm.button_pressed = Global.held_sprite.dictmain.should_talk
	mouthop.button_pressed = Global.held_sprite.dictmain.open_mouth
	%ShouldRotCheck.button_pressed = Global.held_sprite.dictmain.should_rotate
	%RotationSpeedBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.should_rot_speed
	%ZOrderSpinbox.value = Global.held_sprite.dictmain.z_index
	
	
	if not Global.held_sprite.dictmain.folder:
		
		%CurrentSelectedNormal.texture = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.normal_texture
		%CurrentSelected.texture = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.diffuse_texture
	else:
		%CurrentSelected.texture = null
		%CurrentSelectedNormal.texture = null
	
	%Name.text = Global.held_sprite.treeitem.get_node("%NameLabel").text
	
	if Global.held_sprite.sprite_type == "Sprite2D":
		%AnimationFramesSlider.value = Global.held_sprite.dictmain.hframes
		%AnimationSpeedSlider.value = Global.held_sprite.dictmain.animation_speed
	
		
	%SizeSpinBox.value = Global.held_sprite.dictmain.scale.x
	%SizeSpinYBox.value = Global.held_sprite.dictmain.scale.y
	
	%StretchBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.stretchAmount
	color.color = Global.held_sprite.dictmain.colored
	%IgnoreBounce.button_pressed = Global.held_sprite.dictmain.ignore_bounce
	%Physics.button_pressed = Global.held_sprite.dictmain.physics
	
	%AdvancedLipSync.button_pressed = Global.held_sprite.dictmain.advanced_lipsync

	
	
	
	if Global.held_sprite.sprite_type == "Sprite2D":
		%WiggleStuff.show()
		%WiggleAppStuff.hide()
		%FlipSpriteHBox.show()
		%WiggleCheck.button_pressed = Global.held_sprite.dictmain.wiggle
		%WigglePhysicsCheck.button_pressed = Global.held_sprite.dictmain.wiggle_physics
		%WiggleAmpBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.wiggle_amp
		%WiggleFreqBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.wiggle_freq
		%FollowParentEffect.button_pressed = Global.held_sprite.dictmain.follow_parent_effects
		%XoffsetSpinBox.value = Global.held_sprite.dictmain.wiggle_rot_offset.x
		%YoffsetSpinBox.value = Global.held_sprite.dictmain.wiggle_rot_offset.y
		
		%FlipSpriteH.button_pressed = Global.held_sprite.dictmain.flip_sprite_h
		%FlipSpriteV.button_pressed = Global.held_sprite.dictmain.flip_sprite_v
		
	
	elif Global.held_sprite.sprite_type == "WiggleApp":
		%FlipSpriteHBox.hide()
		%WiggleStuff.hide()
		%WiggleAppStuff.show()
		
		%WiggleAppSegmBSlider.get_node("SliderValue").value = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").segment_count
		%WiggleAppsCurveBSlider.get_node("SliderValue").value = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").curvature
		%WiggleAppsStiffBSlider.get_node("SliderValue").value = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").stiffness
		%WiggleAppsMaxAngleBSlider.get_node("SliderValue").value = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").max_angle
		%WiggleAppsPhysStiffBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.wiggle_physics_stiffness
		%WiggleWidthSpin.value = Global.held_sprite.dictmain.width
		%WiggleLengthSpin.value = Global.held_sprite.dictmain.segm_length
		%WiggleSubDSpin.value = Global.held_sprite.dictmain.subdivision
		%WAGravityX.value = Global.held_sprite.dictmain.wiggle_gravity.x
		%WAGravityY.value = Global.held_sprite.dictmain.wiggle_gravity.y
		%ClosedLoopCheck.button_pressed = Global.held_sprite.dictmain.wiggle_closed_loop
		%AutoWagCheck.button_pressed = Global.held_sprite.dictmain.auto_wag
		%WagSpeedBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.wag_speed
		%MinimumCurve.get_node("SliderValue").value = Global.held_sprite.dictmain.wag_mini
		%MaxmumCurve.get_node("SliderValue").value = Global.held_sprite.dictmain.wag_max
		%WagFreqBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.wag_freq
		
		
	%OffsetXSpinBox.value = Global.held_sprite.dictmain.offset.x
	%OffsetYSpinBox.value = Global.held_sprite.dictmain.offset.y
	
	%PosXSpinBox.value = Global.held_sprite.dictmain.position.x
	%PosYSpinBox.value = Global.held_sprite.dictmain.position.y
	%RotSpinBox.value = Global.held_sprite.dictmain.rotation / 0.01745
	
	if !%PosXSpinBox.value_changed.is_connected(_on_pos_x_spin_box_value_changed):
		%PosXSpinBox.value_changed.connect(_on_pos_x_spin_box_value_changed)
		%PosYSpinBox.value_changed.connect(_on_pos_y_spin_box_value_changed)
	
	
	%MiniFWBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.follow_wa_mini
	%MaxFWBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.follow_wa_max
	
	
	if Global.held_sprite.get_parent() is WigglyAppendage2D:
		%TipSpin.max_value = Global.held_sprite.get_parent().points.size() -1
		
	
	%TipSpin.value = Global.held_sprite.dictmain.tip_point
	
	if Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").get_clip_children_mode() == 0:
		clip.button_pressed = false
	else:
		clip.button_pressed = true
		
	blend.text = Global.held_sprite.dictmain.blend_mode
	
	%FMxBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.look_at_mouse_pos
	%FMYBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.look_at_mouse_pos_y
	
	%AnimationReset.button_pressed = Global.held_sprite.dictmain.should_reset
	%AnimationOneShot.button_pressed = Global.held_sprite.dictmain.one_shot
	
	%Rainbow.button_pressed = Global.held_sprite.dictmain.rainbow
	%"Self-Rainbow Only".button_pressed = Global.held_sprite.dictmain.rainbow_self
	%RSSlider.value = Global.held_sprite.dictmain.rainbow_speed
	
	%FollowWiggleAppTip.button_pressed = Global.held_sprite.dictmain.follow_wa_tip
	
	%MiniRotationLevelBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.rLimitMin
	%MaxRotationLevelBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.rLimitMax
	
	%DragBSlider.get_node("SliderValue").value = Global.held_sprite.dictmain.dragSpeed
	
	
	%IsAssetButton.action = str(Global.held_sprite.sprite_id)
	%IsAssetCheck.button_pressed = Global.held_sprite.is_asset
	%ShouldDisList.clear()
	for i in Global.held_sprite.saved_keys:
		%ShouldDisList.add_item(i)
	%ShouldDisappearCheck.button_pressed = Global.held_sprite.should_disappear
	%IsAssetButton.update_key_text()
	

func update_pos_spins():
	%PosXSpinBox.value = Global.held_sprite.position.x
	%PosYSpinBox.value = Global.held_sprite.position.y
	%RotSpinBox.value = Global.held_sprite.rotation / 0.01745
	Global.held_sprite.save_state(Global.current_state)
	





func update_offset():
	%OffsetXSpinBox.value = Global.held_sprite.dictmain.offset.x
	%OffsetYSpinBox.value = Global.held_sprite.dictmain.offset.y
	update_pos_spins()





func reinfoanim():
	mc_anim.text = contain.current_mc_anim
	mo_anim.text = contain.current_mo_anim

#endregion

#region Movement Sliders
func _on_x_amp_slider_value_changed(value):
	Global.held_sprite.dictmain.xAmp = value
	Global.held_sprite.save_state(Global.current_state)

func _on_xf_slider_value_changed(value):
	Global.held_sprite.dictmain.xFrq = value
	Global.held_sprite.save_state(Global.current_state)

func _on_y_amp_slider_value_changed(value):
	Global.held_sprite.dictmain.yAmp = value
	Global.held_sprite.save_state(Global.current_state)

func _on_yf_slider_value_changed(value):
	Global.held_sprite.dictmain.yFrq = value
	Global.held_sprite.save_state(Global.current_state)

func _on_rotation_level_value_changed(value):
	Global.held_sprite.dictmain.rdragStr = value
	Global.held_sprite.save_state(Global.current_state)

func _on_stretch_slider_value_changed(value):
	Global.held_sprite.dictmain.stretchAmount = value
	Global.held_sprite.save_state(Global.current_state)
#endregion

#region misc
func _on_check_box_toggled(toggled_on):
	if toggled_on:
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").set_clip_children_mode(2)
		Global.held_sprite.dictmain.clip = 2
	else:
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").set_clip_children_mode(0)
		Global.held_sprite.dictmain.clip = 0
	Global.held_sprite.save_state(Global.current_state)

func _on_name_text_submitted(new_text):
	Global.held_sprite.treeitem.get_node("%NameLabel").text = new_text
	Global.held_sprite.sprite_name = new_text
	Global.held_sprite.save_state(Global.current_state)
	Global.spinbox_held = false
	%Name.release_focus()

func _on_visible_toggled(toggled_on):
	if toggled_on:
		Global.held_sprite.dictmain.visible = true
		Global.held_sprite.visible = true
	else:
		Global.held_sprite.dictmain.visible = false
		Global.held_sprite.visible = false
	get_parent().update_visib_buttons()
	Global.held_sprite.save_state(Global.current_state)

func _on_z_order_spinbox_value_changed(value):
	Global.held_sprite.dictmain.z_index = value
	Global.held_sprite.z_index = value
	Global.held_sprite.save_state(Global.current_state)

func _on_color_picker_button_color_changed(newcolor):
	if Global.held_sprite.sprite_type == "Folder":
		Global.held_sprite.modulate.r = newcolor.r
		Global.held_sprite.modulate.g = newcolor.g
		Global.held_sprite.modulate.b = newcolor.b
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").self_modulate.a = newcolor.a
	else:
		Global.held_sprite.modulate = newcolor
	
	Global.held_sprite.dictmain.colored = newcolor
	Global.held_sprite.save_state(Global.current_state)


func _on_rotation_speed_value_changed(value):
	Global.held_sprite.dictmain.should_rot_speed = value
	Global.held_sprite.save_state(Global.current_state)


func _on_should_rot_check_toggled(toggled_on):
	Global.held_sprite.dictmain.should_rotate = toggled_on
	if not toggled_on:
		Global.held_sprite.get_node("Pos/Wobble").rotation = 0
	
	Global.held_sprite.save_state(Global.current_state)



func _on_animation_reset_toggled(toggled_on):
	Global.held_sprite.dictmain.should_reset = toggled_on
	Global.held_sprite.save_state(Global.current_state)


func _on_rainbow_toggled(toggled_on):
	Global.held_sprite.dictmain.rainbow = toggled_on
	Global.held_sprite.save_state(Global.current_state)


func _on_self_rainbow_only_toggled(toggled_on):
	Global.held_sprite.dictmain.rainbow_self = toggled_on
	Global.held_sprite.save_state(Global.current_state)


func _on_rs_slider_value_changed(value):
	Global.held_sprite.dictmain.rainbow_speed = value
	Global.held_sprite.save_state(Global.current_state)



#endregion

#region Eye and Mouth stuff
func _on_check_eye_toggled(toggled_on):
	Global.held_sprite.dictmain.should_blink = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_eye_open_toggled(toggled_on):
	Global.held_sprite.dictmain.open_eyes = toggled_on
	Global.held_sprite.blink()
	
	Global.held_sprite.save_state(Global.current_state)

func _on_check_mouth_toggled(toggled_on):
	Global.held_sprite.dictmain.should_talk = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_mouth_open_toggled(toggled_on):
	Global.held_sprite.dictmain.open_mouth = toggled_on
	Global.held_sprite.check_talk()
	
	Global.held_sprite.save_state(Global.current_state)

func _on_volume_slider_value_changed(value):
	Global.settings_dict.volume_limit = value


func _on_delay_slider_value_changed(value):
	Global.settings_dict.volume_delay = value



func _on_sensitivity_slider_value_changed(value):
	Global.settings_dict.sensitivity_limit = value
	%SensitivityBar.value = value
#endregion

#region Left Panel
func _on_animation_frames_slider_value_changed(value):
	%AnimationFramesLabel.text = "Animation frames : " + str(value)
	Global.held_sprite.dictmain.hframes = value
	Global.held_sprite.animation()
	Global.held_sprite.get_node("%Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT
	Global.held_sprite.save_state(Global.current_state)

func _on_animation_speed_slider_value_changed(value):
	%AnimationSpeedLabel.text = "Animation Speed : " + str(value) + " Fps"
	Global.held_sprite.dictmain.animation_speed = value
	Global.held_sprite.animation()
	Global.held_sprite.save_state(Global.current_state)

func _on_blink_speed_slider_value_changed(value):
	Global.settings_dict.blink_speed = value
	%BlinkSpeedLabel.text = "Blink Speed : " + str(snappedf(value, 0.1))

func _on_delete_button_pressed():
	if Global.held_sprite != null:
		Global.held_sprite.treeitem.free()
		Global.held_sprite.queue_free()
		%CurrentSelected.texture = null
		Global.held_sprite = null
		held_sprite_is_null()
		%DeselectButton.hide()

func _on_duplicate_button_pressed():
	if Global.held_sprite != null:
		var obj
		if Global.held_sprite.sprite_type == "WiggleApp":
			obj = preload("res://Misc/AppendageObject/Appendage_object.tscn").instantiate()
			
		elif Global.held_sprite.sprite_type == "Folder":
			obj = preload("res://Misc/FolderObject/Folder_object.tscn").instantiate()
		else:
			obj = preload("res://Misc/SpriteObject/sprite_object.tscn").instantiate()
		
		obj.scale = Global.held_sprite.scale
		obj.dictmain.scale = Global.held_sprite.scale
		contain.add_child(obj)
		if obj.sprite_type != "Folder":
			obj.texture = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture
			obj.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture = Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture
		obj.sprite_name = "Duplicate" + Global.held_sprite.sprite_name 

		if Global.held_sprite.dictmain.folder:
			obj.dictmain.folder = true
		
		if Global.held_sprite.img_animated:
			obj.img_animated = true
			obj.anim_texture = Global.held_sprite.anim_texture
			obj.anim_texture_normal = Global.held_sprite.anim_texture_normal 
		
		obj.dictmain = Global.held_sprite.dictmain.duplicate()
		obj.states = Global.held_sprite.states.duplicate()
		get_parent().add_item(obj)
		obj.sprite_id = obj.get_instance_id()
		obj.get_state(Global.current_state)


func _on_replace_button_pressed():
	get_tree().get_root().get_node("Main").replacing_sprite()

func _on_add_sprite_button_pressed():
	get_tree().get_root().get_node("Main").load_sprites()

func _on_folder_button_pressed():
	var sprte_obj = preload("res://Misc/SpriteObject/sprite_object.tscn").instantiate()
	contain.add_child(sprte_obj)
	sprte_obj.texture = preload("res://Misc/SpriteObject/Folder.png")
	sprte_obj.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.diffuse_texture = preload("res://Misc/SpriteObject/Folder.png")
	sprte_obj.sprite_name = str("Folder")
	sprte_obj.dictmain.folder = true
	var states = get_tree().get_nodes_in_group("StateButtons").size()
	for i in states:
		sprte_obj.states.append({})
	get_parent().add_item(sprte_obj)
	sprte_obj.sprite_id = sprte_obj.get_instance_id()
#endregion

#region Bounce stuff
func _on_ignore_bounce_toggled(toggled_on):
	Global.held_sprite.dictmain.ignore_bounce = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_physics_toggled(toggled_on):
	Global.held_sprite.dictmain.physics = toggled_on
	Global.held_sprite.save_state(Global.current_state)
#endregion

#region Position and rotation
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
#endregion

#region normalmap stuff
func _on_add_normal_button_pressed():
	get_tree().get_root().get_node("Main").add_normal_sprite()

func _on_del_normal_button_pressed():
	if Global.held_sprite != null:
		if !Global.held_sprite.is_apng:
			if not Global.held_sprite.dictmain.folder:
				Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.normal_texture = null
#endregion

#region size stuff

func _on_size_spin_y_box_value_changed(value):
	Global.held_sprite.dictmain.scale.y = value
	Global.held_sprite.scale.y = value
	Global.held_sprite.save_state(Global.current_state)

func _on_size_spin_box_value_changed(value):
	Global.held_sprite.dictmain.scale.x = value
	Global.held_sprite.scale.x = value
	Global.held_sprite.save_state(Global.current_state)
#endregion

#region Wiggle stuff
func _on_wiggle_amp_slider_value_changed(value):
	Global.held_sprite.dictmain.wiggle_amp = value
	Global.held_sprite.save_state(Global.current_state)

func _on_wiggle_freq_slider_value_changed(value):
	Global.held_sprite.dictmain.wiggle_freq = value
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_check_toggled(toggled_on):
	Global.held_sprite.dictmain.wiggle = toggled_on
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").material.set_shader_parameter("wiggle", toggled_on)
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_physics_check_toggled(toggled_on):
	Global.held_sprite.dictmain.wiggle_physics = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_xoffset_spin_box_value_changed(value):
	Global.held_sprite.dictmain.wiggle_rot_offset.x = value
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").material.set_shader_parameter("wiggle_rot_offset:x", value)
	Global.held_sprite.save_state(Global.current_state)

func _on_yoffset_spin_box_value_changed(value):
	Global.held_sprite.dictmain.wiggle_rot_offset.y = value
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").material.set_shader_parameter("wiggle_rot_offset:y", value)
	Global.held_sprite.save_state(Global.current_state)

# -------------------------------------------------


func _on_wiggle_app_segm_slider_value_changed(value):
	if Global.held_sprite:
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").segment_count = value
		Global.held_sprite.save_state(Global.current_state)

func _on_wiggle_apps_curve_slider_value_changed(value):
	if Global.held_sprite:
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").curvature = value
		Global.held_sprite.save_state(Global.current_state)

func _on_wiggle_apps_stiff_slider_value_changed(value):
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").stiffness = value
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_apps_max_angle_slider_value_changed(value):
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").max_angle = value
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_apps_phys_stiff_slider_value_changed(value):
	if Global.held_sprite:
		Global.held_sprite.dictmain.wiggle_physics_stiffness = value
		Global.held_sprite.save_state(Global.current_state)

func _on_follow_wiggle_app_tip_toggled(toggled_on):
	Global.held_sprite.dictmain.follow_wa_tip = toggled_on
	if toggled_on:
		%HBox34.show()
		%MiniFWBox.show()
		%MaxFWBox.show()
	if not toggled_on:
		%HBox34.hide()
		%MiniFWBox.hide()
		%MaxFWBox.hide()
		Global.held_sprite.get_node("Pos").position = Vector2(0,0)
	Global.held_sprite.save_state(Global.current_state)
	

func _on_wiggle_width_spin_value_changed(value):
	Global.held_sprite.dictmain.width = value
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").width = value
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_length_spin_value_changed(value):
	Global.held_sprite.dictmain.segm_length = value
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").segment_length = value
	Global.held_sprite.save_state(Global.current_state)


func _on_wiggle_sub_d_spin_value_changed(value):
	Global.held_sprite.dictmain.subdivision = value
	Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").subdivision = value
	Global.held_sprite.save_state(Global.current_state)

func _on_follow_parent_effect_toggled(toggled_on):
	Global.held_sprite.dictmain.follow_parent_effects = toggled_on
	Global.held_sprite.save_state(Global.current_state)
	


#endregion

#region Advanced-LipSync
func _on_advanced_lip_sync_toggled(toggled_on):
	Global.held_sprite.dictmain.advanced_lipsync = toggled_on
	if Global.held_sprite.sprite_type == "Sprite2D":
		Global.held_sprite.dictmain.animation_speed = 1
		if toggled_on:
			Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").hframes = 6
		else:
			Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").hframes = 1
		Global.held_sprite.advanced_lipsyc()
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D/Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT
		Global.held_sprite.save_state(Global.current_state)
	%AnimationFramesSlider.editable = !toggled_on
	%AnimationSpeedSlider.editable = !toggled_on
	

func _on_advanced_lip_sync_mouse_entered():
	%AdvancedLipSyncLabel.show()

func _on_advanced_lip_sync_mouse_exited():
	%AdvancedLipSyncLabel.hide()

#endregion

#region Follow Mouse
func _on_f_mx_slider_value_changed(value):
	Global.held_sprite.dictmain.look_at_mouse_pos = value
	Global.held_sprite.save_state(Global.current_state)


func _on_fmy_slider_value_changed(value):
	Global.held_sprite.dictmain.look_at_mouse_pos_y = value
	Global.held_sprite.save_state(Global.current_state)

#endregion

func _on_animation_one_shot_toggled(toggled_on):
	Global.held_sprite.dictmain.one_shot = toggled_on
	if Global.held_sprite.img_animated:
		Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.diffuse_texture.one_shot = toggled_on
		if Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.normal_texture != null:
			Global.held_sprite.get_node("Pos/Wobble/Squish/Drag/Rotation/Sprite2D").texture.normal_texture.one_shot = toggled_on
	Global.held_sprite.save_state(Global.current_state)

func _on_mini_rotation_level_value_changed(value):
	Global.held_sprite.dictmain.rLimitMin = value
	Global.held_sprite.save_state(Global.current_state)

func _on_max_rotation_level_value_changed(value):
	Global.held_sprite.dictmain.rLimitMax = value
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



func _on_wa_gravity_x_value_changed(value):
	if Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.dictmain.wiggle_gravity.x = value
		Global.held_sprite.get_node("%Sprite2D").gravity.x = value
		Global.held_sprite.save_state(Global.current_state)
		


func _on_wa_gravity_y_value_changed(value):
	if Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.dictmain.wiggle_gravity.y = value
		Global.held_sprite.get_node("%Sprite2D").gravity.y = value
		Global.held_sprite.save_state(Global.current_state)



func _on_tip_spin_value_changed(value):
	Global.held_sprite.dictmain.tip_point = value
	Global.held_sprite.save_state(Global.current_state)


func _on_closed_loop_check_toggled(toggled_on):
	if Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.dictmain.wiggle_closed_loop = toggled_on
		Global.held_sprite.get_node("%Sprite2D").closed = toggled_on
		Global.held_sprite.save_state(Global.current_state)


func on_wag_speed_changed(value):
	if Global.held_sprite != null:
		Global.held_sprite.dictmain.wag_speed = value
		Global.held_sprite.save_state(Global.current_state)

func on_wag_minicurve_changed(value):
	if Global.held_sprite != null:
		Global.held_sprite.dictmain.wag_mini = value
		Global.held_sprite.save_state(Global.current_state)
		
func on_wag_maxcurve_changed(value):
	if Global.held_sprite != null:
		Global.held_sprite.dictmain.wag_max = value
		Global.held_sprite.save_state(Global.current_state)
		

func _on_auto_wag_check_toggled(toggled_on):
	Global.held_sprite.dictmain.auto_wag = toggled_on
	if toggled_on:
		%HBoxMiniCurve.show()
		%HBoxMaxCurve.show()
		%HBoxWagFreq.show()
		%HBox26.hide()
	if !toggled_on:
		Global.held_sprite.get_node("%Sprite2D").curvature = Global.held_sprite.dictmain.wiggle_curve
		%HBoxMiniCurve.hide()
		%HBoxMaxCurve.hide()
		%HBoxWagFreq.hide()
		%HBox26.show()
		
	Global.held_sprite.save_state(Global.current_state)



func on_wag_freq_changed(value):
	if Global.held_sprite != null:
		Global.held_sprite.dictmain.wag_freq = value
		Global.held_sprite.save_state(Global.current_state)


func on_drag_changed(value):
	Global.held_sprite.dictmain.dragSpeed = value
	Global.held_sprite.save_state(Global.current_state)


func on_mini_fw_changed(value):
	Global.held_sprite.dictmain.follow_wa_mini = value
	Global.held_sprite.save_state(Global.current_state)



func on_max_fw_changed(value):
	Global.held_sprite.dictmain.follow_wa_max = value
	Global.held_sprite.save_state(Global.current_state)


func _on_flip_sprite_h_toggled(toggled_on: bool) -> void:
	if Global.held_sprite.sprite_type == "Sprite2D":
		Global.held_sprite.dictmain.flip_sprite_h = toggled_on
		Global.held_sprite.get_node("%Sprite2D").flip_h = toggled_on
		Global.held_sprite.save_state(Global.current_state)

func _on_flip_sprite_v_toggled(toggled_on: bool) -> void:
	if Global.held_sprite.sprite_type == "Sprite2D":
		Global.held_sprite.dictmain.flip_sprite_v = toggled_on
		Global.held_sprite.get_node("%Sprite2D").flip_v = toggled_on
		Global.held_sprite.save_state(Global.current_state)


func _on_name_focus_entered() -> void:
	Global.spinbox_held = true


func _on_name_focus_exited() -> void:
	Global.spinbox_held = false


func _on_color_picker_button_focus_entered() -> void:
	Global.spinbox_held = true


func _on_color_picker_button_focus_exited() -> void:
	Global.spinbox_held = false
