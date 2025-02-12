extends Node2D
var save_sustem = SaveSystem.new()
func _ready() -> void:
	save_sustem.save_game()
	
	
