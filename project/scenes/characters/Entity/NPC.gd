extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var Anim: AnimationPlayer = $AnimationPlayer
@onready var dialog_manager: Node2D = $DialogManager

@export var npc_id: String
@export var npc_name: String
@export var dialog_resourse: Dialog

var action: bool = false
var triger:bool = false
var current_state: String = "start"
var current_branch_index: int = 0

# Quest vars
@export var quests: Array[Quest] = []
var quest_manager: Node = null

const lines: Array[String] = [
	"Привет, как дела?",
	"Что делаешь?",
	"Я хочу дать тебе задание, да не простое, а очень сложное",
	". . . . .",
	"шутка",
	"Пока."
]

func _ready() -> void:
	# загружаем диалоги НПС
	dialog_resourse.load_from_json("res://project/data/Resources/Dialog/dialog_data.json")
	# инициализация НПС
	dialog_manager.npc = self
	#Получение ссылки на quest_manager
	quest_manager = Global.player.quest_manager
	print("NPC Ready, Quest loaded: ", quests.size())

func toggle_mode() -> void:
	action = !action

func icon_up() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Up")
	tween.tween_property(interact, "modulate", Color(10.453, 0.931, 0.0), 0.5)

func icon_down() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Down")
	tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.5)

# появление иконки чата
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		icon_up()
		triger = true
		

#получение нужной ветки диалога
func get_current_dialog():
	var npc_dialogs = dialog_resourse.get_npc_dialog(npc_id) 
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog
	return null

# Обновление диалоговой ветки
func set_dialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

# Обновление состояния диалога
func set_dialog_state(state):
	current_state = state
	
func start_dialog() -> void:
	toggle_mode()
	if action and triger:
		$Area2D/AnimatedSprite2D.visible = !visible
		###Global.start_dialog(global_position, lines)
		var npc_dialogs = dialog_resourse.get_npc_dialog(npc_id)
		if npc_dialogs.is_empty():
			return
		dialog_manager.show_dialog(self)
			
	elif Global.is_dialog_active == false:
		print("Появление чата")
		icon_up()
	else:
		#Anim.play_backwards("chat")
		#await Anim.animation_finished
		$Area2D/AnimatedSprite2D.show()

#func _input(_event: InputEvent) -> void:
#	if Input.is_action_pressed("Interaction") and triger:
#		#start_dialog()
#		pass	
#			
		
# исчезание иконки
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		icon_down()
		triger = false
		

# предложить квест в выбранной ветке дилога
func offer_quest(quest_id: String) -> void:
	print("Попытка предложить квест: ", quest_id)
	
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest)
			return
	
	print(" Квест не найден или уже начат")
	
	
# Gets quest dialog
func get_quest_dialog() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialog, "options": {}}
	return {"text": "", "options": {}}
	
	
