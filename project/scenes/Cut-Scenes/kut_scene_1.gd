extends Node2D

@onready var Anim: AnimationPlayer = $AnimationPlayer
@onready var level_1: Node2D = preload("res://project/scenes/levels/Level_1/Level_1.tscn").instantiate()

func _ready() -> void:
	if Global.to_cutscene:
		Anim.play("Start_Game")
		
func continue_cutscene() -> void:
	get_tree().change_scene_to_node(level_1)
