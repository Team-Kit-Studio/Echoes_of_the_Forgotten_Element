extends Node2D
func _ready() -> void:
	Persistence.array_save = get_tree().get_nodes_in_group("save_it")
