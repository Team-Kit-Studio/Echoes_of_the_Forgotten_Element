extends Node

const SETTINGS_CONFIG_PATH: String = "user://user_config/settings.cfg"

var config: ConfigFile

func _ready() -> void:
	if not FileAccess.file_exists(SETTINGS_CONFIG_PATH):
		new_config_settings()
	
	else:
		load_data()


func save_data() -> void:
	ConfigUtil.save_config(config, SETTINGS_CONFIG_PATH)

func new_config_settings() -> void:
	config = ConfigUtil.set_config_dict(PrivateDefaultSettingsData.new().SETTINGS)

func load_data() -> void:
	config = ConfigUtil.load_config(SETTINGS_CONFIG_PATH)
	load_video_settings()

func save_control_settings(action: String, event: InputEvent) -> void:
	var event_str: String
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)

	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)

	config.set_value("Управление", action, event_str)
	save_data()

func get_key_binds() -> Dictionary[String, InputEvent]:
	var binds_settings: Dictionary[String, InputEvent] = {}
	for action: String  in config.get_section_keys("Управление"): #запускаем цикл по всем ключам секции "Управление"
		var input_event: InputEvent
		var value: String = config.get_value("Управление", action) #получаем значение для текущего действия(action) из секции Управление

		if value.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(value.split("_")[1])
			
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(value)
				
				
		binds_settings[action] = input_event
	
	return binds_settings

func load_video_settings() -> void:
	DisplayServer.window_set_mode(config.get_value("Видео", "fullscreen"))

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, config.get_value("Видео", "borderless"))

	DisplayServer.window_set_vsync_mode(config.get_value("Видео", "vsync"))

func save_audio_settings(key:String, value: float)-> void:
	config.set_value("Аудио", key, value)

# func load_audio_settings() -> Dictionary[String, float]: Я хуй знает зачем это тут
# 	var audio_settings: Dictionary[String, float] = {}
# 	for key in config.get_section_keys("Аудио"):
# 		audio_settings[key] = config.get_value("Аудио", key)

# 	return audio_settings
