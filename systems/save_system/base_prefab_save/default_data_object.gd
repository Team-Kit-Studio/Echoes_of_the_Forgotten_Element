class_name DefaultObject
extends Object

func _init(name: String = "default_object", path: String = "res://", dynamic: bool = false) -> void:
	object["info"]["name"] = name
	object["info"]["path"] = path
	object["info"]["dynamic"] = dynamic


var object: Dictionary = {
	"info":{
		"name": "default_object",
		"path": "res://",
		"dynamic": false,
	},

	"data": {
		"position": {"x": 0, "y": 0},
		"health": 100,
		"state": "IDLE",
	}
}