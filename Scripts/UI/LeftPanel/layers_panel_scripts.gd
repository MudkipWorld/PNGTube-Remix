extends Node

var sprite_obj = preload("res://Misc/SpriteObject/sprite_object.tscn")
var append_obj = preload("res://Misc/AppendageObject/Appendage_object.tscn")

func _ready() -> void:
	Global.deselect.connect(nullfy)
	Global.reinfo.connect(enable)

func nullfy():
	%ReplaceButton.disabled = true
	%DuplicateButton.disabled = true
	%DeleteButton.disabled = true
	%AddNormalButton.disabled = true
	%DelNormalButton.disabled = true

func enable():
	%DuplicateButton.disabled = false
	%DeleteButton.disabled = false
	if Global.held_sprite.dictmain.folder:
		%AddNormalButton.disabled = true
		%DelNormalButton.disabled = true
		%ReplaceButton.disabled = true
	else:
		%AddNormalButton.disabled = false
		%DelNormalButton.disabled = false
		%ReplaceButton.disabled = false

func _on_delete_button_pressed():
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		Global.held_sprite.treeitem.get_parent().queue_free()
		Global.held_sprite.queue_free()
		Global.held_sprite = null
		Global.deselect.emit()
		Global.top_ui.get_node("%DeselectButton").hide()

func _on_duplicate_button_pressed():
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		var obj
		if Global.held_sprite.sprite_type == "WiggleApp":
			obj = append_obj.instantiate()
			
		else:
			obj = sprite_obj.instantiate()
		
		obj.scale = Global.held_sprite.scale
		obj.dictmain.scale = Global.held_sprite.scale
		Global.sprite_container.add_child(obj)
		if obj.sprite_type != "Folder":
			obj.texture = Global.held_sprite.get_node("%Sprite2D").texture
			obj.get_node("%Sprite2D").texture = Global.held_sprite.get_node("%Sprite2D").texture
		obj.sprite_name = "Duplicate" + Global.held_sprite.sprite_name 

		if Global.held_sprite.dictmain.folder:
			obj.dictmain.folder = true
		
		if Global.held_sprite.img_animated:
			obj.img_animated = true
			obj.anim_texture = Global.held_sprite.anim_texture
			obj.anim_texture_normal = Global.held_sprite.anim_texture_normal 
		
		obj.dictmain = Global.held_sprite.dictmain.duplicate()
		obj.states = Global.held_sprite.states.duplicate()
		Global.update_layers.emit(0, obj, obj.sprite_type)
		obj.sprite_id = obj.get_instance_id()
		obj.get_state(Global.current_state)


func _on_replace_button_pressed():
	Global.main.replacing_sprite()

func _on_add_sprite_button_pressed():
	Global.main.load_sprites()

func _on_folder_button_pressed():
	var sprte_obj = sprite_obj.instantiate()
	Global.sprite_container.add_child(sprte_obj)
	var canv = CanvasTexture.new()
	canv.diffuse_texture = preload("res://Misc/SpriteObject/Folder.png")
	sprte_obj.get_node("%Sprite2D").texture =  canv
	sprte_obj.sprite_name = str("Folder")
	sprte_obj.dictmain.folder = true
	var states = get_tree().get_nodes_in_group("StateButtons").size()
	for i in states:
		sprte_obj.states.append({})
	Global.update_layers.emit(0, sprte_obj, "Sprite2D")
	sprte_obj.sprite_id = sprte_obj.get_instance_id()


func _on_add_normal_button_pressed():
	Global.main.add_normal_sprite()

func _on_del_normal_button_pressed():
	if Global.held_sprite != null && is_instance_valid(Global.held_sprite):
		if !Global.held_sprite.is_apng:
			if not Global.held_sprite.dictmain.folder:
				Global.held_sprite.get_node("%Sprite2D").texture.normal_texture = null
