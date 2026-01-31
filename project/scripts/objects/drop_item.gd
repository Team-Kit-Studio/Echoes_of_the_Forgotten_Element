extends Area2D
class_name DroppedItem

@export var data: ItemData

@onready var sprite: Sprite2D = $Sprite2D
@onready var amount_label: Label = $Amount
@onready var hint_f: CanvasItem = $HintF

func _ready() -> void:
	add_to_group("dropped_item")
	input_pickable = true

	if hint_f:
		hint_f.visible = false

	update_visual()

func update_visual() -> void:
	if data and sprite:
		sprite.texture = data.texture

	if amount_label:
		if data and data.max_stack_size > 1 and data.amount > 1:
			amount_label.text = str(data.amount)
			amount_label.visible = true
		else:
			amount_label.visible = false

func set_highlight(active: bool) -> void:
	if hint_f:
		hint_f.visible = active
