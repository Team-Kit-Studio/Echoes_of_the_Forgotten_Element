extends Control

signal save_create(save_name: String)

@onready var CancelButton: Button = $Panel/Cancel
@onready var ApplyButton: Button = $Panel/Apply
@onready var linedit: LineEdit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit

const forbidden_characters: Array[String] = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", " ", "#", "%", "{"
	, "}", "^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", ""
]

func _ready() -> void:
	linedit.grab_focus()

func _on_apply_pressed() -> void:
	var SaveName: String = linedit.text
	SaveName = restriction_check(SaveName, forbidden_characters)
	linedit.text = ""
	if SaveName: 
		animate_and_hide()
		emit_signal("save_create", SaveName)
	else:
		show_invalid_name_message()
	
	
func _on_cancel_pressed() -> void:
	linedit.text = ""
	animate_and_hide()
	
	
func animate_and_hide() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	self.hide()
	
	
func show_invalid_name_message() -> void:
	linedit.placeholder_text = "Неверное название!"
	await get_tree().create_timer(2.2).timeout
	linedit.placeholder_text = "Введите название..."
	
	
func restriction_check(Check: String, From: Array[String]) -> String:
	for letter in Check:
		if letter in From:
			return ""
	return Check
