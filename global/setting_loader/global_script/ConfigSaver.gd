extends Node

const SETTINGS_CONFIG_PATH: String = "user://user_config/settings.cfg"

var settings_config: ConfigFile

func _ready() -> void:
    if not FileAccess.file_exists(SETTINGS_CONFIG_PATH):
        new_config_settings()
    
    else:
        load_data()
    
    

func save_data() -> void:
    ConfigUtil.save_config(settings_config, SETTINGS_CONFIG_PATH)

func new_config_settings() -> void:
    settings_config = ConfigUtil.set_config_dict(PrivateDefaultSettingsData.new().settings)

func load_data() -> void:
    if not FileAccess.file_exists(SETTINGS_CONFIG_PATH):
        new_config_settings()
        save_data()

    settings_config = ConfigUtil.load_config(SETTINGS_CONFIG_PATH)
