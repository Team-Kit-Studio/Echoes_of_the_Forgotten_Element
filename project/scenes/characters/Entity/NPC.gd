extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var Anim: AnimationPlayer = $AnimationPlayer
@onready var dialog_manager: Node2D = $DialogManager

@export var npc_id: String
@export var npc_name: String
@export var dialog_resource: Dialog

var triger: bool = false
var current_state: String = "start"
var current_branch_index: int = 0

# Квесты, связанные с NPC
@export var quests: Array[Quest] = []
var quest_manager: Node = null

func _ready() -> void:
	Global.npc = self
	dialog_resource.load_from_json("res://project/data/Resources/Dialog/dialog_data.json")
	dialog_manager.npc = self
	quest_manager = Global.player.quest_manager
	print("NPC Ready, Quest loaded: ", quests.size())

# ------------------------------------------------------------------
# Анимация появления иконки чата
# ------------------------------------------------------------------
func icon_up() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Up")
	tween.tween_property(interact, "modulate", Color(10.453, 0.931, 0.0), 0.5)

# ------------------------------------------------------------------
# Анимация исчезновения иконки чата
# ------------------------------------------------------------------
func icon_down() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Down")
	tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.5)

# ------------------------------------------------------------------
# Игрок вошёл в зону взаимодействия
# ------------------------------------------------------------------
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		icon_up()
		triger = true

# ------------------------------------------------------------------
# Игрок вышел из зоны взаимодействия
# ------------------------------------------------------------------
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		icon_down()
		triger = false

# ------------------------------------------------------------------
# Получение текущего диалога из ресурса по состоянию
# ------------------------------------------------------------------
func get_current_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id) 
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog
	return null

# ------------------------------------------------------------------
# Установка текущей ветки диалога
# ------------------------------------------------------------------
func set_dialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

# ------------------------------------------------------------------
# Установка состояния диалога (текущей реплики)
# ------------------------------------------------------------------
func set_dialog_state(state):
	current_state = state

# ------------------------------------------------------------------
# Запуск диалога (вызывается игроком)
# ------------------------------------------------------------------
func start_dialog() -> void:
	if triger:
		$Area2D/AnimatedSprite2D.visible = false
		var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
		if npc_dialogs.is_empty():
			return
		# Полноценный диалог с рамками
		dialog_manager.show_npc_dialog(self)


# ------------------------------------------------------------------
# Предложение квеста игроку
# ------------------------------------------------------------------
func offer_quest(quest_id: String) -> void:
	print("Попытка предложить квест: ", quest_id)
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest)
			return
	print("Квест не найден или уже начат")

# ------------------------------------------------------------------
# Получение диалога, связанного с квестом (если есть)
# ------------------------------------------------------------------
func get_quest_dialog() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialog, "options": {}}
	return {"text": "", "options": {}}

# ------------------------------------------------------------------
# Точка для отображения облачка текста (над головой)
# ------------------------------------------------------------------
func get_dialog_origin() -> Vector2:
	return global_position + Vector2(0, -32)
