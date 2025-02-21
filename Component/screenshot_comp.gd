class_name ScreenShotComp
extends Node


func path_saves_background(_name: String) -> String:
	return Gvars.SAVES_BACKGROUNG_PATH + _name + ".png"
	
func screen_shot(_name: String) -> Image:
	var path: String = path_saves_background(_name)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(path)
	return image
