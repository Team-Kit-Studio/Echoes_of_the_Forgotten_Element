extends Node

# Глобальный скрипт входа в игру, точнее ее среду. Тут можно обьявлять константы путей, версий, , переменные и вызывать функции которые нужны при запуске.
# А ище, тут будет храниться информация о игре тоесть версия, и тд.


const FORBIDDEN_CHARACTERS: Array[StringName] = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", "#", "%", "{", "}",
	"^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", "!", "+",
	" ", "№", "«", "»", "—", "–", "“", "”", "„", "‘", "’", "‚", "‹", "›",
	]

const ENCRYPT_KEY: StringName = StringName("1670d1f781e5ebee67da304f4fda6b04303616c3850ff218baaff7aca251c569")

const USER_FOLDER_PATH: StringName = StringName("user://")
const SAVE_FOLDER_PATH: StringName = StringName("user://saves/")
const SAVE_LIST_CONFIG_PATH: StringName = StringName("user://saves/_saves_list.cfg")
const SETTINGS_CONFIG_PATH: StringName = StringName("user://user_config/settings.cfg")

const SAVES_LIMIT: int = 13
const SAVE_NAME_CHARACTERS_LIMIT: int = 20

func _ready() -> void:
	DirUtil.create_folders(USER_FOLDER_PATH, ["saves", "user_config", "screenshot"])
	if not FileAccess.file_exists(SAVE_LIST_CONFIG_PATH): ConfigFile.new().save(SAVE_LIST_CONFIG_PATH)
	
func debag_memory() -> void:
	var memory_info: Dictionary = OS.get_memory_info()

	var total: float = memory_info["stack"] / (1024 * 1024)
	var used: float = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	var free: float = memory_info["free"] / (1024 * 1024)
	
	print("Стек: %.1f МБ" % total, " Используемая память: %.2f МБ" % used, " Свободная память: %.1f МБ" % free)
