extends Node2D


@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D





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

func _ready() -> void:
	SavesManager.load_from_data.connect(load_from_data)
	SavesManager.data_update.connect(self_objects_saves)
	Play_Music("res://project/assets/sounds/music/Sound_Game_Background.mp3")
	
func self_objects_saves() -> void:
	var temp: SavesTemplate.DataTemp = SavesTemplate.DataTemp.new() 
	var temp_matadata: SavesTemplate.MetaDataTemp = SavesTemplate.MetaDataTemp.new()

	temp.data["data"]["level_scene"] = self.scene_file_path
	temp.data["data"]["player"] = $Player.data()
	
	temp_matadata.data["metadata"]["name"] = self.name
	temp_matadata.data["metadata"]["last_modified_time"]["date"] = Time.get_date_dict_from_system()
	temp_matadata.data["metadata"]["last_modified_time"]["time"] = Time.get_time_dict_from_system()

	#for enemy: Node in $Objects/Enemy.get_children():
	#	if enemy.data(): temp["data"]["enemy"].append(enemy.data())
	#	
	#for allies: Node in $Objects/Allies.get_children():
	#	if allies.data(): temp["data"]["allies"].append(allies.data())
	#	
	#for items: Node in $Items.get_children():
	#	if items.data(): temp["data"]["items"].append(items.data())
		
	SavesManager.emit_signal("data_updated", temp.data["data"], temp_matadata.data["metadata"])
	temp = null
	temp_matadata = null





func load_from_data(data: Dictionary) -> void:
	if data:
		delete_node()
		for enemy: Dictionary in data["enemy"]:
			pass

		for allies: Dictionary in data["allies"]:
			pass

		for items: Dictionary in data["items"]:
			pass

		load_player(data)

func delete_node() -> void:
#	for enemy: Node in $Objects/Enemy.get_children():
#		$Objects/Enemy.remove_child(enemy)
#		enemy.queue_free()
#
#	for allies: Node in $Objects/Allies.get_children():
#		$Objects/Allies.remove_child(allies)
#		allies.queue_free()
#
#
#	for items: Node in $Items.get_children():
#		$Items.remove_child(items)
#		items.queue_free()

	var player: CharacterBody2D = $Player
	$Player.remove_child(player)
	player.queue_free()

func load_player(data: Dictionary) -> void:
	var inst_player: Node = load(data["player"]["file_name"]).instantiate()
	add_child(inst_player)
	inst_player.call_deferred("load_data", data["player"])
	inst_player.name = "Player"

func Play_Music(path: String) -> void:
	var stream = load(path)
	if audio.playing:
		return
	
	if stream is AudioStream:
		audio.stream = stream
		audio.play()
	else:
		push_error("Ошибка загрузки музыки")
