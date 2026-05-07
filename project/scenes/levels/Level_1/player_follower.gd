extends PathFollow2D

signal finished

@export var speed: float = 100.0
@export var message_progress: float = 200.0
@export var message_text: String = "Ну вот я и на месте!"
@export var message_position: Vector2 = Vector2(1650, 1690)

var player_node: CharacterBody2D = null
var message_shown: bool = false
var dialog_manager
var is_moving: bool = false
var cinematic_bars = null

func _ready() -> void:
	dialog_manager = Global.npc.dialog_manager
	if dialog_manager:
		cinematic_bars = dialog_manager.cinematic_bars

func show_bars() -> void:
	if cinematic_bars:
		await cinematic_bars.show_bars()

func hide_bars() -> void:
	if cinematic_bars:
		await cinematic_bars.hide_bars()

func start() -> void:
	if is_moving:
		return
	player_node = get_tree().root.find_child("Player", true, false)
	if not player_node:
		push_error("Player not found")
		return
	
	player_node.is_being_controlled_by_cutscene = true
	player_node.can_move = false
	player_node.visible = true
	if player_node.has_method("set_skin"):
		player_node.set_skin("no_suit")
	await get_tree().create_timer(2).timeout
	
	# Устанавливаем начальное направление по первой точке пути
	var first_point = global_position
	var start_direction = (first_point - player_node.global_position).normalized()
	if start_direction.length() > 0:
		player_node.input_direction = start_direction
		player_node.last_direction = player_node.get_clean_direction(start_direction)
		player_node.update_animation_based_on_state()
	
	progress = 0.0
	message_shown = false
	is_moving = true
	set_process(true)

func _process(delta: float) -> void:
	if not is_moving or not player_node:
		return

	var total_length = get_parent().curve.get_baked_length()
	var next_progress = progress + speed * delta
	
	if next_progress >= total_length:
		_finish()
		return
	
	progress = next_progress
	
	# Получаем точную позицию на кривой (в координатах мира)
	var target_local = get_parent().curve.sample_baked(progress)
	var target_pos = get_parent().global_position + target_local
	var direction = (target_pos - player_node.global_position).normalized()
	
	# Если направление почти нулевое (игрок уже на месте), выходим
	if direction.length() < 0.01:
		_finish()
		return

	player_node.velocity = direction * speed
	player_node.input_direction = direction
	player_node.last_direction = player_node.get_clean_direction(direction)
	player_node.update_animation_based_on_state()
	
	if not message_shown and progress >= message_progress:
		message_shown = true
		_show_message()

func _show_message() -> void:
	if dialog_manager:
		dialog_manager.show_text_at_position(message_text, message_position)
	else:
		print("Диалоговый менеджер не найден")

func _finish() -> void:
	is_moving = false
	set_process(false)
	if player_node and is_instance_valid(player_node):
		player_node.input_direction = Vector2.ZERO
		player_node.velocity = Vector2.ZERO
		player_node.update_animation_based_on_state()
		await get_tree().create_timer(2).timeout
		if player_node.has_method("set_skin"):
			player_node.set_skin("suit")
		player_node.is_being_controlled_by_cutscene = false
		player_node.can_move = true
	player_node = null
	finished.emit()
