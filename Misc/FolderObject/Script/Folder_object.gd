extends Node2D

#Movement
var heldTicks = 0
var dragSpeed = 0
@onready var dragger = $Pos/Wobble/Squish/Drag
@onready var wob = $Pos/Wobble
@onready var sprite = $%Sprite2D
@onready var contain = get_tree().get_root().get_node("Main/SubViewportContainer/SubViewport/Node2D/Origin/SpritesContainer")
@onready var img = null
#Wobble
var squish = 1
var texture 

# Misc
var treeitem : TreeItem
var visb
var tick = 0
var sprite_name : String = ""
@export var states : Array = [{}]
var coord
var dragging : bool = false
var of = Vector2(0,0)

var sprite_id : float
var parent_id : float = 0
var physics_effect = 1
var glob
var sprite_type : String = "Folder"
var currently_speaking : bool = false

@onready var dictmain : Dictionary = {
	xFrq = 0,
	xAmp = 0,
	yFrq = 0,
	yAmp = 0,
	rdragStr = 0,
	rLimitMax = 100,
	rLimitMin = -100,
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
	folder = true,
	global_position = global_position,
	rotation = rotation,
#	offset = $%Sprite2D.offset,
	ignore_bounce = false,
	clip = 0,
	physics = true,
	
	wiggle = false,
	wiggle_amp = 0,
	wiggle_freq = 0,
	wiggle_physics = false,
	
	advanced_lipsync = false,
	
	look_at_mouse_pos = 0,
	look_at_mouse_pos_y = 0,
	
	should_rotate = false,
	should_rot_speed = 0.01,
	
	should_reset = false,
	rainbow = false,
	rainbow_self = false,
	rainbow_speed = 0.01,
	
	follow_parent_effects = false,
	follow_wa_tip = false,
	}
var smooth_rot = 0.0
var smooth_glob = Vector2(0.0,0.0)

var anim_texture 
var anim_texture_normal 
var img_animated : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():

	Global.blink.connect(blink)
	Global.speaking.connect(speaking)
	Global.not_speaking.connect(not_speaking)
	animation()
#	print(get_node("Pos/Wobble/Squish/Drag/Sprite2D/Grab").pivot_offset)
	

func animation():
	return

func _process(delta):
	if Global.held_sprite == self:
		%Grab.mouse_filter = 1
	else:
		%Grab.mouse_filter = 2
	if dragging:
		global_position = get_global_mouse_position() - of
		dictmain.global_position = get_global_mouse_position() - of
		smooth_glob = get_global_mouse_position() - of
		get_tree().get_root().get_node("Main/Control/UIInput").update_pos_spins()
	
	
	tick += 1
	glob = dragger.global_position
	
	
	drag(delta)
	wobble()
	if not dictmain.ignore_bounce:
		glob.y -= contain.bounceChange
	
	var length = (glob.y - dragger.global_position.y)
	
	if dictmain.physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D or get_parent() is CanvasGroup:
			var c_parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
			
			var c_parrent_length = (c_parent.glob.y - c_parent.dragger.global_position.y)
			length += c_parrent_length
	
	rotationalDrag(length)
	stretch(length)
	
	if dictmain.wiggle:
		wiggle_sprite()
		
	
	if dictmain.should_rotate:
		auto_rotate()

	
	rainbow()
	follow_wiggle()
	follow_mouse()


func follow_wiggle():
	if dictmain.follow_wa_tip:
		if get_parent() is WigglyAppendage2D:
			position = get_parent().points[get_parent().points.size() -1]
			%Pos.rotation = (get_parent().points[get_parent().points.size() -1].y/100)
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


func follow_mouse():
	
	var mouse = get_local_mouse_position()
	var dir = Vector2.ZERO.direction_to(mouse)
	%Pos.position.x = dir.x * dictmain.look_at_mouse_pos
	%Pos.position.y = dir.y * dictmain.look_at_mouse_pos_y


func auto_rotate():
	%Rotation.rotate(dictmain.should_rot_speed)


