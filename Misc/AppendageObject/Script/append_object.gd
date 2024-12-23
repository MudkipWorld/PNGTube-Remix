extends Node2D

#Movement
var heldTicks = 0
@onready var dragger = $Pos/Wobble/Squish/Drag
@onready var wob = $Pos/Wobble
@onready var sprite = %Sprite2D
@onready var contain = get_tree().get_root().get_node("Main/SubViewportContainer/SubViewport/Node2D/Origin/SpritesContainer")
@onready var img = %Sprite2D.texture.get_image()
#Wobble
var squish = 1
var texture 
var currently_speaking : bool = false
# Misc
var treeitem : LayerItem
var visb
var sprite_name : String = ""
@export var states : Array = [{},{},{},{},{},{},{},{},{},{}]
var coord
var dragging : bool = false
var of = Vector2(0,0)

var sprite_id : float
var parent_id : float = 0
var physics_effect = 1
var glob

var sprite_type : String = "WiggleApp"

var anim_texture 
var anim_texture_normal 
var img_animated : bool = false



@onready var dictmain : Dictionary = {
	xFrq = 0,
	xAmp = 0,
	yFrq = 0,
	yAmp = 0,
	rdragStr = 0,
	rLimitMax = 180,
	rLimitMin = -180,
	dragSpeed = 0,
	stretchAmount = 0,
	blend_mode = "Normal",
	visible = visible,
	colored = modulate,
	z_index = z_index,
	open_eyes = true,
	open_mouth = false,
	should_blink = false,
	should_talk =  false,
	animation_speed = 1,
	hframes = 1,
	scale = scale,
	folder = false,
	position = position,
	rotation = rotation,
	offset = %Sprite2D.position,
	ignore_bounce = false,
	clip = 0,
	physics = true,
	wiggle_segm = 5,
	wiggle_curve = 0,
	wiggle_stiff = 20,
	wiggle_max_angle = 0.5,
	wiggle_physics_stiffness = 2.5,
	wiggle_gravity = Vector2(0,0),
	wiggle_closed_loop = false,
	advanced_lipsync = false,
	look_at_mouse_pos = 0,
	look_at_mouse_pos_y = 0,
	should_rotate = false,
	should_rot_speed = 0.001,
	width = 80,
	segm_length = 30,
	subdivision = 5,
	should_reset = false,
	one_shot = false,
	rainbow = false,
	rainbow_self = false,
	rainbow_speed = 0.01,
	follow_wa_tip = false,
	tip_point = 0,
	auto_wag = false,
	wag_mini = -180,
	wag_max = 180,
	wag_speed = 0.5,
	wag_freq = 0.02,
	follow_wa_mini = -180,
	follow_wa_max = 180,
	
	max_angular_momentum = 15,
	damping = 5,
	comeback_speed = 0.419,
	follow_mouse_velocity = false,
	}

var smooth_rot = 0.0
var smooth_glob = Vector2(0.0,0.0)
var is_apng : bool = false
var is_collapsed : bool = false

var dt = 0.0
var frames : Array[AImgIOFrame] = []
var frames2 : Array[AImgIOFrame] = []
var fidx = 0

var saved_event : InputEvent
var is_asset : bool = false
var was_active_before : bool = true
var should_disappear : bool = false
var saved_keys : Array = []

var last_mouse_position : Vector2 = Vector2(0,0)
var last_dist : Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().get_node("Main").key_pressed.connect(asset)
	Global.mode_changed.connect(update_to_mode_change)
	Global.blink.connect(blink)
	Global.blink.connect(editor_blink)
	Global.speaking.connect(speaking)
	Global.not_speaking.connect(not_speaking)
	%Dragger.top_level = true
	%Dragger.global_position = wob.global_position
	
	
	
	update_wiggle_parts()

