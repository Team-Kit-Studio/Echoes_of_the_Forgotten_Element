class_name FileUtil

# - get_file_path(folder_path: String, file_name: String, extension: String) -> String
#   - Конструирует и возвращает полный путь к файлу.
static func get_file_path(folder_path: String, file_name: String, extension: String) -> String:
    return PathManager.build_path(folder_path, file_name, extension)

# - save_to_file_as_format_json(data: Dictionary, folder_path: String, file_name: String, extension: String) -> void
#   - Сохраняет словарь в виде JSON файла по указанному пути.
static func save_to_file_as_format_json(data: Dictionary, folder_path: String, file_name: String, extension: String) -> void:
    var path: String = get_file_path(folder_path, file_name, extension)
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    print(path)
    if file:
        file.store_string(JSON.stringify(data, '\t'))
        file.close()

# - file_read(folder_path: String, file_name: String, extension: String) -> Dictionary
#   - Читает и возвращает содержимое JSON файла в виде словаря.
static func file_read(file_path: String) -> Dictionary:
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
static func delete_file(folder_path: String, file_name: String, extension: String) -> void:
    var path: String = get_file_path(folder_path, file_name, extension)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)
