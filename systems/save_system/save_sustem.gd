extends Node

signal load(_name: String)
signal save(_name: String)
signal delete(_name: String)

signal set_data(data: Dictionary)
signal save_data()
signal load_from_data(data: Dictionary)

const SAVE_PATH: String = "user://saves/" 

var data_save: Dictionary = {}

#Create Floader
func  _ready() -> void:
	self.load.connect(load_handler)
	self.save.connect(save_handler)
	self.delete.connect(delete_hanlder)
	self.set_data.connect(set_data_handler)

	create_folder_ready()

func create_folder_ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)

#Path to save
func path_floder_save(_name: String) -> String:
	return SAVE_PATH + _name + "/"

func path_file_save(floder_name: String, file_name: String, extension: String) -> String:
	return SAVE_PATH + floder_name + "/" + file_name + extension

#Delete save
func delete_save(_name: String) -> void:
	var path: String = path_floder_save(_name)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func delete_image(_name: String) -> void:
	var path_image: String = path_file_save(_name, "image", ".jpg")
	if FileAccess.file_exists(path_image):
		DirAccess.remove_absolute(path_image)


#Get files in directory to create ready save
func get_files_in_directory(directory_path: String) -> Array:
	# var files: Array = []
	var dir: DirAccess = DirAccess.open(directory_path)
	# if not dir:
	# 	push_error("Не удалось открыть директорию: " + directory_path)
	# 	return files
	

	# dir.list_dir_begin()  
	# var file_name: String = dir.get_next()

	# while file_name != "":
	# 	if not dir.current_is_dir():
	# 		files.append(file_name)
	# 	file_name = dir.get_next()

	# dir.list_dir_end()
	return dir.get_directories()
	
# Read save to load level 
func set_data_handler(data: Dictionary) -> void:
	data_save = data
	print(data)

func read_save(_name: String) -> Dictionary:
	var path: String = path_file_save(_name, "data", ".save")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		self.emit_signal("load_from_data", data)
		return data
	else:
		return {}

# Save game from level data
func save_to_files(_name: String) -> void:
	folder_exists(_name)
	var path: String = path_file_save(_name, "data", ".save")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var temp: DefaultSave = DefaultSave.new(_name)
	self.emit_signal("save_data")
	temp.data["data"] = data_save
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(temp.data, "\t"))
		file.close()
	else:
		return	

func folder_exists(_name: String) -> void:
	var path: String = SAVE_PATH + _name
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)

#Signal handler
func load_handler(_name: String) -> void:
	read_save(_name)

func save_handler(_name: String) -> void:
	save_to_files(_name)

func delete_hanlder(_name: String) -> void:
	delete_save(_name)
	delete_image(_name)
