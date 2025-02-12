class_name SaveDataDefault
extends Object

func _init(save_name: String = "defaul_save", last_save_date: Dictionary = {}) -> void:
	last_save_date = {"year": last_save_date["year"], "month": last_save_date["month"], "day": last_save_date["day"]}
	
	save["data"]["save_metadata"]["save_name"] = save_name
	save["data"]["save_metadata"]["last_save_date"] = last_save_date
	
#Базовый сейв.json - его словарь
var save: Dictionary = {
	 "data": {
		"save_metadata": {
			"save_name": "default_save",
			"last_save_date": null
		},
		"level_metadata": {
			"current_level": 0,
			"level_name": "default_level"
		},
	},
	"object_data": {},
	"level_data": {},
	"player_data": {}
	}
