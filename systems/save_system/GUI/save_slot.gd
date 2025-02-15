extends Panel

signal pressed(panel)

func _ready() -> void:
	self.pressed.connect(h)
	$VBoxContainer/HBoxContainer/SaveName.text = self.name
	$Line2D.hide()

func _on_mouse_entered() -> void:
	$Line2D.show()

func _on_mouse_exited() -> void:
	$Line2D.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit(self)
func h(panel):
	print(self.name)
