extends CharacterBody2D

enum state { MOVE, DAMAGE, ATTACK, DEATH }

@export var speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@onready var audio_sfx1: AudioStreamPlayer2D = $AudioSFX
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var ShadowSprite: AnimatedSprite2D = %AnimatedSprite2D2

# Зона взаимодействия (Area2D)
@onready var interact: Area2D = $interact

# Инвентари (ищем в дереве)
@onready var player_inventory: CanvasItem = get_tree().root.find_child("PlayerInventory", true, false) as CanvasItem
@onready var external_inventory: CanvasItem = get_tree().root.find_child("ExternalInventory", true, false) as CanvasItem

const ANIMATION_NAMES: PackedStringArray = [
	"State_Idle_FromSide", "State_Idle_Up", "State_Idle_Down",
	"State_Run_FromSide", "State_Run_Up", "State_Run_Down"
]

var current_state: state = state.MOVE

var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2i = Vector2i.ZERO
var was_moving: bool = false
var current_target: Node = null

func _ready() -> void:
	# ✅ Загружаем звук шагов
	var step_sound = preload("res://project/assets/sounds/MSE/zhelezo.mp3")
	audio_sfx1.stream = step_sound
	
	# ✅ ВКЛЮЧАЕМ LOOP В КОДЕ (если забыли в Import Settings)
	if audio_sfx1.stream is AudioStreamMP3:
		audio_sfx1.stream.loop = true
	elif audio_sfx1.stream is AudioStreamOggVorbis:
		audio_sfx1.stream.loop = true

func _physics_process(delta: float) -> void:
	# Если инвентарь открыт — игрок стоит
	if is_inventory_open():
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_stop_footsteps()
		input_direction = Vector2.ZERO
		Move_State_Play_Animation()
		move_and_slide()
		return

	# Движение + анимация + шаги
	match current_state:
		state.MOVE:
			Move_State(delta)
		state.DAMAGE:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			_stop_footsteps()
		state.ATTACK:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			_stop_footsteps()
		state.DEATH:
			velocity = Vector2.ZERO
			_stop_footsteps()

	move_and_slide()
	update_nearest_target()
	_check_movement_for_footsteps()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_filedialog_delete"):
		get_tree().quit()

	# E — открыть/закрыть инвентари
	if event.is_action_pressed("Inventory"):
		if is_inventory_open():
			close_all_inventories()
		else:
			if player_inventory:
				player_inventory.visible = true

	# F — поднять предмет или открыть/закрыть контейнер
	if event.is_action_pressed("Interaction"):
		handle_f_action()

# =========================================================
# Движение + анимации
# =========================================================

