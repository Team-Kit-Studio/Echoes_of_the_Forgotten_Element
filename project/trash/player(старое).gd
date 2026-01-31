extends CharacterBody2D


enum {
	MOVE,
	DAMAGE,
	ATTACK,
	DEATH
}

var alive = true
var health = 100
var speed = 200.0
var state = MOVE
var combo = false


@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

func _physics_process(_delta):
	match state:
		MOVE:
			move_state()
		DAMAGE:
			pass
		ATTACK:
			attack_state()
		DEATH:
			death_state()
	move_and_slide()

func move_state():
	if alive == true:
		var input_direction = Input.get_vector("left","right","up","down").normalized()
		if input_direction:
			velocity = input_direction * speed
			animPlayer.play("State_Run")
			print(input_direction)
			if input_direction == 1:
				print("доп доп ес ес")
		else:
			velocity = input_direction * 0
			animPlayer.play("State_Idle_fromsife")
		if input_direction.x < 0:
			anim.flip_h = true
		elif input_direction.x > 0:
			anim.flip_h = false
		if Input.is_action_just_pressed('click'):
			state = ATTACK
		if health <= 0:
			state = DEATH
		
	
	#queue_free()
func attack_state():
	#if Input.is_action_just_pressed("click") and combo == true:# комбо
		#state = ATTACK
	velocity.x =0
	velocity.y =0
	animPlayer.play("Shoot")
	await animPlayer.animation_finished
	state = MOVE
func combo_shoot():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func death_state():
	alive = false
	health = 0
	velocity.x = 0
	velocity.y = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	animPlayer.pause()
	anim.visible = false
