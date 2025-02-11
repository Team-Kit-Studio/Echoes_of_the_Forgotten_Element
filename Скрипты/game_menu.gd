extends Control

@onready var button: Button = $CanvasLayer/Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/Options
@onready var Canvas: CanvasLayer = $CanvasLayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load_control_from_settings()
	Canvas.visible = true
	$CanvasLayer/Main_Menu.visible = false
	$CanvasLayer/Options/Settings.visible = false	
	$CanvasLayer/Button.visible = true
func _process(delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
	
func load_control_from_settings() -> void:
	var keybinds = Persistence.load_control_settings()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
	
func toggle() -> void:
	visible = !visible
	get_tree().paused
	$CanvasLayer/Main_Menu.visible = visible
	$CanvasLayer/Button.visible = !visible



func _on_options_toggled(toggled_on) -> void:
	var tween = get_tree().create_tween()
	if toggled_on:
		$CanvasLayer/Options/Settings.visible = true
		tween.tween_property($CanvasLayer/Options/Settings, "position:x", 310, 0.2)
		await tween.finished
		
	else:
		tween.tween_property($CanvasLayer/Options/Settings, "position:x", -240, 0.2)
		await tween.finished
		$CanvasLayer/Options/Settings.visible = false
	

func _on_continue_pressed() -> void:
	$CanvasLayer/Main_Menu.visible = false
	$CanvasLayer/Button.visible = true


func _on_button_pressed() -> void:
	$CanvasLayer/Main_Menu.visible = true
	$CanvasLayer/Button.visible = false


func _on_exit_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
	
	
func _on_load_game_pressed() -> void:
	pass
