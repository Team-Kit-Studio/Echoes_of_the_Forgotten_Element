class_name DefaultDataObject
extends Object

func _init(obj_name: String = "default_object", obj_node: Node = null, instantiate: bool = true, obj_group: String = "no_save") -> void:
	object["obj_info"]["object_name"] = obj_name
	object["obj_info"]["object_node"] = obj_node
	object["obj_info"]["object_group"] = obj_group
	object["obj_info"]["object_instantiate"] = instantiate
	
var object: Dictionary = {
	"obj_info": {
		"object_name": "default_object",
		"object_node": "obj_node",
		"object_instantiate": true,
		"object_group": null
	},
	"obj_data": {
		"pos_x": 0,
		"pos_y": 0
	}
}
