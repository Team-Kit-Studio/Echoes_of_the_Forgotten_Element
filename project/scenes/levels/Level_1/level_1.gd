extends Node2D

@onready var Inventory: Node = $UI/Inventory
@export var block: Dictionary[String, BlockData]
var currently_equipped: Item = null



func _on_corridor_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Corridor True")
		explore_territory("corridor", 0)

func explore_territory(room: String, state: float) -> void:
	for points in get_tree().get_nodes_in_group(room):
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(points, "energy", state, 1)


func _on_spawn_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Spawn true")
		explore_territory("spawn", 0)


func _on_corridor_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("Corridor False")
		explore_territory("corridor", 0.97)


func _on_spawn_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("Spawn False")
		explore_territory("spawn", 0.97)
