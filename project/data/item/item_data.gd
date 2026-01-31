class_name ItemData
extends Resource

@export var name: String = "Item"
@export var texture: Texture2D
@export_multiline var description: String = ""

# Размеры для тетриса
@export var width: int = 1
@export var height: int = 1

# Настройки стака
@export var amount: int = 1:          # Текущее количество (настраиваем в инспекторе)
	set(value):
		amount = value
		# Если вдруг в инспекторе задали больше макс, расширяем макс? 
		# Или просто ограничиваем? Давай просто хранить.

@export var max_stack_size: int = 1   # Если > 1, то предмет считается стакуемым

# Вычисляемое свойство: можно ли стакать?
var stackable: bool:
	get:
		return max_stack_size > 1

# Состояние поворота (не экспортируем, это рантайм)
var is_rotated: bool = false

func _init() -> void:
	# amount уже инициализирован export-ом
	pass

# Получить размер (для тетриса)
func get_size() -> Vector2i:
	if is_rotated:
		return Vector2i(height, width)
	return Vector2i(width, height)

# Логика слияния
func try_merge(other: ItemData) -> bool:
	# Проверка: оба должны быть стакуемыми
	if not stackable or not other.stackable: return false
	if name != other.name: return false
	
	var space = max_stack_size - amount
	if space <= 0: return false
	
	var transfer = mini(space, other.amount)
	amount += transfer
	other.amount -= transfer
	return true
