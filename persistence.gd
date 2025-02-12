extends Node

const  PATH: String = "user://settings.cfg" # задаем путь для конфига, он по стандарту
var config: ConfigFile = ConfigFile.new()   # создаем новый конфиг и записываем в переменную config

#часть сохранения
const  PATH_SAVE: String = "user://save/"



func _ready() -> void:
	save_game("test")
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
	if config.load("user://settings.cfg") != OK:
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
	var binds_settings = {}
	var keys = config.get_section_keys("Управление") #получаем список всех ключей из секции Управление
	for action in keys: #запускаем цикл по всем ключам в keys
		var input_event
		var value = config.get_value("Управление", action) #получаем щзначение для текущего действия(action) из секции Управление
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
	var screen_type = config.get_value("Видео", "fullscreen")
	DisplayServer.window_set_mode(screen_type)
	
	var borderless = config.get_value("Видео", "vsync")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	
	var vsync_index = config.get_value("Видео", "vsync")
	DisplayServer.window_set_vsync_mode(vsync_index)
	
func save_audio_settings(key:String, value)-> void:
	config.set_value("Аудио", key, value)
	save_data()
	
	
func load_audio_settings() -> Dictionary:
	var audio_settings: Dictionary
	for key in config.get_section_keys("Аудио"):
		audio_settings[key] = config.get_value("Аудио", key)
	print(audio_settings)
	return audio_settings
	
	
func save_game(save_name: String = "default_save", _scene_chidre: Array[Node] = []) -> void:
	var name_path: String = PATH_SAVE + save_name + ".json"
	var base_data: SaveDataDefault = SaveDataDefault.new(save_name)
	var file = FileAccess.open(name_path, FileAccess.WRITE)
	
	var coutn = 0
	if FileAccess.get_open_error() == OK and _scene_chidre != []:
		base_data.data["metadata"]["object_data"] = {}
		for child in _scene_chidre: 
			coutn += 1
			base_data.data["metadata"]["object_data"][child.name] = {}
			base_data.data["metadata"]["object_data"][child.name]["pos_x"] = child.position.x
			base_data.data["metadata"]["object_data"][child.name]["pos_y"] = child.position.y
			if coutn == _scene_chidre.size():
				file.store_string(JSON.stringify(base_data.data, "\t"))
				file.close()
				coutn = 0
	else:
		printerr("Error: ", FileAccess.get_open_error())
		pass
		
func load_game(save_name: String, child_set_settings: Array[Node]) -> void:
	var file: FileAccess = FileAccess.open(PATH_SAVE + save_name + ".json", FileAccess.READ)
	var _content: Dictionary
	if FileAccess.get_open_error() == OK:
		_content = JSON.parse_string(file.get_as_text())
		file.close()
		
	else:
		_content = {}
		file.close()
		printerr("Error: ", "ERROR LOAD")
