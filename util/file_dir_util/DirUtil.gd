class_name DirUtil


# - _get_folder_path(folder_path: String) -> String
# - Конструирует и возвращает полный путь к директории.
static func _get_folder_path(folder_path: String, folder_name: String) -> String:
	return PathManager.build_directory_path(folder_path, folder_name)

# - create_folders(path: String, folders_name: String) -> void
# - Рекурсивно создает директории по указанному пути.
static func create_folders(path: String, folders_name: Array[String]) -> void:
		var _folder_path: String
		if folders_name.size() > 1:
			for folder_name in folders_name:
				_folder_path = PathManager.build_directory_path(path, folder_name)
				if not DirAccess.dir_exists_absolute(_folder_path):
					DirAccess.make_dir_absolute(_folder_path)
		else:
			_folder_path = PathManager.build_directory_path(path, folders_name[0])
			DirAccess.make_dir_absolute(_folder_path)

static func create_folders_recursive(path: String, folders_name: String) -> void:
	var folder_path: String = PathManager.build_directory_path(path, folders_name)
	DirAccess.make_dir_recursive_absolute(folder_path)

# - get_files_in_directory(directory_path: String) -> PackedStringArray
# - Возвращает массив файлов в указанной директории.
static func get_directory(directory_path: String) -> PackedStringArray:
	var dir: DirAccess = DirAccess.open(directory_path)
	return dir.get_directories()

# - delete_folder_recursively(path: String) -> void
# - Рекурсивно удаляет указанную директорию и её содержимое.
static func delete_folder_recursively(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		for file: String in dir.get_files():
			DirAccess.remove_absolute("%s/%s" % [path, file])
		for subdir: String in dir.get_directories():
			delete_folder_recursively("%s/%s" % [path, subdir])

		DirAccess.remove_absolute(path)
