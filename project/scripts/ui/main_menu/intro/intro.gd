extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var main_menu: Node2D = preload("res://project/scenes/ui/main_menu/Main_Menu.tscn").instantiate()


func _ready() -> void:
	anim.play("intro")



func to_main() -> void:
	get_tree().change_scene_to_node(main_menu)
