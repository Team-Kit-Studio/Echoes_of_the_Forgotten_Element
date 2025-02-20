extends Panel

@onready var parent: Node = get_parent().get_owner()

var is_pressed: bool = false
var is_mouse_over: bool = false

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
			hide_line()
			

func handle_mouse_click() -> void:
	is_pressed = true
	show_line()
	parent.emit_signal("update_current_node", self)
	parent.enable_buttons()
	

func hide_line() -> void:
	$Line2D.hide()


func show_line() -> void:
	$Line2D.show()


func update_time_ready() -> void:
	var date: Dictionary = Time.get_date_dict_from_system()
	var time: Dictionary = Time.get_time_dict_from_system()
	handler_time(date, time)


func update_time_json() -> void:
	var data: Dictionary = SaveSustem.read_save(name)
	var date: Dictionary = data["info"]["last_date"]
	var time: Dictionary = data["info"]["last_time"]
	handler_time(date, time)


func handler_time(date: Dictionary, time: Dictionary) -> void:
	var sum_time: String = str(date.day) + "." + str(date.month) + "." + str(date.year) + "\n" + str(time.hour) + " : " + str(time.minute)
	if str(time.minute).length() < 2:
		sum_time = str(date.day) + "." + str(date.month) + "." + str(date.year) + "\n" + str(time.hour) + " : " + "0" + str(time.minute)
	update_time_text(sum_time)


func update_time_text(_text: String) -> void:
	$VBoxContainer/HBoxContainer/SaveDate.text = _text
