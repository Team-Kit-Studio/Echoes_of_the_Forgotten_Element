extends Node 

signal load(folder_name: String)
signal save(folder_name: String)
signal delete(folder_name: String)

signal data_updated(data: Dictionary, metadata: Dictionary)
signal data_update

signal load_from_data(data: Dictionary)


# const Main.SAVE_FOLDER_PATH: StringName = "user://saves/"
# const SAVE_LIST_PATH: StringName = "user://saves/_saves_list.cfg"

var save_data: PrivateSaveData

# Функция, вызываемая при готовности узла
func _ready() -> void:
	self.load.connect(func(file_path: String) -> void: game_load_from_file(file_path))
	self.save.connect(func(folder_name: String) -> void: self.emit_signal("data_update"); game_save_to_file(folder_name))
	self.delete.connect(func(folder_name: String) -> void: DirUtil.delete_folder_recursively(Main.SAVE_FOLDER_PATH + folder_name))
	self.data_updated.connect(data_update_handler)
	
func _physics_process(delta: float) -> void:
	print

# Обработчик сигнала сохранения
func save_handler(folder_name: String) -> void:
	self.emit_signal("data_update")
	game_save_to_file(folder_name)

# Обработчик сигнала обновления данных
func data_update_handler(data: Dictionary, metadata: Dictionary) -> void:
	save_data = PrivateSaveData.new()
	save_data.data = data
	save_data.metadata = metadata

# Сохранение данных игры в файл
func game_save_to_file(folder_name: String) -> void:
	var path: String = PathManager.build_directory_path(Main.SAVE_FOLDER_PATH, folder_name)
	if not DirUtil.get_directory(Main.SAVE_FOLDER_PATH).size() >= Main.SAVES_LIMIT:
		DirUtil.create_folders(path, [""])
		FileUtil.save_to_file_as_format_json(save_data.data, path, "data", ".sav", FileUtil.encrypt_mode.NO_ENCRYPT) #пока не надо шифровать
		FileUtil.save_to_file_as_format_json(save_data.metadata, path , "metadata", ".json", FileUtil.encrypt_mode.NO_ENCRYPT)
	else:
		#save_data = null
		return

	#save_data = null

# Загрузка данных игры из файла
func game_load_from_file(folder_name: String) -> void:
	var load_content: Dictionary = FileUtil.file_read(PathManager.build_path(Main.SAVE_FOLDER_PATH + folder_name, "/data", ".sav"), FileUtil.encrypt_mode.NO_DECRYPTION)
	self.emit_signal("load_from_data", load_content)

func save_list_saves_config(data: Array[Dictionary]) -> void:
	var config: ConfigFile = ConfigUtil.set_config_array(data)
	config.save(Main.SAVE_LIST_CONFIG_PATH)

# Класс для хранения данных сохранения
class PrivateSaveData extends RefCounted:
	var data: Dictionary = {}
	var metadata: Dictionary = {}
