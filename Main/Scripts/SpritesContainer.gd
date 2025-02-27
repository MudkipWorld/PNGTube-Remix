extends Node2D

signal reinfoanim
var mouth_closed = 0
var mouth_open = 0

var pos = Vector2(0,0)
var current_mc_anim = "Idle"
var current_mo_anim = "Idle"
var should_squish : bool = false
var squish_amount : float = 1.0
var tween : Tween

var bounce_amount = 50
var wave_amount = Vector2(100,100)

var yVel = 100
var bounceChange = 0.0

var currenly_speaking : bool = false
var tick = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.animation_state.connect(get_state)
	Global.speaking.connect(speaking)
	Global.not_speaking.connect(not_speaking)
	Global.blink.connect(_squish)


func _squish():
	if should_squish:
		if tween:
			tween.kill()
		tween = create_tween()
		scale.y = 1.0 * (1/squish_amount)
		tween.tween_property(self, "scale:y", 1.0 * (squish_amount), 0.25).set_trans(Tween.TRANS_SINE)
		await tween.finished
		tween.kill()
		tween = create_tween()
		tween.tween_property(self, "scale:y", 1.0 , 0.1).set_trans(Tween.TRANS_SINE)
		await tween.finished
		tween.kill()

func _process(delta):
	tick +=1
	var hold = get_parent().position.y
	
	get_parent().position.y = clamp(get_parent().position.y + (yVel * delta),-90000000, 0)
	
	get_parent().position.y = lerp(get_parent().position.y, 0.0, 0.08)
	bounceChange = hold - get_parent().position.y
	
	yVel = clamp(yVel + Global.settings_dict.bounceGravity* delta,-90000000, 90000000)
	
	
	if currenly_speaking:
		if current_mo_anim == "Bouncy":
			set_mo_bouncy()
			
		elif current_mo_anim == "Wobble":
			set_mo_wobble()
			
		elif current_mo_anim == "Squish":
			set_mo_squish()
		elif current_mo_anim == "Float":
			set_mo_float()
		else:
			position = lerp(position, pos, 0.05)
			
		if current_mo_anim != "Squish":
			scale = lerp(scale, Vector2(1.0,1.0), 0.06)
			
	elif not currenly_speaking:
		if current_mc_anim == "Bouncy":
			set_mc_bouncy()
		elif current_mc_anim == "Wobble":
			set_mc_wobble()
		elif current_mc_anim == "Squish":
			set_mc_squish()
		elif current_mc_anim == "Float":
			set_mc_float()
		else:
			position = lerp(position, pos, 0.05)
		
		if current_mc_anim != "Squish":
			scale = lerp(scale, Vector2(1.0,1.0), 0.06)



	if Global.settings_dict.darken && !currenly_speaking:
		modulate = lerp(modulate, Global.settings_dict.dim_color, 0.08)
	else:
		modulate = Color.WHITE


func save_state(id):
	var dict = {
		mouth_closed = mouth_closed,
		mouth_open = mouth_open,
		current_mc_anim = current_mc_anim,
		current_mo_anim = current_mo_anim,
		should_squish = should_squish,
		squish_amount = squish_amount,
	}
	Global.settings_dict.states[id] = dict
	
	if GlobalMicAudio.has_spoken:
		speaking()
	else:
		not_speaking()

func get_state(state):
	if not Global.settings_dict.states[state].is_empty():
		var dict : Dictionary = Global.settings_dict.states[state]
		mouth_closed = dict.mouth_closed
		mouth_open = dict.mouth_open
		current_mc_anim = dict.current_mc_anim
		current_mo_anim = dict.current_mo_anim
		if dict.has("squish_amount"):
			squish_amount = dict.squish_amount
			should_squish = dict.should_squish
		
		if Global.settings_dict.bounce_state:
			state_bounce()
			
		if GlobalMicAudio.has_spoken:
			speaking()
		else:
			not_speaking()
			
	reinfoanim.emit()

func not_speaking():
	currenly_speaking = false
	
	match mouth_closed:
		0:
			set_mc_idle()
		1:
		#	position = pos
			set_mc_bouncy()
		3:
		#	position = pos
			set_mc_one_bounce()
		4:
			set_mc_wobble()
		5:
			set_mc_squish()

func speaking():
#	modulate = Color.WHITE
	currenly_speaking = true
	
	match mouth_open:
		0:
			set_mo_idle()
		1:
		#	position = pos
			set_mo_bouncy()
		3:
		#	position = pos
			set_mo_one_bounce()
		4:
			set_mo_wobble()
			
		5:
			set_mo_squish()


func state_bounce():
	if get_parent().position.y > -16:
		yVel = Global.settings_dict.bounceSlider * -1


func set_mc_float():
	position.y = lerp(position.y, (sin(tick*Global.settings_dict.yFrq)*(Global.settings_dict.yAmp)), 0.08)
#	yVel = (position.y * 0.08)
	bounceChange = position.y /8


func set_mc_idle():
	pass
#	position = pos

func set_mc_bouncy():
	if get_parent().position.y > -1:
		yVel = Global.settings_dict.bounceSlider * -1

func set_mc_one_bounce():
	if get_parent().position.y > -16:
		yVel = Global.settings_dict.bounceSlider * -1

func set_mc_wobble():
	position.x = lerp(position.x, sin(tick*Global.settings_dict.xFrq)*Global.settings_dict.xAmp, 0.08)
	position.y = lerp(position.y, sin(tick*Global.settings_dict.yFrq)*Global.settings_dict.yAmp, 0.08)
	bounceChange = position.y/10
	

func set_mc_squish():
	position.y = lerp(position.y,sin(tick*Global.settings_dict.yFrq)*Global.settings_dict.yAmp, 0.08)
	
	var yvel = (position.y * 0.01)
	var target = Vector2(1.0-yvel,1.0+yvel)

	scale = lerp(scale,target,0.5)



func set_mo_float():
	position.y = lerp(position.y, (sin(tick*Global.settings_dict.yFrq)*(Global.settings_dict.yAmp)), 0.08)
#	yVel = (position.y * 0.08)
	bounceChange = position.y /8

func set_mo_idle():
	pass
#	position = pos

func set_mo_bouncy():
	if get_parent().position.y > -1:
		yVel = Global.settings_dict.bounceSlider * -1

func set_mo_one_bounce():
	if get_parent().position.y > -16:
		yVel = Global.settings_dict.bounceSlider * -1

func set_mo_wobble():
	position.x = lerp(position.x, sin(tick*Global.settings_dict.xFrq)*Global.settings_dict.xAmp, 0.08)
	position.y = lerp(position.y, sin(tick*Global.settings_dict.yFrq)*Global.settings_dict.yAmp, 0.08)
	bounceChange = position.y/10
	


func set_mo_squish():
	position.y = lerp(position.y,sin(tick*Global.settings_dict.yFrq)*Global.settings_dict.yAmp, 0.08)
	
	var yvel = (position.y * 0.01)
	var target = Vector2(1.0-yvel,1.0+yvel)

	scale = lerp(scale,target,0.5)
