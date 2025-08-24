extends Resource

class_name Item

@export var ItemName: String
@export var texture: Texture2D
@export var recipe:Array[Item]


@export_enum("Tools", "Material", "Food") var type: String

func SaveData():
	return {
		"ItemName": ItemName,
		"texture": texture,
		"recipe": recipe,
		"type": type
	}
	
	
