extends HBoxContainer

signal equip(item: Item)

var curretly_equipped: Item:
	set(value):
		curretly_equipped = value
		equip.emit(value)
		
var index = 0:
	set(value):
		index = value
		
		if index >= get_child_count():
			index = 0
		elif index < 0:
			index = get_child_count() - 1
		
		curretly_equipped = get_child(index).item
		queue_redraw()
		
func _draw():
	draw_rect(Rect2(get_child(index).position , get_child(index).size), Color.WHITE, false, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			index -= 1
			print(index)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			index += 1
			print(index)
			
func update():
	curretly_equipped = get_child(index).item
	
	
func use_current():
	get_child(index).amount -= 1
	
