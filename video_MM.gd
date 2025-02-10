extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_type = Persistence.config.get_value("Видео", "fullscreen")
	if screen_type == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%Fullscreen.button_pressed = true
	
	var borderless_type = Persistence.config.get_value("Видео", "borderless")
	if borderless_type == true:
		%Borderless.button_pressed = true
	
	var vsync_index = Persistence.config.get_value("Видео", "vsync")
	%VSync.selected = vsync_index
	
func _on_fullscreen_toggled(toggled_on):
	if %Fullscreen.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Persistence.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_FULLSCREEN)
		%Borderless.button_pressed = false
		
	elif %Borderless.button_pressed == true:
		pass
		
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		Persistence.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	Persistence.save_data()
	
func _on_borderless_toggled(toggled_on):
	if %Borderless.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Persistence.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
		%Fullscreen.button_pressed = false
		
	elif %Fullscreen.button_pressed == true:
		pass
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	Persistence.config.set_value("Видео", "borderless", toggled_on)
	Persistence.save_data()
	
func _on_v_sync_item_selected(index):
	DisplayServer.window_set_vsync_mode(index)
	Persistence.config.set_value("Видео", "vsync", index)
	Persistence.save_data()	
