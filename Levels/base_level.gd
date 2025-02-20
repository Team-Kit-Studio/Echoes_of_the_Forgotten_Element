extends Node2D

func saves() -> Dictionary:
	print(1111)
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
	SaveSustem.save_game(data)
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

	var player: Node = $Objects/Players/Player
	$Objects/Players.remove_child(player)
	player.queue_free()


