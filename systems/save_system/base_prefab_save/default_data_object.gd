class_name DefaultDataObject
extends Object

func _init(obj_name: String = "default_object", obj_node: Node = null, instantiate: bool = true, obj_group: String = "no_save") -> void:
	object["metadata"]["object_name"] = obj_name
	object["metadata"]["object_node"] = obj_node
	object["metadata"]["object_group"] = obj_group
	object["metadata"]["object_instantiate"] = instantiate
	
var object: Dictionary = {
	"metadata": {
		"object_name": "default_object",
		"object_node": null,
		"object_instantiate": true,
		"object_group": null
	},
	"data": {
		"pos_x": 0,
		"pos_y": 0
	}
}
