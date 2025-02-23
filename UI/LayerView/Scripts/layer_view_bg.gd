extends PanelContainer
signal sprite_info 

@onready var layers_popup: PopupMenu = $LayersPopup
@onready var uiinput: = get_tree().get_root().get_node("Main/%Control/UIInput")
@onready var topbarinput: = get_tree().get_root().get_node("Main/%TopUI/TopBarInput")
var layer_item = preload("res://UI/LayerView/layer_item.tscn")


func _ready() -> void:
	Global.new_file.connect(delete_layers)
	Global.remake_layers.connect(remake_layers)
	Global.update_layers.connect(update_layers)
	layers_popup.connect("id_pressed",choosing_layers_popup)
	Global.deselect.connect(deselect_all)
	Global.update_layer_visib.connect(update_visib_buttons)

func deselect_all():
	for i in get_tree().get_nodes_in_group("Layers"):
		i.deselect()

func choosing_layers_popup(id):
	var main = get_tree().get_root().get_node("Main")
	match id:
		0:
			main.load_sprites()
		1:  
			uiinput._on_folder_button_pressed()
		2:#replace
			get_tree().get_root().get_node("Main").replacing_sprite()
		3:#duplicate
			uiinput._on_duplicate_button_pressed()
		4:#Delete
			uiinput._on_delete_button_pressed()
		5:#add normal
			get_tree().get_root().get_node("Main").add_normal_sprite()
		6: #delete normal
			uiinput._on_del_normal_button_pressed()
		7: #Deselect
			topbarinput.desel_everything()

func update_layers(update_type : int, new_item = null, type : String = "Sprite"):
	match update_type:
		0:
			if new_item != null:
				add_new_layer_item(new_item, type)

func add_new_layer_item(new_item, type):
	var new_layer_item = layer_item.instantiate()
	new_layer_item.get_node("LayerItem").data = {
		sprite_object = new_item,
		parent = new_layer_item,
	}
	if type == "Sprite2D":
		if new_item.dictmain.folder:
			new_layer_item.get_node("%Icon").texture = preload("res://UI/Assets/FolderButton.png")
		else:
			new_layer_item.get_node("%Icon").texture = new_item.get_node("%Sprite2D").texture
	elif type == "WiggleApp":
		new_layer_item.get_node("%Icon").texture = new_item.get_node("%Sprite2D").texture

	new_layer_item.get_node("%NameLabel").text = new_item.sprite_name
	new_layer_item.get_node("LayerItem").layer_holder = self
	%LayerVBox.add_child(new_layer_item)
	new_item.treeitem = new_layer_item.get_node("LayerItem")

func delete_layers():
	for i in %LayerVBox.get_children():
		i.queue_free()

func remake_layers(sprites : Array = get_tree().get_nodes_in_group("Sprites")):
	delete_layers()
	for i in sprites:
		add_new_layer_item(i, i.sprite_type)
		
	correct_rearrange(sprites)
	update_visib_buttons()
	collapsing(sprites)
	for i in sprites:
		i.reparent_obj(get_tree().get_nodes_in_group("Sprites"))

func correct_rearrange(sprites : Array = get_tree().get_nodes_in_group("Sprites")):
	for i in sprites:
		for l in sprites:
			if i.parent_id == l.sprite_id:
				if i.treeitem.get_parent().get_parent() == l.treeitem.get_parent().get_node("%OtherLayers"):
					pass
				else:
					var parent = i.treeitem.get_parent().get_parent()
					parent.remove_child(i.treeitem.get_parent())
					l.treeitem.get_parent().get_node("%OtherLayers").add_child(i.treeitem.get_parent())
					l.treeitem.check_indents()
					i.treeitem.check_indents()

func update_visib_buttons():
	for i in get_tree().get_nodes_in_group("Sprites"):
		if i.dictmain.visible:
			i.treeitem.get_node("%Visiblity").button_pressed = false
		elif not i.dictmain.visible:
			i.treeitem.get_node("%Visiblity").button_pressed = true

func collapsing(sprites):
	for i in sprites:
		if i.treeitem.get_node("%OtherLayers").get_child_count() > 0:
			i.treeitem.get_node("%Collapse").button_pressed = i.is_collapsed

func _on_layer_view_bg_focus_entered() -> void:
	if has_focus():
		release_focus()
	deselect_all()
	Global.deselect.emit()


func _on_focus_entered() -> void:
	pass # Replace with function body.
