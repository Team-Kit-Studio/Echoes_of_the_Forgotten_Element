extends Control

@onready var input_button_scene = preload("res://systems/Input_Button/Child_Files/button.tscn")
@onready var changable_list = $PanelContainer/MarginContainer/ScrollContainer/ChangableList

var is_remapping: bool = false
var action_to_remap = null
var remaping_button = null

var input_actions: Dictionary[String, String] = {
	"up": "Вверх", #Inputmode NAME: "New Name"
	"left": "Влево",
	"down": "Вниз",
	"right": "Вправо",
	#"Interact_Game_Objects": "Interact Objects"
}

func _ready() -> void:
	load_control_from_settings()
	_create_action_list()



func _create_action_list() -> void:
	for item in changable_list.get_children():
		item.queue_free()
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("InputLabel")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		changable_list.add_child(button)
		button.pressed.connect(Callable(self, "_on_button_pressed").bind(button, action))

func _on_button_pressed(button: Button, action: String)-> void:
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remaping_button = button
		button.find_child("InputLabel").text ="Press Key To Bind"
		
func _input(event: InputEvent) -> void:
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton&& event.pressed)
		):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			Persistence.save_control_settings(action_to_remap, event)
			_update_changable_list(remaping_button, event)
			
			
			is_remapping = false
			action_to_remap = null
			remaping_button = null
			
func load_control_from_settings() -> void:
	var keybinds = Persistence.load_control_settings()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
		print(InputMap)
func _update_changable_list(button, event):
	button.find_child("InputLabel").text = event.as_text().trim_suffix(" (Physical)")
	
