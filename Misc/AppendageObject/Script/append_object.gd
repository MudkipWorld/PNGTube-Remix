extends Node2D

#Movement
var heldTicks = 0
@onready var dragger = $Pos/Wobble/Squish/Drag
@onready var wob = $Pos/Wobble
@onready var sprite = %Sprite2D
@onready var img = %Sprite2D.texture.get_image()
#Wobble
var squish = 1
var texture 
var currently_speaking : bool = false
# Misc
var treeitem : LayerItem
var visb
var sprite_name : String = ""
@export var states : Array = [{}]
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
var is_plus_first_import : bool = false

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
	tint = self_modulate,
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
	flip_h = false,
	flip_v = false,
	rot_frq = 0.0,
	mouse_rotation = 0.0,
	mouse_scale_x = 0.0,
	mouse_scale_y = 0.0,
	}

var smooth_rot = 0.0
var smooth_glob = Vector2(0.0,0.0)
var is_apng : bool = false
var is_collapsed : bool = false

var dt = 0.0
var frames : Array[AImgIOFrame] = []
var frames2 : Array[AImgIOFrame] = []
var fidx = 0
var played_once : bool = false

var saved_event : InputEvent
var is_asset : bool = false
var was_active_before : bool = true
var should_disappear : bool = false
var show_only : bool = false
var saved_keys : Array = []

var last_mouse_position : Vector2 = Vector2(0,0)
var last_dist : Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	%Dragger.top_level = true
	%Dragger.global_position = wob.global_position
	
	update_wiggle_parts()

func correct_sprite_size():
	var w = %Sprite2D.texture.get_image().get_size().y / 0.98
	var l = %Sprite2D.texture.get_image().get_size().x / 5
	
	dictmain.width = w
	dictmain.segm_length = l

func _process(_delta):
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
		Global.update_pos_spins.emit()
	
	
	if !Global.static_view:
		if dictmain.auto_wag:
			%Sprite2D.curvature = clamp(sin(Global.tick*(dictmain.wag_freq))*dictmain.wag_speed, deg_to_rad(dictmain.wag_mini), deg_to_rad(dictmain.wag_max))
		

	%Grab.anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT

func wiggle_sprite():
	var wiggle_val = sin(Global.tick*dictmain.wiggle_freq)*dictmain.wiggle_amp
	if dictmain.wiggle_physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D:
			var c_parent = get_parent().owner
			var c_parrent_length = (c_parent.glob.y - c_parent.dragger.global_position.y)
			wiggle_val = wiggle_val + (c_parrent_length/10)
		
		
	%Sprite2D.material.set_shader_parameter("rotation", wiggle_val )

func save_state(id):
	var dict : Dictionary = dictmain.duplicate()
	states[id] = dict

func get_state(id):
	if not states[id].is_empty():
		var dict = states[id]
		dictmain.merge(dict, true)
		
		
		%Wobble.z_index = dictmain.z_index
		modulate = dictmain.colored
		visible = dictmain.visible
		scale = dictmain.scale
	#	global_position = dictmain.global_position
		position = dictmain.position
		%Sprite2D.position = dictmain.offset 
		%Sprite2D.scale = Vector2(1,1)
		
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
		%ReactionConfig.speaking()
		%ReactionConfig.not_speaking()
#		animation()
		set_blend(dictmain.blend_mode)
		if dictmain.one_shot:
			fidx = 0
		played_once = false

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
			if is_plus_first_import:
				for zaza in states:
					var global = global_position
					zaza.position = to_local(global)
					#position = zaza.position

func proper_apng_one_shot():
	var cframe: AImgIOFrame = frames[0]
	var tex = ImageTexture.create_from_image(cframe.content)
	%Sprite2D.texture.diffuse_texture = tex
	if %Sprite2D.texture.normal_texture:
		var cframe2 = frames2[0]
		%Sprite2D.texture.normal_texture = ImageTexture.create_from_image(cframe2.content)

func _physics_process(delta):
	var cframe2: AImgIOFrame
	if is_apng:
		if !played_once:
			if len(frames) == 0:
				return
			if fidx >= len(frames):
				fidx = 0
				if dictmain.one_shot:
					played_once = true
					return
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
