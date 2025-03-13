class_name ConfigUtil

static func save_config(data: Dictionary, path: String) -> void:
	_set_values(data).save(path)
	

static func load_config(path: String) -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()

	if not FileAccess.file_exists(path):
		config = null
		return

	config.load(path)
	return config


static func _set_values(data: Dictionary) -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	for section_key: String in data.keys():
		for key: String in data[section_key].keys():
			config.set_value(section_key, key, data[section_key][key])

	return config
