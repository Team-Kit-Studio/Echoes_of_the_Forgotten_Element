extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer

const MAX_WIGTH: int = 256

var text:String = ""
var letter_index: int = 0

var leter_time = 0.03
var space_time: int = 0.06
var punctuation_time: int = 0.2


signal finished_displaying()

func display_text(text_to_display: String) -> void:
	text = text_to_display
	label.text = text_to_display
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIGTH)
	
	if size.x > MAX_WIGTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # x resize
		await resized # y resize
		custom_minimum_size.y = size.y
		
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	label.text = ""
	_display_letter()

func _display_letter() -> void:
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit()
		return
		
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(leter_time)


func _on_letter_display_timer_timeout() -> void:
	_display_letter()
