extends CharacterBody2D

@onready var interact: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var Anim: AnimationPlayer = $AnimationPlayer

@export var npc_id: String
@export var npc_name: String

var action: bool = false
var triger:bool = false

const lines: Array[String] = [
	"Привет, как дела?",
	"Что делаешь?",
	"Я хочу дать тебе задание, да не простое, а очень сложное",
	". . . . .",
	"шутка",
	"Пока."
]

func _ready() -> void:
	#$TextureRect.hide()
	#interact.modulate = Color(10.453, 0.931, 0.0)
	pass

func toggle_mode() -> void:
	action = !action

func icon_up() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Up")
	tween.tween_property(interact, "modulate", Color(10.453, 0.931, 0.0), 0.5)

func icon_down() -> void:
	var tween = get_tree().create_tween()
	interact.play("ChatIcon_Down")
	tween.tween_property(interact, "modulate", Color(1,1,1,0), 0.5)

# появление иконки чата
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		icon_up()
		triger = true
		print(triger)

func start_dialog() -> void:
	toggle_mode()
	if action and triger:
		$Area2D/AnimatedSprite2D.visible = !visible
		Global.start_dialog(global_position, lines)
		#Anim.play("chat")
		#await Anim.animation_finished
	elif Global.is_dialog_active == false:
		print("Появление чата")
		icon_up()
	else:
		#Anim.play_backwards("chat")
		#await Anim.animation_finished
		$Area2D/AnimatedSprite2D.show()

#func _input(_event: InputEvent) -> void:
#	if Input.is_action_pressed("Interaction") and triger:
#		#start_dialog()
#		pass	
#			
		
# исчезание иконки
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		icon_down()
		triger = false
		print(triger)
		
