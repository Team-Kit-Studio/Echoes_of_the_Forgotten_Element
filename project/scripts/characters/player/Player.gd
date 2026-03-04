extends CharacterBody2D

# Состояния игрока
enum state { MOVE, DAMAGE, ATTACK, DEATH }
@export var speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

# Ссылки на ноды
@onready var audio_sfx1: AudioStreamPlayer2D = $AudioSFX
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var ShadowSprite: AnimatedSprite2D = %AnimatedSprite2D2
@onready var interact: Area2D = $interact  # Зона взаимодействия

# Инвентари (ищем в дереве)
@onready var player_inventory: CanvasItem = get_tree().root.find_child("PlayerInventory", true, false) as CanvasItem
@onready var external_inventory: CanvasItem = get_tree().root.find_child("ExternalInventory", true, false) as CanvasItem

# Менеджер инвентаря (автозагрузка)
@onready var inventory_manager = InventoryManage

var can_move: bool = true

# Названия анимаций
const ANIMATION_NAMES: PackedStringArray = [
	"State_Idle_FromSide", "State_Idle_Up", "State_Idle_Down",
	"State_Run_FromSide", "State_Run_Up", "State_Run_Down"
]

# Переменные состояния
var current_state: state = state.MOVE
var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2i = Vector2i.ZERO
var was_moving: bool = false
var current_target: Node = null  # Текущая цель для взаимодействия

func _ready() -> void:
	Global.player = self
	# Загружаем звук шагов
	var step_sound = preload("res://project/assets/sounds/MSE/zhelezo.mp3")
	audio_sfx1.stream = step_sound
	
	# Включаем зацикливание звука
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
	
	# Обработка состояний
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
	update_nearest_target()  # Обновляем ближайшую цель
	_check_movement_for_footsteps()  # Проверяем шаги

func _unhandled_input(event: InputEvent) -> void:
	# Выход из игры
	if Input.is_action_just_pressed("ui_text_delete"):
		get_tree().quit()
	
	# E — открыть/закрыть инвентари
	if event.is_action_pressed("Inventory"):
		if is_inventory_open():
			close_all_inventories()
		else:
			if player_inventory:
				# Проверяем, не держим ли мы предмет из другого инвентаря
				if inventory_manager and inventory_manager.has_held():
					var source_info = inventory_manager.get_source()
					# Если предмет из внешнего инвентаря - сначала откроем его
					if source_info.inventory == external_inventory:
						if external_inventory and external_inventory.has_method("open_container"):
							external_inventory.open_container(source_info.inventory.bound_container)
						return
				
				# Иначе открываем инвентарь игрока
				player_inventory.visible = true
	
	# F — взаимодействие с выбранной целью
	if event.is_action_pressed("Interaction"):
		handle_f_action()

# =========================================================
# Движение + анимации
# =========================================================
func Move_State(delta: float) -> void:
	# Получаем направление ввода
	input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction != Vector2.ZERO:
		last_direction = get_clean_direction(input_direction)
	
	# Рассчитываем скорость
	var target_velocity: Vector2 = input_direction * speed
	var accel_value: float = acceleration if input_direction != Vector2.ZERO else friction
	velocity = velocity.move_toward(target_velocity, accel_value * delta)
	Move_State_Play_Animation()

func Move_State_Play_Animation() -> void:
	# Определяем индекс анимации (0 - idle, 1 - run)
	var index := 1 if input_direction != Vector2.ZERO else 0
	play_animation(index, last_direction)

# Получение индекса анимации по состоянию и направлению
func get_animation_index(index: int, key: Vector2i) -> int:
	match index:
		0:  # idle
			match key:
				Vector2i.RIGHT, Vector2i.LEFT: return 0  # State_Idle_FromSide
				Vector2i.UP: return 1  # State_Idle_Up
				Vector2i.DOWN: return 2  # State_Idle_Down
				_: return 0
		1:  # run
			match key:
				Vector2i.RIGHT, Vector2i.LEFT: return 3  # State_Run_FromSide
				Vector2i.UP: return 4  # State_Run_Up
				Vector2i.DOWN: return 5  # State_Run_Down
				_: return 0
	return 0

# Преобразование вектора направления в дискретные значения
func get_clean_direction(raw_input: Vector2) -> Vector2i:
	if abs(raw_input.y) > abs(raw_input.x):
		return Vector2i(0, int(sign(raw_input.y)))
	return Vector2i(int(sign(raw_input.x)), 0) if raw_input.x != 0 else Vector2i.ZERO

# Отражение спрайта по горизонтали
func flip_anim() -> void:
	if last_direction.x != 0:
		anim.flip_h = last_direction.x > 0
		ShadowSprite.flip_h = last_direction.x > 0

# Воспроизведение анимации
func play_animation(index: int, key: Vector2i = Vector2i.ZERO) -> void:
	var anim_index := get_animation_index(index, key)
	ShadowSprite.play(ANIMATION_NAMES[anim_index])
	AnimPlayer.play(ANIMATION_NAMES[anim_index])
	flip_anim()

