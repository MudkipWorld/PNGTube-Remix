extends Node2D

#Movement
var heldTicks = 0
@onready var dragger = %Drag
@onready var wob = $Pos/Wobble
@onready var sprite = %Sprite2D
@onready var contain = get_tree().get_root().get_node("Main/%SpritesContainer")
@onready var img = %Sprite2D.texture.get_image()
#Wobble
var squish = 1
var texture 

# Misc
var treeitem : LayerItem
var visb

var sprite_name : String = ""
@export var states : Array = [{}]
var coord
var dragging : bool = false
var of = Vector2(0,0)

var sprite_id : float
var parent_id 
var physics_effect = 1
var glob
var sprite_type : String = "Sprite2D"
var currently_speaking : bool = false
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
#	global_position = global_position,
	position = position,
	rotation = rotation,
	offset = Vector2(0,0),
	ignore_bounce = false,
	clip = 0,
	physics = true,
	wiggle = false,
	wiggle_amp = 0,
	wiggle_freq = 0,
	wiggle_physics = false,
	wiggle_rot_offset = Vector2(0.5, 0.5),
	advanced_lipsync = false,
	look_at_mouse_pos = 0,
	look_at_mouse_pos_y = 0,
	should_rotate = false,
	should_rot_speed = 0.01,
	should_reset = false,
	one_shot = false,
	rainbow = false,
	rainbow_self = false,
	rainbow_speed = 0.01,
	follow_parent_effects = false,
	follow_wa_tip = false,
	tip_point = 0,
	follow_wa_mini = -180,
	follow_wa_max = 180,
	flip_sprite_h = false,
	flip_sprite_v = false,
	follow_mouse_velocity = false,
	rot_frq = 0.0,
	mouse_rotation = 0.0,
	mouse_scale_x = 0.0,
	mouse_scale_y = 0.0,
	}

var anim_texture 
var anim_texture_normal 
var img_animated : bool = false
var is_apng : bool = false
var is_collapsed : bool = false
var played_once : bool = false

var dragging_type = "Null"
@onready var og_glob = global_position

var dt = 0.0
var frames : Array[AImgIOFrame] = []
var frames2 : Array[AImgIOFrame] = []
var fidx = 0

var saved_event : InputEvent
var is_asset : bool = false
var was_active_before : bool = true
var show_only : bool = false
var should_disappear : bool = false
var saved_keys : Array = []

var last_mouse_position : Vector2 = Vector2(0,0)
var last_dist : Vector2 = Vector2(0,0)
var global

# Called when the node enters the scene tree for the first time.
func _ready():
	og_glob = dictmain.position
	animation()
	%Dragger.top_level = true
	%Dragger.global_position = wob.global_position

func animation():
	if not dictmain.advanced_lipsync:
		%Sprite2D.hframes = dictmain.hframes
		%Sprite2D.vframes = 1
		if dictmain.hframes > 1:
			coord = dictmain.hframes -1
			if not coord <= 0:
				if %Sprite2D.frame == coord:
					if dictmain.one_shot:
						return
					%Sprite2D.frame = 0
					
				elif dictmain.hframes > 1:
					%Sprite2D.set_frame_coords(Vector2(clamp(%Sprite2D.frame +1, 0,coord), 0))
					
		else:
			%Sprite2D.set_frame_coords(Vector2(0, 0))
	
	
	$Animation.wait_time = 1/dictmain.animation_speed 
	$Animation.start()

func _process(_delta):
	if Global.held_sprite == self:
		%Grab.mouse_filter = 1
		%Ghost.texture = %Sprite2D.texture
		%Ghost.hframes = %Sprite2D.hframes
		%Ghost.frame = %Sprite2D.frame
		%Ghost.show()
	
		if dictmain.wiggle:
			%WiggleOrigin.show()
			var pos = ( %Sprite2D.material.get_shader_parameter("rotation_offset") * %Sprite2D.texture.get_size())/2
			%WiggleOrigin.position = Vector2(pos.x, pos.y)
		else:
			%WiggleOrigin.hide()
		%Ghost.material.set_shader_parameter("wiggle", dictmain.wiggle)
		%Ghost.material.set_shader_parameter("rotation", %Sprite2D.material.get_shader_parameter("rotation"))
		
	else:
		%Grab.mouse_filter = 2
		%Ghost.hide()
	#	%Sprite2D.material.set_shader_parameter("marshing_ants",false)
		%WiggleOrigin.hide()
	#	%Origin.mouse_filter = 2
	
	if dragging:
		var mpos = get_parent().to_local(get_global_mouse_position())
		position = mpos - of
		dictmain.position = position
		save_state(Global.current_state)
		get_tree().get_root().get_node("Main/%Control/UIInput").update_pos_spins()
		
	if !Global.static_view:
		if dictmain.wiggle:
			wiggle_sprite()
		
	advanced_lipsyc()

