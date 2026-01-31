class_name InventorySlot
extends Control

# Перечисление состояний слота для подсветки
enum SlotState {
	DEFAULT,   # Обычное состояние (фон инвентаря)
	VALID,     # Зеленый: сюда можно положить предмет
	INVALID,   # Красный: сюда нельзя положить (занято или выход за границы)
	SWAP       # Желтый: произойдет обмен предметами
}

# Словарь, связывающий состояние с цветом
const STATE_COLORS = {
	SlotState.DEFAULT: Color(1.0, 1.0, 1.0, 1.0), # Темно-серый
	SlotState.VALID:   Color(0.2, 0.6, 0.2, 1.0),    # Зеленый
	SlotState.INVALID: Color(0.6, 0.2, 0.2, 1.0),    # Красный
	SlotState.SWAP:    Color(0.6, 0.6, 0.2, 1.0)     # Желтый
}

# Ссылка на узел ColorRect, который служит фоном слота
@onready var background: ColorRect = $ColorRect

func _ready() -> void:
	# Устанавливаем начальный цвет
	set_state(SlotState.DEFAULT)

# Основная функция: меняет цвет фона в зависимости от переданного состояния
func set_state(state: SlotState) -> void:
	if background and state in STATE_COLORS:
		background.color = STATE_COLORS[state]
