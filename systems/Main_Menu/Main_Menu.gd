extends Node2D

enum {
	Intro,
	Main_Menu
}

var state = Intro
@onready var menu = $Main_Menu
@onready var options = $Options
@onready var video = $Video
@onready var audio = $Audio
@onready var audiogame = $AudioStreamPlayer2D
@onready var controls = $Controls

# Called when the node enters the scene tree for the first time.
func _ready():
	$DirectionalLight2D.enabled = true
	menu.visible = true
	options.visible = false
	video.visible = false
	audio.visible = false
	controls.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	match state:
		Intro:
			intro()



func intro():
	var tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 0 , 5)
	if audiogame.playing == false:
		audiogame.playing = true
		#print("gg")

	


func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/LevelDemo.tscn")


func _on_options_pressed() -> void:
	menu.visible = false
	options.visible = true


func _on_video_pressed() -> void:
	options.visible = false
	video.visible = true


func _on_audio_pressed() -> void:
	options.visible = false
	audio.visible = true

func _on_back_menu_pressed() -> void:
	options.visible = false
	menu.visible = true


func _on_back_settings_pressed():
	video.visible = false
	audio.visible = false
	controls.visible = false
	options.visible = true


func _on_controls_pressed():
	options.visible = false
	controls.visible = true
