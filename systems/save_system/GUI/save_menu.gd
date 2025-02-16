extends Control

signal create_a_save(_name: String)
signal delete_save(_name: String)
signal update_save_name(_name: String)

@onready var NewSave: Control = $NewSave
@onready var Load: Button = $Panel/Load
@onready var Delete: Button = $Panel/Delete
@onready var NewSaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV
var SaveSlot: PackedScene = preload("res://systems/save_system/GUI/SaveSlot.tscn")

var CurrentSave: String

func _ready() -> void:
	self.create_a_save.connect(create_save)
	self.delete_save.connect(delate_save)
	self.update_save_name.connect(update_save_name_handler)
	
func _on_new_save_pressed() -> void:
	if not NewSave.visible:
		NewSave.show()
		NewSave.scale = Vector2(0.3, 0.3)
		var tween = get_tree().create_tween()
		tween.tween_property(NewSave, "scale", Vector2(1,1), 0.1)
	else:
		await NewSave.animate_and_hide()
		NewSave.hide()
		

func _on_cancel_pressed() -> void:
	cancel_save_menu()
	
func cancel_save_menu() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", -700, 0.3)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.1), 0.15)
	tween.tween_property(NewSave, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	NewSave.hide()
	self.hide()
	
func create_save(save_name: String) -> void:
	var created_save: Node = SaveSlot.instantiate()
	created_save.custom_minimum_size = Vector2(375.135, 70.185)
	created_save.name = save_name
	SaveList.add_child(created_save)
	
func _on_delete_pressed() -> void:
	emit_signal("delete_save", CurrentSave)
	
func delate_save(_name: String) -> void:
	NewSaveButton.show()
	Delete.hide()
	for child in SaveList.get_children():
		child.self_delete()
		break
func update_save_name_handler(_name: String) -> void:
	CurrentSave = _name

	
func _on_load_pressed() -> void:
	pass
