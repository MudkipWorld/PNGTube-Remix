extends PanelContainer
class_name LayerItem

@warning_ignore("unused_signal")
signal sprite_info 

static var dragged_item = null
var drop_place = 0
@export var data : Dictionary
@export var can_be_moved : bool = true
var layer_holder 
static var selected_layer : LayerItem 


func deselect() -> void:
	selected_layer = null
	%Select.hide()
	if Global.held_sprite:
		if Global.held_sprite.has_node("%Origin"):
			Global.held_sprite.get_node("%Origin").hide()

func _on_focus_entered() -> void:
	for i in get_tree().get_nodes_in_group("Layers"):
		i.deselect()
		
	%Select.show()
	Global.held_sprite = data.sprite_object
	if Global.held_sprite.has_node("%Origin"):
		Global.held_sprite.get_node("%Origin").show()
	
	Global.reinfo.emit()
	selected_layer = self



func _on_mouse_entered() -> void:
	if has_focus():
		return
	%Select.show()


func _on_mouse_exited() -> void:
	if has_focus():
		return
	%Select.hide()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			grab_focus()
			layer_holder.layers_popup.popup_on_parent(Rect2(event.global_position, Vector2.ZERO))
	else: 
			pass


func _get_drag_data(_at_position: Vector2) -> Variant:
	if can_be_moved:
		dragged_item = self
		return self
	else:
		return null


func _can_drop_data(_at_position: Vector2, newdata: Variant) -> bool:
	return newdata is LayerItem

func _drop_data(at_position: Vector2, newdata: Variant) -> void:
	dragged_item = null
	var other_item = _get_item_at_pos(at_position)
	if other_item != null && other_item != newdata:
		var old_parent = newdata.get_parent().get_parent()
		
		
		for i in get_all_layeritems(newdata, true):
			if i.get_node("%LayerItem") == other_item:
				return
		
		
	#	print(drop_place)
		if drop_place == 0:
			newdata.get_parent().get_parent().remove_child(newdata.get_parent())
			other_item.get_node("%Intend2").show()
			newdata.get_node("%Intend2").show()
			newdata.get_node("%Intend").show()
			other_item.get_node("%T").show()
			other_item.get_node("%OtherLayers").add_child(newdata.get_parent())
			other_item.get_node("%Collapse").disabled = false
			
			newdata.data.sprite_object.get_parent().remove_child(newdata.data.sprite_object)
			other_item.data.sprite_object.get_node("%Sprite2D").add_child(newdata.data.sprite_object)
			newdata.data.sprite_object.parent_id = other_item.data.sprite_object.sprite_id
			
		
		if drop_place == 1:
			if other_item.get_parent().get_parent() != newdata.get_parent().get_parent():
				if other_item.get_parent().get_parent().name == "LayerVBox":
					newdata.get_node("%Intend").hide()
					newdata.data.sprite_object.parent_id = 0
				else:
					other_item.get_node("%Intend").show()
					newdata.get_node("%Intend2").show()
					newdata.data.sprite_object.parent_id = other_item.data.sprite_object.parent_id
				newdata.get_parent().get_parent().remove_child(newdata.get_parent())
				other_item.get_parent().get_parent().add_child(newdata.get_parent())
				other_item.get_parent().get_parent().move_child(newdata.get_parent(), clamp(other_item.get_parent().get_index(), 0, other_item.get_parent().get_index() + 1))
				
				newdata.data.sprite_object.get_parent().remove_child(newdata.data.sprite_object)
				other_item.data.sprite_object.get_parent().add_child(newdata.data.sprite_object)
				newdata.data.sprite_object.get_parent().move_child(newdata.data.sprite_object,newdata.get_parent().get_index())
				
				
				
			else:
				newdata.get_parent().get_parent().move_child(newdata.get_parent(), clamp(other_item.get_parent().get_index(), 0, other_item.get_parent().get_index() + 1))
				newdata.data.sprite_object.get_parent().move_child(newdata.data.sprite_object,newdata.get_parent().get_index())
				
				
			
		if drop_place == -1:
			if other_item.get_parent().get_parent() != newdata.get_parent().get_parent():
				if other_item.get_parent().get_parent().name == "LayerVBox":
					newdata.data.sprite_object.parent_id = 0
					newdata.get_node("%Intend").hide()
					
				else:
					other_item.get_node("%Intend").show()
					newdata.get_node("%Intend2").show()
					newdata.data.sprite_object.parent_id = other_item.data.sprite_object.parent_id
				newdata.get_parent().get_parent().remove_child(newdata.get_parent())
				other_item.get_parent().get_parent().add_child(newdata.get_parent())
				other_item.get_parent().get_parent().move_child(newdata.get_parent(), clamp(other_item.get_parent().get_index() + 1, 0, other_item.get_parent().get_index() + 1))
				
				newdata.data.sprite_object.get_parent().remove_child(newdata.data.sprite_object)
				other_item.data.sprite_object.get_parent().add_child(newdata.data.sprite_object)
				newdata.data.sprite_object.get_parent().move_child(newdata.data.sprite_object, clamp(newdata.get_parent().get_index(), 0, newdata.data.sprite_object.get_parent().get_child_count() - 1))
				
				
			else:
				newdata.get_parent().get_parent().move_child(newdata.get_parent(), clamp(other_item.get_parent().get_index() +1, 0, other_item.get_parent().get_index() + 1))
				newdata.data.sprite_object.get_parent().move_child(newdata.data.sprite_object,newdata.get_parent().get_index())
		
		if old_parent.get_children().size() == 0 && old_parent.name == "OtherLayers":
		#	old_parent.get_parent().get_parent().get_node("%Intend").hide()
			old_parent.get_parent().get_parent().get_node("%Collapse").disabled = true
			old_parent.get_parent().get_parent().get_node("%Collapse").button_pressed = false
			if old_parent.get_parent().get_parent().has_node("%T"):
				old_parent.get_parent().get_parent().get_node("%T").hide()
		drop_place = 0


