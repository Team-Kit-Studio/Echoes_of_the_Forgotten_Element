class_name SaveSystem
extends Node

const path_floder: String = "user://save/"

static func save_game(save_name: String = "default_save") -> void:
	var save_path: String = path_floder + save_name + ".json"
	var file_save: SaveDataDefault = SaveDataDefault.new(save_name + ".json", Time.get_datetime_dict_from_system())
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file and FileAccess.get_open_error() == OK:
		var count: int = 0
		print("Сохранение успешно: ", save_path)
		for node in Persistence.array_save:
			add_object(file_save, node.name, node, true, "save_it")
			file_save.data["level_data"]["list_objects"][node.name]["obj_data"]["pos_x"] = node.position.x
			file_save.data["level_data"]["list_objects"][node.name]["obj_data"]["pos_y"] = node.position.y
			count += 1
			if count >= Persistence.array_save.size() and FileAccess.get_open_error() == OK:
				file.store_string(JSON.stringify(file_save.data, "\t"))
				file.close()
				count = 0
				
	else: 
		printerr("Ошибка")
		file.close()
		
		
static func save_load(save_name: String, _key_loaded: String) -> Dictionary:
	var save_path: String = path_floder + save_name + ".json"
	var file: FileAccess 
	var content: Dictionary = {} 
	if FileAccess.file_exists(save_path):
		file = FileAccess.open(save_path, FileAccess.READ)
		if FileAccess.get_open_error() == OK:
			content = JSON.parse_string(file.get_as_text())
			for node in Persistence.array_save:
				var obj_data: Dictionary = content["level_data"]["list_objects"][node.name]
				node.position = Vector2(obj_data["obj_data"]["pos_x"], obj_data["obj_data"]["pos_y"])
				file.close()
				print("Загрузка сохранения успешна: ", save_path )
				return content
		else:
			file.close()
	else:
		print("Сохранения не существует")
		return {}
	return {}

static func add_object(file_save: SaveDataDefault, obj_name: String, node: Node, instance: bool, group_name: String) -> Dictionary:
	var obj: DefaultDataObject = DefaultDataObject.new(obj_name, node, instance, group_name)
	file_save.data["level_data"]["list_objects"][obj_name] = obj.object
	return obj.object
	
