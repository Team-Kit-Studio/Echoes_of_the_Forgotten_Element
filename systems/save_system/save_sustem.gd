class_name SaveSystem
extends Node



signal create_a_save(_name: String)
signal delete_a_save(_name: String)

func  _ready() -> void:
	if not DirAccess.dir_exists_absolute(Gvars.SAVE_PATH):
		DirAccess.make_dir_absolute(Gvars.SAVE_PATH)
	self.create_a_save.connect(create_save_handler)
	self.delete_a_save.connect(delete_save_handler)

func create_save_handler(_name: String) -> void:
	create_save(_name)

func create_save(_name: String) -> void:
	var Save: DefaultSave = DefaultSave.new(_name)
	var file: FileAccess = FileAccess.open(Gvars.SAVE_PATH + _name + ".save", FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(Save.data.duplicate(), "\t"))
		file.close()
	else:
		print("Error: ", FileAccess.get_open_error())
		file.close()
		return

func delete_save_handler(_name: String) -> void:
	delete_save(_name)

func delete_save(_name: String) -> void:
	var path: String = Gvars.SAVE_PATH + _name + ".save"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)	
	else:
		print("Error: File not found")
		return
		
