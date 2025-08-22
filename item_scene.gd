extends RigidBody2D

class_name ItemDrop

@export var item: Item = null:
	set(value):
		item = value
		if value != null:
			$TextureRect.texture = value.texture
		else:
			$TextureRect.texture = null
