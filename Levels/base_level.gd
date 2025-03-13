extends Node2D

func _ready() -> void:
	SavesManager.load_from_data.connect(load_from_data)
	SavesManager.data_update.connect(_data)
	
func _data() -> void:
	var temp: SavesTemplate.DataTemp = SavesTemplate.DataTemp.new() 
	var temp_matadata: SavesTemplate.MetaDataTemp = SavesTemplate.MetaDataTemp.new()

	temp.data["data"]["level_scene"] = self.scene_file_path
	temp.data["data"]["player"] = $Objects/Players/Player.data()
	
	temp_matadata.data["metadata"]["name"] = self.name
	temp_matadata.data["metadata"]["last_modified_time"]["date"] = Time.get_date_dict_from_system()
	temp_matadata.data["metadata"]["last_modified_time"]["time"] = Time.get_time_dict_from_system()


	for enemy: Node in $Objects/Enemy.get_children():
		if enemy.data():
			temp["data"]["enemy"].append(enemy.data())

	for allies: Node in $Objects/Allies.get_children():
		if allies.data():
			temp["data"]["allies"].append(allies.data())

	for items: Node in $Items.get_children():
		if items.data():
			temp["data"]["items"].append(items.data())


	SavesManager.emit_signal("data_updated", temp.data["data"], temp_matadata.data["metadata"])
	temp = null
	temp_matadata = null


func load_from_data(data: Dictionary) -> void:
	delete_node()
	if data:
		for enemy: Dictionary in data["enemy"]:
			pass

		for allies: Dictionary in data["allies"]:
			pass

		for items: Dictionary in data["items"]:
			pass

	load_player(data)

func delete_node() -> void:
	for enemy: Node in $Objects/Enemy.get_children():
		$Objects/Enemy.remove_child(enemy)
		enemy.queue_free()

	for allies: Node in $Objects/Allies.get_children():
		$Objects/Allies.remove_child(allies)
		allies.queue_free()


	for items: Node in $Items.get_children():
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
