extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

var chase = false
var atack = false
var SPEED = 100
var alive = true
var health = 100



func _physics_process(delta):
	var player = $"../../player/Player"
	var direction = (player.position - self.position).normalized()
	if alive == true:
		if chase == true:
			velocity = direction * SPEED
			anim.play("Run")
			if direction.x < 0:
				$AnimatedSprite2D.flip_h = true
			elif direction.x > 0:
				$AnimatedSprite2D.flip_h = false
		else:
			velocity.x = 0
			velocity.y = 0
			anim.play("idle")
		if $"../../player/Player".alive == false:
			velocity.x = 0
			velocity.y = 0
			anim.play("idle")
		if health <= 0:
			Death() 
	

	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		chase = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		chase = false
		

func _on_atack_body_entered(body):
	if body.name == "Player":
		if alive == true:
			#body.velocity.x -= 500
			#body.velocity.y -= 500
			Atack()
			await Atack()
			
			body.health -= 40
			$"../Player".cycle = true
		
func Death():
	alive = false
	anim.play('Death')
	await anim.animation_finished
	queue_free()
	
func Atack():
	alive = false
	velocity.x = 0
	velocity.y = 0
	anim.play("Atack 1")
	await anim.animation_finished
	alive = true
