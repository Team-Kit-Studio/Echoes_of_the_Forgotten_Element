extends Node2D

func _ready() -> void:
	SaveSustem.load_from_data.connect(load_from_data)
	SaveSustem.save_data.connect(_data)
	
func _data() -> void:
	var temp: SavesTemplate.BaseDataSaveTemplate = SavesTemplate.BaseDataSaveTemplate.new() 

	temp.data["data"]["level_scene"] = self.scene_file_path
	temp.data["data"]["player"] = $Objects/Players/Player.data()
	
	temp.data["metadata"]["name"] = self.name
	temp.data["metadata"]["last_modified_time"]["date"] = Time.get_date_dict_from_system()
	temp.data["metadata"]["last_modified_time"]["time"] = Time.get_time_dict_from_system()

	for enemy in $Objects/Enemy.get_children():
		if enemy.data():
			temp["data"]["enemy"].append(enemy.data())

	for allies in $Objects/Allies.get_children():
		if allies.data():
			temp["data"]["allies"].append(allies.data())

	for items in $Items.get_children():
		if items.data():
			temp["data"]["items"].append(items.data())

	SaveSustem.emit_signal("set_data", temp.data["data"])
	SaveSustem.emit_signal("set_metadata", temp.data["metadata"])

func load_from_data(data: Dictionary) -> void:
	delete_node()
	if data:
		for enemy in data["enemy"]:
			pass

		for allies in data["allies"]:
			pass

		for items in data["items"]:
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

	var player: CharacterBody2D = $Objects/Players/Player
	$Objects/Players.remove_child(player)
	player.queue_free()

func load_player(data: Dictionary) -> void:
	var inst_player: Node = load(data["player"]["file_name"]).instantiate()
	inst_player.load_data(data["player"])
	inst_player.name = "Player"
	$Objects/Players.add_child(inst_player)
