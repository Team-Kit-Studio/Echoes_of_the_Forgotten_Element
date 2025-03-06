extends Control

signal update_current_node(_node: Node)
signal create_new_save(_name: String)

@onready var SaveMenu: Control = $NewSave
@onready var Confirm: Control = $Confirm
@onready var LoadButton: Button = $Panel/Load
@onready var DeleteButton: Button = $Panel/Delete
@onready var SaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV
@onready var SaveImage: TextureRect = $Panel/SaveInfo/SaveImage

var SaveSlot: Resource = preload("res://systems/save_system/GUI/SaveSlot.tscn")

var current_save: Node

func _ready() -> void:
	self.create_new_save.connect(Callable(self, "create_new_save_handler"))
	self.update_current_node.connect(Callable(self, "update_current_node_handler"))
	Confirm.confirm_apply.connect(Callable(self, "confirm_apply_handler"))

	save_create_ready()


#Save Menu
func update_current_node_handler(_node: Node) -> void:
	current_save = _node

func _on_new_save_button_pressed() -> void:
	const _call: Dictionary = {
		"Создать": "save_menu_show",
		"Перезаписать": "confirm_overwtite"
	}
	call(_call[SaveButton.text])

func confirm_overwtite() -> void:
	Confirm.set_text("Вы уверены, что хотите перезаписать \nсохранение? \nЭто действие нельзя отменить!")
	Confirm.confirm_show("Overwrite")
	SaveMenu.hide()


func save_menu_show() -> void:
	if not SaveMenu.visible:
		SaveMenu.animate_and_show()
		Confirm.hide()
	else:
		SaveMenu.animate_and_hide()


#Save Slot 
func enable_buttons() -> void:
	await get_tree().create_timer(0.13).timeout
	set_text_save_button("Перезаписать")
	DeleteButton.disabled = false
	LoadButton.disabled = false
	

func disable_buttons() -> void:
	await get_tree().create_timer(0.13).timeout
	set_text_save_button("Создать")
	DeleteButton.disabled = true
	LoadButton.disabled = true


func set_text_save_button(_text: String) -> void:
	SaveButton.text = _text


#Create visual save
func create_new_save_handler(_name: String) -> void:
	var names: String = get_unique_save_name(_name)
	SaveSustem.emit_signal("save", names)
	create_visual_save(names, true)


func create_visual_save(_name: String, is_ready: bool) -> void:
	var inst_slot: Node = SaveSlot.instantiate()
	inst_slot.name = _name
	inst_slot.custom_minimum_size = Vector2(375.135, 70.185)
	if is_ready:
		inst_slot._image = await image_screen(_name)
		inst_slot.update_time_ready()
	else:
		inst_slot.update_time_json()
		inst_slot._image = image_load(_name)

	SaveList.add_child(inst_slot)


func image_load(_name: String) ->  Texture2D:
	var path: String = SaveSustem.get_save_file_path(_name, "save_image", ".jpg")
	print(path)
	if FileAccess.file_exists(path):
		var image: Image = Image.new()
		image.load(path)
		return ImageTexture.create_from_image(image)
	return


#Create unique save name
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


#Delete save visual
func _on_delete_pressed() -> void:
	Confirm.set_text("Вы уверены, что хотите удалить \nсохранение? \nЭто действие нельзя отменить!")
	Confirm.confirm_show("Delete")
	SaveMenu.hide()

func delete_visual_save() -> void:
	if current_save:
		SaveList.remove_child(current_save)
		current_save.call_deferred("queue_free")
		current_save = null
	else:
		return


#Overwrite save
func overwrite_save() -> void:
	SaveSustem.emit_signal("save", current_save.name)
	current_save._image = await image_screen(current_save.name)
	current_save = null
	

#call confirm
func confirm_apply_handler(_mode) -> void:
	const mode: Dictionary = {
		"Delete": "delete",
		"Overwrite": 'overwrite',
		"Load": "load"
	}
	call(mode[_mode])

func delete() -> void:
	SaveSustem.emit_signal("delete", current_save.name)
	delete_visual_save()

func overwrite() -> void:
	current_save.update_time_ready()
	overwrite_save()

func load() -> void:
	get_parent().get_owner().color_rect_show()
	SaveSustem.emit_signal("load", current_save.name)
	


#load save
func _on_load_pressed() -> void:
	Confirm.set_text("Вы уверены, что хотите загрузить \nсохранение? \nВсе не сохраненные данные будут потеряны!")
	Confirm.confirm_show("Load")


#Hided self - save menu
func _on_cancel_pressed() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.1), 0.15) 
	tween.tween_property(self, "position:x", -240, 0.2)
	await tween.finished
	self.hide()


#Ready add save to save list
func save_create_ready() -> void:
	for save_name in SaveSustem.get_files_in_directory(SaveSustem.SAVE_PATH):
		print(save_name)
		create_visual_save(save_name, false) 

#Save image add
func image_screen(_name: String) -> Texture2D:
	var path: String = SaveSustem.get_save_file_path(_name, "save_image", ".jpg")

	get_parent().get_owner().hide_canvas()
	await RenderingServer.frame_post_draw
	var image: Image  = get_viewport().get_texture().get_image()
	image.save_jpg(path)
	get_parent().get_owner().show_canvas()
	return ImageTexture.create_from_image(image)

func set_image_save(_texture: Texture2D) -> void:
	SaveImage.texture = _texture


func set_missions_text(_text: String) -> void: # в будущем будет
	pass
