extends Node2D

var chase = false
var speed = 150

func _on_agry_body_entered(body):
	if body.name == "Player":
		chase = true
	var player = $player/Player
	var _direction = (player.position - self.position).normalized()
