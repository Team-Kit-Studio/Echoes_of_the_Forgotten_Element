extends Control

signal show_confirm(mode: String)
signal _on_apply(mode: String)

@onready var LabelText: Label = $Panel/HBoxContainer/VBoxContainer/Label
var mode: String

func  _ready():
	self.show_confirm.connect(Callable(self, "confirm_show"))

func set_text(text: String) -> void:
	LabelText.text = text

func _on_apply_pressed() -> void:
	self.emit_signal("_on_apply", mode)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.15)
	await tween.finished
	self.hide()


func _on_cancel_pressed() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.15)
	await tween.finished
	self.hide()

func confirm_show(_mode: String) -> void:
	mode = _mode
	self.show()
	self.scale = Vector2(0.3, 0.3)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15)
