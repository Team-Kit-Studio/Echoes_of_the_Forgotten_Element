extends CharacterBody2D

enum {
	MOVE,
	DAMAGE,
	ATTACK,
	DEATH
}


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer

const speed: int = 100

const direction_run: Dictionary = {
	Vector2.RIGHT: "State_Run_FromSide",
	Vector2.LEFT: "State_Run_FromSide",
	Vector2.UP: "State_Run_Up",
	Vector2.DOWN: "State_Run_Down" 
}

const direction_idle: Dictionary = {
	Vector2.RIGHT: "State_Idle_FromSide",
	Vector2.LEFT: "State_Idle_FromSide",
	Vector2.UP: "State_Idle_Up",
	Vector2.DOWN: "State_Idle_Down" 
}

var alive: bool = true
var health: int = 100
var state: int = MOVE
var combo: bool = false
var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	match state:
		MOVE:
			Move_State()
		DAMAGE:
			pass
		ATTACK:
			pass
		DEATH:
			pass
	move_and_slide()
	
	
func Move_State() -> void:
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	if input_direction != Vector2.ZERO:


		velocity = input_direction * speed
		
		
		last_direction = input_direction
		
		if last_direction.x != 0:  
			anim.flip_h = last_direction.x > 0
		
		if direction_run.has(last_direction):
			play_animation(direction_run[last_direction])
	else:
		velocity = Vector2.ZERO  

		
		if last_direction != Vector2.ZERO and direction_idle.has(last_direction):
			play_animation(direction_idle[last_direction])
		else:
			
			play_animation("State_Idle_FromSide")
		
func play_animation(animation: String) -> void:
	AnimPlayer.play(animation)

func data() -> Dictionary:
	var player_data: Dictionary = {
		"file_name": get_scene_file_path(),
		"position": {"x": self.position.x, "y": self.position.y},
		"health": health,
		"last_direction": {"x": last_direction.x, "y": last_direction.y},
	}
	return player_data

func load_data(data_player: Dictionary) -> void:
	position = Vector2(data_player["position"]["x"], data_player["position"]["y"])
	last_direction = Vector2(data_player["last_direction"]["x"], data_player["last_direction"]["y"])
	