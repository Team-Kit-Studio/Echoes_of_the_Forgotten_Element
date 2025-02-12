class_name SaveSystem
extends Node

const save_path: String = "user://save/"

static func save_game(save_name: String = "default_save") -> void:
	var save_path: String = save_path + save_name + ".json"
	var file_save: SaveDataDefault = SaveDataDefault.new(save_path, Time.get_datetime_dict_from_system())
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file and file.get_open_error() == OK:
		print("Сохранение загружено: ", save_name + ".json")
		var count: int = 0
		for node in Persistence.array_save:
			var object: DefaultDataObject = DefaultDataObject.new(node.name, node, true, "save_it")
			var data: Dictionary = file_save.save["object_data"]
			if node.name:
				file_save.save["object_data"][object.object["metadata"]["object_name"]] = object.object
				data[node.name]["data"]["pos_x"] = node.position.x
				data[node.name]["data"]["pos_y"] = node.position.y
				if data.has("Player"):
					file_save.save["player_data"]["Player"] = {}
					file_save.save["player_data"]["Player"] = file_save.save["object_data"]["Player"]
			count += 1
			if count >= Persistence.array_save.size() and FileAccess.get_open_error() == OK:
				file.store_string(JSON.stringify(file_save.save, "\t"))
				file.close()
				count = 0
				
	else: 
		printerr("Ошибка")
		file.close()
		
		
static func save_load(save_name: String, _key_loaded: String) -> Dictionary:
	var save_path: String = save_path + save_name + ".json"
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	var content: Dictionary = JSON.parse_string(file.get_as_text())
	if FileAccess.get_open_error() == OK and content:
		for node in Persistence.array_save:
				var data: Dictionary = content["object_data"][node.name]["data"]
				node.position = Vector2(data["pos_x"], data["pos_y"])
				file.close()
	else:
		file.close()
	print(content["object_data"]["Player"])
	return content
	
	
