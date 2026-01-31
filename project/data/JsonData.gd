extends Node

var item_data: Dictionary

func _ready() -> void:
	item_data = LoadData("res://project/data/item/ItemData.json")

func LoadData(path):
	var file_data  = FileAccess.open(path, FileAccess.READ)
	var json_data  = JSON.new()
	json_data.parse(file_data .get_as_text())
	file_data.close()
	return json_data.get_data()
 
