extends StaticBody2D

@onready var inventory_manager = InventoryManage

# Изначальные предметы — задаются в инспекторе
@export var storage: Array[ItemData] = []

# Сохранённая раскладка сундука (после первого открытия/перетаскиваний)
# Формат: [{ "data": ItemData, "origin": Vector2i }, ...]
var saved_layout: Array[Dictionary] = []

@onready var hint_marker: Panel = $Panel

func _ready() -> void:
	if hint_marker:
		hint_marker.visible = false

func set_highlight(is_active: bool) -> void:
	if hint_marker:
		hint_marker.visible = is_active

# Функция, которую вызывает игрок при нажатии F
func player_interact() -> void:
	var external_inventory = get_node("/root/Main/UI/ExternalInventory")
	
	if not external_inventory:
		return
	
	if external_inventory.visible and external_inventory.is_bound_to(self):
		# Закрываем этот сундук
		external_inventory.close_container()
	else:
		# Если держим предмет из другого инвентаря - сначала закроем всё
		if inventory_manager and inventory_manager.has_held():
			var source_info = inventory_manager.get_source()
			if source_info.inventory != external_inventory:
				var player = get_node("/root/Main/Player")
				if player and player.has_method("close_all_inventories"):
					player.close_all_inventories()
		
		# Открываем этот сундук
		external_inventory.open_container(self)

# UI будет вызывать это при открытии
func get_inventory_layout() -> Array[Dictionary]:
	# Если ещё ни разу не сохраняли раскладку — отдадим "просто предметы",
	# чтобы UI сам их разложил (origin = (-1,-1) значит "авторасстановка").
	if saved_layout.is_empty():
		var layout: Array[Dictionary] = []
		for it in storage:
			layout.append({"data": it, "origin": Vector2i(-1, -1)})
		return layout

	return saved_layout

# UI будет вызывать это при закрытии
func set_inventory_layout(layout: Array[Dictionary]) -> void:
	saved_layout = layout

	# Обновляем storage, чтобы список предметов в сундуке соответствовал факту
	storage.clear()
	for e in saved_layout:
		if e.has("data") and e["data"] != null:
			storage.append(e["data"])
