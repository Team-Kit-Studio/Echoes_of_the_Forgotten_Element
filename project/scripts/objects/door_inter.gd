extends RigidBody2D

class_name DoorStateMachine

enum DoorState {
	LOCKED,
	UNLOCKED,
	OPENING,
	OPEN,
	CLOSING
}

@export var required_item: String = "KeyCardGray"
@export var auto_close: bool = false
@export var auto_close_delay: float = 3.0

var current_state: DoorState = DoorState.LOCKED    
var player_in_area: bool = false                   
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D               
@onready var door_collision_left: CollisionShape2D = $Left
@onready var door_collision_right: CollisionShape2D = $Right
@onready var react: Area2D= $react
@onready var react_collision: CollisionShape2D = $react/CollisionShape2D  
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var Audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer

signal state_changed(old_state, new_state)         # Изменилось состояние
signal door_unlocked()                             # Дверь разблокирована
signal door_opened()                               # Дверь открыта
signal door_closed()

func _ready():
	# Инициализация начального состояния
	_enter_state(current_state)
	
func _enter_state(new_state: DoorState):
	# Сохраняем предыдущее состояние для сигнала
	var old_state = current_state
	# Обновляем текущее состояние
	current_state = new_state
	
	# Выполняем действия при входе в конкретное состояние
	match new_state:
		DoorState.LOCKED:
			_on_locked_enter()
		DoorState.UNLOCKED:
			_on_unlocked_enter()
		DoorState.OPENING:
			_on_opening_enter()
		DoorState.OPEN:
			_on_open_enter()
		DoorState.CLOSING:
			_on_closing_enter()
	
	# Уведомляем о смене состояния
	state_changed.emit(old_state, new_state)

func transition_to(new_state: DoorState):
	# Пытаемся перейти в новое состояние, если это возможно
	if _can_transition_to(new_state):
		_enter_state(new_state)

func _can_transition_to(new_state: DoorState) -> bool:
	# Проверяем возможные переходы из текущего состояния
	match current_state:
		DoorState.LOCKED:
			# Из LOCKED можно перейти только в UNLOCKED
			return new_state == DoorState.UNLOCKED
		DoorState.UNLOCKED:
			# Из UNLOCKED можно открыть или снова запереть дверь
			return new_state in [DoorState.OPENING, DoorState.LOCKED]
		DoorState.OPENING:
			# После открытия переходим в OPEN
			return new_state == DoorState.OPEN
		DoorState.OPEN:
			# Из OPEN можно начать закрытие или запереть
			return new_state in [DoorState.CLOSING, DoorState.LOCKED]
		DoorState.CLOSING:
			# После закрытия возвращаемся в UNLOCKED
			return new_state == DoorState.UNLOCKED
	return false
	
# Реализация состояний
func _on_locked_enter():
	door_closed.emit()
	# Проигрываем анимацию заблокированной двери
	if animation_player.has_animation("Door_Lock"):
		animation_player.play("Door_Lock")
	
	# Если игрок уже в зоне, проверяем его инвентарь
	if player_in_area and player_ref:
		check_inventory(player_ref)
func _on_unlocked_enter():
	# Уведомляем о разблокировке
	door_unlocked.emit()
	# Автоматически открываем если игрок в зоне
	if player_in_area:
		transition_to(DoorState.OPENING)
		
func _on_opening_enter():
	# Проигрываем анимацию открытия
	if animation_player.has_animation("Door_Open"):
		animation_player.play("Door_Open")
	else:
		# Если анимации нет, сразу переходим в OPEN
		transition_to(DoorState.OPEN)
		
func _on_open_enter():
	# Уведомляем об открытии
	door_opened.emit()
	
	# Если включено авто-закрытие, ждем и закрываем
	if auto_close:
		await get_tree().create_timer(auto_close_delay).timeout
		if current_state == DoorState.OPEN:
			transition_to(DoorState.CLOSING)
			
func _on_closing_enter():
	# Анимация закрытия
	if animation_player.has_animation("close"):
		animation_player.play("close")
	else:
		# Если анимации нет, сразу переходим в UNLOCKED
		transition_to(DoorState.UNLOCKED)
		
# Обработка завершения анимаций
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Door_Open":
			# После анимации открытия переходим в состояние OPEN
			if current_state == DoorState.OPENING:
				transition_to(DoorState.OPEN)
		"Door_Close":
			# После анимации закрытия переходим в UNLOCKED
			if current_state == DoorState.CLOSING:
				transition_to(DoorState.UNLOCKED)
				
	

