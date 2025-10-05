extends Node2D

class_name DoorStateMachine

enum DoorState {
	LOCKED,      # Дверь заперта, требуется ключ
	OPENING,     # Дверь открывается
	OPEN,        # Дверь открыта
	CLOSING      # Дверь закрывается
}

@export var required_item: String = "KeyCardGray"
@export var auto_close_delay: float = 4.0  # Задержка перед закрытием

var current_state: DoorState = DoorState.LOCKED
var player_in_area: bool = false
var player_ref: Node2D = null
var close_timer: Timer

# Ссылки на компоненты
@onready var sprite = $Sprite2D
@onready var left_collision = $Left
@onready var right_collision = $Right
@onready var react_collision = $react/CollisionShape2D
@onready var react = $react
@onready var animation_player = $AnimationPlayer
@onready var audio = $AudioStreamPlayer2D

func _ready():
	# Создаем таймер для авто-закрытия
	close_timer = Timer.new()
	close_timer.one_shot = true
	add_child(close_timer)
	close_timer.timeout.connect(_on_close_timer_timeout)
	
	_enter_state(current_state)

func _enter_state(new_state: DoorState):
	if animation_player.is_playing():
		animation_player.stop()
	current_state = new_state
	
	match new_state:
		DoorState.LOCKED:
			_on_locked_enter()
		DoorState.OPENING:
			_on_opening_enter()
		DoorState.OPEN:
			_on_open_enter()
		DoorState.CLOSING:
			_on_closing_enter()

func transition_to(new_state: DoorState):
	if _can_transition_to(new_state):
		_enter_state(new_state)

func _can_transition_to(new_state: DoorState) -> bool:
	match current_state:
		DoorState.LOCKED:
			return new_state == DoorState.OPENING  # Только открытие при наличии ключа
		DoorState.OPENING:
			return new_state == DoorState.OPEN
		DoorState.OPEN:
			return new_state == DoorState.CLOSING
		DoorState.CLOSING:
			return new_state == DoorState.LOCKED
	return false

# Реализация состояний
func _on_locked_enter():
	if animation_player.has_animation("Door_Lock"):
		print("ЗАКРЫТО")
		animation_player.play("Door_Lock")

func _on_opening_enter():
	if animation_player.has_animation("Door_Open"):
		animation_player.play("Door_Open")
	else:
		# Если нет анимации, сразу открываем
		transition_to(DoorState.OPEN)

func _on_open_enter():
	if animation_player.has_animation("Door_Open_Idle"):
		animation_player.play("Door_Open_Idle")
	elif  animation_player.has_animation("Door_Open"):
		animation_player.stop(false)
	# Если игрок вышел из зоны, запускаем таймер закрытия
	if not player_in_area:
		print("Таймер ПУСК")
		start_close_timer()

func _on_closing_enter():
	if animation_player.has_animation("Door_Close"):
		animation_player.play("Door_Close")
	else:
		# Если нет анимации, сразу закрываем
		transition_to(DoorState.LOCKED)

# Обработка анимаций
func _on_animation_player_animation_finished(anim_name):
	
	match anim_name:
		"Door_Open":
			if current_state == DoorState.OPENING:
				#print("✅ Анимация открытия завершена, переходим в OPEN")
				transition_to(DoorState.OPEN)
			else:
				print("❌ Странно: анимация open завершилась, но состояние не OPENING")
		"Door_Close":
			if current_state == DoorState.CLOSING:
				#print("✅ Анимация закрытия завершена, переходим в LOCKED")
				transition_to(DoorState.LOCKED)
# Таймер закрытия
func start_close_timer():
	close_timer.start(auto_close_delay)

func stop_close_timer():
	if close_timer.time_left > 0:
		close_timer.stop()

func _on_close_timer_timeout():
	print("Состояние = ", current_state)
	print("player_in_area", player_in_area)
	# Таймер сработал только если игрок все еще не в зоне
	if current_state == DoorState.OPEN and not player_in_area:
		transition_to(DoorState.CLOSING)
	else:
		print("Условия не ВЫПОЛНИЛИСЬ")

# Обработка входа/выхода игрока
func _on_react_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_area = true
		player_ref = body
		
		# Останавливаем таймер закрытия (если запущен)
		stop_close_timer()
		
		# Проверяем инвентарь
		check_inventory(body)

func _on_react_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_area = false
		player_ref = null
		
		# Если дверь открыта и игрок вышел - запускаем таймер закрытия
		if current_state == DoorState.OPEN or current_state == DoorState.OPENING:
			print("Запустил таймер")
			start_close_timer()

# Проверка инвентаря
func check_inventory(player: Node2D):
	# Проверяем только если дверь заблокирована
	if current_state != DoorState.LOCKED:
		return
	
	var inventory = get_player_inventory(player)
	
	if inventory and has_required_item(inventory):
		unlock_and_open_door()
	else:
		show_locked_message()

# Функция разблокировки и открытия
func unlock_and_open_door():
	if animation_player.is_playing():
		animation_player.stop()
	
	if current_state == DoorState.LOCKED:
		print("Дверь открыта ключом: ", required_item)
		transition_to(DoorState.OPENING)

# Проверка наличия предмета (исправленная версия)
func has_required_item(inventory: Array) -> bool:
	for item_slot in inventory:
		# Пропускаем пустые слоты
		if item_slot == null:
			continue
		
		# Проверяем что слот имеет поле item и оно не пустое
		if "item" in item_slot and item_slot.item != null:
			var item = item_slot.item
			
			# Проверяем что это ресурс и имеет нужное свойство
			if item is Resource and "ItemName" in item:
				if item.ItemName == required_item:
					print("✅ КЛЮЧ НАЙДЕН: ", item.ItemName)
					return true
	
	return false

# Получение инвентаря игрока
func get_player_inventory(player: Node2D) -> Array:
	if player.has_method("get_inventory"):
		return player.get_inventory()
	elif player.has_method("DataInventory"):
		return player.DataInventory()
	elif player.has_node("Inventory"):
		return player.get_node("Inventory").get_items()
	else:
		return []

# Вспомогательные методы
func show_locked_message():
	if player_in_area:
		var message = "Требуется: " + required_item
		print(message)  # Замените на вашу систему UI
		if animation_player.has_animation("Door_Lock"):
			animation_player.play("Door_Lock")

# Внешнее управление (для отладки)
func force_open():
	if current_state == DoorState.LOCKED:
		transition_to(DoorState.OPENING)

func _input(event):
	# Для отладки - принудительное открытие по Space
	if event.is_action_pressed("ui_accept"):
		force_open()
