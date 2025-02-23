extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	sliders_revalue(Global.settings_dict)
	Global.reinfo.connect(info_held)
	%CreditLabel.text = "PNGTuber Remix by TheMime (MudkipWorld)
	Original PNGTuber+ Code by kaiakairos. Better UI by LeoRson.
	V" + str(ProjectSettings.get_setting("application/config/version"))

func info_held():
	%DeselectButton.show()

func check_data():
	%AutoLoadCheck.button_pressed = Themes.theme_settings.auto_load
	%SaveOnExitCheck.button_pressed = Themes.theme_settings.save_on_exit
	%AutoSaveCheck.button_pressed = Global.settings_dict.auto_save

func _physics_process(_delta):
	%VolumeBar.value = GlobalMicAudio.volume
	%DelayBar.value = GlobalMicAudio.delay

func sliders_revalue(settings_dict):
	%BounceAmountSlider.get_node("%SliderValue").value = settings_dict.bounceSlider
	%GravityAmountSlider.get_node("%SliderValue").value = settings_dict.bounceGravity
	%BGColorPicker.color = settings_dict.bg_color
	%InputCheckButton.button_pressed = settings_dict.checkinput
	%VolumeSlider.value = settings_dict.volume_limit
	%SensitivitySlider.value = settings_dict.sensitivity_limit
	%AntiAlCheck.button_pressed = settings_dict.anti_alias
	$TopBarInput.origin_alias()
	%BounceStateCheck.button_pressed = settings_dict.bounce_state
	%XFreqWobbleSlider.value = settings_dict.xFrq
	%XAmpWobbleSlider.value = settings_dict.xAmp
	%YFreqWobbleSlider.value = settings_dict.yFrq
	%YAmpWobbleSlider.value = settings_dict.yAmp
	%AutoSaveCheck.button_pressed = settings_dict.auto_save
	%AutoSaveSpin.value = settings_dict.auto_save_timer
	%DelaySlider.value = settings_dict.volume_delay
	get_tree().get_root().get_node("Main/SubViewportContainer/%Camera2D").zoom = settings_dict.zoom
	get_tree().get_root().get_node("Main/SubViewportContainer/%CamPos").global_position = settings_dict.pan
	
	get_tree().get_root().get_node("Main/%Control/%BlinkSpeedSlider").value = Global.settings_dict.blink_speed
	%DeltaTimeCheck.button_pressed = settings_dict.should_delta
	%MaxFPSlider.value = settings_dict.max_fps
	update_fps(settings_dict.max_fps)
	
	if %AutoSaveCheck.button_pressed:
		%AutoSaveTimer.start()

func update_fps(value):
	if value == 241:
		Engine.max_fps = 0
		return
	
	Engine.max_fps = value

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.volume_limit = %VolumeSlider.value

func _on_delay_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.volume_delay = %DelaySlider.value

func _on_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings_dict.sensitivity_limit = %SensitivitySlider.value
