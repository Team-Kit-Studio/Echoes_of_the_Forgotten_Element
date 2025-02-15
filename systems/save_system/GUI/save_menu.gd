extends Control

@onready var game_menu = preload("res://systems/Game_Menu/game_menu.tscn")
@onready var add_save = preload("res://systems/save_system/GUI/SaveSlot.tscn")
@onready var ApplyButon = preload("res://systems/save_system/GUI/NewSave.tscn")
@onready var NewSave: Control = $NewSave
@onready var SaveMenu: Control = $"."
@onready var SaveLoad_Game: Button = $"../../Main_Menu/PanelContainer/HBoxContainer/VBoxContainer/SaveLoad Game"
var button_instance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_instance = ApplyButon.instantiate()
	add_child(button_instance)
	
	#button_instance.connect("create_item_pressed", self, "_on_Create_Item_Pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_save_pressed() -> void:
	if NewSave.visible == false:
		NewSave.show()
		var tween = get_tree().create_tween()
		NewSave.scale = Vector2(0.3, 0.3)
		tween.tween_property(NewSave, "scale", Vector2(1,1), 0.1)
		


func _on_cancel_pressed() -> void:
	#var gameMenu: Node = game_menu.instantiate()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(SaveMenu, "position:x", -240, 0.2)
	tween.tween_property(SaveMenu, "modulate", Color(1, 1, 1, 0.1), 0.15) 
	tween.set_parallel(false)
	tween.tween_property(NewSave, "scale", Vector2(0.4, 0.4), 0.1)
	await tween.finished
	NewSave.hide()
	SaveMenu.hide()
	SaveLoad_Game.button_pressed = false

func _on_Create_Item_Pressed():
	pass



func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	pass # Replace with function body.
