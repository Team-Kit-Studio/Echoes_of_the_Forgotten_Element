extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/Interactive_Flow


var triger:bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		interact.play("chat_icon_Up")
		tween.tween_property(interact, "modulate", Color(1,1,1,1), 0.5)
		triger = true
		
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Interaction") and triger:
		interact.play("Active")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		interact.play("chat_icon_down")
		tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.2)
		triger = false
