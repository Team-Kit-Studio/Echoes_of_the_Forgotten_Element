extends Node

signal load(_name: String)
signal save(_name: String)
signal delete(_name: String)

signal set_data(data: Dictionary)
signal set_metadata(metadata: Dictionary)

signal save_data()
signal load_from_data(data: Dictionary)


const SAVE_PATH: String = "user://saves/" 

var data_save: Dictionary = {}
var metadata_save: Dictionary = {}


func _ready() -> void:
	self.load.connect(load_handler)
	self.save.connect(save_handler)
	self.delete.connect(delete_hanlder)
	self.set_data.connect(set_data_handler)
	self.set_metadata.connect(set_metadata_handler)

	create_folder_ready()

# Methods for working with paths and directories
#Блок функций
func create_folder_ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)

func folder_exists(_name: String) -> void:
	var path: String = SAVE_PATH + _name
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)

	else:
		return

func get_files_in_directory(directory_path: String) -> Array:
	var dir: DirAccess = DirAccess.open(directory_path)
	return dir.get_directories()

func get_save_folder_path(floder_name: String) -> String:
	return "%s%s/" % [SAVE_PATH, floder_name]

func get_save_file_path(floder_name: String, file_name: String, extension: String) -> String:
	return "%s%s%s" % [get_save_folder_path(floder_name), file_name, extension]
# Блок функций

#Signal handler
func load_handler(_name: String) -> void:
	read_save(_name, "data", ".save")

func save_handler(_name: String) -> void:
	save_to_files(_name)

func delete_hanlder(_name: String) -> void:
	delete_floder_save(_name)
	delete_save_image(_name)


# Read save to load level 
func set_data_handler(data: Dictionary) -> void:
	data_save = data

func set_metadata_handler(metadata: Dictionary) -> void:
	metadata_save = metadata
	print(metadata_save)


# Save game from level data
func save_to_files(_name: String) -> void:
	folder_exists(_name)
	self.emit_signal("save_data")
	var path: String = get_save_file_path(_name, "data", ".save")
	var file_data: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var save_template: SavesTemplate.BaseSaveTemplate = SavesTemplate.BaseSaveTemplate.new()
	save_template.save["data"] = data_save
	if FileAccess.get_open_error() == OK:
		file_data.store_string(JSON.stringify(save_template.save["data"], "\t"))
		save_metadata_to_file(_name, metadata_save)
		file_data.close()

	else:
		return

func save_metadata_to_file(floder_name: String,metadata: Dictionary) -> void:
	var path: String = get_save_file_path(floder_name, "metadata", ".json")
	var file_metadata: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file_metadata.store_string(JSON.stringify(metadata))
	
	else: 
		return

func read_save(floder_name: String, file_name: String,extension: String) -> Dictionary:
	var path: String = get_save_file_path(floder_name, file_name, extension)
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		self.emit_signal("load_from_data", data)
		return data

	else:
		return {}


#Delete save
func delete_floder_save(_name: String) -> void:
	var path: String = get_save_folder_path(_name)
	var dir := DirAccess.open(path)
	if dir:
		var files = dir.get_files()
		# var subdirs = dir.get_directories()

		for file in files:
			dir.remove(path + "/" + file)
		# for subdir in subdirs:
		# 	delete_floder_save(path + "/" + subdir) Это разкоментить когда появяться подпапки в сохранении

		dir.remove(path)


func delete_save_image(_name: String) -> void:
	var path_image: String = get_save_file_path(_name, "image", ".jpg")
	if FileAccess.file_exists(path_image):
		DirAccess.remove_absolute(path_image)
	
	else:
		return
