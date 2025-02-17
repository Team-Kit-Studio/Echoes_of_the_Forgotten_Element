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
			load_save()
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_mouse_click()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_pressed and not is_mouse_over:
			is_pressed = false
			disable_buttons()
			hide_line()
			
func handle_mouse_click() -> void:
	enable_buttons()
	$Line2D.show()
	is_pressed = true
	
func load_save() -> void:
	# сюда прилепить лоад сохранения, как-нибудь
	pass

func hide_line() -> void:
	disable_buttons()
	$Line2D.hide()

func enable_buttons() -> void:
	parent.emit_signal("update_save_name", self.name)
	await get_tree().create_timer(0.13).timeout
	parent.set_save_button_text("OVERWRITE")
	parent.Delete.disabled = false
	parent.Load.disabled = false
	
func disable_buttons() -> void:
	await get_tree().create_timer(0.13).timeout
	parent.set_save_button_text("SAVE")
	parent.Load.disabled = true
	parent.Delete.disabled = true

func overwrite_save() -> void:
	print("Overwrite save: ", self.name)
	update_time()

func update_time() -> void:
	var time: Dictionary = Time.get_date_dict_from_system()
	$VBoxContainer/HBoxContainer/SaveDate.text = str(time["day"]) + "." + str(time["month"]) + "." + str(time["year"])