func wiggle_sprite():
	var wiggle_val = sin(tick*dictmain.wiggle_freq)*dictmain.wiggle_amp
	if dictmain.wiggle_physics:
		if get_parent() is Sprite2D or get_parent() is WigglyAppendage2D:
			var c_parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
			var c_parrent_length = (c_parent.glob.y - c_parent.dragger.global_position.y)
			wiggle_val = wiggle_val + (c_parrent_length/10)
		
		
	$%Sprite2D.material.set_shader_parameter("rotation", wiggle_val )

func drag(delta):
	if dragSpeed == 0:
		dragger.global_position = wob.global_position
	else:
		dragger.global_position = lerp(dragger.global_position,wob.global_position,(delta*20)/dragSpeed)

func wobble():
	wob.position.x = sin(tick*dictmain.xFrq)*dictmain.xAmp
	wob.position.y = sin(tick*dictmain.yFrq)*dictmain.yAmp

func rotationalDrag(length):
	var yvel = (length * dictmain.rdragStr)
	
	#Calculate Max angle
	
	yvel = clamp(yvel,dictmain.rLimitMin,dictmain.rLimitMax)
	
	sprite.rotation = lerp_angle(sprite.rotation,deg_to_rad(yvel),0.25)

func stretch(length):
	var yvel = (length * dictmain.stretchAmount * 0.01)
	var target = Vector2(1.0-yvel,1.0+yvel)
	
	sprite.scale = lerp(sprite.scale,target,0.5)

func blink():
	if dictmain.should_blink:
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

func speaking():
	if dictmain.should_talk:
		if dictmain.open_mouth:
			show()
			coord = 0
			animation()
				
		else:
			hide()
	currently_speaking = true
	

func advanced_lipsyc():
	return



func not_speaking():
	if dictmain.should_talk:
		if dictmain.open_mouth:
			hide()
		else:
			show()
			coord = 0
	currently_speaking = false


func save_state(id):
	var dict : Dictionary = dictmain.duplicate()
	states[id] = dict


func get_state(id):
	if not states[id].is_empty():
		var dict = states[id]
		dictmain.merge(dict, true)
		
		'''
		if dictmain.should_reset:
			if img_animated:
				%Sprite2D.texture.diffuse_texture.current_frame = 0
				if %Sprite2D.texture.normal_texture != null:
					%Sprite2D.texture.normal_texture.current_frame = 0
			elif dictmain.hframes > 1:
				%Sprite2D.frame_coords.x = 0
				print(%Sprite2D.frame)
		'''
		
		z_index = dictmain.z_index
		modulate.r = dictmain.colored.r
		modulate.g = dictmain.colored.g
		modulate.b = dictmain.colored.b
		%Sprite2D.self_modulate.a = dictmain.colored.a
		scale = dictmain.scale
		global_position = dictmain.global_position
#		$%Sprite2D.offset = dictmain.offset 
#		$%Sprite2D/Origin.position = - dictmain.offset 
		get_node("%Sprite2D").set_clip_children_mode(dictmain.clip)
		rotation = dictmain.rotation
#		$%Sprite2D.material.set_shader_parameter("wiggle", dictmain.wiggle)
		
#		if dictmain.advanced_lipsync:
#			$%Sprite2D.hframes = 6
		
		visible = dictmain.visible
		speaking()
		not_speaking()
#		set_blend(dictmain.blend_mode)
		
		
		follow_p_wiggle()
		
		%Pos.position = Vector2(0,0)


func follow_p_wiggle():
	if dictmain.follow_parent_effects:
		use_parent_material = true
		%Sprite2D.use_parent_material = true
	else:
		use_parent_material = false
		%Sprite2D.use_parent_material = false


func check_talk():
	if dictmain.should_talk:
		if dictmain.open_mouth:
			hide()
		else:
			show()


func set_blend(_blend):
	pass

func _on_grab_button_down():
	if Global.held_sprite == self:
		of = get_global_mouse_position() - global_position
		dragging = true


func _on_grab_button_up():
	if Global.held_sprite == self:
		dragging = false
		save_state(Global.current_state)


func reparent_obj(parent):
	for i in parent:
		if i.sprite_id == parent_id:
			reparent(i.get_node("%Sprite2D"))
