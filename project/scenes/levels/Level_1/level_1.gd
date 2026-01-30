extends Node2D

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	SavesManager.load_from_data.connect(load_from_data)
	SavesManager.data_update.connect(self_objects_saves)
	Play_Music("res://project/assets/sounds/music/Sound_Game_Background.mp3")
	
#реализует систему сохранения состояния сцены
func self_objects_saves() -> void:
	var game_data: Dictionary = {
		"level_scene": scene_file_path,
		"player": $"1_floor/Entity/Player".data()
	}
	
	var metadata: Dictionary = {
		"name": name,
		"last_modified_date": Time.get_date_dict_from_system(),
		"last_modified_time": Time.get_time_dict_from_system()
	}
	
	# Передаем данные напрямую (без лишней вложенности)
	SavesManager.emit_signal("data_updated", game_data, metadata)

	#for enemy: Node in $Objects/Enemy.get_children():
	#	if enemy.data(): temp["data"]["enemy"].append(enemy.data())
	#	
	#for allies: Node in $Objects/Allies.get_children():
	#	if allies.data(): temp["data"]["allies"].append(allies.data())
	#	
	#for items: Node in $Items.get_children():
	#	if items.data(): temp["data"]["items"].append(items.data())
		




#загружает состояние сцены из сохраненных данных.
func load_from_data(data: Dictionary) -> void:
	if not data.has("player"):
		return
	
	# Удаляем старого игрока
	var old_player = get_node_or_null("1_floor/Entity/Player")
	if old_player:
		old_player.get_parent().remove_child(old_player)
		old_player.queue_free()
	
	# Загружаем нового
	load_player(data.player)


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

#загружает и восстанавливает состояние игрока из сохраненных данных
func load_player(player_data: Dictionary) -> void:
	var player_scene = load(player_data.file_name)
	if not player_scene:
		push_error("Не удалось загрузить сцену игрока: " + str(player_data.file_name))
		return
	
	var inst_player = player_scene.instantiate()
	
	# Добавляем в правильное место
	var entity_parent = get_node_or_null("1_floor/Entity")
	if entity_parent:
		entity_parent.add_child(inst_player)
	else:
		add_child(inst_player)
	
	inst_player.name = "Player"
	inst_player.call_deferred("load_data", player_data)


func Play_Music(path: String) -> void:
	var stream = load(path)
	if audio.playing:
		return
	
	if stream is AudioStream:
		audio.stream = stream
		audio.play()
	else:
		push_error("Ошибка загрузки музыки")
