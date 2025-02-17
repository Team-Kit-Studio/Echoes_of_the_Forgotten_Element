class_name SaveSystem
extends Node

signal create_a_save(_name: String)
signal delete_a_save(_name: String)

func  _ready() -> void:
	if not DirAccess.dir_exists_absolute(Gvars.SAVE_PATH):
		DirAccess.make_dir_absolute(Gvars.SAVE_PATH)
	self.create_a_save.connect(Callable(self, "create_save"))
	self.delete_a_save.connect(Callable(self, "delete_save"))

func create_save(_name: String) -> void:
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	var Save: DefaultSave = DefaultSave.new(_name)
	if not FileAccess.file_exists(path):
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if FileAccess.get_open_error() == OK:
			file.store_string(JSON.stringify(Save.data.duplicate(), "\t"))
			file.close()
		else:
			return
	else:
		return


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