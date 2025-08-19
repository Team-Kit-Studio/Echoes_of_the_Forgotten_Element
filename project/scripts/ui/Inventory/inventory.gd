extends Control

var current_scene

@export var hotbar: HBoxContainer
@export var grid: GridContainer
@onready var Inventory: GridContainer = $UI/GridContainer
@onready var panel: Panel = $UI/Panel
	

func _ready():
	Inventory.hide()
	panel.hide()

func _on_hot_bar_equip(item: Item) -> void:
	if current_scene != null:
		current_scene.currently_equipped = item

func Toggle():
	visible = !visible
	Inventory.visible = !Inventory.visible
	panel.visible = !panel.visible
		
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Inventory"):
		Toggle()

func use_stackable_item():
	hotbar.update()
	hotbar.use_current()
