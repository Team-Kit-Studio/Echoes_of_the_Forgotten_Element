extends Control

@onready var linedit = $Panel/HBoxContainer/VBoxContainer/MarginContainer/LineEdit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linedit.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
