extends Button
class_name BetterToggles

@export var sp_type : String = "Null"
@export var value_to_update : String = "position"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.reinfo.connect(enable)
	Global.deselect.connect(nullfy)
	nullfy()
	toggle_mode = true
	toggled.connect(on_toggle)

func enable():
	if sp_type == "Null" or sp_type == "":
		disabled = false
		button_pressed = Global.held_sprite.dictmain[value_to_update]
	
	else:
		if sp_type == Global.held_sprite.sprite_type:
			disabled = false
			button_pressed = Global.held_sprite.dictmain[value_to_update]
			

func nullfy():
	disabled = true

func on_toggle(toggle : bool):
	if sp_type == "Null":
		Global.held_sprite.dictmain[value_to_update] = toggle