func _get_item_at_pos(_at_position) -> Variant:
	if mouse_entered:
		return self
	else:
		return null


func _on_drop_1_mouse_entered() -> void:
	if dragged_item != null:
		$Drop1.color.a = 1
		drop_place = -1
	else:
		$Drop1.color.a = 0


func _on_drop_2_mouse_entered() -> void:
	if dragged_item != null:
		$Drop2.color.a = 1
		drop_place = 1
	else:
		$Drop2.color.a = 0

func _on_drop_1_mouse_exited() -> void:
	$Drop1.color.a = 0
	drop_place = 0

func _on_drop_2_mouse_exited() -> void:
	$Drop2.color.a = 0
	drop_place = 0


func _on_collapse_toggled(toggled_on: bool) -> void:
	data.sprite_object.is_collapsed = toggled_on
	if toggled_on:
		%OtherLayers.hide()
		
	else:
		%OtherLayers.show()


func get_all_layeritems(layeritem, recursive) -> Array:
	var children := []
	for child in layeritem.get_node("%OtherLayers").get_children():
		children.append(child)
		
		if recursive and child.get_node("%OtherLayers").get_child_count():
			children.append_array(get_all_layeritems(child, true))
		
	return children


func _on_move_up_pressed() -> void:
	get_parent().get_parent().move_child(get_parent(), clamp(get_parent().get_index() - 1, 0, get_parent().get_parent().get_child_count() - 1))
	data.sprite_object.get_parent().move_child(data.sprite_object, clamp(get_parent().get_index(), 0, data.sprite_object.get_parent().get_child_count() - 1))

func _on_move_down_pressed() -> void:
	get_parent().get_parent().move_child(get_parent(), clamp(get_parent().get_index() + 1, 0, get_parent().get_parent().get_child_count() - 1))
	data.sprite_object.get_parent().move_child(data.sprite_object, clamp(get_parent().get_index(), 0, data.sprite_object.get_parent().get_child_count() - 1))


func _on_visiblity_toggled(toggled_on: bool) -> void:
	if toggled_on:
		data.sprite_object.dictmain.visible = false
		data.sprite_object.visible = false
	else:
		data.sprite_object.dictmain.visible = true
		data.sprite_object.visible = true

#	data.sprite_object.save_state(Global.current_state)

func check_indents():
	if %OtherLayers.get_child_count() > 0:
		%Intend.show()
		%Collapse.disabled = false
		%Collapse.button_pressed = data.sprite_object.is_collapsed
	if is_instance_valid(get_parent().get_parent()):
		if get_parent().get_parent().name == "OtherLayers":
			%Intend.show()
			%Intend2.show()

func update_visib_buttons():
	if Global.held_sprite.dictmain.visible:
		%Visiblity.button_pressed = false
	elif !Global.held_sprite.dictmain.visible:
		%Visiblity.button_pressed = true
