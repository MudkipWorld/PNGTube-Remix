extends Node

var devices : Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%UIThemeButton.item_selected.connect(Themes._on_ui_theme_button_item_selected)
	%UIThemeButton.select(Themes.theme_settings.theme_id)
	%MicroPhoneMenu.get_popup().connect("id_pressed",choosing_device)
	get_parent().close_requested.connect(close)
	sliders_revalue(Global.settings_dict)
	check_data()
	devices = AudioServer.get_input_device_list()
	for i in devices:
		%MicroPhoneMenu.get_popup().add_item(i)
	
	for i in get_tree().get_nodes_in_group("StateButtons"):
		var remap_btn = preload("res://UI/StateButton/state_remap_button.tscn").instantiate()
		remap_btn.get_node("State").text = "State " + i.text
		remap_btn.get_node("StateRemapButton").action = i.input_key
		remap_btn.get_node("StateRemapButton").state_button = i
		remap_btn.get_node("StateRemapButton").update_stuff()
		%Grid.add_child(remap_btn)


func close():
	get_parent().queue_free()

func check_data():
	%AutoLoadCheck.button_pressed = Themes.theme_settings.auto_load
	%SaveOnExitCheck.button_pressed = Themes.theme_settings.save_on_exit
	%AutoSaveCheck.button_pressed = Global.settings_dict.auto_save

func _physics_process(_delta):
	%VolumeBar.value = GlobalMicAudio.volume
	%DelayBar.value = GlobalMicAudio.delay

func sliders_revalue(settings_dict):
	%InputCheckButton.button_pressed = settings_dict.checkinput
	%VolumeSlider.value = settings_dict.volume_limit
	%SensitivitySlider.value = settings_dict.sensitivity_limit
	%AntiAlCheck.button_pressed = settings_dict.anti_alias
#	$TopBarInput.origin_alias()
	%AutoSaveCheck.button_pressed = settings_dict.auto_save
	%AutoSaveSpin.value = settings_dict.auto_save_timer
	%DelaySlider.value = settings_dict.volume_delay
	%DeltaTimeCheck.button_pressed = settings_dict.should_delta
	%MaxFPSlider.value = settings_dict.max_fps

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.volume_limit = %VolumeSlider.value

func _on_delay_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.volume_delay = %DelaySlider.value

func _on_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.sensitivity_limit = %SensitivitySlider.value

func _on_sensitivity_slider_value_changed(value: float) -> void:
	%SensitivityBar.value = value


func _on_auto_load_check_toggled(toggled_on: bool) -> void:
	Themes.theme_settings.auto_load = toggled_on
	Themes.save()


func _on_save_on_exit_check_toggled(toggled_on: bool) -> void:
	Themes.theme_settings.save_on_exit = toggled_on
	Themes.save()


func _on_delta_time_check_toggled(toggled_on: bool) -> void:
	Global.settings_dict.should_delta = toggled_on


func _on_auto_save_spin_value_changed(value):
	Themes.save_timer.wait_time = value * 60
	Global.settings_dict.auto_save_timer = Themes.save_timer.wait_time



func choosing_device(id):
	if id != null:
		if AudioServer.get_input_device_list().has(devices[id]):
			AudioServer.input_device = devices[id]
			ProjectSettings.set("audio/driver/mix_rate", AudioServer.get_mix_rate())
	else:
		reset_mic_list()

func _on_reset_mic_button_pressed():
	reset_mic_list()

func reset_mic_list():
	%MicroPhoneMenu.get_popup().clear()
	devices = AudioServer.get_input_device_list()
	devices.append_array(AudioServer.get_output_device_list())
	for i in devices:
		%MicroPhoneMenu.get_popup().add_item(i)


func _on_anti_al_check_toggled(toggled_on):
	Global.settings_dict.anti_alias = toggled_on
	if toggled_on:
		Global.sprite_container.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	else:
		Global.sprite_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS


func _on_input_check_button_toggled(toggled_on):
	Global.settings_dict.checkinput = toggled_on

func _on_max_fp_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		%MaxFPSLabel.text = "Max FPS : " + str(%MaxFPSlider.value)
		Global.settings_dict.max_fps = %MaxFPSlider.value
		Global.top_ui.update_fps(%MaxFPSlider.value)

func _on_max_fp_slider_value_changed(value: float) -> void:
	%MaxFPSLabel.text = "Max FPS : " + str(value)


func _on_auto_save_check_toggled(toggled_on):
	Global.settings_dict.auto_save = toggled_on
	if toggled_on:
		Themes.save_timer.start()
	else:
		Themes.save_timer.stop()
