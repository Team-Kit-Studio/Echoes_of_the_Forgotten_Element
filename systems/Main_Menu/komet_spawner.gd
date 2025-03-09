extends Node


func rand_pos() -> Vector2:
	var rect: Rect2 = get_viewport().get_visible_rect()
	return Vector2(rect.end.x , randf_range(rect.end.y, -rect.end.y))

func rand_propetry() -> Dictionary:
	var property: Dictionary = {
		"speed_x": randf_range(5, 10),
		"speed_y": randf_range(-1, 1),
		"rotate_speed": randf_range(-1, 1)
	}
	return property

func spawn(rand_property: Dictionary) -> void:
	pass 
