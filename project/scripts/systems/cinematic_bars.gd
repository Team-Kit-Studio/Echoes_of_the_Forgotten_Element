extends Control

@onready var top_bar: ColorRect = $CanvasLayer/TopBar
@onready var bottom_bar: ColorRect = $CanvasLayer/BottomBar

const ANIMATION_DURATION: float = 0.3

func _ready() -> void:
	# Скрываем изначально
	hide()

# ------------------------------------------------------------------
# Показать рамки
# ------------------------------------------------------------------
func show_bars() -> void:
	show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", 0, ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(bottom_bar, "position:y", 573, ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	await tween.finished

# ------------------------------------------------------------------
# Скрыть рамки
# ------------------------------------------------------------------
func hide_bars() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", -100, ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_property(bottom_bar, "position:y", 648, ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
