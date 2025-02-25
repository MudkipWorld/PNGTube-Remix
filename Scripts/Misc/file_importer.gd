extends Node

var sprite = preload("res://Misc/SpriteObject/sprite_object.tscn")
var appendage = preload("res://Misc/AppendageObject/Appendage_object.tscn")


func import_sprite(path : String):
	var spawn = sprite.instantiate()
	var apng_test = AImgIOAPNGImporter.load_from_file(path)
	var img_tex : CanvasTexture 
	if apng_test != ["No frames", null]:
		img_tex = import_apng_sprite(path, spawn)
	else:
		img_tex = import_png(path, spawn)
	spawn.get_node("%Sprite2D").texture = img_tex
	return spawn

func import_appendage(path : String):
	var spawn = appendage.instantiate()
	var apng_test = AImgIOAPNGImporter.load_from_file(path)
	var img_tex : CanvasTexture 
	if apng_test != ["No frames", null]:
		img_tex = import_apng_sprite(path , spawn)
	else:
		img_tex = import_png(path, spawn)
	
	spawn.get_node("%Sprite2D").texture = img_tex
	return spawn

func import_apng_sprite(path : String , spawn) -> CanvasTexture:
	var img = AImgIOAPNGImporter.load_from_file(path)
	var tex = img[1] as Array[AImgIOFrame]
	spawn.frames = tex
	
	for n in spawn.frames:
		n.content.fix_alpha_edges()
	
	var cframe: AImgIOFrame = spawn.frames[0]
	var text = ImageTexture.create_from_image(cframe.content)
	var img_can = CanvasTexture.new()
	img_can.diffuse_texture = text
	spawn.is_apng = true
	spawn.sprite_name = "(Apng) " + path.get_file().get_basename() 
	return img_can

func import_png(path : String, spawn) -> CanvasTexture:
	var img = Image.load_from_file(path)
	img.fix_alpha_edges()
	var texture = ImageTexture.create_from_image(img)
	var img_can = CanvasTexture.new()
	img_can.diffuse_texture = texture
	spawn.sprite_name = path.get_file().get_basename()
	return img_can

func add_normal(path):
	var apng_test = AImgIOAPNGImporter.load_from_file(path)
	if apng_test != ["No frames", null]:
		var img = AImgIOAPNGImporter.load_from_file(path)
		var tex = img[1] as Array[AImgIOFrame]
		Global.held_sprite.frames2 = tex
		
		for n in Global.held_sprite.frames2:
			n.content.fix_alpha_edges()
		
		var cframe: AImgIOFrame = Global.held_sprite.frames2[0]
		var text = ImageTexture.create_from_image(cframe.content)
		Global.held_sprite.get_node("%Sprite2D").texture.normal_texture = text

	else:
		var img = Image.load_from_file(path)
		img.fix_alpha_edges()
		var texture = ImageTexture.create_from_image(img)
		Global.held_sprite.get_node("%Sprite2D").texture.normal_texture = texture
	Global.get_sprite_states(Global.current_state)

func replace_texture(path):
	var apng_test = AImgIOAPNGImporter.load_from_file(path)
	if apng_test != ["No frames", null]:
		var img = AImgIOAPNGImporter.load_from_file(path)
		var tex = img[1] as Array[AImgIOFrame]
		Global.held_sprite.frames = tex
		
		for n in Global.held_sprite.frames:
			n.content.fix_alpha_edges()
		
		var cframe: AImgIOFrame = Global.held_sprite.frames[0]
		var text = ImageTexture.create_from_image(cframe.content)
		var img_can = CanvasTexture.new()
		img_can.diffuse_texture = text
		Global.held_sprite.treeitem.get_node("%Icon").texture = Global.held_sprite.texture
		Global.held_sprite.is_apng = true
		Global.held_sprite.img_animated = false
	else:
		var img = Image.load_from_file(path)
		var texture = ImageTexture.create_from_image(img)
		var img_can = CanvasTexture.new()
		img.fix_alpha_edges()
		Global.held_sprite.img_animated = false
		Global.held_sprite.is_apng = false
		img_can.diffuse_texture = texture
		Global.held_sprite.get_node("%Sprite2D").texture = img_can
		Global.held_sprite.save_state(Global.current_state)
		Global.held_sprite.treeitem.get_node("%Icon").texture = texture
		
	if Global.held_sprite.sprite_type == "WiggleApp":
		Global.held_sprite.correct_sprite_size()
		Global.held_sprite.update_wiggle_parts()
	Global.held_sprite.get_node("%Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT
	Global.get_sprite_states(Global.current_state)
	Global.reinfo.emit()
