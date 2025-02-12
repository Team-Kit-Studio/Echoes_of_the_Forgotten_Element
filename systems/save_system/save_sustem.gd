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
			count += 1 
			var object: DefaultDataObject = DefaultDataObject.new(node.name, node, true, "save_it")
			file_save.save["object_data"][object.object["metadata"]["object_name"]] = object.object
			if file_save.save["object_data"].has("Player"):
				file_save.save["player_data"]["Player"] = {}
				file_save.save["player_data"]["Player"] = file_save.save["object_data"]["Player"]
			if count >= Persistence.array_save.size():
				file.store_string(JSON.stringify(file_save.save, "\t"))
				file.close()
	else: 
		printerr("Ошибка")
		file.close()

	