func correct_sprite_size():
	var w = %Sprite2D.texture.get_image().get_size().y / 0.98
	var l = %Sprite2D.texture.get_image().get_size().x / 5
	
	dictmain.width = w
	dictmain.segm_length = l


func blink():
	if Global.mode != 0:
		if dictmain.should_blink:
			%Pos.modulate.a = 1
			if not dictmain.open_eyes:
				
				%Pos.show()
			else:
				%Pos.hide()
		
		$Blink.wait_time = 0.2 * Global.settings_dict.blink_speed
		$Blink.start()
		await  $Blink.timeout
		if dictmain.should_blink:
			if not dictmain.open_eyes:
				%Pos.hide()
			else:
				%Pos.show()
		else:
			%Pos.show()

func editor_blink():
	if Global.mode == 0:
		if dictmain.should_blink:
			%Pos.show()
			if not dictmain.open_eyes:
				
				%Pos.modulate.a = 1
			else:
				%Pos.modulate.a = 0.3
		
		$Blink.wait_time = 0.2 * Global.settings_dict.blink_speed
		$Blink.start()
		await  $Blink.timeout
		if dictmain.should_blink:
			if not dictmain.open_eyes:
				%Pos.modulate.a = 0.3
			else:
				%Pos.modulate.a = 1
		else:
			%Pos.modulate.a = 1

func update_to_mode_change(mode : int):
	match mode:
		0:
			editor_blink()
			%Rotation.show()
			if dictmain.should_talk:
				if currently_speaking:
					if dictmain.open_mouth:
						%Rotation.modulate.a = 1
					else:
						%Rotation.modulate.a = 0.3
				if !currently_speaking:
					if !dictmain.open_mouth:
						%Rotation.modulate.a = 0.3
					else:
						%Rotation.modulate.a = 1
			else:
				%Rotation.show()
				%Rotation.modulate.a = 1
		1:
			blink()
			%Rotation.modulate.a = 1
			if dictmain.should_talk:
				if currently_speaking:
					if dictmain.open_mouth:
						%Rotation.show()
					else:
						%Rotation.hide()
				elif !currently_speaking:
					if !dictmain.open_mouth:
						%Rotation.show()
					else:
						%Rotation.hide()
			else:
				%Rotation.show()
				%Rotation.modulate.a = 1




func _process(delta):
	if Global.held_sprite == self:
		%Grab.mouse_filter = 1
		%Selection.show()
	else:
		%Grab.mouse_filter = 2
		%Selection.hide()
	#	%Origin.mouse_filter = 2
	if dragging:
		var mpos = get_parent().to_local(get_global_mouse_position())
		position = mpos - of
		dictmain.position = position
		save_state(Global.current_state)
		get_tree().get_root().get_node("Main/%Control/UIInput").update_pos_spins()
	
	
	if !Global.static_view:
		if dictmain.auto_wag:
			%Sprite2D.curvature = clamp(sin(Global.tick*(dictmain.wag_freq))*dictmain.wag_speed, deg_to_rad(dictmain.wag_mini), deg_to_rad(dictmain.wag_max))
		
		
		
		movements(delta)
		follow_mouse(delta)
		
		if dictmain.should_rotate:
			auto_rotate()
			
		rainbow()
	else:
		static_prev()
	
	follow_wiggle()
	
	%Grab.anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT

func static_prev():
	%Pos.position = Vector2(0,0)
	%Sprite2D.self_modulate.s = 0
	%Pos.modulate.s = 0
	$Pos/Wobble.rotation = 0
	wob.position = Vector2(0,0)
	sprite.scale = Vector2(1,1)
	dragger.global_position = wob.global_position
	%Sprite2D.curvature = 0

