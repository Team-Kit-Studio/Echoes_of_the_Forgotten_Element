extends Control

signal create_item_pressed
@onready var CancelButton: Button = $Panel/Cancel
@onready var ApplyButton: Button = $Panel/Apply
@onready var linedit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit
@onready var AllGUI: Control = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linedit.grab_focus()
	ApplyButton.pressed.connect(_on_apply_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_apply_pressed() -> void:
	var SaveName: String
	var tween = get_tree().create_tween()
	SaveName = linedit.text
	tween.tween_property(AllGUI, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	AllGUI.hide()
	emit_signal("create_item_pressed")


func _on_cancel_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(AllGUI, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	AllGUI.hide()
