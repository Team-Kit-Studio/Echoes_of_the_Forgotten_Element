extends Control

signal choice_selected(option: String)

@onready var panel: Panel = $CanvasLayer/Panel
@onready var button_container: VBoxContainer = $CanvasLayer/Panel/ButtonContainer

const MAX_WIDTH: int = 400
const PADDING: int = 20
const SIDE_MARGIN: int = 20
const BUTTON_SCENE = preload("res://project/scenes/ui/Systems/Dialog/Text_Box/ChoiceButton.tscn")

func set_options(options: Dictionary) -> void:
	for child in button_container.get_children():
		child.queue_free()
	
	# 1. Фиксируем ширину панели
	panel.custom_minimum_size.x = MAX_WIDTH
	panel.size.x = MAX_WIDTH
	
	# 2. Создаём кнопки
	for option_text in options.keys():
		var btn = BUTTON_SCENE.instantiate()
		btn.text = option_text
		btn.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.pressed.connect(_on_button_pressed.bind(option_text))
		button_container.add_child(btn)
	
	# 3. Ждём один кадр, чтобы кнопки отрисовались и текст перенёсся
	await get_tree().process_frame
	
	# 4. Вычисляем высоту контейнера (теперь она должна быть корректной)
	var content_height = button_container.get_combined_minimum_size().y
	var panel_height = content_height + PADDING * 2
	
	# 5. Устанавливаем высоту панели
	panel.custom_minimum_size.y = panel_height
	panel.size.y = panel_height
	button_container.position = Vector2(PADDING, PADDING)
	button_container.size = Vector2(MAX_WIDTH - PADDING * 2, content_height)
	
	# 6. Запускаем анимацию
	show_slide_in()

func show_slide_in() -> void:
	var window_size = DisplayServer.window_get_size()
	var panel_width = panel.size.x
	var target_x = window_size.x - panel_width - SIDE_MARGIN
	var target_y = panel.position.y  # оставляем вертикальную позицию из сцены
	
	panel.position = Vector2(window_size.x, target_y)
	panel.visible = true
	show()
	
	var tween = create_tween()
	tween.tween_property(panel, "position:x", target_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tween.finished

func hide_slide_out() -> void:
	var window_size = DisplayServer.window_get_size()
	var tween = create_tween()
	tween.tween_property(panel, "position:x", window_size.x, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	hide()

func _on_button_pressed(option: String) -> void:
	choice_selected.emit(option)
	hide_slide_out()