func movements(delta):
	glob = %Dragger.global_position
	if not dictmain.ignore_bounce:
		glob.y -= contain.bounceChange
	drag(delta)
	wobble()
	var length = (glob.y - %Dragger.global_position.y)
	if dictmain.physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D or get_parent() is CanvasGroup:
			var c_parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
			
			var c_parrent_length = (c_parent.glob.y - c_parent.get_node("%Drag").global_position.y)
			var c_parrent_length2 = (c_parent.glob.x - c_parent.get_node("%Drag").global_position.x)
			length += c_parrent_length + c_parrent_length2
	
	rotationalDrag(length,delta)
	stretch(length,delta)

func drag(_delta):
	if dictmain.dragSpeed == 0:
		%Dragger.global_position = %Wobble.global_position
	else:
		%Dragger.global_position = lerp(%Dragger.global_position,%Wobble.global_position,1/dictmain.dragSpeed)
		%Drag.global_position = %Dragger.global_position

func wobble():
	%Wobble.position.x = sin(Global.tick*dictmain.xFrq)*dictmain.xAmp
	%Wobble.position.y = sin(Global.tick*dictmain.yFrq)*dictmain.yAmp

func rotationalDrag(length,_delta):
	var yvel = (length * dictmain.rdragStr)
	
	#Calculate Max angle
	
	yvel = clamp(yvel,dictmain.rLimitMin,dictmain.rLimitMax)
	
	%Sprite2D.rotation = lerp_angle(%Sprite2D.rotation,deg_to_rad(yvel),0.25)

func stretch(length,_delta):
	var yvel = (length * dictmain.stretchAmount * 0.01)
	var target = Vector2(1.0-yvel,1.0+yvel)
	
	%Sprite2D.scale = lerp(%Sprite2D.scale,target,0.5)


func follow_wiggle():
	if dictmain.follow_wa_tip:
		if get_parent() is WigglyAppendage2D:
			var pnt = get_parent().points[clamp(dictmain.tip_point,0, get_parent().points.size() -1)]
			position = pnt
			%Pos.rotation = clamp(deg_to_rad((pnt.y/80)), dictmain.follow_wa_mini, dictmain.follow_wa_max)
		else:
			%Pos.rotation = 0
		
	else:
		%Pos.rotation = 0

func rainbow():
	if dictmain.rainbow:
		if not dictmain.rainbow_self:
			%Sprite2D.self_modulate.s = 0
			%Pos.modulate.s = 1
			%Pos.modulate.h = wrap(%Pos.modulate.h + dictmain.rainbow_speed, 0, 1)
		else:
			%Pos.modulate.s = 0
			%Sprite2D.self_modulate.s = 1
			%Sprite2D.self_modulate.h = wrap(%Sprite2D.self_modulate.h + dictmain.rainbow_speed, 0, 1)
	else:
		%Sprite2D.self_modulate.s = 0
		%Pos.modulate.s = 0


func follow_mouse(delta):
	if dictmain.follow_mouse_velocity:
		var mouse = get_local_mouse_position()
		var distance = last_mouse_position - mouse
		if !distance.is_zero_approx():
			var vel = -(distance/delta)
			var dir = Vector2.ZERO.direction_to(vel)
			var dist = vel.length()
			last_dist = Vector2(dir.x * min(dist, dictmain.look_at_mouse_pos),dir.y * min(dist, dictmain.look_at_mouse_pos_y))
		%Pos.position.x = lerp(%Pos.position.x, last_dist.x, 0.1)
		%Pos.position.y = lerp(%Pos.position.y, last_dist.y, 0.1)
		last_mouse_position = mouse
	else:
		var mouse = get_local_mouse_position()
		var dir = Vector2.ZERO.direction_to(mouse)
		var dist = mouse.length()
		%Pos.position.x = lerp(%Pos.position.x, dir.x * min(dist, dictmain.look_at_mouse_pos), 0.1)
		%Pos.position.y = lerp(%Pos.position.y, dir.y * min(dist, dictmain.look_at_mouse_pos_y), 0.1)

func auto_rotate():
	$Pos/Wobble.rotate(dictmain.should_rot_speed)


