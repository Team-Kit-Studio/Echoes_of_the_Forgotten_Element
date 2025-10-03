extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var Anim: AnimationPlayer = $AnimationPlayer


var action: bool = false
var triger:bool = false

func _ready() -> void:
	$TextureRect.hide()

func toggle_mode() -> void:
	action = !action


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		interact.play("ChatIcon_Up")
		tween.tween_property(interact, "modulate", Color(1,1,1,1), 0.5)
		triger = true
		
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Interaction") and triger:
		toggle_mode()
		if action:
			$Area2D/AnimatedSprite2D.visible = !visible
			Anim.play("chat")
			await Anim.animation_finished
		else:
			Anim.play_backwards("chat")
			await Anim.animation_finished
			$Area2D/AnimatedSprite2D.show()
			
			
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		interact.play("ChatIcon_Down")
		var tween = get_tree().create_tween()
		tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.5)
		triger = false
