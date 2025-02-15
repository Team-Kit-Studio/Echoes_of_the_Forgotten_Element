extends Control

@onready var NewSave: Control = $NewSave
@onready var SaveMenu: Control = self
@onready var Load: Button = $Panel/Load
@onready var Delete: Button = $Panel/Delete
@onready var NewSaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV
var SaveSlot: PackedScene = preload("res://systems/save_system/GUI/SaveSlot.tscn")
var SaveName: String
func _ready() -> void:
	NewSave.save_create.connect(save_created_handler)
	
func _physics_process(delta: float) -> void:
	pass
	
func _on_new_save_pressed() -> void:
	if not NewSave.visible:
		NewSave.show()
		NewSave.scale = Vector2(0.3, 0.3)
		var tween = get_tree().create_tween()
		tween.tween_property(NewSave, "scale", Vector2(1,1), 0.1)
	else:
		await NewSave.animate_and_hide()
		NewSave.hide()
	
	
func save_created_handler(save_name: String) -> void:
	create_save(save_name)
func _on_cancel_pressed() -> void:
	cancel_save_menu()
	
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
	
func create_save(save_name: String) -> void:
	var created_save: Node = SaveSlot.instantiate()
	created_save.custom_minimum_size = Vector2(375.135, 70.185)
	created_save.name = save_name
	SaveList.add_child(created_save)
	
func _on_delete_pressed() -> void:
	delate_save()
	
func delate_save() -> void:
	NewSaveButton.show()
	Delete.hide()
	for child in SaveList.get_children():
		child.self_delete()
		break
	
func _on_load_pressed() -> void:
	pass