func wiggle_sprite():
	var wiggle_val = sin(Global.tick*dictmain.wiggle_freq)*dictmain.wiggle_amp
	if dictmain.wiggle_physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D:
			var c_parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
			var c_parrent_length = (c_parent.glob.y - c_parent.dragger.global_position.y)
			wiggle_val = wiggle_val + (c_parrent_length/10)
		
		
	%Sprite2D.material.set_shader_parameter("rotation", wiggle_val )

func speaking():
	if Global.mode != 0:
		%Rotation.modulate.a = 1
		if dictmain.should_talk:
			if dictmain.open_mouth:
				%Rotation.show()
					
			else:
				%Rotation.hide()
		else:
			%Rotation.show()
			
	elif Global.mode == 0:
		%Rotation.show()
		if dictmain.should_talk:
			if dictmain.open_mouth:
				%Rotation.modulate.a = 1
					
			else:
				%Rotation.modulate.a = 0.3
		else:
			%Rotation.modulate.a = 1
		
	currently_speaking = true

func not_speaking():
	if Global.mode != 0:
		%Rotation.modulate.a = 1
		if dictmain.should_talk:
			if dictmain.open_mouth:
				%Rotation.hide()
			else:
				%Rotation.show()
		else:
			%Rotation.show()
			
	elif Global.mode == 0:
		%Rotation.show()
		if dictmain.should_talk:
			if dictmain.open_mouth:
				%Rotation.modulate.a = 0.3
			else:
				%Rotation.modulate.a = 1
		else:
			%Rotation.modulate.a = 1
			
		
		
	currently_speaking = false


func save_state(id):
	var dict : Dictionary = dictmain.duplicate()
	states[id] = dict


func get_state(id):
	if not states[id].is_empty():
		var dict = states[id]
		dictmain.merge(dict, true)
		
		if img_animated && dictmain.should_reset:
			%Sprite2D.texture.diffuse_texture.current_frame = 0
			if %Sprite2D.texture.normal_texture != null:
				%Sprite2D.texture.normal_texture.current_frame = 0
				
			if img_animated:
				%Sprite2D.texture.diffuse_texture.one_shot = dictmain.one_shot
				if %Sprite2D.texture.normal_texture != null:
					%Sprite2D.texture.normal_texture.one_shot = dictmain.one_shot
		
		%Wobble.z_index = dictmain.z_index
		modulate = dictmain.colored
		visible = dictmain.visible
		scale = dictmain.scale
	#	global_position = dictmain.global_position
		position = dictmain.position
		%Sprite2D.position = dictmain.offset 
		
		%Sprite2D.closed = dictmain.wiggle_closed_loop
		%Sprite2D.gravity = dictmain.wiggle_gravity
		
		
		
		if %Sprite2D.segment_count != dictmain.wiggle_segm:
			%Sprite2D.segment_count = dictmain.wiggle_segm
		if %Sprite2D.curvature != dictmain.wiggle_curve:
			%Sprite2D.curvature = dictmain.wiggle_curve
		if %Sprite2D.stiffness != dictmain.wiggle_stiff:
			%Sprite2D.stiffness = dictmain.wiggle_stiff
		if %Sprite2D.max_angle != dictmain.wiggle_max_angle:
			%Sprite2D.max_angle = dictmain.wiggle_max_angle
		
		if %Sprite2D.width != dictmain.width:
			%Sprite2D.width = dictmain.width
		if %Sprite2D.segment_length != dictmain.segm_length:
			%Sprite2D.segment_length = dictmain.segm_length
		if %Sprite2D.subdivision!= dictmain.subdivision:
			%Sprite2D.subdivision = dictmain.subdivision
		

		%Sprite2D.set_clip_children_mode(dictmain.clip)
		rotation = dictmain.rotation
		
		if dictmain.should_blink:
			if dictmain.open_eyes:
				
				%Pos.show()
			else:
				%Pos.hide()
		speaking()
		not_speaking()
