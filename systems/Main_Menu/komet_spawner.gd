extends Node

@onready var timer: Timer = $Timer

var reload_comet: float = 5
var comet_pre: Resource = preload("res://systems/Main_Menu/komet.tscn")


func _physics_process(_delta: float) -> void:
	check_timer()
	print(get_parent().get_viewport_rect())


func spawn_comet() -> void:
	var comet_instance: Node2D = comet_pre.instantiate() as Sprite2D
	comet_instance.position = cordinate_spawn()
	comet_instance.set("property", generate_property())
	self.add_child(comet_instance)


func generate_property() -> Dictionary:
	var rand_scale: float = randf_range(1, 1.8)
	var property: Dictionary = {
		"scale": rand_scale,
		"rotation_speed": rand_scale / 1.1,
		"speed_x": rand_scale / 1.30,
		"speed_y": randf_range(10, -10)
	}

	return property


func cordinate_spawn() -> Vector2:
	return Vector2(get_parent().get_viewport_rect())


func check_timer() -> void:
	if timer.is_stopped():
		spawn_comet()
		timer.start(1)
	