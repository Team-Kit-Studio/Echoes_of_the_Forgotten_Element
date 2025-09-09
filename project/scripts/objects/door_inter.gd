extends RigidBody2D

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var collis_left: CollisionShape2D = $Left
@onready var collis_right: CollisionShape2D = $Right
@onready var timer: Timer = $Timer
@onready var react: Sprite2D = $Right/Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
var in_react = preload("res://project/assets/sprites/Objects/Interactive/Key_cardridder_react.png")
var out_react = preload("res://project/assets/sprites/Objects/Interactive/Key_cardridder.png")
var Open:bool = false
var area: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		react.texture = in_react
		area = true
		check_item(body)
		
func check_item(BodyFunc: Node2D):
	for key in BodyFunc.DataInventory():
		if key.item != null and key.item.ItemName == "KeyCardGray":
			Open = true
			print("Открыто")
			return
		else:
			Open =false
			
		
func interactive() -> void:
	#print("клавиша нажата")
	if Open:
		var nodes = get_tree().get_nodes_in_group("collision")
		anim.play("Open")
		Play_Music("res://project/assets/sounds/MSE/SealedDoorOpen (3).wav")
		for anima in nodes:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(anima, "position:x", anima.position.x * 3.0625, 0.8)
		timer.start(4)
		await timer.timeout
		for anima in nodes:
			var tween_back: Tween = get_tree().create_tween()
			tween_back.tween_property(anima, "position:x", anima.position.x / 3.0625, 0.7)
		anim.play("Close")
		Play_Music("res://project/assets/sounds/MSE/SealedDoorClose (2).wav")
		area = false
	else:
		print("Заперто")
		anim.play("Lock")
			
func _unhandled_key_input(event: InputEvent) -> void:
	if area and Input.is_action_just_pressed("Interaction"):
		interactive()
		print("взаимодействие")


func _on_react_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print(dict.Slots)
		area = false
		print("Вне зоныц")
		react.texture = out_react
		
func Play_Music(path: String) -> void:
	var stream = load(path)
	if audio.playing:
		return
	
	if stream is AudioStream:
		audio.stream = stream
		audio.play()
	else:
		push_error("Ошибка загрузки музыки")
	
