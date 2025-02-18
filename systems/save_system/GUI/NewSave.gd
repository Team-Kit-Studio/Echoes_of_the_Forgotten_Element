extends Control

@onready var cancel_button: Button = $Panel/Cancel
@onready var apply_button: Button = $Panel/Apply
@onready var line_edit: LineEdit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit

func _ready() -> void:
	line_edit.grab_focus()

func _on_apply_pressed() -> void:
	var save_name: String = check_restrictions(line_edit.text)
	line_edit.clear()
	if save_name:
		animate_and_hide()
		SaveSustem.emit_signal("create_a_save", get_parent().get_unique_save_name(save_name))
	else:
		show_invalid_name_message()

func _on_cancel_pressed() -> void:
	animate_and_hide()

func animate_and_hide() -> void:
	line_edit.clear()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	self.hide()

func show_invalid_name_message() -> void:
	line_edit.placeholder_text = "Неверное название!"
	await get_tree().create_timer(2.2).timeout
	line_edit.placeholder_text = "Введите название..."

func check_restrictions(input_text: String) -> String:
	for c in input_text:
		if c in Gvars.FORBIDDEN_CHARACTERS:
			return ""
	return input_text