func _on_react_body_entered(body: Node2D) -> void:
	# Проверяем что вошел игрок (по имени или группе)
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_area = true      # Отмечаем что игрок в зоне
		player_ref = body          # Сохраняем ссылку на игрока
		
		# Обновляем подсказку для игрока
		update_interaction_prompt()
		
		# Проверяем инвентарь игрока
		check_inventory(body)
		
		
func _on_react_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_area = false     # Игрок вышел из зоны
		player_ref = null          # Очищаем ссылку
		hide_interaction_prompt()

# Основная функция проверки инвентаря
func check_inventory(player: Node2D):
	# Проверяем только если дверь заблокирована
	if current_state != DoorState.LOCKED:
		return
	
	 # Получаем инвентарь игрока
	var inventory = get_player_inventory(player)
	
	# Проверяем наличие нужного предмета
	if inventory and has_required_item(inventory):
		unlock_door()  # Разблокируем дверь если есть ключ
	else:
		show_locked_message()  # Показываем сообщение если ключа нет

# Получение инвентаря игрока разными способами
func get_player_inventory(player: Node2D) -> Array:
	# Пытаемся получить инвентарь разными методами
	if player.has_method("get_inventory"):
		return player.get_inventory()
	elif player.has_method("DataInventory"):
		return player.DataInventory()
	elif player.has_node("Inventory"):
		return player.get_node("Inventory").get_items()
	else:
		# Если не нашли инвентарь, возвращаем пустой массив
		print("Инвентарь не найден")
		return []

# Проверка наличия требуемого предмета в инвентаре
# Проверка наличия требуемого предмета в инвентаре
func has_required_item(inventory: Array) -> bool:
	for item_slot in inventory:
		# Извлекаем предмет из слота
		var item = extract_item_from_slot(item_slot)
		
		# Получаем название предмета
		var item_name = get_item_name(item)
		
		# Сравниваем с требуемым предметом
		if item_name == required_item:
			return true
			
	return false

# Извлечение предмета из слота инвентаря
func extract_item_from_slot(item_slot) -> Variant:
	if item_slot is Dictionary and "item" in item_slot:
		return item_slot["item"]
	elif item_slot is Object and item_slot.has_method("get_item"):
		return item_slot.get_item()
	else:
		return item_slot

# Получение названия предмета
func get_item_name(item) -> String:
	if item == null:
		return ""
		
	if item is String:
		return item
	elif item is Object and item.has_method("get_item_name"):
		return item.get_item_name()
	elif item is Object and "ItemName" in item:
		return item.ItemName
	elif item is Dictionary and "ItemName" in item:
		return item["ItemName"]
	else:
		return ""

# Разблокировка двери
func unlock_door():
	if current_state == DoorState.LOCKED:
		print("Дверь открыта ключом: ", required_item)
		transition_to(DoorState.UNLOCKED)
		
# Показать сообщение о заблокированной двери
func show_locked_message():
	if player_in_area:
		# Создаем текст сообщения
		var message = "Требуется: " + required_item
		show_floating_text(message)  # Показываем игроку
		
		# Воспроизводим звук заблокированной двери
		play_locked_sound()
		
# Обновление подсказки взаимодействия
func update_interaction_prompt():
	if not player_in_area:
		return
		
	# Показываем разные подсказки в зависимости от состояния
	match current_state:
		DoorState.LOCKED:
			show_interaction_prompt("Нажмите F (требуется ключ)")
		DoorState.UNLOCKED:
			show_interaction_prompt("Нажмите F чтобы открыть")
		DoorState.OPEN:
			if not auto_close:
				show_interaction_prompt("Нажмите F чтобы закрыть")
				
# Показать подсказку взаимодействия
func show_interaction_prompt(text: String):
	if has_node("InteractionPrompt"):
		get_node("InteractionPrompt").show_text(text)
		
# Скрыть подсказку
func hide_interaction_prompt():
	if has_node("InteractionPrompt"):
		get_node("InteractionPrompt").hide()

# Показать всплывающий текст (заглушка)
func show_floating_text(text: String):
	print(text)  # Здесь должна быть ваша реализация UI

# Воспроизвести звук заблокированной двери
func play_locked_sound():
	animation_player.play("Door_Lock")

# Внешние методы управления дверью
func force_unlock():
	# Принудительная разблокировка
	transition_to(DoorState.UNLOCKED)

func force_lock():
	# Принудительная блокировка
	transition_to(DoorState.LOCKED)

func break_door():
	# Поломка двери (остается открытой навсегда)
	door_collision_left.set_deferred("disabled", true)
	door_collision_right.set_deferred("disabled", true)
	if animation_player.has_animation("Door_Open"):
		animation_player.play("Door_Open")
