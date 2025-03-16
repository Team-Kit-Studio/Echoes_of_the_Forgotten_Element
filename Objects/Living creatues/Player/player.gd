extends CharacterBody2D

enum state {
	MOVE,
	DAMAGE,
	ATTACK,
	DEATH
}


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer

const speed: int = 100

const anim_list: Dictionary[StringName, Dictionary] = {
	StringName("idle"): {
		Vector2i.RIGHT: "State_Idle_FromSide",
		Vector2i.LEFT: "State_Idle_FromSide",
		Vector2i.UP: "State_Idle_Up",
		Vector2i.DOWN: "State_Idle_Down",
		Vector2i.ZERO: "State_Idle_FromSide"
	},

	StringName("run"): {
		Vector2i.RIGHT: "State_Run_FromSide",
		Vector2i.LEFT: "State_Run_FromSide",
		Vector2i.UP: "State_Run_Up",
		Vector2i.DOWN: "State_Run_Down",
		Vector2i.ZERO: ""
	}
}

var alive: bool = true
var health: int = 100
var current_state: state = state.MOVE
var combo: bool = false
var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2i = Vector2.ZERO


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
	
func Move_State() -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction != Vector2.ZERO:

		last_direction = Vector2i(input_direction)

		velocity = input_direction * speed
		
		if last_direction.x != 0:  
			anim.flip_h = last_direction.x > 0
		
		play_animation(anim_list["run"][last_direction])

	else:
		velocity = Vector2.ZERO  

		play_animation(anim_list["idle"][last_direction])

	move_and_slide()

func play_animation(animation: String) -> void:
	AnimPlayer.play(animation)

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
