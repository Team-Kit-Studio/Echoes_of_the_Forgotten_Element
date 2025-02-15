extends Panel

var pressed: bool = false
var get_mouse: bool = false

func _ready() -> void:
	$VBoxContainer/HBoxContainer/SaveName.text = self.name
	$Line2D.hide()

func _on_mouse_entered() -> void:
	get_mouse = true
	if not pressed:
		$Line2D.show()

func _on_mouse_exited() -> void:
	get_mouse = false
	if not pressed:
		$Line2D.hide()
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed = true
			$Line2D.show()
			load_button_hide()
		if event.double_click:
			pass #сюда прилепить лоад сохранения, как-нибудь
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not get_mouse and pressed:
			hide_is_line()
			load_button_show()
	
func hide_is_line() -> void:
	if not get_mouse:
		$Line2D.hide()
		pressed = false
		get_mouse = false
	
func load_button_hide() -> void:
	get_parent().get_owner().Delete.visible = true
	get_parent().get_owner().NewSaveButton.visible = false
	get_parent().get_owner().Load.disabled = false
	get_parent().get_owner().SaveName= self.name
	
func load_button_show() -> void:
	get_parent().get_owner().SaveName = ""
	await get_tree().create_timer(0.1).timeout
	get_parent().get_owner().Delete.visible = false
	get_parent().get_owner().NewSaveButton.visible = true
	get_parent().get_owner().Load.disabled = true
	
func self_delete() -> void:
	self.call_deferred("queue_free")
