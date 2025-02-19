extends Node2D

signal update_current_save(node: Node)

var current_save: Node
func _ready():
	self.update_current_save.connect(Callable(self, "update_current_node"))

func update_current_node(node: Node) -> void:
	current_save = node

func saves() -> Dictionary:
	var data: Dictionary = {
		"player": $Objects/Players/Player.data(),
		"enemy": [],
		"allies": [],
		"items": []
	}
	
	for enemy in $Objects/Enemy.get_children():
		if enemy.data():
			data["enemy"].append(enemy.data())

	for allies in $Objects/Allies.get_children():
		if allies.data():
			data["allies"].append(allies.data())
	
	for items in $Items.get_children():
		if items.data():
			data["items"].append(items.data())
	SaveSustem.save_game(data, "penis")
	return data

func load_from_data(data: Dictionary) -> void:
	delete_node()

	for enemy in data["enemy"]:
		pass

	for allies in data["allies"]:
		pass

	for items in data["items"]:
		pass

func delete_node() -> void:
	for enemy in $Objects/Enemy.get_children():
		$Objects/Enemy.remove_child(enemy)
		enemy.queue_free()

	for allies in $Objects/Allies.get_children():
		$Objects/Allies.remove_child(allies)
		allies.queue_free()


	for items in $Items.get_children():
		$Items.remove_child(items)
		items.queue_free()
	$Objects/Players.remove_child($Objects/Players/Player)
	$Objects/Players/Player.queue_free()

