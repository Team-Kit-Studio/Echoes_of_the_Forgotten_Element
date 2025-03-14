extends Node2D

enum intro_state {
	INTRO_IN,
	INTRO_OUT
}

var state: intro_state:
	set(value):
		match value:
			intro_state.INTRO_IN:
				state_intro_in()
			
			intro_state.INTRO_OUT:
				state_intro_out()


@onready var timer: Timer = $Timer

func _ready() -> void:
	state = intro_state.INTRO_IN
	$DirectionalLight2D.visible = true

func state_intro_in() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 0 , 2.5)


func state_intro_out() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 1.5 , 1)
	await tween.finished
	get_tree().call_deferred("change_scene_to_file", "res://systems/Main_Menu/Main_Menu.tscn")



func _on_timer_timeout() -> void:
	state = intro_state.INTRO_OUT
	
