extends Node
class_name FileDirManager

# Будет доработано

# Этот скрипт определяет класс FileDirManager, который предоставляет утилиты для управления файлами и директориями.
# Он включает вложенные классы для работы с файлами (FilesUtil), директориями (DirUtil) и управления путями (PathManager).

var user_path: String = OS.get_user_data_dir()

static var FilesUtil: FilesUtilClass = FilesUtilClass.new()
static var DirUtil: DirUtilClass = DirUtilClass.new()
static var PathManager: PathManagerClass = PathManagerClass.new()

# FilesUtil
# - Статический класс для утилит, связанных с файлами.
class FilesUtilClass extends FileDirManager:

# - get_file_path(folder_path: String, file_name: String, extension: String) -> String
#   - Конструирует и возвращает полный путь к файлу.
	func get_file_path(folder_path: String, file_name: String, extension: String) -> String:
		return PathManager.build_path(folder_path, file_name, extension)

# - save_to_file_as_format_json(data: Dictionary, folder_path: String, file_name: String, extension: String) -> void
#   - Сохраняет словарь в виде JSON файла по указанному пути.
	func save_to_file_as_format_json(data: Dictionary, folder_path: String, file_name: String, extension: String) -> void:
		var path: String = get_file_path(folder_path, file_name, extension)
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		print(path)
		if file:
			file.store_string(JSON.stringify(data, '\t'))
			file.close()

# - file_read(folder_path: String, file_name: String, extension: String) -> Dictionary
#   - Читает и возвращает содержимое JSON файла в виде словаря.
	func file_read(file_path: String) -> Dictionary:
		var path: String = file_path
		var file: FileAccess
		if not FileAccess.file_exists(path):
			return {}

		file = FileAccess.open(path, FileAccess.READ)
		
		if file:
			var content: Dictionary = JSON.parse_string(file.get_as_text())
			file.close()
			return content
		return {}

# - delete_file(folder_path: String, file_name: String, extension: String) -> void
#   - Удаляет указанный файл, если он существует.
	func delete_file(folder_path: String, file_name: String, extension: String) -> void:
		var path: String = get_file_path(folder_path, file_name, extension)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)



# DirUtil
# - Статический класс для утилит, связанных с директориями.
class DirUtilClass extends FileDirManager:

# - _get_folder_path(folder_path: String) -> String
# - Конструирует и возвращает полный путь к директории.
	func _get_folder_path(folder_path: String, folder_name: String) -> String:
		return PathManager.build_directory_path(folder_path, folder_name)

# - create_folders(path: String, folders_name: String) -> void
# - Рекурсивно создает директории по указанному пути.
	func create_folders(path: String, folders_name: Array[String]) -> void:
			var folder_path: String
			if folders_name.size() > 1:
				for folder_name in folders_name:
					folder_path = PathManager.build_directory_path(path, folder_name)
					if not DirAccess.dir_exists_absolute(folder_path):
						DirAccess.make_dir_absolute(folder_path)
			else:
				folder_path = PathManager.build_directory_path(path, folders_name[0])
				DirAccess.make_dir_absolute(folder_path)

	func create_folders_recursive(path: String, folders_name: String) -> void:
		var folder_path: String = PathManager.build_directory_path(path, folders_name)
		DirAccess.make_dir_recursive_absolute(folder_path)

# - get_files_in_directory(directory_path: String) -> PackedStringArray
# - Возвращает массив файлов в указанной директории.
	func get_files_in_directory(directory_path: String) -> PackedStringArray:
		var dir: DirAccess = DirAccess.open(directory_path)
		return dir.get_directories()

# - delete_folder_recursively(path: String) -> void
# - Рекурсивно удаляет указанную директорию и её содержимое.
	func delete_folder_recursively(path: String) -> void:
		var dir: DirAccess = DirAccess.open(path)
		if dir:
			for file in dir.get_files():
				DirAccess.remove_absolute("%s/%s" % [path, file])
			for subdir in dir.get_directories():
				delete_folder_recursively("%s/%s" % [path, subdir])

			DirAccess.remove_absolute(path)



# PathManager
# - Статический класс для утилит управления путями.
class PathManagerClass:

# - build_path(base_path: String, name: String, extension: String = "") -> String
# - Конструирует и возвращает полный путь к файлу с необязательным расширением.
	func build_path(base_path: String, name: String, extension: String) -> String:
		if extension != "" and not extension.begins_with("."):
			extension = "." + extension
			
		return "%s%s%s" % [base_path, name, extension]

# - build_directory_path(base_path: String, directory_name: String) -> String
# - Конструирует и возвращает полный путь к директории.
	func build_directory_path(base_path: String, directory_name: String) -> String:
		return "%s%s/" % [base_path, directory_name]
		
