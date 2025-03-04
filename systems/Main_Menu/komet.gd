extends Sprite2D

var property: Dictionary:
    set(value):
        property = value
        set_property()

var speed_x: float
var speed_y: float

func _physics_process(_delta: float) -> void:
    is_on_screen()
    move()

func set_property() -> void:
    self.scale = Vector2(property["scale"], property["scale"])
    self.rotation += property["rotation_speed"]
    speed_x = property["speed_x"]
    speed_y = property["speed_y"]


func is_on_screen() -> void:
    if not $VisibleOnScreenNotifier2D.is_on_screen():
        self.queue_free()

func move() -> void:
    position.x += -speed_x
    # position.y += property["speed_y"]

    