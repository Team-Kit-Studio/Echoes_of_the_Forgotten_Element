class_name SaveDataDefault
extends Object

func _init(save_name: String = "defaul_save", last_save_date: Dictionary = {}) -> void:
	last_save_date = {
		"year": last_save_date["year"], 
		"month": last_save_date["month"], 
		"day": last_save_date["day"]
	}
	data["save_info"]["save_name"] = save_name
	data["save_info"]["last_save_date"] = last_save_date
	
#Базовый сейв.json - его словарь
var data: Dictionary = {
	"save_info": {
		"save_name": "default_save",
		"last_save_date": {},
		},
	"player_data": {
		"inventory": {
			"item": {}
			}
		},
	"level_data":{
		"level_info": {
			"level_name": "default_level",
		},
		"list_objects": {}
	}
}
