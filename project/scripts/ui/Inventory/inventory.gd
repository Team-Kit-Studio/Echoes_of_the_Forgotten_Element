extends Control

class_name Inventory

@export var Items:Dictionary
@export var grid: GridContainer
@export var count = 19

@onready var inventory: GridContainer = $UI/GridContainer
@onready var panel: Panel = $UI/Panel
@onready var hotbar: HBoxContainer = $UI/Hotbar

var current_scene

func _ready():
	inventory.hide()
	panel.hide()

func Toggle():
	visible = !visible
	inventory.visible = !inventory.visible
	panel.visible = !panel.visible
		
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Inventory"):
		Toggle()