#		animation()
		set_blend(dictmain.blend_mode)

func update_wiggle_parts():
	if %Sprite2D.segment_count != dictmain.wiggle_segm:
		%Sprite2D.segment_count = dictmain.wiggle_segm
	if %Sprite2D.curvature != dictmain.wiggle_curve:
		%Sprite2D.curvature = dictmain.wiggle_curve
	if %Sprite2D.stiffness != dictmain.wiggle_stiff:
		%Sprite2D.stiffness = dictmain.wiggle_stiff
	if %Sprite2D.max_angle != dictmain.wiggle_max_angle:
		%Sprite2D.max_angle = dictmain.wiggle_max_angle
	
	if %Sprite2D.width != dictmain.width:
		%Sprite2D.width = dictmain.width
	if %Sprite2D.segment_length != dictmain.segm_length:
		%Sprite2D.segment_length = dictmain.segm_length
	if %Sprite2D.subdivision!= dictmain.subdivision:
		%Sprite2D.subdivision = dictmain.subdivision
		
	if %Sprite2D.comeback_speed!= dictmain.comeback_speed:
		%Sprite2D.comeback_speed = dictmain.comeback_speed
		
	if %Sprite2D.max_angular_momentum!= dictmain.max_angular_momentum:
		%Sprite2D.max_angular_momentum = dictmain.max_angular_momentum
		
	if %Sprite2D.damping!= dictmain.damping:
		%Sprite2D.damping = dictmain.damping



func check_talk():
	if dictmain.should_talk:
		if dictmain.open_mouth:
			%Rotation.hide()
		else:
			%Rotation.show()


func set_blend(blend):
	match  blend:
		"Normal":
			%Sprite2D.material.set_shader_parameter("enabled", false)
		"Add":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/add.png"))
		"Subtract":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/exclusion.png"))
		"Multiply":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/multiply.png"))
		"Burn":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/burn.png"))
		"HardMix":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/hardmix.png"))
		"Cursed":
			%Sprite2D.material.set_shader_parameter("enabled", true)
			%Sprite2D.material.set_shader_parameter("Blend", preload("res://Misc/EasyBlend/Blends/test1.png"))


func _on_grab_button_down():
	if Global.held_sprite == self:
		of = get_parent().to_local(get_global_mouse_position()) - position
		dragging = true


func _on_grab_button_up():
	if Global.held_sprite == self:
		dragging = false
		save_state(Global.current_state)


func reparent_obj(parent):
	for i in parent:
		if i.sprite_id == parent_id:
			reparent(i.get_node("%Sprite2D"))


func _physics_process(delta):
	var cframe2: AImgIOFrame
	if is_apng:
		if len(frames) == 0:
			return
		if fidx >= len(frames):
			fidx = 0
		dt += delta
		var cframe: AImgIOFrame = frames[fidx]
		if %Sprite2D.texture.normal_texture:
			cframe2= frames2[fidx]
		if dt >= cframe.duration:
			dt -= cframe.duration
			fidx += 1
		# yes this does this every _process, oh well
		var tex = ImageTexture.create_from_image(cframe.content)
		%Sprite2D.texture.diffuse_texture = tex
		if %Sprite2D.texture.normal_texture:
			if frames2.size() != frames.size():
				frames2.resize(frames.size())
			%Sprite2D.texture.normal_texture = ImageTexture.create_from_image(cframe2.content)
		

func asset(key):
	if is_asset:
		if InputMap.action_get_events(str(sprite_id)).size() > 0:
			if saved_event.as_text() == key:
				%Drag.visible = !%Drag.visible
				was_active_before = %Drag.visible
				for i in get_tree().get_nodes_in_group("Sprites"):
					if i.should_disappear:
						if saved_event.as_text() in i.saved_keys:
							i.get_node("%Drag").visible = false
							i.was_active_before = false
