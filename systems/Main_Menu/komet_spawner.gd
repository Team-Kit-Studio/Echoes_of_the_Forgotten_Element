extends Node


func rand_pos() -> Vector2:
	var rect: Rect2 = get_viewport().get_visible_rect()
	return Vector2(rect.end.x , randf_range(rect.end.y, -rect.end.y))


