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
		print(SaveLoadButton.button_pressed)
	
func load_control_from_settings() -> void:
	var keybinds = Persistence.load_control_settings()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
	
func toggle() -> void:
	visible = !visible
	get_tree().paused
	Main_Menu.visible = visible
	Pause_Button.visible = !visible



func _on_options_toggled(toggled_on) -> void:
	var tween = get_tree().create_tween()
	if toggled_on:
		Settings.visible = true
		tween.tween_property(Settings, "position:x", 310, 0.2)
		await tween.finished
		
	else:
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
	get_tree().change_scene_to_file("res://Menu.tscn")
	
	
func _on_load_game_pressed() -> void:
	SaveSystem.save_load("def", "kye")




	#SaveSystem.save_game("def")
	#SaveSystem.save_game("base_save")
	#SaveSystem.save_game("save_game")


func _on_save_game_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var tween = get_tree().create_tween()
		SaveMenu.visible = true
		tween.tween_property(SaveMenu, "position:x", 310, 0.2)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(SaveMenu, "position:x", -240, 0.2)
		await tween.finished
		SaveMenu.visible = false
	
