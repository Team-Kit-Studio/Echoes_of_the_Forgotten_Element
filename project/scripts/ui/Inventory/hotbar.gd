extends HBoxContainer

signal equip(item: Item)

@onready var inventorygrid = $"../GridContainer"
var Slots: Array

var currently_equipped: Item:
	set(value):
		currently_equipped = value
		equip.emit(value)
		
var index = 0:
	set(value):
		index = value
		
		if index >= get_child_count():
			index = 0
		elif index <0:
			index = get_child_count() - 1
		
		currently_equipped = get_child(index).item
		queue_redraw()

func _ready() -> void:
	var hotbarchild = get_children()
	for i1 in hotbarchild:
		Slots.append(i1)
	for i2 in inventorygrid.get_children():
		Slots.append(i2)
	#print(Slots)
	#print(hotbarchild)
func _draw() -> void:
	draw_rect(Rect2(get_child(index).position, get_child(index).size), Color.WHITE, false, 1)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			index -= 1
			print(index)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			index += 1
			print(index)
			
func update():
	currently_equipped = get_child(index).item
	
func use_current():
	get_child(index).amount -= 1


func addItem(item: Item):
	for i in Slots:
		if i.item == null:
			i.item = item
			return 
		elif i.item != null and i.item.ItemName == item.ItemName:
			i.count = i.count + 1
			return
	
	
