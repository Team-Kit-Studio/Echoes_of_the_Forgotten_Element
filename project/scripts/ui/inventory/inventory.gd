extends PanelContainer

@export var items: Array[ItemData] = []
@export var inventory_item_scene: PackedScene

@onready var item_grid: Node = %ItemGrid

var bound_container: Node = null


func _ready() -> void:
	await get_tree().process_frame
	for item_data in items:
		if item_data:
			add_item(item_data)


func _get_drop_zone() -> Node:
	return get_tree().root.find_child("DropZone", true, false)


func _hide_drop_zone_if_needed() -> void:
	var dz = _get_drop_zone()
	if dz and dz.has_method("hide_zone"):
		dz.hide_zone()


func add_item(item_data: ItemData) -> void:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	add_child(inventory_item)

	if not item_grid.try_add_item(item_data, inventory_item):
		inventory_item.queue_free()


func _clear_visual_items() -> void:
	for child in get_children():
		if child.is_in_group("inventory_item") and not child.is_in_group("held_item"):
			child.queue_free()


func open_container(container: Node) -> void:
	bound_container = container

	_clear_visual_items()
	item_grid.clear_grid_data_only()

	await get_tree().process_frame

	var layout: Array[Dictionary] = []
	if container and container.has_method("get_inventory_layout"):
		layout = container.get_inventory_layout()

	for e in layout:
		var data: ItemData = e.get("data", null)
		var origin: Vector2i = e.get("origin", Vector2i(-1, -1))
		if data == null:
			continue

		var inv_item = inventory_item_scene.instantiate()
		inv_item.data = data
		add_child(inv_item)

		if not item_grid.try_add_item_at(data, inv_item, origin):
			if not item_grid.try_add_item(data, inv_item):
				inv_item.queue_free()

	visible = true


func close_container() -> void:
	_hide_drop_zone_if_needed()

	if bound_container and bound_container.has_method("set_inventory_layout"):
		var layout = item_grid.export_layout()
		bound_container.set_inventory_layout(layout)

	bound_container = null
	visible = false


func is_bound_to(container: Node) -> bool:
	return bound_container == container


# Если это PlayerInventory (а не External), можно закрывать без container
func close_player_inventory() -> void:
	_hide_drop_zone_if_needed()
	visible = false
