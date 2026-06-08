extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var Anim: AnimationPlayer = $AnimationPlayer
@onready var dialog_manager: Node2D = $DialogManager
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var quest_marker: Label = $Area2D/Quest_Marker   # метка (Label)
@onready var ray_cast_2d: RayCast2D = $RayCast2D


@export var npc_id: String
@export var npc_name: String
@export var dialog_resource: Dialog

var triger: bool = false
var current_state: String = "start"
var current_branch_index: int = 0
## Множитель скорости анимации (1.0 = нормальная). Управляется ActorFollower.
var animation_speed: float = 1.0

@export var quests: Array[Quest] = []
var quest_manager: Node = null
var force_hide_marker: bool = false

# Движение
var is_being_controlled_by_cutscene: bool = false
var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2i = Vector2i.LEFT
@export var speed: float = 100.0

# Скины
@export var default_skin: String = "suit"
var current_skin: String = default_skin

var animations: Dictionary = {
	"suit": {
		"idle_right": "State_Idle_FromSide",
		"idle_left":  "State_Idle_FromSide",
		"idle_up":    "State_Idle_Up",
		"idle_down":  "State_Idle_Down",
		"run_right":  "State_Run_FromSide",
		"run_left":   "State_Run_FromSide",
		"run_up":     "State_Run_Up",
		"run_down":   "State_Run_Down"
	},
	"no_suit": {
		"idle_right": "State_Idle_FromSide_No_Costume",
		"idle_left":  "State_Idle_FromSide_No_Costume",
		"idle_up":    "State_Idle_Up",
		"idle_down":  "State_Idle_Down_No_Costume",
		"run_right":  "State_Run_FromSide",
		"run_left":   "State_Run_FromSide",
		"run_up":     "State_Run_Up",
		"run_down":   "State_Run_Down_No_Costume"
	}
}

func _ready() -> void:
	Global.npc = self
	dialog_resource.load_from_json("res://project/data/Resources/Dialog/Components_Scripts/dialog_data.json")
	dialog_manager.npc = self
	quest_manager = Global.player.quest_manager
	if quest_manager:
		quest_manager.quest_updated.connect(_on_quests_changed)
		quest_manager.quest_list_updated.connect(_on_quests_changed)
	# Подписываемся на завершение диалога, чтобы обновить метку
	if not dialog_manager.is_connected("dialog_finished", _on_dialog_finished):
		dialog_manager.dialog_finished.connect(_on_dialog_finished)
	current_skin = default_skin
	if sprite:
		if last_direction.x != 0:
			sprite.flip_h = last_direction.x > 0
	update_quest_marker()
	print("NPC Ready, Quest loaded: ", quests.size())

func _physics_process(delta: float) -> void:
	if is_being_controlled_by_cutscene:
		_check_door_with_ray()   # ← новый вызов
		update_animation()
		move_and_slide()
		return
	velocity = Vector2.ZERO
	update_animation()
	move_and_slide()

func _check_door_with_ray() -> void:
	if not ray_cast_2d or not is_being_controlled_by_cutscene:
		return
	var dir = last_direction
	if dir == Vector2i.ZERO:
		return
	ray_cast_2d.target_position = Vector2(dir * 80)
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider and collider.is_in_group("door") and collider.has_method("force_open"):
			collider.force_open()

func get_clean_direction(raw_input: Vector2) -> Vector2i:
	if abs(raw_input.y) > abs(raw_input.x):
		return Vector2i(0, int(sign(raw_input.y)))
	return Vector2i(int(sign(raw_input.x)), 0) if raw_input.x != 0 else Vector2i.ZERO

func update_animation() -> void:
	if not Anim:
		return
	var is_moving = velocity.length() > 10.0
	if is_moving:
		var dir = Vector2.ZERO
		if abs(velocity.x) > abs(velocity.y):
			dir.x = sign(velocity.x)
		else:
			dir.y = sign(velocity.y)
		if dir != Vector2.ZERO:
			last_direction = get_clean_direction(dir)
	if sprite:
		if last_direction.x != 0:
			sprite.flip_h = last_direction.x > 0
	var anim_block = animations.get(current_skin, animations["suit"])
	var anim_name = ""
	var dir_key = ""
	match last_direction:
		Vector2i(1,0):  dir_key = "right"
		Vector2i(-1,0): dir_key = "left"
		Vector2i(0,-1): dir_key = "up"
		Vector2i(0,1):  dir_key = "down"
		_:              dir_key = "down"
	if is_moving:
		anim_name = anim_block["run_" + dir_key]
	else:
		anim_name = anim_block["idle_" + dir_key]
	Anim.speed_scale = animation_speed
	Anim.play(anim_name)

