extends Node2D

enum {
	INTRO_IN,
	INTRO_OUT
}
var state = INTRO_IN
@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	$DirectionalLight2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		INTRO_IN:
			state_intro_in()
		INTRO_OUT:
			state_intro_out()
	

func state_intro_in():
	var tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 0 , 3)
	#print("gg1")

func state_intro_out():
	var tween = get_tree().create_tween()
	tween.tween_property($DirectionalLight2D, "energy", 1 , 1)
	await tween.finished
	get_tree().call_deferred("change_scene_to_file", "res://Menu.tscn")
	#print("gg2")


func _on_timer_timeout():
	state = INTRO_OUT
	#print("gggg")
	
