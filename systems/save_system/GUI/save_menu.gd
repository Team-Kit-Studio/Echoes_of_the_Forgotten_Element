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

const MODE_TEXT: Dictionary = {
	"SAVE": "Сохранить",
	"OVERWRITE": "Перезаписать"
}

var CurrentSave: String

func _ready() -> void:
	self.create_a_save.connect(create_save)
	self.delete_save.connect(delete_save_handler)
	self.update_save_name.connect(update_save_name_handler)
# func _physics_process(delta: float) -> void:
# 	print(CurrentSave)

	
func _on_new_save_pressed() -> void:
	if NewSaveButton.text != "Перезаписать":
		if not NewSave.visible:
			NewSave.show()
			NewSave.scale = Vector2(0.3, 0.3)
			var tween = get_tree().create_tween()
			tween.tween_property(NewSave, "scale", Vector2(1,1), 0.1)
		else:
			await NewSave.animate_and_hide()
			NewSave.hide()
	else:
		var save = find_save(CurrentSave)
		if save:
			save.overwrite_save()
		

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
	
func create_save(_name: String) -> void:
	var created_save: Node = SaveSlot.instantiate()
	created_save.custom_minimum_size = Vector2(375.135, 70.185)
	created_save.name = get_unique_save_name(_name)
	SaveList.add_child(created_save)
	
func _on_delete_pressed() -> void:
	set_save_button_text("SAVE")
	emit_signal("delete_save", CurrentSave)
	
func delete_save_handler(_name: String) -> void:
	print(_name)
	Delete.disabled = true
	Load.disabled = true
	NewSaveButton.show()
	var save: Node = find_save(_name)
	if save:
		print(save)
		save.call_deferred("queue_free")
	
func update_save_name_handler(_name: String) -> void:
	CurrentSave = _name

func _on_load_pressed() -> void:
	pass

func set_save_button_text(_mode: String) -> void:
	NewSaveButton.text = MODE_TEXT[_mode]

func find_save(_name: String) -> Node:
	for node in SaveList.get_children():
		if node.name == _name:
			return node
	return null

func get_unique_save_name(base_name: String) -> String:
	var name = base_name
	var counter = 1
	while find_save(name) != null:
		name = base_name + "-(" + str(counter) + ")"
		counter += 1
	return name