func Move_State(delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")

	if input_direction != Vector2.ZERO:
		last_direction = get_clean_direction(input_direction)

	var target_velocity: Vector2 = input_direction * speed
	var accel_value: float = acceleration if input_direction != Vector2.ZERO else friction
	velocity = velocity.move_toward(target_velocity, accel_value * delta)

	Move_State_Play_Animation()

func Move_State_Play_Animation() -> void:
	var index := 1 if input_direction != Vector2.ZERO else 0
	play_animation(index, last_direction)

func get_animation_index(index: int, key: Vector2i) -> int:
	match index:
		0: # idle
			match key:
				Vector2i.RIGHT, Vector2i.LEFT: return 0
				Vector2i.UP: return 1
				Vector2i.DOWN: return 2
				_: return 0
		1: # run
			match key:
				Vector2i.RIGHT, Vector2i.LEFT: return 3
				Vector2i.UP: return 4
				Vector2i.DOWN: return 5
				_: return 0
	return 0

func get_clean_direction(raw_input: Vector2) -> Vector2i:
	if abs(raw_input.y) > abs(raw_input.x):
		return Vector2i(0, int(sign(raw_input.y)))
	return Vector2i(int(sign(raw_input.x)), 0) if raw_input.x != 0 else Vector2i.ZERO

func flip_anim() -> void:
	if last_direction.x != 0:
		anim.flip_h = last_direction.x > 0
		ShadowSprite.flip_h = last_direction.x > 0

func play_animation(index: int, key: Vector2i = Vector2i.ZERO) -> void:
	var anim_index := get_animation_index(index, key)
	ShadowSprite.play(ANIMATION_NAMES[anim_index])
	AnimPlayer.play(ANIMATION_NAMES[anim_index])
	flip_anim()

# =========================================================
# ✅ ШАГИ С АВТОРЕЕСТАРТОМ
# =========================================================

func _check_movement_for_footsteps() -> void:
	var is_moving := velocity.length() > 10.0
	
	if is_moving:
		# ✅ Если звук не играет → запускаем
		if not audio_sfx1.playing:
			audio_sfx1.play()
		was_moving = true
	elif was_moving:
		# ✅ Остановились → останавливаем
		_stop_footsteps()

func _stop_footsteps() -> void:
	if audio_sfx1.playing:
		audio_sfx1.stop()
	was_moving = false

# =========================================================
# Инвентари
# =========================================================

func is_inventory_open() -> bool:
	var p_open := (player_inventory != null and player_inventory.visible)
	var e_open := (external_inventory != null and external_inventory.visible)
	return p_open or e_open

func close_all_inventories() -> void:
	if external_inventory and external_inventory.visible:
		if external_inventory.has_method("close_container"):
			external_inventory.call("close_container")
	if player_inventory:
		player_inventory.visible = false

# =========================================================
# Поиск ближайшего (DroppedItem приоритетнее сундуков)
# =========================================================

func update_nearest_target() -> void:
	if interact == null:
		return

	var areas := interact.get_overlapping_areas()

	var best_item: DroppedItem = null
	var best_item_dist := INF

	var best_chest: Node = null
	var best_chest_dist := INF

	for a in areas:
		# 1) Предмет (DroppedItem)
		var di := a as DroppedItem
		if di != null and di.data != null:
			var d := global_position.distance_to(di.global_position)
			if d < best_item_dist:
				best_item_dist = d
				best_item = di
			continue

		# 2) Сундук (родитель area в группе interactable)
		var parent := a.get_parent()
		if parent and parent.is_in_group("interactable"):
			var d2 := global_position.distance_to(parent.global_position)
			if d2 < best_chest_dist:
				best_chest_dist = d2
				best_chest = parent

	var new_target: Node = best_item if best_item != null else best_chest

	if new_target == current_target:
		return

	if current_target and current_target.has_method("set_highlight"):
		current_target.call("set_highlight", false)

	current_target = new_target

	if current_target and current_target.has_method("set_highlight"):
		current_target.call("set_highlight", true)

# =========================================================
# Нажатие F: поднять предмет или открыть/закрыть сундук
# =========================================================

func handle_f_action() -> void:
	if current_target == null:
		return

	# 1) Предмет — поднять
	if current_target is DroppedItem:
		var item := current_target as DroppedItem
		if item.data == null:
			return

		if player_inventory and player_inventory.has_method("add_item"):
			player_inventory.call("add_item", item.data)

		if item.has_method("set_highlight"):
			item.call("set_highlight", false)
		item.queue_free()

		current_target = null
		return

	# 2) Сундук — toggle
	if current_target.is_in_group("interactable"):
		if external_inventory and external_inventory.visible and external_inventory.has_method("is_bound_to") and external_inventory.call("is_bound_to", current_target):
			close_all_inventories()
			return

		if player_inventory:
			player_inventory.visible = true
		if external_inventory and external_inventory.has_method("open_container"):
			external_inventory.call("open_container", current_target)

# =========================================================
# Сохранение/загрузка
# =========================================================

func data() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y},
		"direction": {"x": last_direction.x, "y": last_direction.y},
		"velocity": {"x": velocity.x, "y": velocity.y}
	}

func load_data(save_data: Dictionary) -> void:
	if save_data.has("position"):
		global_position.x = save_data.position.x
		global_position.y = save_data.position.y
	
	if save_data.has("direction"):
		last_direction.x = save_data.direction.x
		last_direction.y = save_data.direction.y
	
	if save_data.has("velocity"):
		velocity.x = save_data.velocity.x
		velocity.y = save_data.velocity.y
	
	play_animation(0 if velocity.length() < 0.1 else 1, last_direction)
