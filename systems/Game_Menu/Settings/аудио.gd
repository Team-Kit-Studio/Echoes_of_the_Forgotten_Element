extends TabBar

@onready var Music := %music
@onready var sfx_value := %Sound_FX
@onready var audio_num_music_text := $HBoxContainer/VBoxContainer3/Audio_Num_LBL
@onready var audio_num_sfx_text := $HBoxContainer/VBoxContainer3/Audio_Num_LBL2


var bus_index_music : int = 2
var bus_index_sfx : int = 1

func _ready() -> void:
	get_bus_index()
	
	
	Music.value = Persistence.config.get_value("Аудио", "music_volume")
	AudioServer.set_bus_volume_db(bus_index_music, linear_to_db(Music.value))
	
	sfx_value.value = Persistence.config.get_value("Аудио", "sfx_volume")
	AudioServer.set_bus_volume_db(bus_index_sfx, linear_to_db(sfx_value.value))
	

func get_bus_index() -> void:
	bus_index_music = AudioServer.get_bus_index("music")
	bus_index_sfx = AudioServer.get_bus_index("sfx_volume")

	

func set_audio_num_text() -> void:
	audio_num_music_text.text = str(Music.value * 100)
	audio_num_sfx_text.text = str(sfx_value.value * 100)


func _on_music_value_changed(value: float) -> void:
	set_volume(bus_index_music, value)


func _on_sound_fx_value_changed(value: float) -> void:
	set_volume(bus_index_sfx, value)

func set_volume(idx: int, value: float) -> void:
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	if idx == bus_index_music:
		Persistence.config.set_value("Аудио", "music_volume", value)
		Persistence.save_data()
	elif idx == bus_index_sfx:
		Persistence.config.set_value("Аудио", "sfx_volume", value)
		Persistence.save_data()
	set_audio_num_text()
	
