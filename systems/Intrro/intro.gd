extends Node2D

enum {
	INTRO_IN,
	INTRO_OUT
}
var _call: Dictionary = {
	INTRO_IN: "state_intro_in",
	INTRO_OUT: "state_intro_out"
}

var state = INTRO_IN

@onready var timer: Timer = $Timer

func _ready():
	$DirectionalLight2D.visible = true


func _process(_delta):
	call(_call[state])

	
func state_intro_in():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 0 , 2.5)


func state_intro_out():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 1.5 , 1)
	await tween.finished
	get_tree().call_deferred("change_scene_to_file", "res://systems/Main_Menu/Main_Menu.tscn")



func _on_timer_timeout():
	state = INTRO_OUT
	
