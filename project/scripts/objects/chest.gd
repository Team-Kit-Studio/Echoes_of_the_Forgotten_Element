extends StaticBody2D

# Изначальные предметы (как ты и хотел) — задаются в инспекторе
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
	# (если ты переносишь предметы между инвентарями — тут это тоже отразится)
	storage.clear()
	for e in saved_layout:
		if e.has("data") and e["data"] != null:
			storage.append(e["data"])
