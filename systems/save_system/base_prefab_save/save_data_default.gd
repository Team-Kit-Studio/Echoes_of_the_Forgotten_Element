class_name DefaultSave
extends Object

func _init(name: String, current_scene: String = "") -> void:
	data["info"]["name"] = name
	data["info"]["current_scene"] = current_scene

var data: Dictionary = {
	"info": {
		"name": "default_save",
		"current_scene": ""
	},
	"data": {
		"list_objects": {},
	}
}