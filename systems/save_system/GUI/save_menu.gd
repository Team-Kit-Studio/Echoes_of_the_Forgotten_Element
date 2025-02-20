extends Control

signal update_current_node(_node: Node)
signal create_new_visual_save(_name: String)

@onready var SaveMenu: Control = $NewSave
@onready var Confirm: Control = $Confirm
@onready var LoadButton: Button = $Panel/Load
@onready var DeleteButton: Button = $Panel/Delete
@onready var SaveButton: Button = $Panel/NewSaveButton
@onready var SaveList: VBoxContainer = $Panel/VBoxContainer/MarginContainer/ScrollContainer/SaveListH/SavelistV

var SaveSlot: Resource = preload("res://systems/save_system/GUI/SaveSlot.tscn")

var current_save: Node
var save_name: String

func _ready():
    self.create_new_visual_save.connect(Callable(self, "create_new_visual_save_handler"))
    self.update_current_node.connect(Callable(self, "update_current_node_handler"))

    Confirm.confirm_apply.connect(Callable(self, "confirm_apply_handler"))


#SaveMenu
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


#SaveSlot 
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
func create_new_visual_save_handler(_name: String) -> void:
    create_visual_save(_name)

func create_visual_save(_name: String) -> void:
    var inst_slot: Node = SaveSlot.instantiate()
    inst_slot.name = get_unique_save_name(_name)
    inst_slot.custom_minimum_size = Vector2(375.135, 70.185)
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
        return


#Overwrite save
func overwrite_save() -> void:
    pass


#call confirm
func confirm_apply_handler(_mode) -> void:
    if _mode == "Delete":
        delete_visual_save()

    elif _mode == "Overwrite":
        pass
