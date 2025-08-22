extends RigidBody2D

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var collis_left: CollisionShape2D = $Left
@onready var collis_right: CollisionShape2D = $Right
@onready var timer: Timer = $Timer
@onready var scrip = preload("res://project/scripts/ui/Inventory/hotbar.gd")
var react:bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		for key in body.DataInventory():
			if key.item != null and key.item.ItemName == "KeyCardGray":
				react = true
				print("в реакте")
				return
			else:
				print("Заперто")
		
func interactive() -> void:
	print("клавиша нажата")
	react = false
	var nodes = get_tree().get_nodes_in_group("collision")
	for anima in nodes:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(anima, "position:x", anima.position.x * 3.0625, 1)
	anim.play("Open")
	timer.start(4)
	await timer.timeout
	for anima in nodes:
		var tween_back: Tween = get_tree().create_tween()
		tween_back.tween_property(anima, "position:x", anima.position.x / 3.0625, 1)
	anim.play("Close")
			
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interaction"):
		if react:
			interactive()
			print("есть контакт")


func _on_react_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print(dict.Slots)
		react = false
		print("Не в реакте")
