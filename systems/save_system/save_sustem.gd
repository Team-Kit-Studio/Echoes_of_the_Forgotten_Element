class_name SaveSystem
extends Node

signal create_new_saves(_name: String)
signal delete_a_save(_name: String)

var current_save: Node

func  _ready() -> void:
	self.create_new_saves.connect(Callable(self, "create_new_save"))
	self.delete_a_save.connect(Callable(self, "delete_save"))


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
	
func create_new_save(_name: String) -> void:
	var file: FileAccess = FileAccess.open(Gvars.SAVE_PATH + _name + ".save", FileAccess.WRITE)
	file.close()

func save_game(data: Dictionary) -> void:
	var path: String = Gvars.SAVE_PATH + current_save.name + ".save"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var temp: DefaultSave = DefaultSave.new(current_save.name)
	temp.data["data"] = data
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(temp.data, "\t"))
		file.close()
	else:
		return

func read_save(_name: String) -> Dictionary:
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		if data:
			return data
	else:
		return {}
	return {}
