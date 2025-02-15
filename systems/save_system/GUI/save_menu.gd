extends Control

@onready var NewSave: Control = $NewSave
@onready var SaveMenu: Control = self
@onready var SaveLoad_Game: Button = $"../../Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad_Game"
var SaveSlot: PackedScene = preload("res://systems/save_system/GUI/SaveSlot.tscn")

func _ready() -> void:
	NewSave.save_create.connect(save_created_handler)

func _process(_delta: float) -> void:
	pass


func _on_new_save_pressed() -> void:
	if NewSave.visible == false:
		NewSave.show()
		var tween = get_tree().create_tween()
		NewSave.scale = Vector2(0.3, 0.3)
		tween.tween_property(NewSave, "scale", Vector2(1,1), 0.1)
		


func _on_cancel_pressed() -> void:
	cancel_save_menu()

func save_created_handler(save_name: String) -> void:
	create_save(save_name)
func cancel_save_menu() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(SaveMenu, "position:x", -700, 0.3)
	tween.tween_property(SaveMenu, "modulate", Color(1, 1, 1, 0.1), 0.15) 
	tween.set_parallel(false)
	tween.tween_property(NewSave, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	NewSave.hide()
	SaveMenu.hide()
	SaveLoad_Game.button_pressed = false
	
func create_save(save_name: String) -> void:
	var created_save: Node = SaveSlot.instantiate()
	created_save.custom_minimum_size = Vector2(375.135, 70.185)
	created_save.name = save_name
	$Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV.add_child(created_save)

	
