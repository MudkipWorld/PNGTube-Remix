extends Control

@onready var view1 
@onready var view2 = $HSplitContainer/LeftPanel/VBox/VPPanel/SubViewportContainer2/SubViewport
@onready var top_bar = get_tree().get_root().get_node("Main/%TopUI")

# Called when the node enters the scene tree for the first time.
func _ready():
#	tree.update_tree.connect(update_tree)
	Global.theme_update.connect(update_ui)
	if get_parent().get_parent().has_node("SubViewportContainer/SubViewport"):
		view1 = get_parent().get_parent().get_node("SubViewportContainer/SubViewport")
		view2.world_2d = view1.world_2d

func update_ui(index):
	match index:
		0:
			purple_theme()
		1:
			blue_theme()
		2:
			orange_theme()
		3:
			white_theme()
		4:
			dark_theme()
		5:
			green_theme()
		6:
			funky_theme()

func blue_theme():
	
	%Panelt.self_modulate = Color.LIGHT_BLUE
	%Paneln.self_modulate = Color.LIGHT_BLUE
	%PanelL1_2.self_modulate = Color.LIGHT_BLUE
	%Properties.self_modulate = Color.LIGHT_BLUE
	%LayersButtons.modulate = Color.AQUA

	%ViewportCam.modulate = Color.AQUA
	top_bar.get_node("%ResetMicButton").modulate = Color.AQUA
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func purple_theme():
	
	%Panelt.self_modulate = Color(0.898, 0.796, 0.996, 1 )
	%Paneln.self_modulate = Color(0.898, 0.796, 0.996, 1 )
	%PanelL1_2.self_modulate = Color(0.898, 0.796, 0.996, 1 )
	%Properties.self_modulate = Color(0.898, 0.796, 0.996, 1 )
	%LayersButtons.modulate = Color(0.898, 0.796, 0.996, 1 )

	%ViewportCam.modulate = Color(0.898, 0.796, 0.996, 1 )
	top_bar.get_node("%ResetMicButton").modulate = Color(0.898, 0.796, 0.996, 1 )
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func orange_theme():
	
	%Panelt.self_modulate = Color.ORANGE
	%Paneln.self_modulate = Color.ORANGE
	%PanelL1_2.self_modulate = Color.ORANGE
	%Properties.self_modulate = Color.ORANGE
	%LayersButtons.modulate = Color.ORANGE

	%ViewportCam.modulate = Color.ORANGE
	top_bar.get_node("%ResetMicButton").modulate = Color.ORANGE
	
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func white_theme():
	
	%Panelt.self_modulate = Color.WHITE
	%Paneln.self_modulate = Color.WHITE
	%PanelL1_2.self_modulate = Color.WHITE
	%Properties.self_modulate = Color.WHITE
	%LayersButtons.modulate = Color.WHITE

	%ViewportCam.modulate = Color.WHITE
	top_bar.get_node("%ResetMicButton").modulate = Color.WHITE
	
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func dark_theme():
	
	%Panelt.self_modulate = Color.WEB_GRAY
	%Paneln.self_modulate = Color.WEB_GRAY
	%PanelL1_2.self_modulate = Color.WEB_GRAY
	%Properties.self_modulate = Color.WEB_GRAY
	%LayersButtons.modulate = Color.DIM_GRAY

	%ViewportCam.modulate = Color.DIM_GRAY
	top_bar.get_node("%ResetMicButton").modulate = Color.DIM_GRAY
	
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func green_theme():
	
	%Panelt.self_modulate = Color.LIGHT_GREEN
	%Paneln.self_modulate = Color.LIGHT_GREEN
	%PanelL1_2.self_modulate = Color.LIGHT_GREEN
	%Properties.self_modulate = Color.LIGHT_GREEN
	%LayersButtons.modulate = Color.LIGHT_GREEN

	%ViewportCam.modulate = Color.LIGHT_GREEN
	top_bar.get_node("%ResetMicButton").modulate = Color.LIGHT_GREEN
	
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func funky_theme():
	
	%Panelt.self_modulate = Color.SKY_BLUE
	%Paneln.self_modulate = Color.SKY_BLUE
	%PanelL1_2.self_modulate = Color.SKY_BLUE
	%Properties.self_modulate = Color.MEDIUM_SEA_GREEN
	%LayersButtons.modulate = Color.SKY_BLUE

	%ViewportCam.modulate = Color.SKY_BLUE
	top_bar.get_node("%ResetMicButton").modulate = Color.SKY_BLUE
	
	%LeftPanel.self_modulate = Color.WHITE
	%RightPanel.self_modulate = Color.WHITE
	top_bar.self_modulate = Color.WHITE

func _on_layer_view_bg_focus_entered() -> void:
	if %LayerViewBG.has_focus():
		%LayerViewBG.release_focus()
	%LayerViewBG.deselect_all()
	%TopBarInput.desel_everything()
