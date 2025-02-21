extends Control

signal key_pressed

var filepath : Array = []
enum State {
	LoadFile,
	SaveFile,
	SaveFileAs,
	LoadSprites,
	ReplaceSprite,
	AddNormal,
	AddAppend,
	AddBgSprite
}
var current_state : State
var can_scroll : bool = false

var rec_inp : bool = false

@onready var origin = %SpritesContainer
var of
var keys : Array = []
var already_input_keys : Array = []

func _ready():
	%FileDialog.use_native_dialog = true

func new_file():
	%ConfirmationDialog.popup()

func load_file():
	%FileDialog.filters = ["*.pngRemix, *.save"]
	$FileDialog.file_mode = 0
	current_state = State.LoadFile
	%FileDialog.show()

func save_as_file():
	%FileDialog.filters = ["*.pngRemix"]
	$FileDialog.file_mode = 4
	current_state = State.SaveFileAs
	%FileDialog.show()

func load_sprites():
	%FileDialog.filters = ["*.png, *.apng", "*.png", "*.jpeg", "*.jpg", "*.svg", "*.apng"]
	$FileDialog.file_mode = 1
	current_state = State.LoadSprites
	%FileDialog.show()

func load_append_sprites():
	%FileDialog.filters = ["*.png, *.apng", "*.png", "*.jpeg", "*.jpg", "*.svg", "*.apng"]
	$FileDialog.file_mode = 1
	current_state = State.AddAppend
	%FileDialog.show()

func replacing_sprite():
	if Global.held_sprite != null:
		if not Global.held_sprite.dictmain.folder:
			%FileDialog.filters = ["*.png, *.apng", "*.jpeg", "*.jpg", "*.svg", "*.apng"]
			$FileDialog.file_mode = 0
			current_state = State.ReplaceSprite
			%FileDialog.show()

func add_normal_sprite():
	if Global.held_sprite != null:
		if not Global.held_sprite.dictmain.folder:
			if Global.held_sprite.img_animated:
				%FileDialog.filters = ["*.gif"]
			elif Global.held_sprite.is_apng:
				%FileDialog.filters = ["*.png","*.apng"]
			else:
				%FileDialog.filters = ["*.png", "*.jpeg", "*.jpg", "*.svg"]
			$FileDialog.file_mode = 0
			current_state = State.AddNormal
			%FileDialog.show()

func _on_file_dialog_file_selected(path): 
	match current_state:
		State.LoadFile:
			SaveAndLoad.load_file(path)
		State.SaveFileAs:
			SaveAndLoad.save_file(path)
			
		State.ReplaceSprite:
			%FileImporter.replace_texture(path)
			
		State.AddNormal:
			%FileImporter.add_normal(path)

func _on_file_dialog_files_selected(paths):
	if current_state == State.LoadSprites or current_state == State.AddAppend:
	#	var sprite_nodes = []
		for path in paths:
			
			var sprte_obj
			if current_state == State.LoadSprites:
				sprte_obj = %FileImporter.import_sprite(path)
			elif current_state == State.AddAppend:
				sprte_obj = %FileImporter.import_appendage(path)
			%SpritesContainer.add_child(sprte_obj)
			sprte_obj.get_node("%Sprite2D/Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT

			sprte_obj.sprite_id = sprte_obj.get_instance_id()
			sprte_obj.states = []
			var states = get_tree().get_nodes_in_group("StateButtons").size()
			for i in states:
				sprte_obj.states.append({})
				
			if current_state == State.AddAppend:
				sprte_obj.correct_sprite_size()
				sprte_obj.update_wiggle_parts()
				Global.update_layers.emit(0, sprte_obj, "WiggleApp")
			else:
				Global.update_layers.emit(0, sprte_obj, "Sprite2D")


func _on_confirmation_dialog_confirmed():
	Themes.theme_settings.path = ""
	%TopUI/TopBarInput.path = ""
	%TopUI/TopBarInput.last_path = ""
	clear_sprites()
	Global.settings_dict.max_fps = 241
	%TopUI.update_fps(241)
	%TopUI/%MaxFPSlider.value = 241

func clear_sprites():
	Global.held_sprite = null
	%Control/UIInput.held_sprite_is_null()
	
	for i in %Control/%LayerViewBG.get_node("%LayerVBox").get_children():
		i.free()
	for i in get_tree().get_nodes_in_group("Sprites"):
		if InputMap.has_action(str(i.sprite_id)):
			InputMap.erase_action(str(i.sprite_id))

	for i in %SpritesContainer.get_children():
		i.free()
		

	%Control/StatesStuff.delete_all_states()
	%Control/StatesStuff.initial_state()
	%Camera2D.zoom = Vector2(1,1)
	%CamPos.global_position = Vector2(640, 360)
	Global.settings_dict.zoom = Vector2(1,1)
	Global.settings_dict.pan = Vector2(640, 360)

func _input(event):
	if can_scroll && not Input.is_action_pressed("ctrl"):
		if event.is_action_pressed("scrollup"):
				%Camera2D.zoom = clamp(%Camera2D.zoom*Vector2(1.1,1.1) , Vector2(0.01,0.01), Vector2(5,5))
				Global.settings_dict.zoom = %Camera2D.zoom
		elif event.is_action_pressed("scrolldown"):
				%Camera2D.zoom = clamp(%Camera2D.zoom/Vector2(1.1,1.1) , Vector2(0.01,0.01), Vector2(5,5))
				Global.settings_dict.zoom = %Camera2D.zoom
		
		if Input.is_action_just_pressed("pan"):
			of = get_global_mouse_position() + %CamPos.global_position
		
		elif Input.is_action_pressed("pan"):
			%CamPos.global_position = -get_global_mouse_position() + of
			Global.settings_dict.pan = %CamPos.global_position

func _on_sub_viewport_container_mouse_entered():
	can_scroll = true

func _on_sub_viewport_container_mouse_exited():
	can_scroll = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		rec_inp = false
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		rec_inp = true

func _on_background_input_capture_bg_key_pressed(_node, keys_pressed):
	if Global.settings_dict.checkinput:
		var keyStrings = []
		var costumeKeys = []
		
		for l in get_tree().get_nodes_in_group("StateButtons"):
			if InputMap.action_get_events(l.input_key).size() > 0:
				costumeKeys.append(InputMap.action_get_events(l.input_key)[0].as_text())
				
		for l in get_tree().get_nodes_in_group("Sprites"):
			if InputMap.action_get_events(str(l.sprite_id)).size() > 0:
				costumeKeys.append(InputMap.action_get_events(str(l.sprite_id))[0].as_text())
		
		
		
		for i in keys_pressed:
			if keys_pressed[i]:
				if OS.get_keycode_string(i) not in already_input_keys:
					keyStrings.append(OS.get_keycode_string(i))
		
		already_input_keys = keyStrings
		
	#	print(keyStrings)
		
		
		if %FileDialog.visible:
			return
			
		
		for key in keyStrings:
			var i = costumeKeys.find(key)
			if i >= 0:
				if costumeKeys[i] not in keys:
				#	print(keys)
				#	print(costumeKeys[i])
					key_pressed.emit(costumeKeys[i])
					keys.append(costumeKeys[i])
	
	keys = []
