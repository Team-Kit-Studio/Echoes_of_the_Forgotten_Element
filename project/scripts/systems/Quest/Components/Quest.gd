extends Resource
class_name Quest

# ═══════════════════ ОСНОВНОЕ ═══════════════════
@export_category("Основное")
## Уникальный идентификатор квеста (например "blacksmith_quest"). Используется для поиска и завершения.
@export var quest_id: String
## Название квеста, которое видит игрок в журнале и трекере.
@export var quest_name: String
## Подробное описание задания.
@export_multiline var quest_description: String

# ═══════════════════ ПРОГРЕСС ═══════════════════
@export_category("Прогресс")
## Текущее состояние: "not_started", "in_progress", "completed". Управляется системой – не изменяйте вручную.
@export var state: String = "not_started"
## Необязательный ключ блокировки. Если задан, квест можно получить только после события с таким же unlock_id.
@export var unlock_id: String
## Список целей квеста. Каждая цель – отдельный ресурс Objectives.
@export var objectives: Array[Objectives] = []

# ═══════════════════ НАГРАДЫ ═══════════════════
@export_category("Награды")
## Список наград, которые игрок получит после выполнения всех целей.
@export var rewards: Array[Rewards] = []

func is_completed() -> bool:
	for objective in objectives:
		if not objective.is_completed:
			return false
	return true

func complete_objective(objective_id: String, quantity: int = 1):
	for objective in objectives:
		if objective.id == objective_id:
			if objective.target_type == "collection":
				objective.collected_quantity += quantity
				if objective.collected_quantity >= objective.required_quantity:
					objective.is_completed = true
			else:
				objective.is_completed = true
			break
	if is_completed():
		state = "completed"
