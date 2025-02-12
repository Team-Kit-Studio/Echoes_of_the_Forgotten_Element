class_name SaveDataDefault
extends Object

func _init(save_name: String = "defaul_save", game_versions: String = "1") -> void:
	data["metadata"]["property"]["save_name"] = save_name
	data["metadata"]["property"]["game_versions"] = game_versions
	
var data: Dictionary = {
	"metadata": {
		"property": {
			"save_name": "defaul_save",
			"game_versions": "2.0",
			},
			
			"game_settings": {
				"current_level": 1,
				"difficulty": "easy",
			},
			}
	}
