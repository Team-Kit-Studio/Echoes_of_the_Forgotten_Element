extends Object
class_name DefaultSave


func _init(name: String, current_scene: String = "") -> void:
	data["info"]["name"] = name
	data["info"]["current_scene"] = current_scene

var data: Dictionary = {
	"info": {
		"name": "default_save",
		"current_scene": "",
		"last_date": Time.get_date_dict_from_system(),
		"last_time": Time.get_time_dict_from_system()
	},
	"data": {}
}