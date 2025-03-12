extends FileDirManager

signal load(folder_name: String)
signal save(folder_name: String)
signal delete(folder_name: String)

signal data_updated(data: Dictionary, metadata: Dictionary)
signal data_update

signal load_from_data(data: Dictionary)


const SAVE_PATH: String = "user://saves/"

var save_data: SaveData = SaveData.new()


# Функция, вызываемая при готовности узла
func _ready() -> void:
	self.load.connect(load_handler)
	self.save.connect(save_handler)
	self.delete.connect(delete_handler)
	self.data_updated.connect(data_update_handler)

	# Создание папки saves при инициализации
	DirUtil.create_folders("user://", ["saves", "puppu"])


# Обработчик сигнала загрузки
func load_handler(file_path: String) -> void:
	game_load_from_file(file_path)


# Обработчик сигнала сохранения
func save_handler(folder_name: String) -> void:
	self.emit_signal("data_update")
	game_save_to_file(folder_name)


# Обработчик сигнала удаления
func delete_handler(folder_name: String) -> void:
	DirUtil.delete_folder_recursively(SAVE_PATH + folder_name)


# Обработчик сигнала обновления данных
func data_update_handler(data: Dictionary, metadata: Dictionary) -> void:
	save_data.set_data(data)
	save_data.set_metadata(metadata)
	

# Сохранение данных игры в файл
func game_save_to_file(folder_name: String) -> void:
	var path: String = PathManager.build_directory_path(SAVE_PATH, folder_name)
	DirUtil.create_folders(path, [""])
	FilesUtil.save_to_file_as_format_json(save_data.data, path, "data", ".sav")
	FilesUtil.save_to_file_as_format_json(save_data.metadata, path , "metadata", ".json")


# Загрузка данных игры из файла
func game_load_from_file(folder_name: String) -> void:
	var load_content: Dictionary = FilesUtil.file_read(PathManager.build_path(SAVE_PATH + folder_name, "/data", ".sav"))
	self.emit_signal("load_from_data", load_content)


# Класс для хранения данных сохранения
class SaveData:
	var data: Dictionary = {}
	var metadata: Dictionary = {}

	# Установка данных
	func set_data(_data: Dictionary) -> void:
		self.data = _data

	# Установка метаданных
	func set_metadata(_metadata: Dictionary) -> void:
		self.metadata = _metadata
