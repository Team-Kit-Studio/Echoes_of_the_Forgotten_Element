class_name PathManager

# - build_path(base_path: String, name: String, extension: String = "") -> String
# - Конструирует и возвращает полный путь к файлу с необязательным расширением.
static func build_path(base_path: String, name: String, extension: String) -> String:
    if extension != "" and not extension.begins_with("."):
        extension = "." + extension
        
    return "%s%s%s" % [base_path, name, extension]

# - build_directory_path(base_path: String, directory_name: String) -> String
# - Конструирует и возвращает полный путь к директории.
static func build_directory_path(base_path: String, directory_name: String) -> String:
    return "%s%s/" % [base_path, directory_name]
    
