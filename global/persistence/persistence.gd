extends Node

const PATH_CONFIG: String = "user://user_config/settings_test.cfg" # задаем путь для конфига, он по стандарту

var config: ConfigFile

func _ready() -> void:
	if !FileAccess.file_exists(PATH_CONFIG):
		new_config_settings()
	
	else:
		
		load_data()
			
			

func save_data() -> void:
	ConfigUtil.save_config(config, PATH_CONFIG)

func new_config_settings() -> void:
	pass
	# config = ConfigUtil.set_config_dict(PrivateDefaultSettingsData.new().settings)

func load_data() -> void:
	if not FileAccess.file_exists(PATH_CONFIG):
		new_config_settings()
		save_data()

	config = ConfigUtil.load_config(PATH_CONFIG)
	load_video_settings()
	load_control_settings()


func save_control_settings(action: String, event: InputEvent) -> void:
	var event_str: String
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
	
func save_audio_settings(key:String, value: float)-> void:
	config.set_value("Аудио", key, value)

	
	
func load_audio_settings() -> Dictionary:
	var audio_settings: Dictionary
	for key in config.get_section_keys("Аудио"):
		audio_settings[key] = config.get_value("Аудио", key)
	return audio_settings
	
