extends Control

signal create_item_pressed
@onready var CancelButton: Button = $Panel/Cancel
@onready var ApplyButton: Button = $Panel/Apply
@onready var linedit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit
@onready var AllGUI= $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linedit.grab_focus()

func _on_apply_pressed() -> void:
	var SaveName: String = linedit.text
	if SaveName: 
		var tween = get_tree().create_tween()
		SaveName = linedit.text
		tween.tween_property(AllGUI, "scale", Vector2(0.4, 0.4), 0.1)
		await tween.finished
		AllGUI.hide()
		emit_signal("create_item_pressed")
	else:
		linedit.placeholder_text = "Неверное название!"
		await get_tree().create_timer(2.2).timeout
		linedit.placeholder_text = "Введите название..."


func _on_cancel_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(AllGUI, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	AllGUI.hide()
