extends Control
@onready var button: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var mainMenu: Control = $CanvasLayer/Main_Menu
@onready var settings: TabContainer = $CanvasLayer/GUI/Settings
@onready var pauseButton: Button = $CanvasLayer/Pause
@onready var saveLoadButton: Button = $"CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad_Game"
@onready var options: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var saveMenu: Control = $CanvasLayer/GUI/SaveMenu

func _ready() -> void:
	canvas.visible = true
	mainMenu.visible = false
	settings.visible = false	
	pauseButton.visible = true

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
	if not saveMenu.visible:
		saveLoadButton.button_pressed = false
	
func load_control_from_settings() -> void:
	var keybinds = Persistence.load_control_settings()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
	
func toggle() -> void:
	visible = !visible
	pauseButton.visible = not visible
	mainMenu.visible = not mainMenu.visible
	saveMenu.visible = false
	settings.visible = false
	
func _on_options_toggled(toggled_on: bool) -> void:
	saveMenu.hide()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	if toggled_on:
		saveLoadButton.button_pressed = false
		settings.visible = true
		tween.tween_property(settings, "modulate", Color(1, 1, 1, 1), 0.30) 
		tween.tween_property(settings, "position:x", 310, 0.2)
	else:
		tween.tween_property(settings, "modulate", Color(1, 1, 1, 0.1), 0.15) 
		tween.tween_property(settings, "position:x", -240, 0.2)
		await(tween.finished)
		settings.visible = false
	
func _on_continue_pressed() -> void:
	mainMenu.visible = false
	saveMenu.visible = false
	pauseButton.visible = true
	settings.hide()
	if not settings.visible:
		options.button_pressed = false

func _on_button_pressed() -> void:
	mainMenu.visible = true
	pauseButton.visible = false

func _on_load_game_pressed() -> void:
	pass

func _on_save_game_toggled(toggled_on: bool) -> void:
	settings.hide()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	if toggled_on:
		options.button_pressed = false
		saveMenu.visible = true
		tween.tween_property(saveMenu, "modulate", Color(1, 1, 1, 1), 0.30) 
		tween.tween_property(saveMenu, "position:x", 310, 0.2)
	else:
		tween.tween_property(saveMenu, "modulate", Color(1, 1, 1, 0.1), 0.15) 
		tween.tween_property(saveMenu, "position:x", -240, 0.2)
		await tween.finished
		saveMenu.visible = false


func _on_exit_game_pressed() -> void:
	get_tree().quit()


func _on_exit_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://systems/Main_Menu/Main_Menu.tscn")

func hide_canvas() -> void:
	$CanvasLayer.hide()