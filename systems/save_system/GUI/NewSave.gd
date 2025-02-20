extends Control

@onready var line_edit: LineEdit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit

func _ready() -> void:
	line_edit.grab_focus()


func _on_apply_pressed() -> void:
	var save_name: String = check_restrictions(line_edit.text)
	line_edit.clear()
	if save_name:
		animate_and_hide()
		get_parent().emit_signal("create_new_save", save_name)
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

func animate_and_show() -> void:
	line_edit.clear()
	self.show()
	self.scale = Vector2(0.4, 0.4)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func show_invalid_name_message() -> void:
	line_edit.placeholder_text = "Неверное название!"
	await get_tree().create_timer(2.2).timeout
	line_edit.placeholder_text = "Введите название..."

func check_restrictions(input_text: String) -> String:
	for letter in input_text:
		if letter in Gvars.FORBIDDEN_CHARACTERS:
			return ""
	return input_text
