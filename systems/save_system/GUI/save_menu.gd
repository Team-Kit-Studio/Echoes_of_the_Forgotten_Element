extends Control

signal update_save_name(_name: Node)

@onready var NewSave: Control = $NewSave
@onready var Confirm: Control = $Confirm
@onready var Load: Button = $Panel/Load
@onready var Delete: Button = $Panel/Delete
@onready var NewSaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV
var SaveSlot: PackedScene = preload("res://systems/save_system/GUI/SaveSlot.tscn")

const MODE_TEXT: Dictionary = {
	"SAVE": "Сохранить",
	"OVERWRITE": "Перезаписать"
}

var CurrentSave: Node

func _ready() -> void:
	Confirm._on_apply.connect(Callable(self, "confirm_handeler"))
	SaveSustem.create_a_save.connect(Callable(self, "create_save_visual"))
	SaveSustem.delete_a_save.connect(Callable(self, "delete_save_handler"))
	self.update_save_name.connect(Callable(self, "update_save_name_handler"))
	save_create_ready()

func _on_new_save_pressed() -> void:
	_on_save_pressed()

func _on_save_pressed() -> void:
	if NewSaveButton.text != "Перезаписать":
		if not NewSave.visible:
			NewSave.show()
			NewSave.scale = Vector2(0.3, 0.3)
			var tween = get_tree().create_tween()
			tween.tween_property(NewSave, "scale", Vector2(1,1), 0.15)
		else:
			await NewSave.animate_and_hide()
			NewSave.hide()
	else:
		var save = CurrentSave.name
		if save:
			Confirm.emit_signal("show_confirm", "OVERWRITE")
			Confirm.set_text("Вы уверены, что хотите перезаписать \nсохранение? \nЭто действие нельзя отменить!")

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
	
func create_save_visual(_name: String) -> void:
	var created_save: Node = SaveSlot.instantiate()
	created_save.custom_minimum_size = Vector2(375.135, 70.185)
	created_save.name = _name
	created_save.update_time()
	SaveList.add_child(created_save)
	
func confirm_handeler(mode: String) -> void:
	if mode == "DELETE":
		set_save_button_text("SAVE")
		SaveSustem.emit_signal("delete_a_save", CurrentSave.name)

	elif mode == "OVERWRITE":
		pass
		
func delete_save_handler(_name: String) -> void:
	print(_name)
	Delete.disabled = true
	Load.disabled = true
	NewSaveButton.show()
	var save: Node = CurrentSave
	if save:
		print(save)
		save.call_deferred("queue_free")
		return
	
func update_save_name_handler(save_node: Node) -> void:
	CurrentSave = save_node

func _on_load_pressed() -> void:
	pass

func set_save_button_text(_mode: String) -> void:
	NewSaveButton.text = MODE_TEXT[_mode]

func get_unique_save_name(base_name: String) -> String:
	var _name = base_name
	var counter = 1
	while find_save(_name) != null:
		_name = base_name + "-(" + str(counter) + ")"
		counter += 1
	return _name

func find_save(_name: String) -> Node:
	for node in SaveList.get_children():
		if node.name == _name:
			return node
	return null

func save_create_ready() -> void:
	for save in SaveSustem.get_files_in_directory(Gvars.SAVE_PATH):
		var save_name: String = remove_save_extension(save)
		create_save_visual(save_name)

func remove_save_extension(file_name: String) -> String:
	return file_name.substr(0, file_name.length() - 5)
	
func _on_delete_pressed() -> void:
	Confirm.emit_signal("show_confirm", "DELETE")
	Confirm.set_text("Вы уверены, что хотите удалить \nсохранение? \nЭто действие нельзя отменить!")
	
