extends Node2D


@onready var menu: Control = $Main_Menu
@onready var options: Control = $Options
@onready var video: Control = $Video
@onready var audio: Control = $Audio
@onready var audiogame: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var controls: Control = $Controls

func _ready() -> void:
	intro()
	$DirectionalLight2D.enabled = true
	menu.visible = true
	options.visible = false
	video.visible = false
	audio.visible = false
	controls.visible = false


func intro() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 0 , 5)
	if audiogame.playing == false:
		audiogame.playing = true

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

func _on_back_settings_pressed() -> void:
	video.visible = false
	audio.visible = false
	controls.visible = false
	options.visible = true


func _on_controls_pressed() -> void:
	options.visible = false
	controls.visible = true
