extends Node2D

@onready var text_box_scene = preload("res://project/scenes/ui/Systems/Dialog/Text_Box/text_box.tscn")
@onready var choice_panel_scene = preload("res://project/scenes/ui/Systems/Dialog/ChoicePanel.tscn")
@onready var cinematic_bars: Control = $CinemticBars

var npc: Node = null
var current_text_box: Node = null
var current_choice_panel: Node = null
var waiting_for_choice: bool = false

# Камера игрока
var player_camera: Camera2D = null
var original_camera_pos: Vector2 = Vector2.ZERO
var original_camera_zoom: Vector2 = Vector2.ONE
var original_smoothing_enabled: bool = false
var original_smoothing_speed: float = 5.0

func _ready() -> void:
	await get_tree().process_frame
	if Global.player:
		player_camera = Global.player.get_node("Camera2D")
		if player_camera:
			
			original_camera_zoom = player_camera.zoom
			original_smoothing_enabled = player_camera.position_smoothing_enabled
			original_smoothing_speed = player_camera.position_smoothing_speed

# ------------------------------------------------------------------
# Плавная фокусировка камеры на NPC (отключаем сглаживание)
# ------------------------------------------------------------------
func focus_on_npc(npc_pos: Vector2) -> void:
	if not player_camera:
		return
	
	# Отключаем сглаживание на время анимации
	original_camera_pos = player_camera.global_position
	player_camera.position_smoothing_enabled = false
	
	var target_zoom = Vector2(2.3, 2.3)   # подберите нужный зум
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_camera, "global_position", npc_pos, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_camera, "zoom", target_zoom, 0.4).set_ease(Tween.EASE_OUT)
	await tween.finished

# ------------------------------------------------------------------
# Возврат камеры к игроку (восстанавливаем сглаживание)
# ------------------------------------------------------------------
func restore_camera() -> void:
	if not player_camera:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_camera, "global_position", original_camera_pos, 0.4).set_ease(Tween.EASE_IN)
	tween.tween_property(player_camera, "zoom", original_camera_zoom, 0.4).set_ease(Tween.EASE_IN)
	await tween.finished
	
	# Восстанавливаем сглаживание
	player_camera.position_smoothing_enabled = original_smoothing_enabled
	player_camera.position_smoothing_speed = original_smoothing_speed

# ------------------------------------------------------------------
# 1) Полноценный диалог с NPC (всегда с рамками, блокируем игрока)
# ------------------------------------------------------------------
func show_npc_dialog(_npc: Node) -> void:
	Global.player.can_move = false
	await focus_on_npc(_npc.global_position)
	await cinematic_bars.show_bars()
	
	npc = _npc
	var current_dialog = npc.get_current_dialog()
	if current_dialog == null:
		hide_dialog()
		return
	
	var text = current_dialog["text"]
	var options = current_dialog.get("options", {})
	_show_text_bubble(text, options)

# ------------------------------------------------------------------
# 2) Филлерный текст над NPC (без рамок, без вариантов)
# ------------------------------------------------------------------
func show_npc_text(_npc: Node, text: String) -> void:
	if current_text_box:
		current_text_box.queue_free()
	
	var origin = _npc.get_dialog_origin()
	current_text_box = text_box_scene.instantiate()
	get_tree().root.add_child(current_text_box)
	current_text_box.global_position = origin
	current_text_box.display_text(text)
	current_text_box.finished_displaying.connect(_on_filler_text_finished)

# ------------------------------------------------------------------
# 3) Текст в произвольной позиции (без рамок, без вариантов)
# ------------------------------------------------------------------
func show_text_at_position(text: String, position: Vector2) -> void:
	if current_text_box:
		current_text_box.queue_free()
	
	current_text_box = text_box_scene.instantiate()
	get_tree().root.add_child(current_text_box)
	current_text_box.global_position = position
	current_text_box.display_text(text)
	current_text_box.finished_displaying.connect(_on_filler_text_finished)

# ------------------------------------------------------------------
# Вспомогательный метод для текста с вариантами
# ------------------------------------------------------------------
func _show_text_bubble(text: String, options: Dictionary = {}) -> void:
	if current_text_box:
		current_text_box.queue_free()
	
	var origin = npc.get_dialog_origin()
	origin.y += 30  # смещение вниз, чтобы не перекрывало рамку
	
	current_text_box = text_box_scene.instantiate()
	get_tree().root.add_child(current_text_box)
	current_text_box.global_position = origin
	current_text_box.display_text(text)
	
	if options.size() > 0:
		current_text_box.finished_displaying.connect(_on_text_finished_with_options.bind(options))
	else:
		current_text_box.finished_displaying.connect(_on_text_finished_no_options)

func _on_filler_text_finished() -> void:
	if current_text_box:
		current_text_box.queue_free()
		current_text_box = null

func _on_text_finished_with_options(options: Dictionary) -> void:
	if options.size() > 0:
		_show_choices(options)
	else:
		hide_dialog()

func _on_text_finished_no_options() -> void:
	hide_dialog()

func _show_choices(options: Dictionary) -> void:
	if current_choice_panel:
		current_choice_panel.queue_free()
	
	current_choice_panel = choice_panel_scene.instantiate()
	get_tree().root.add_child(current_choice_panel)
	current_choice_panel.set_options(options)
	current_choice_panel.choice_selected.connect(_on_choice_selected)
	waiting_for_choice = true

func _on_choice_selected(option: String) -> void:
	waiting_for_choice = false
	
	if current_text_box:
		current_text_box.queue_free()
		current_text_box = null
	
	if current_choice_panel:
		await current_choice_panel.hide_slide_out()
		current_choice_panel.queue_free()
		current_choice_panel = null
	
	var current_dialog = npc.get_current_dialog()
	if current_dialog == null:
		hide_dialog()
		return
	
	var next_state = current_dialog["options"].get(option, "start")
	npc.set_dialog_state(next_state)
	
	match next_state:
		"end":
			if npc.current_branch_index < npc.dialog_resource.get_npc_dialog(npc.npc_id).size() - 1:
				npc.set_dialog_tree(npc.current_branch_index + 1)
			hide_dialog()
		"exit":
			npc.set_dialog_state("start")
			hide_dialog()
		"give_quests":
			if npc.dialog_resource.get_npc_dialog(npc.npc_id)[npc.current_branch_index]["branch_id"] == "npc_default":
				offer_remaining_quests()
			else:
				offer_quests(npc.dialog_resource.get_npc_dialog(npc.npc_id)[npc.current_branch_index]["branch_id"])
			show_npc_dialog(npc)
		_:
			show_npc_dialog(npc)

func hide_dialog() -> void:
	if current_text_box:
		current_text_box.queue_free()
		current_text_box = null
	if current_choice_panel:
		current_choice_panel.queue_free()
		current_choice_panel = null
	waiting_for_choice = false
	
	await cinematic_bars.hide_bars()
	await restore_camera()
	
	Global.player.can_move = true

func offer_quests(branch_id: String) -> void:
	for quest in npc.quests:
		if quest.unlock_id == branch_id and quest.state == "not_started":
			npc.offer_quest(quest.quest_id)

func offer_remaining_quests() -> void:
	for quest in npc.quests:
		if quest.state == "not_started":
			npc.offer_quest(quest.quest_id)