func wiggle_sprite():
	var wiggle_val = sin(Global.tick*dictmain.wiggle_freq)*dictmain.wiggle_amp
	if dictmain.wiggle_physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D:
			var c_parent = get_parent().owner
			var c_parrent_length = (c_parent.glob.y - c_parent.dragger.global_position.y)
			wiggle_val = wiggle_val + (c_parrent_length/10)
		
	
	if !get_parent() is Sprite2D:
		%Sprite2D.material.set_shader_parameter("rotation", wiggle_val )
	elif get_parent() is Sprite2D:
		if dictmain.follow_parent_effects:
			var c_parent = get_parent().owner
			%Sprite2D.material.set_shader_parameter("rotation", c_parent.get_node("%Sprite2D").material.get_shader_parameter("rotation"))
		else:
			%Sprite2D.material.set_shader_parameter("rotation", wiggle_val )

func advanced_lipsyc():
	if dictmain.advanced_lipsync:
		if %Sprite2D.hframes != 14:
			%Sprite2D.hframes = 14
		if currently_speaking:
			if GlobalAudioStreamPlayer.t.value == 0:
				%Sprite2D.frame_coords.x = 13
			else:
				%Sprite2D.frame_coords.x = GlobalAudioStreamPlayer.t.actual_value
		else:
			%Sprite2D.frame_coords.x = 13

func save_state(id):
	var dict : Dictionary = dictmain.duplicate()
	states[id] = dict

func get_state(id):
	if not states[id].is_empty():
		var dict = states[id]
		dictmain.merge(dict, true)
		
		if dictmain.should_reset:
			if img_animated:
				%Sprite2D.texture.diffuse_texture.current_frame = 0
				if %Sprite2D.texture.normal_texture != null:
					%Sprite2D.texture.normal_texture.current_frame = 0
			elif dictmain.hframes > 1:
				%Sprite2D.frame = 0
				print(%Sprite2D.frame)
			elif is_apng:
				fidx = 0
				
		
		%Sprite2D.position = dictmain.offset 
		%Sprite2D.scale = Vector2(1,1)
		
		%Wobble.z_index = dictmain.z_index
		modulate = dictmain.colored
		scale = dictmain.scale
	#	global_position = dictmain.global_position
		position = dictmain.position

		%Sprite2D.set_clip_children_mode(dictmain.clip)
		rotation = dictmain.rotation
		%Sprite2D.material.set_shader_parameter("wiggle", dictmain.wiggle)
		%Sprite2D.material.set_shader_parameter("rotation_offset", dictmain.wiggle_rot_offset)
		
		
		%Sprite2D.flip_h = dictmain.flip_sprite_h
		%Sprite2D.flip_v = dictmain.flip_sprite_v
		
		
		
		if dictmain.advanced_lipsync:
			%Sprite2D.hframes = 6
		
		if dictmain.should_blink:
			if dictmain.open_eyes:
				
				%Pos.show()
			else:
				%Pos.hide()
		
		
		visible = dictmain.visible
		%ReactionConfig.speaking()
		%ReactionConfig.not_speaking()
		animation()
		set_blend(dictmain.blend_mode)
		advanced_lipsyc()

		
		%Sprite2D.scale = Vector2(1,1)
		%Pos.position = Vector2(0,0)
		if dictmain.one_shot:
			fidx = 0
			proper_apng_one_shot()
		played_once = false

func check_talk():
	if dictmain.should_talk:
		if dictmain.open_mouth:
			%Rotation.hide()
		else:
			%Rotation.show()
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
		if not Input.is_action_pressed("ctrl"):
			of = get_parent().to_local(get_global_mouse_position()) - position
			dragging = true
			dragging_type = "Sprite"
		else:
			dragging_type = "Null"

func _on_grab_button_up():
	if Global.held_sprite == self && dragging:
		dragging_type = "Null"
		save_state(Global.current_state)
		dragging = false

func reparent_obj(parent):
	for i in parent:
		if i.sprite_id == parent_id:
			#global = global_position
			reparent(i.get_node("%Sprite2D"))

func zazaza(perent):
	for i in perent:
		if i.sprite_id == parent_id:
			if is_plus_first_import:
				for state in states:
					if !state.is_empty():
						global = global_position
						state.position = to_local(global) - state.offset

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
				if dictmain.one_shot:
					played_once = true
					return
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
