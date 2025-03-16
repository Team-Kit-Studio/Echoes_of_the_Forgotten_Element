extends Node

# Глобальный скрипт входа в игру, точнее ее среду. Тут можно обьявлять константы, переменные и вызывать функции которые нужны при запуске.
# А ище, тут будет храниться информация о игре тоесть версия, и тд.


const FORBIDDEN_CHARACTERS: Array[String] = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", "#", "%", "{", "}",
	"^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", "!", "+"
]

const USER_PATH: String = "user://"

func _ready() -> void:
	DirUtil.create_folders(USER_PATH, ["saves", "user_config", "screenshot"])

func debag_memory() -> void:
	var memory_info: Dictionary = OS.get_memory_info()

	var total: float = memory_info["stack"] / (1024 * 1024)
	var used: float = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	var free: float = memory_info["free"] / (1024 * 1024)
	
	print("Стек: %.1f МБ" % total, " Используемая память: %.2f МБ" % used, " Свободная память: %.1f МБ" % free)
