# inventory_manager.gd
extends Node

# Текущее состояние
var held_item_data: ItemData = null
var held_item_visual: Node2D = null
var source_grid: Node = null  # ItemGrid, откуда взяли предмет
var source_inventory: Node = null  # Inventory, откуда взяли предмет

# Взять предмет
func pick_up(item_data: ItemData, visual: Node2D, grid: Node, inventory: Node) -> void:
	# Если уже что-то держим - сначала возвращаем
	if held_item_data:
		return_item()
	
	held_item_data = item_data
	held_item_visual = visual
	source_grid = grid
	source_inventory = inventory
	
	# Добавляем в группу для глобального поиска
	if visual:
		visual.add_to_group("held_item")

# Положить предмет (успешное размещение)
func place(item_data: ItemData, visual: Node2D) -> bool:
	if held_item_data != item_data:
		return false
	
	# Убираем из группы
	if visual:
		visual.remove_from_group("held_item")
	
	held_item_data = null
	held_item_visual = null
	source_grid = null
	source_inventory = null
	
	return true

# Вернуть предмет в исходный инвентарь
func return_item() -> void:
	if not held_item_data or not source_grid:
		return
	
	# Находим оригинальную позицию предмета
	var origin = source_grid.get_item_origin(held_item_data)
	if origin != Vector2i(-1, -1):
		# Прямое размещение в исходной сетке
		if source_grid.try_add_item_at(held_item_data, held_item_visual, origin):
			if held_item_visual:
				held_item_visual.remove_from_group("held_item")
			
			# Обновляем визуал
			held_item_visual.set_grid_position(source_grid.grid_to_screen(origin))
			
			held_item_data = null
			held_item_visual = null
			source_grid = null
			source_inventory = null

# Проверить, держим ли мы предмет
func has_held() -> bool:
	return held_item_data != null

# Получить держимый предмет
func get_held_data() -> ItemData:
	return held_item_data

# Получить визуал держимого предмета
func get_held_visual() -> Node2D:
	return held_item_visual

# Получить источник
func get_source() -> Dictionary:
	return {
		"grid": source_grid,
		"inventory": source_inventory
	}

# Очистить всё (принудительно)
func clear() -> void:
	if held_item_visual:
		held_item_visual.remove_from_group("held_item")
	
	held_item_data = null
	held_item_visual = null
	source_grid = null
	source_inventory = null
