extends Panel


var ItemClass =preload("res://project/scenes/objects/item.tscn")


@export var item: Item = null:
	set(value):
		item = value
		
		if value == null:
			$Icon.texture = null
			$Amount.text = " "
			return
		$Icon.texture = value.icon
		
@export var amount: int = 0:
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			item = null
			
			
func set_amount(value: int):
	amount = value
	
func add_amount(value: int):
	amount += value
	
func _can_drop_data(at_position: Vector2, data: Variant):
	if "item" in data:
		return is_instance_of(data.item, Item)
	return false
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var temp = item
	item = data.item
	data.item = temp
	
	temp = amount
	amount = data.amount
	data.amount = temp
	
	if get_parent().has_method("update"):
		get_parent().update()
	if data.get_parent().has_method("update"):
		data.get_parent().update()
		
func _get_drag_data(at_position: Vector2):
	if item:
		var preview_texture = TextureRect.new()
		
		preview_texture.texture = item.icon
		preview_texture.size = Vector2(16,16)
		preview_texture.position = -Vector2(8,8)
		
		var preview = Control.new()
		preview.add_child(preview_texture)
		set_drag_preview(preview)
		
	return self
