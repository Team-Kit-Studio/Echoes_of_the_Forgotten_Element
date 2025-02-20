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
			# get_parent().emit_signal("load_to_save", self.name)
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
