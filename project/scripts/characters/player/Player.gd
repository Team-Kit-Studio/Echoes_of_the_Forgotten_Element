extends CharacterBody2D

signal datainv(dict: Dictionary)

enum state {
	MOVE,
	DAMAGE,
	ATTACK,
	DEATH
}

@onready var audioPl: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
#@onready var ShadowPlayer: AnimationPlayer = %AnimationPlayer2
@onready var ShadowSprite: AnimatedSprite2D = %AnimatedSprite2D2
#@onready var inventory: Inventory = get_node("UI/Inventory")
@onready var hotbar = get_node("UI/Inventory/UI/Hotbar")
var interact_body: Node2D
var react_item:bool = false

const speed: int = 100

const ANIMATION_NAMES: PackedStringArray = [
	#idle animations names
	StringName("State_Idle_FromSide"),  # 0
	StringName("State_Idle_Up"),        # 1
	StringName("State_Idle_Down"),      # 2
	#run animations names
	StringName("State_Run_FromSide"),   # 3
	StringName("State_Run_Up"),         # 4
	StringName("State_Run_Down"),       # 5
]

var alive: bool = true
var health: int = 100
var current_state: state = state.MOVE
var combo: bool = false
var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2i = Vector2.ZERO



func get_animation_index(index: int, key: Vector2i) -> int:
	match index:
		0:  # idle
			match key:
				Vector2i.RIGHT, Vector2i.LEFT:
					return 0
				Vector2i.UP:
					return 1
				Vector2i.DOWN:
					return 2
				Vector2i.ZERO:
					return 0
		1:  # run
			match key:
				Vector2i.RIGHT, Vector2i.LEFT:
					return 3
				Vector2i.UP:
					return 4
				Vector2i.DOWN:
					return 5
				Vector2i.ZERO:
					return 0
	return 0  # значение по умолчанию

func get_clean_direction(raw_input: Vector2) -> Vector2i:
# Если вертикальное движение сильнее -> используем его
	if abs(raw_input.y) > abs(raw_input.x):
		return Vector2i(0, sign(raw_input.y))  # UP или DOWN
		
	elif raw_input.x != 0:
		return Vector2i(sign(raw_input.x), 0)  # LEFT или RIGHT

	return Vector2i.ZERO

func _physics_process(_delta: float) -> void:
	match current_state:
		state.MOVE:
			Move_State()
			
		state.DAMAGE:
			pass

		state.ATTACK:
			pass

		state.DEATH:
			pass

func _unhandled_input(_event: InputEvent) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
func Move_State() -> void:
	if input_direction != Vector2.ZERO:
		last_direction = get_clean_direction(input_direction)
		
		velocity = input_direction * speed
		
		Play_Music("res://project/assets/sounds/MSE/zhelezo.mp3")
		
	else:
		velocity = Vector2.ZERO  

	Move_State_Play_Animation()
	move_and_slide()
	

func Move_State_Play_Animation() -> void:
	if input_direction != Vector2.ZERO:
		flip_anim()
		play_animation(1, last_direction)

	else:
		play_animation(0, last_direction)

func flip_anim() -> void:
	if last_direction.x != 0: 
		anim.flip_h = last_direction.x > 0
		ShadowSprite.flip_h = last_direction.x > 0

func play_animation(index: int, key: Vector2i = Vector2i.ZERO) -> void:
	var anim_index = get_animation_index(index, key)
	#print("Playing animation:", ANIMATION_NAMES[anim_index])  # Отладка
	ShadowSprite.play(ANIMATION_NAMES[anim_index])
	AnimPlayer.play(ANIMATION_NAMES[anim_index])
	flip_anim()

func data() -> Dictionary:
	var player_data: Dictionary = {
		"file_name": get_scene_file_path(),
		"pos": {"x": self.position.x, "y": self.position.y},
		"health": health,
		"last_dir": {"x": last_direction.x, "y": last_direction.y},
	}
	return player_data

func load_data(_data: Dictionary) -> void:
	position = Vector2(_data["pos"]["x"], _data["pos"]["y"])
	last_direction = Vector2i(_data["last_dir"]["x"], _data["last_dir"]["y"])
	play_animation(0, last_direction)
	flip_anim()

func _on_pick_up_body_entered(body: Node2D) -> void:
	print(body.item.resource_name)
	interact_body = body
		
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interaction") and interact_body != null:
		if interact_body.get("item"):
			get_node("UI/Inventory/UI/Hotbar").addItem(interact_body.item)
			interact_body.queue_free()
			


func _on_pick_up_body_exited(body: Node2D) -> void:
	interact_body = null

func DataInventory():
	var arr: Array = get_node("UI/Inventory/UI/Hotbar").Slots
	return arr
	
func Play_Music(music_path: String) -> void:
	var stream = load(music_path)
	if audioPl.playing:
		return
	if stream is AudioStream:
		audioPl.stream = stream
		audioPl.play()
		# Пока играет — каждофреймово проверяем скорость
		while audioPl.playing:
			# Для Vector2/Vector3:
			if velocity.length() <= 0.01:
				audioPl.stop()
				break
			# Ждём следующий кадр
			await get_tree().process_frame
	else:
		push_error("Ошибка загрузки музыки")

	


func _on_audio_stream_player_2d_finished() -> void:
	print("velocity")
	if velocity != Vector2.ZERO: 
		Play_Music("res://project/assets/sounds/MSE/Step1.wav")
	else:
		print("no")
