extends Panel

@onready var parent: Node = get_parent().get_owner()

var is_pressed: bool = false
var is_mouse_over: bool = false

var _image: Texture2D

func _ready() -> void:
	$VBoxContainer/HBoxContainer/SaveName.text = self.name
	$Line2D.hide()


func _on_mouse_entered() -> void:
	is_mouse_over = true
	if not is_pressed:
		$Line2D.show()


func _on_mouse_exited() -> void:
	is_mouse_over = false
	if not is_pressed:
		$Line2D.hide()
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			pass
			
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_mouse_click()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_pressed and not is_mouse_over:
			is_pressed = false
			parent.disable_buttons()
			parent.set_image_save(null)
			hide_line()
			

func handle_mouse_click() -> void:
	is_pressed = true
	show_line()
	parent.set_image_save(_image)
	parent.emit_signal("update_current_node", self)
	parent.enable_buttons()
	parent.set_image_save(_image)
	

func hide_line() -> void:
	$Line2D.hide()


func show_line() -> void:
	$Line2D.show()


func update_time_ready() -> void:
	handle_date_time(Time.get_date_dict_from_system(), Time.get_time_dict_from_system())

func update_time_json() -> void:
	var time_data: Dictionary = SaveSustem.read_save(self.name, "metadata" , ".json")
	handle_date_time(time_data["last_modified_time"]["date"], time_data["last_modified_time"]["time"])

func format_date_time(date: Dictionary, time: Dictionary) -> String:
	var formatted_date: String = "%02d.%02d.%d" % [date.day, date.month, date.year]
	var formatted_time: String = "%02d:%02d" % [time.hour, time.minute] 
	return "%s\n%s" % [formatted_date, formatted_time]


func handle_date_time(date: Dictionary, time: Dictionary) -> void:
	var formatted_date_time: String = format_date_time(date, time)
	update_text(formatted_date_time)

func update_text(_text: String) -> void:
	$VBoxContainer/HBoxContainer/SaveDate.text = _text
