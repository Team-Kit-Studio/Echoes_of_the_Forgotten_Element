extends Node2D

func _ready() -> void:
	SaveSustem.current_level = self
	SaveSustem.load_from_data.connect(Callable(self, "load_from_data"))
	
func save_data() -> Dictionary:
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

	return data


func load_from_data(data: Dictionary) -> void:
	delete_node()
	if data:
		for enemy in data["data"]["enemy"]:
			pass

		for allies in data["data"]["allies"]:
			pass

		for items in data["data"]["items"]:
			pass

	load_player(data)

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

func load_player(data: Dictionary) -> void:
	var inst_player: Node = load(data["data"]["player"]["file_name"]).instantiate()
	inst_player.load_data(data["data"]["player"])
	inst_player.name = "Player"
	$Objects/Players.add_child(inst_player)