func update_animation_based_on_state() -> void:
	update_animation()

func set_skin(skin_name: String) -> void:
	if animations.has(skin_name):
		current_skin = skin_name
		update_animation()
	else:
		push_error("NPC: неизвестный скин " + skin_name)

func set_is_controlled(flag: bool) -> void:
	is_being_controlled_by_cutscene = flag

# Иконка чата (старая анимация) больше не используется, но оставлена для совместимости
func icon_up() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Up")
	tween.tween_property(interact, "modulate", Color(10.453, 0.931, 0.0), 0.5)

func icon_down() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Down")
	tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.5)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		icon_up()
		triger = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		icon_down()
		triger = false

# ------------------ МЕТКА КВЕСТА / ДИАЛОГА ------------------
func update_quest_marker() -> void:
	if not quest_marker:
		return
	if force_hide_marker:          # <-- проверка флага
		quest_marker.visible = false
		return
		
	var has_quest = has_available_quest()
	var has_dialog = has_available_dialog()

	if has_quest and has_dialog:
		quest_marker.text = "!"
		quest_marker.add_theme_color_override("font_color", Color.GOLD)
		quest_marker.visible = true
	elif has_quest:
		quest_marker.text = "!"
		quest_marker.add_theme_color_override("font_color", Color.RED)
		quest_marker.visible = true
	elif has_dialog:
		quest_marker.text = "?"
		quest_marker.add_theme_color_override("font_color", Color.RED)
		quest_marker.visible = true
	else:
		quest_marker.visible = false

# Есть ли доступный квест (не начатый или in_progress с целью "talk_to" для этого NPC)
func has_available_quest() -> bool:
	for quest in quests:
		if quest.state == "not_started":
			return true
		elif quest.state == "in_progress":
			for obj in quest.objectives:
				if obj.target_id == npc_id and obj.target_type == "talk_to" and not obj.is_completed:
					return true
	return false

# Есть ли доступный диалог (не null в текущем состоянии)
func has_available_dialog() -> bool:
	return get_current_dialog() != null

func _on_quests_changed(_param = null):
	update_quest_marker()

func _on_dialog_finished():
	update_quest_marker()

# ------------------ ДИАЛОГИ ------------------
func get_current_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id) 
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog
	return null

func set_dialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

func set_dialog_state(state):
	current_state = state

func start_dialog(type: String = "full", text: String = "", position: Vector2 = Vector2.ZERO, ignore_triger: bool = false, wait_for_input: bool = true, actor_path: String = "") -> void:
	if not ignore_triger and not triger:
		return
	match type:
		"full":
			$Area2D/AnimatedSprite2D.visible = false
			var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
			if npc_dialogs.is_empty():
				return
			dialog_manager.show_npc_dialog(self)
		"filler":
			dialog_manager.show_npc_text(self, text, wait_for_input)
		"text_at_position":
			dialog_manager.show_text_at_position(text, position, wait_for_input)
		"over_actor":
			dialog_manager.show_text_over_actor(actor_path, text, wait_for_input)

func start_dialog_and_wait(type: String = "full", text: String = "", position: Vector2 = Vector2.ZERO, ignore_triger: bool = true, wait_for_input: bool = true, actor_path: String = "") -> Signal:
	start_dialog(type, text, position, ignore_triger, wait_for_input, actor_path)
	return dialog_manager.dialog_finished

func show_text_over_actor(actor_path: String, text: String, wait_for_input: bool = true) -> void:
	dialog_manager.show_text_over_actor(actor_path, text, wait_for_input)

func show_text_over_actor_and_wait(actor_path: String, text: String, wait_for_input: bool = true) -> Signal:
	return dialog_manager.show_text_over_actor_and_wait(actor_path, text, wait_for_input)

# ------------------ КВЕСТЫ ------------------
func offer_quest(quest_id: String) -> void:
	print("Попытка предложить квест: ", quest_id)
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest)
			update_quest_marker()
			return
	print("Квест не найден или уже начат")

func set_force_hide_marker(val: bool) -> void:
	force_hide_marker = val
	update_quest_marker()

func get_quest_dialog() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialog, "options": {}}
	return {"text": "", "options": {}}

func get_dialog_origin() -> Vector2:
	return global_position + Vector2(0, -32)
