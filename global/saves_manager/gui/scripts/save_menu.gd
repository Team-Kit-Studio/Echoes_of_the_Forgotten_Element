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

var SaveSlot: Resource = preload("res://global/saves_manager/gui/scenes/SaveSlot.tscn")

var game_menu: Node 
var current_save: Node

func _ready() -> void:
	game_menu = get_parent().get_owner()

	self.create_new_save.connect(create_new_save_handler)
	self.update_current_node.connect(update_current_node_handler)
	Confirm.confirm_apply.connect(confirm_apply_handler)

	save_create_ready()

# Handlers
func update_current_node_handler(_node: Node) -> void:
	current_save = _node

func create_new_save_handler(save_name: String) -> void:
	var _name: String = get_unique_save_name(save_name)
	SavesManager.emit_signal("save", _name)
	create_visual_save(_name, true)

func confirm_apply_handler(_mode: String) -> void:
	const mode: Dictionary[String, String] = {
		"Delete": "delete",
		"Overwrite": 'overwrite',
		"Load": "load"
	}

	call(mode[_mode])

# Save Menu
func _on_new_save_button_pressed() -> void:
	const _call: Dictionary[String, String] = {
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

func _on_cancel_pressed() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.1), 0.15) 
	tween.tween_property(self, "position:x", -240, 0.2)
	await tween.finished
	self.hide()

# Save Slot 
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

# Create visual save
func create_visual_save(_name: String, is_ready: bool) -> void:
	var inst_slot: Node = SaveSlot.instantiate()
	inst_slot.name = _name
	inst_slot.custom_minimum_size = Vector2(375.135, 70.185)
	if is_ready:
		inst_slot.image_save = await screen_shot(_name)
		inst_slot.update_time_ready()
	else:
		inst_slot.update_time_json()
		inst_slot.image_save = ImageTexture.create_from_image(ScreenshotManager.load_image(SavesManager.SAVE_PATH, _name + "/image", ".jpg"))


	SaveList.add_child(inst_slot)

func save_create_ready() -> void:
	for save_name: String in DirUtil.get_files_in_directory(SavesManager.SAVE_PATH):
		create_visual_save(save_name, false)

# Create unique save name
func get_unique_save_name(base_name: String) -> String:
	var _name: String = base_name
	var counter: int = 1
	while find_save(_name) != null:
		_name = base_name + "-(" + str(counter) + ")"
		counter += 1
	return _name

func find_save(_name: String) -> Node:
	for node: Node in SaveList.get_children():
		if node.name == _name:
			return node
	return null

# Delete save visual
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

func delete() -> void:
	SavesManager.emit_signal("delete", current_save.name)
	delete_visual_save()

# Overwrite save
func overwrite_save() -> void:
	SavesManager.emit_signal("save", current_save.name)
	current_save = null

func overwrite() -> void:
	current_save.update_time_ready()
	overwrite_save()

# Load save
func load() -> void:
	game_menu.color_rect_show()
	SavesManager.emit_signal("load", current_save.name)
	SaveList.move_child(current_save, 0)
	reset_scroll()
	
func _on_load_pressed() -> void:
	Confirm.set_text("Вы уверены, что хотите загрузить \nсохранение? \nВсе не сохраненные данные будут потеряны!")
	Confirm.confirm_show("Load")

func screen_shot(folder_name: String) -> Texture2D:
	game_menu.hide_canvas()
	await RenderingServer.frame_post_draw
	var image: Image = ScreenshotManager.save_image(PathManager.build_path(SavesManager.SAVE_PATH + folder_name, "/image", ".jpg"), get_viewport().get_texture().get_image())
	game_menu.show_canvas()

	return ImageTexture.create_from_image(image)

func set_save_image(texture: Texture2D) -> void:
	SaveImage.texture = texture

func reset_scroll() -> void:
	$Panel/VBoxContainer/MarginContainer/ScrollContainer.set_deferred("scroll_vertical", 0)
