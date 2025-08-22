extends Resource

class_name Item

@export var ItemName: String
@export var texture: Texture2D


@export_enum("Tools", "Material", "Food")
var type = "Material"

@export var recipe:Array[Item]
