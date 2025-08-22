extends Panel

class_name Slot

@onready var texture = $Icon

@export var item: Item = null:
	set(value):
		item = value
		
		if value != null:
			$Icon.texture = value.texture
		else:
			$Icon.texture = null
			
@export var count: int = 1:
	set(value):
		count = value
		if value != null:
			if value > 1:
				$Amount.show()
			else:
				$Amount.hide()
			$Amount.text = str(value)
		else:
			$Amount.hide()
			$Amount.text = "1"

func get_preview():
	var preview_text: TextureRect = TextureRect.new()
	preview_text.texture = texture.texture
	
	var preview = Control.new()
	preview.add_child(preview_text)
	
	return preview
	
func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Slot
		
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var tempItem = item
	var tempCount = count
	item = data.item
	count = data.count
	data.item = tempItem
	data.count = tempCount
