class_name SaveSystem
extends Node

signal load_game(data: Dictionary)

var current_level: Node



func  _ready() -> void:
	if not DirAccess.dir_exists_absolute(Gvars.SAVE_PATH):
		DirAccess.make_dir_absolute(Gvars.SAVE_PATH)


func delete_save(_name: String) -> void:
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)	
	else:
		print("Error: Файл не существует")
		return
		

func get_files_in_directory(directory_path: String) -> Array:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(directory_path)
	if not dir:
		push_error("Не удалось открыть директорию: " + directory_path)
		return files

	dir.list_dir_begin()  
	var file_name: String = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			files.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return files
	

func read_save(_name: String) -> Dictionary:
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		self.emit_signal("load_game", data)
		return data
	else:
		return {}


func save_game(_name: String) -> void:
	var data: Dictionary
	if current_level:
		data = current_level.save_data()
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var temp: DefaultSave = DefaultSave.new(_name)
	temp.data["data"] = data
	temp.data["info"]["current_scene"] = current_level
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(temp.data, "\t"))
	else:
		return	
