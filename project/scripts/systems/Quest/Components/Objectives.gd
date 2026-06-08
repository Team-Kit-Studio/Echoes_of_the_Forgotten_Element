extends Resource
class_name Objectives

# ═══════════════════ ЦЕЛЬ ═══════════════════
@export_category("Цель")
## Уникальное имя цели внутри квеста (например "talk_to_guard").
@export var id: String
## Текст цели, который отображается в журнале (например "Поговорить со стражником").
@export var description: String
## Флаг выполнения (автоматический). Не заполняйте вручную.
@export var is_completed: bool = false

# ═══════════════════ ПАРАМЕТРЫ ═══════════════════
@export_category("Параметры")
## Для talk_to – npc_id персонажа, с которым нужно поговорить. Для collection – item_id предмета.
@export var target_id: String
## Тип цели: "talk_to" (разговор) или "collection" (сбор предметов).
@export var target_type: String

# ═══════════════ КОЛИЧЕСТВО (для collection) ═══════════════
@export_category("Количество (collection)")
## Только для collection: сколько всего нужно собрать предметов.
@export var required_quantity: int = 1
## Только для collection: сколько уже собрано (автоматически). Не редактируйте вручную.
@export var collected_quantity: int = 0

# ═══════════════ ДИАЛОГ (для talk_to) ═══════════════
@export_category("Диалог (talk_to)")
## Только для talk_to: фраза, которую NPC произнесёт при разговоре по этому квесту.
@export_multiline var objective_dialog: String = ""
