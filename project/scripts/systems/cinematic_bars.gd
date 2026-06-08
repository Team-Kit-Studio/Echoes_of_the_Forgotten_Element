extends Control

@onready var top_bar: ColorRect = $CanvasLayer/TopBar
@onready var bottom_bar: ColorRect = $CanvasLayer/BottomBar

const ANIMATION_DURATION: float = 0.3

func _ready() -> void:
	hide()

# ------------------------------------------------------------------
# Показать рамки
# ------------------------------------------------------------------
func show_bars() -> void:
	show()
	var viewport_height = get_viewport().get_visible_rect().size.y
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", 0, ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(bottom_bar, "position:y", viewport_height - bottom_bar.size.y, ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	await tween.finished

# ------------------------------------------------------------------
# Скрыть рамки
# ------------------------------------------------------------------
func hide_bars() -> void:
	var viewport_height = get_viewport().get_visible_rect().size.y
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", -top_bar.size.y, ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_property(bottom_bar, "position:y", viewport_height, ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
