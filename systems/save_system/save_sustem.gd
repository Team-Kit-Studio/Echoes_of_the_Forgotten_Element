class_name SaveSystem
extends Node

signal create_save(_name: String)

func  _ready() -> void:
	if not DirAccess.dir_exists_absolute(Gvars.SAVE_PATH):
		DirAccess.make_dir_absolute(Gvars.SAVE_PATH)
		
func print() -> void:
	var save: DefaultSave = DefaultSave.new()
	print(save.save["info"]["last_save_date"])