extends Node

const FORBIDDEN_CHARACTERS: Array[String] = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", "#", "%", "{", "}",
     "^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", "!", "+"
]

const SAVE_PATH: String = "user://saves/" # путы сохранений
const SAVES_BACKGROUNG_PATH: String = "user://saves_background/" # путь картинок сохранений
const PATH: String = "user://user_config/settings.cfg" # задаем путь для конфига, он по стандарту

var config: ConfigFile = ConfigFile.new()   # создаем новый конфиг и записываем в переменную config


func _ready() -> void:
	if !DirAccess.dir_exists_absolute("user://user_config/"):
		DirAccess.make_dir_absolute("user://user_config/")

	if !FileAccess.file_exists(PATH):
		config.set_value("Управление", "up", "W")
		config.set_value("Управление","left","A")
		config.set_value("Управление", "down", "S")
		config.set_value("Управление","right","D")
			
		config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
		config.set_value("Видео", "borderless", false)
		config.set_value("Видео", "vsync", DisplayServer.VSYNC_ENABLED)
		
		config.set_value("Аудио", "master_volume", 1.0)
		config.set_value("Аудио", "sfx_volume", 1.0)
		config.set_value("Аудио", "music_volume", 1.0)
		
		

		save_data()
	else:
		load_data()
			
			
func save_data() -> void:
	config.save(PATH)
	
	
func load_data() -> void:
	if config.load(PATH) != OK:
		save_data()
		print("нет доступа, сохраняю")
		return 
	
	load_control_settings()
	load_video_settings()
	print("Загрузка файла", "\n")


func save_control_settings(action: String, event: InputEvent) -> void:
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
		
	config.set_value("Управление", action, event_str)
	save_data()


func load_control_settings() -> Dictionary:
	var binds_settings: Dictionary = {}
	var keys: PackedStringArray = config.get_section_keys("Управление") #получаем список всех ключей из секции Управление
	for action in keys: #запускаем цикл по всем ключам в keys
		var input_event: InputEvent
		var value: String = config.get_value("Управление", action) #получаем значение для текущего действия(action) из секции Управление
		if value.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(value.split("_")[1])
			
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(value)
				
				
		binds_settings[action] = input_event
		#print(binds_settings[action])
	return binds_settings

func load_video_settings() -> void:
	var screen_type: int = config.get_value("Видео", "fullscreen")
	DisplayServer.window_set_mode(screen_type)
	
	var borderless: bool = config.get_value("Видео", "vsync")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	
	var vsync_index: int = config.get_value("Видео", "vsync")
	DisplayServer.window_set_vsync_mode(vsync_index)
	
func save_audio_settings(key:String, value)-> void:
	config.set_value("Аудио", key, value)
	save_data()
	
	
func load_audio_settings() -> Dictionary:
	var audio_settings: Dictionary
	for key in config.get_section_keys("Аудио"):
		audio_settings[key] = config.get_value("Аудио", key)
	# print(audio_settings)
	return audio_settings
	
	
