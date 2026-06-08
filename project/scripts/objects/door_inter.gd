extends Node2D

enum DoorState {
	LOCKED,
	OPENING,
	OPEN,
	CLOSING
}

## Идентификатор требуемой ключ-карты (item_id в ItemData)
@export var required_item_id: String = "KeyCardGray"
## Задержка перед автоматическим закрытием (в секундах)
@export var auto_close_delay: float = 4.0

var current_state: DoorState = DoorState.LOCKED
var actor_in_area: bool = false
var actor_ref: Node2D = null
var close_timer: Timer

@onready var sprite = $Sprite2D
@onready var left_collision = $Left
@onready var right_collision = $Right
@onready var react_collision = $react/CollisionShape2D
@onready var react = $react
@onready var animation_player = $AnimationPlayer
@onready var audio = $AudioStreamPlayer2D

func _ready():
	if Engine.is_editor_hint():
		sprite.texture = sprite.texture
		current_state = DoorState.LOCKED
	close_timer = Timer.new()
	close_timer.one_shot = true
	add_child(close_timer)
	close_timer.timeout.connect(_on_close_timer_timeout)
	add_to_group("door") # ← регистрируем дверь для поиска лучом
	current_state = DoorState.LOCKED
	sprite.show()

## Переводит дверь в новое состояние
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
			return new_state == DoorState.OPENING
		DoorState.OPENING:
			return new_state == DoorState.OPEN
		DoorState.OPEN:
			return new_state == DoorState.CLOSING
		DoorState.CLOSING:
			return new_state == DoorState.LOCKED
	return false

func _on_locked_enter():
	pass

## Проигрывает анимацию запрета
func play_deny_animation():
	if animation_player.has_animation("Door_Lock"):
		animation_player.play("Door_Lock")

func _on_opening_enter():
	if animation_player.has_animation("Door_Open"):
		animation_player.play("Door_Open")
	else:
		transition_to(DoorState.OPEN)

func _on_open_enter():
	if animation_player.has_animation("Door_Open_Idle"):
		animation_player.play("Door_Open_Idle")
	elif animation_player.has_animation("Door_Open"):
		animation_player.stop(false)
	if not actor_in_area:
		start_close_timer()

func _on_closing_enter():
	if animation_player.has_animation("Door_Close"):
		animation_player.play("Door_Close")
	else:
		transition_to(DoorState.LOCKED)

func _on_animation_player_animation_finished(anim_name: String):
	match anim_name:
		"Door_Open":
			if current_state == DoorState.OPENING:
				transition_to(DoorState.OPEN)
		"Door_Close":
			if current_state == DoorState.CLOSING:
				transition_to(DoorState.LOCKED)

func start_close_timer():
	close_timer.start(auto_close_delay)

func stop_close_timer():
	if close_timer.time_left > 0:
		close_timer.stop()

func _on_close_timer_timeout():
	if current_state == DoorState.OPEN and not actor_in_area:
		transition_to(DoorState.CLOSING)

func _on_react_body_entered(body: Node2D) -> void:
	if body.is_in_group("NPC"):
		actor_in_area = true
		actor_ref = body
		stop_close_timer()
		if current_state == DoorState.LOCKED:
			unlock_and_open_door()
		return

	if body.is_in_group("Player") or body.name == "Player":
		actor_in_area = true
		actor_ref = body
		stop_close_timer()
		check_inventory(body)

func _on_react_body_exited(body: Node2D) -> void:
	if (body.is_in_group("NPC") or body.is_in_group("Player") or body.name == "Player") and actor_ref == body:
		actor_in_area = false
		actor_ref = null
		if current_state == DoorState.OPEN:
			start_close_timer()

## Проверяет инвентарь игрока на наличие ключ-карты
func check_inventory(player: Node2D):
	if current_state != DoorState.LOCKED:
		return

	var inv = get_tree().root.find_child("PlayerInventory", true, false)
	if not inv:
		return

	if inv.has_method("has_item_by_id") and inv.has_item_by_id(required_item_id):
		unlock_and_open_door()
	else:
		show_locked_message()
		play_deny_animation()

## Отпирает дверь и запускает анимацию открытия
func unlock_and_open_door():
	if animation_player.is_playing():
		animation_player.stop()
	if current_state == DoorState.LOCKED:
		transition_to(DoorState.OPENING)

## Показывает сообщение о требуемом предмете
func show_locked_message():
	if actor_ref and actor_in_area:
		var dm = null
		if Global.npc and is_instance_valid(Global.npc):
			dm = Global.npc.dialog_manager
		if dm and dm.has_method("show_text_at_position"):
			dm.show_text_at_position("Требуется: " + required_item_id, actor_ref.global_position + Vector2(0, -50), false)
		else:
			print("Требуется: ", required_item_id)

## Принудительно открывает дверь (для катсцен / NPC-луча)
func force_open():
	if current_state == DoorState.LOCKED:
		transition_to(DoorState.OPENING)

## Принудительно закрывает дверь (для катсцен)
func force_close():
	if current_state == DoorState.OPEN:
		transition_to(DoorState.CLOSING)