# =========================================================
# Шаги с авторестартом
# =========================================================
func _check_movement_for_footsteps() -> void:
	var is_moving := velocity.length() > 10.0
	if is_moving:
		# Если звук не играет → запускаем
		if not audio_sfx1.playing:
			audio_sfx1.play()
		was_moving = true
	elif was_moving:
		# Остановились → останавливаем звук
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
	# Если держим предмет - обрабатываем через менеджер
	if inventory_manager and inventory_manager.has_held():
		var source_info = inventory_manager.get_source()
		
		# Если предмет из инвентаря игрока - возвращаем
		if source_info.inventory == player_inventory:
			inventory_manager.return_item()
		# Если из внешнего инвентаря - закрываем и возвращаем
		elif external_inventory and external_inventory.visible:
			if external_inventory.has_method("close_container"):
				external_inventory.close_container()
	
	# Закрываем инвентари
	if external_inventory and external_inventory.visible:
		if external_inventory.has_method("close_container"):
			external_inventory.call("close_container")
	
	if player_inventory:
		player_inventory.visible = false

# =========================================================
# Система выбора целей с приоритетами
# =========================================================
func update_nearest_target() -> void:
	if interact == null:
		return
	
	var areas := interact.get_overlapping_areas()
	
	# Храним лучшие цели каждого типа
	var best_item: Node = null
	var best_item_dist := INF
	
	var best_container: Node = null
	var best_container_dist := INF
	
	var best_npc: Node = null
	var best_npc_dist := INF
	
	# Сканируем все объекты в зоне взаимодействия
	for area in areas:
		var distance := global_position.distance_to(area.global_position)
		
		# 1) ПРОВЕРКА НА ПРЕДМЕТ (группа "item") - ВЫСШИЙ ПРИОРИТЕТ
		if area.is_in_group("item"):
			if distance < best_item_dist:
				best_item_dist = distance
				best_item = area
			continue
		
		# 2) ПРОВЕРКА НА КОНТЕЙНЕР (группа "interactable")
		if area.is_in_group("interactable"):
			if distance < best_container_dist:
				best_container_dist = distance
				best_container = area
			continue
		
		# 3) ПРОВЕРКА НА NPC (группа "NPC") - НИЗШИЙ ПРИОРИТЕТ
		if area.is_in_group("NPC"):
			if distance < best_npc_dist:
				best_npc_dist = distance
				best_npc = area
			continue
		
		# Проверяем родителя area
		var parent := area.get_parent()
		if parent:
			if parent.is_in_group("item"):
				if distance < best_item_dist:
					best_item_dist = distance
					best_item = parent
				continue
			
			if parent.is_in_group("interactable"):
				if distance < best_container_dist:
					best_container_dist = distance
					best_container = parent
				continue
			
			if parent.is_in_group("NPC"):
				if distance < best_npc_dist:
					best_npc_dist = distance
					best_npc = parent
	
	# ВЫБОР ЦЕЛИ ПО ПРИОРИТЕТУ
	var new_target: Node = null
	
	# 1. Сначала предметы (дистанция до 50 пикселей)
	if best_item != null and best_item_dist <= 50.0:
		new_target = best_item
	# 2. Потом контейнеры
	elif best_container != null and best_container_dist <= 50.0:
		new_target = best_container
	# 3. И только потом NPC
	elif best_npc != null and best_npc_dist <= 50.0:
		new_target = best_npc
	
	# Обновление подсветки
	if new_target != current_target:
		# Убираем подсветку со старой цели
		if current_target and current_target.has_method("set_highlight"):
			current_target.call("set_highlight", false)
		
		# Устанавливаем новую цель
		current_target = new_target
		
		# Добавляем подсветку новой цели
		if current_target and current_target.has_method("set_highlight"):
			current_target.call("set_highlight", true)

# =========================================================
# Нажатие F: взаимодействие с выбранной целью
# =========================================================
func handle_f_action() -> void:
	if current_target == null:
		return
	
	# Проверяем группу объекта
	if current_target.is_in_group("item"):
		# Предмет — поднять
		var item := current_target as DroppedItem
		if item.data == null:
			return

		if item.has_method("set_highlight"):
			item.set_highlight(false)
		item.queue_free()

		current_target = null
		return
		#if current_target.has_method("pick_up"):
		#	current_target.call("pick_up")
	
	elif current_target.is_in_group("interactable"):
		# Сундук — открыть/закрыть
		if external_inventory and external_inventory.visible and external_inventory.has_method("is_bound_to") and external_inventory.call("is_bound_to", current_target):
			# Если этот сундук уже открыт - закрываем
			close_all_inventories()
			return
		
		# Если держим предмет из другого инвентаря - сначала закроем всё
		if inventory_manager and inventory_manager.has_held():
			var source_info = inventory_manager.get_source()
			if source_info.inventory != external_inventory:
				close_all_inventories()
		
		# Открываем инвентарь игрока (если закрыт)
		if player_inventory and not player_inventory.visible:
			player_inventory.visible = true
		
		# Открываем сундук
		if external_inventory and external_inventory.has_method("open_container"):
			external_inventory.call("open_container", current_target)
		return
	
	elif current_target.is_in_group("NPC"):
		# NPC — взаимодействие
		if current_target.has_method("start_dialog"):
			current_target.call("start_dialog")
		return

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
	
	# Воспроизводим анимацию в зависимости от скорости
	play_animation(0 if velocity.length() < 0.1 else 1, last_direction)
