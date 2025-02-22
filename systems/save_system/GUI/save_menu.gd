extends Control

signal update_current_node(_node: Node)
signal create_new_save(_name: String)

@onready var SaveMenu: Control = $NewSave
@onready var Confirm: Control = $Confirm
@onready var LoadButton: Button = $Panel/Load
@onready var DeleteButton: Button = $Panel/Delete
@onready var SaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV
@onready var SaveImage: TextureRect = $Panel/SaveImage

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
	if SaveButton.text == "Создать":
		if not SaveMenu.visible:
			SaveMenu.animate_and_show()
			Confirm.hide()
		else:
			SaveMenu.animate_and_hide()
	else:
		Confirm.set_text("Вы уверены, что хотите перезаписать \nсохранение? \nЭто действие нельзя отменить!")
		Confirm.confirm_show("Overwrite")
		SaveMenu.hide()


#Save Slot 
func enable_buttons() -> void:
	await get_tree().create_timer(0.11).timeout
	set_text_save_button("Перезаписать")
	DeleteButton.disabled = false
	LoadButton.disabled = false
	
func disable_buttons() -> void:
	await get_tree().create_timer(0.11).timeout
	set_text_save_button("Создать")
	DeleteButton.disabled = true
	LoadButton.disabled = true

func set_text_save_button(_text: String) -> void:
	SaveButton.text = _text


#Create visual save
func create_new_save_handler(_name: String) -> void:
	var names: String = get_unique_save_name(_name)
	SaveSustem.save_game(names)
	create_visual_save(names, true)
   


func create_visual_save(_name: String, is_time_update: bool) -> void:
	var inst_slot: Node = SaveSlot.instantiate()
	inst_slot.name = _name
	inst_slot.custom_minimum_size = Vector2(375.135, 70.185)
	if is_time_update:
		inst_slot._image = await image_screen(_name)
		inst_slot.update_time_ready()
	else:
		inst_slot.update_time_json()
		var image: Image = Image.new()
		image.load(Gvars.SAVES_BACKGROUNG_PATH + _name + ".jpg")
		inst_slot._image = ImageTexture.create_from_image(image)
	SaveList.add_child(inst_slot)


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
	else:
		pass


#Overwrite save
func overwrite_save() -> void:
	SaveSustem.save_game(current_save.name)
	current_save._image = await image_screen(current_save.name)
	


#call confirm
func confirm_apply_handler(_mode) -> void:
	if _mode == "Delete":
		delete_visual_save()
		SaveSustem.delete_save(current_save.name)
		SaveSustem.delete_jpg(current_save.name)

	elif _mode == "Overwrite":
		overwrite_save()
		current_save.update_time_ready()


#load save
func _on_load_pressed() -> void:
	if current_save:
		SaveSustem.read_save(current_save.name)



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
	for save in SaveSustem.get_files_in_directory(Gvars.SAVE_PATH):
		var save_name: String = remove_save_extension(save)
		create_visual_save(save_name, false) 

func remove_save_extension(file_name: String) -> String:
	return file_name.substr(0, file_name.length() - 5)

#Save image add
func image_screen(_name: String) -> Texture2D:
	var path: String = Gvars.SAVES_BACKGROUNG_PATH + _name + ".jpg"
	get_parent().get_owner().hide_canvas()
	await RenderingServer.frame_post_draw
	var image: Image  = get_viewport().get_texture().get_image()
	image.save_jpg(path)
	get_parent().get_owner().show_canvas()
	return ImageTexture.create_from_image(image)

func set_image_save(_texture: Texture2D) -> void:
	SaveImage.texture = _texture
