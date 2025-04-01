extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var chase: bool = false
var atack: bool = false
var SPEED: int = 100
var alive: bool = true
var health: int = 100



func _physics_process(_delta) -> void:
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


func _on_area_2d_body_entered(body) -> void:
	if body.name == "Player":
		chase = true


func _on_area_2d_body_exited(body) -> void:
	if body.name == "Player":
		chase = false
		

func _on_atack_body_entered(body) -> void:
	if body.name == "Player":
		if alive == true:
			#body.velocity.x -= 500
			#body.velocity.y -= 500
			Atack()
			await Atack()
			
			body.health -= 40

		
func Death() -> void:
	alive = false
	anim.play('Death')
	await anim.animation_finished
	self.queue_free()
	
func Atack() -> void:
	alive = false
	velocity.x = 0
	velocity.y = 0
	anim.play("Atack 1")
	await anim.animation_finished
	alive = true
