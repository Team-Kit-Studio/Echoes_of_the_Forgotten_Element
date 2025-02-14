extends Control

@onready var button: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var Canvas: CanvasLayer = $CanvasLayer
@onready var Main_Menu: Control = $CanvasLayer/Main_Menu
@onready var Settings: TabContainer = $CanvasLayer/GUI/Settings
@onready var Pause_Button: Button = $CanvasLayer/Pause
@onready var SaveLoadButton: Button = $"CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad Game"
@onready var Options: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var SaveMenu: Control = $CanvasLayer/GUI/SaveMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load_control_from_settings()
	Canvas.visible = true
	Main_Menu.visible = false
	Settings.visible = false	
	Pause_Button.visible = true
	SaveMenu.hide()
func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
	if SaveMenu.visible == false:
		SaveLoadButton.button_pressed = false
	
func load_control_from_settings() -> void:
	var keybinds = Persistence.load_control_settings()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
	
func toggle() -> void:
	get_tree().paused
	visible = !visible
	Pause_Button.visible = !visible
	Main_Menu.visible = visible
	SaveMenu.visible = false
	Settings.visible = false



func _on_options_toggled(toggled_on) -> void:
	SaveMenu.hide()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	if toggled_on:
		$"CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad Game".button_pressed = false
		Settings.visible = true
		tween.tween_property(Settings, "modulate", Color(1, 1, 1, 1), 0.30) 
		tween.tween_property(Settings, "position:x", 310, 0.2)
		
	else:
		tween.tween_property(Settings, "modulate", Color(1, 1, 1, 0.1), 0.15) 
		tween.tween_property(Settings, "position:x", -240, 0.2)
		await tween.finished
		Settings.visible = false
	

func _on_continue_pressed() -> void:
	Main_Menu.visible = false
	Pause_Button.visible = true
	Settings.hide()
	if Settings.visible == false:
		Options.button_pressed = false
	


func _on_button_pressed() -> void:
	Main_Menu.visible = true
	Pause_Button.visible = false


func _on_exit_game_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Menu.tscn")
	
	
func _on_load_game_pressed() -> void:
	SaveSystem.save_load("def", "kye")

func _on_save_game_toggled(toggled_on: bool) -> void:
	Settings.hide()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	if toggled_on:
		$CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options.button_pressed = false
		SaveMenu.visible = true
		tween.tween_property(SaveMenu, "modulate", Color(1, 1, 1, 1), 0.30) 
		tween.tween_property(SaveMenu, "position:x", 310, 0.2)
	else:
		tween.tween_property(SaveMenu, "modulate", Color(1, 1, 1, 0.1), 0.15) 
		tween.tween_property(SaveMenu, "position:x", -240, 0.2)
		await tween.finished
		SaveMenu.visible = false
