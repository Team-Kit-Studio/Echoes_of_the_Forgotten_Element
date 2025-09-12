extends CharacterBody2D

@onready var interaction: AnimatedSprite2D = $Area2D/Interaction


var triger:bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(interaction, "modulate", Color(1,1,1,0.6), 0.5)
		triger = true
		
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Interaction") and triger:
		interaction.play("Active")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(interaction, "modulate", Color(1,1,1,0), 0.2)
		triger = false
