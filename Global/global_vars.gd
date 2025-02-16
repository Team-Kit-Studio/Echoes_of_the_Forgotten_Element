extends Node

const FORBIDDEN_CHARACTERS: PackedStringArray = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", "#", "%", "{", "}",
     "^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", "!", "+"
]
const SAVE_PATH: String = "user://saves/"