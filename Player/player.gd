extends CharacterBody2D

enum {
	MOVE,
	DAMAGE,
	ATTACK,
	DEATH
}


@onready var anim = $AnimatedSprite2D
@onready var AnimPlayer = $AnimationPlayer

const speed = 100.0

const direction_run: Dictionary = {
	Vector2.RIGHT: "State_Run_FromSide",
	Vector2.LEFT: "State_Run_FromSide",
	Vector2.UP: "State_Run_Up",
	Vector2.DOWN: "State_Run_Down" 
}

const direction_idle: Dictionary = {
	Vector2.RIGHT: "State_Idle_FromSide",
	Vector2.LEFT: "State_Idle_FromSide",
	Vector2.UP: "State_Idle_Up",
	Vector2.DOWN: "State_Idle_Down" 
}

var alive = true
var health = 100
var state = MOVE
var combo = false
var input_direction = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

func _physics_process(_delta):
	match state:
		MOVE:
			Move_State()
		DAMAGE:
			pass
		ATTACK:
			pass
		DEATH:
			pass
	move_and_slide()
	
	
func Move_State():
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	if input_direction != Vector2.ZERO:
		# Устанавливаем скорость передвижения
		velocity = input_direction * speed
		
		# Сохраняем последнее направление
		last_direction = input_direction
		
		if last_direction.x != 0:  # То есть если есть горизонтальное движение
			anim.flip_h = last_direction.x > 0
		# Управляем анимацией бега
		if direction_run.has(last_direction):
			play_animation(direction_run[last_direction])
	else:
		velocity = Vector2.ZERO  # Останавливаем персонажа

		# Играть анимацию бездействия, основываясь на последнем направлении
		if last_direction != Vector2.ZERO and direction_idle.has(last_direction):
			play_animation(direction_idle[last_direction])
		else:
			# Если не было движения, переключаем на обычную анимацию бездействия
			play_animation("State_Idle_FromSide")
		
func play_animation(animation: String) -> void:

	#print("Играет анимация: ", animation)
	AnimPlayer.play(animation)
