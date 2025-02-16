extends Node

const FORBIDDEN_CHARACTERS: Array[String] = [
	"\\", "/", ":", "*", "?", "\"", "<", ">", "|", "#", "%", "{", "}",
     "^", "~", "[", "]", ";", ",", ".", "(", ")", "@", "$", "&", "!", "+"
]
const SAVE_PATH: String = "user://saves/"