extends Panel

var pressed: bool = false
var get_mouse: bool = false

func _ready() -> void:
    $VBoxContainer/HBoxContainer/SaveName.text = self.name
    $Line2D.hide()

func _on_mouse_entered() -> void:
    get_mouse = true
    if not pressed:
        $Line2D.show()

func _on_mouse_exited() -> void:
    get_mouse = false
    if not pressed:
        $Line2D.hide()
    
func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            handle_mouse_click()
        if event.double_click:
            handle_double_click()
    
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if not get_mouse and pressed:
            hide_line_and_show_buttons()

func handle_mouse_click() -> void:
    pressed = true
    $Line2D.show()
    hide_buttons()

func handle_double_click() -> void:
    # сюда прилепить лоад сохранения, как-нибудь
    pass

func hide_line_and_show_buttons() -> void:
    if not get_mouse:
        hide_line()
        show_buttons()

func hide_line() -> void:
    $Line2D.hide()
    pressed = false
    get_mouse = false

func hide_buttons() -> void:
    var parent = get_parent().get_owner()
    parent.Delete.visible = true
    parent.NewSaveButton.visible = false
    parent.Load.disabled = false
    parent.emit_signal("update_save_name", self.name)

func show_buttons() -> void:
    var parent = get_parent().get_owner()
    await get_tree().create_timer(0.12).timeout
    parent.Delete.visible = false
    parent.NewSaveButton.visible = true
    parent.Load.disabled = true

func self_delete() -> void:
    self.call_deferred("queue_free")
