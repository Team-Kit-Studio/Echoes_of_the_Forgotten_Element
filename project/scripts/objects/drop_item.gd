@tool
extends Area2D
class_name DroppedItem

@export var data: ItemData
@export var item_id: String = ""
@export var item_quantity: int = 1


@onready var sprite: Sprite2D = $Sprite2D
@onready var amount_label: Label = $Amount
@onready var hint_f: CanvasItem = $HintF


func _ready() -> void:
	if not Engine.is_editor_hint():
		sprite.texture = data.texture
	#add_to_group("dropped_item")
	input_pickable = true

	if hint_f:
		hint_f.visible = false

	update_visual()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		sprite.texture = data.texture

func update_visual() -> void:
	if data and sprite:
		sprite.texture = data.texture

	if amount_label:
		if data and data.max_stack_size > 1 and data.amount > 1:
			amount_label.text = str(data.amount)
			item_quantity = int(amount_label.text)
			amount_label.visible = true
		else:
			amount_label.visible = false

func set_highlight(active: bool) -> void:
	if hint_f:
		hint_f.visible = active
