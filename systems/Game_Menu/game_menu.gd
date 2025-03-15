extends Control
@onready var button: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var mainMenu: Control = $CanvasLayer/Main_Menu
@onready var settings: TabContainer = $CanvasLayer/GUI/Settings
@onready var pauseButton: Button = $CanvasLayer/Pause
@onready var saveLoadButton: Button = $"CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad_Game"
@onready var optionsButton: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var saveMenu: Control = $CanvasLayer/GUI/SaveMenu
@onready var colorrect: ColorRect = $CanvasLayer/Load_visible

func _ready() -> void:
	canvas.visible = true
	mainMenu.visible = false
	settings.visible = false	
	pauseButton.visible = true

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()

func load_control_from_settings() -> void:
	var keybinds: Dictionary[String, InputEvent] = SettingsLoader.load_control_settings()
	for action: String in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
	
func toggle() -> void:
	visible = !visible
	pauseButton.visible = !pauseButton.visible	
	mainMenu.visible = !mainMenu.visible
	saveMenu.visible = false
	settings.visible = false
	off_toggeled()
	
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
	continues()

func _on_button_pressed() -> void:
	toggle()
	

func continues() -> void:
	pauseButton.visible = true
	mainMenu.visible = false
	saveMenu.visible = false
	off_toggeled()
	settings.hide()

	if not settings.visible:
		optionsButton.button_pressed = false

	if not saveMenu.visible:
		saveLoadButton.button_pressed = false

func off_toggeled() -> void:
	optionsButton.button_pressed = false
	saveLoadButton.button_pressed = false

func _on_save_game_toggled(toggled_on: bool) -> void:
	settings.hide()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	if toggled_on:
		optionsButton.button_pressed = false
		saveMenu.visible = true
		tween.tween_property(saveMenu, "modulate", Color(1, 1, 1, 1), 0.30) 
		tween.tween_property(saveMenu, "position:x", 310, 0.2)
	else:
		tween.tween_property(saveMenu, "modulate", Color(1, 1, 1, 0.1), 0.15) 
		tween.tween_property(saveMenu, "position:x", -240, 0.2)
		await(tween.finished)
		saveMenu.visible = false


func _on_exit_game_pressed() -> void:
	get_tree().quit()


func _on_exit_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://systems/Main_Menu/Main_Menu.tscn")

func hide_canvas() -> void:
	mainMenu.hide()
	canvas.hide()

func show_canvas() -> void:
	mainMenu.show()
	canvas.show()

func color_rect_show() -> void:
	colorrect.show()
	var tween: Tween = create_tween()
	colorrect.modulate = Color(1, 1, 1, 1)
	tween.tween_property(colorrect, "modulate", Color(1, 1, 1, 0.1), 1.5)
	await tween.finished
	colorrect.hide() 
