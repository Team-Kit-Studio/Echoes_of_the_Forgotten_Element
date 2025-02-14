extends Panel

signal pressed(panel)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Line2D.hide()

func _on_mouse_entered() -> void:
	$Line2D.show()

func _on_mouse_exited() -> void:
	$Line2D.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit(self)
			
