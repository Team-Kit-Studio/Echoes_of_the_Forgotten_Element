class_name ItemData
extends Resource

## Уникальный идентификатор предмета (например "KeyCardGray").
## Используется для проверок дверей, квестов и поиска в инвентаре.
@export var item_id: String = ""

## Отображаемое имя предмета.
@export var name: String = "Item"

## Иконка предмета в инвентаре и на земле.
@export var texture: Texture2D

## Текстовое описание (показывается при осмотре).
@export_multiline var description: String = ""

## Ширина в ячейках инвентаря (для тетрис-сетки).
@export var width: int = 1

## Высота в ячейках инвентаря.
@export var height: int = 1

## Текущее количество (стакуемые предметы могут иметь >1).
@export var amount: int = 1:
	set(value):
		amount = value

## Максимальный размер стака. Если >1, предмет можно стакать.
@export var max_stack_size: int = 1

## Удобное свойство: true, если max_stack_size > 1.
var stackable: bool:
	get:
		return max_stack_size > 1

## Флаг поворота (не сохраняется в редакторе, используется в рантайме).
var is_rotated: bool = false

## Возвращает размер в ячейках с учётом поворота.
func get_size() -> Vector2i:
	if is_rotated:
		return Vector2i(height, width)
	return Vector2i(width, height)

## Пытается объединить стак с другим предметом.
## Возвращает true, если хотя бы одна единица была перенесена.
func try_merge(other: ItemData) -> bool:
	if not stackable or not other.stackable: return false
	if name != other.name: return false
	var space = max_stack_size - amount
	if space <= 0: return false
	var transfer = mini(space, other.amount)
	amount += transfer
	other.amount -= transfer
	return true
