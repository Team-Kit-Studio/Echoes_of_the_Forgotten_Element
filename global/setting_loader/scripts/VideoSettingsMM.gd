extends Control

func _ready() -> void:
	if SettingsLoader.config.get_value("Видео", "fullscreen") == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%Fullscreen.button_pressed = true
	
	if SettingsLoader.config.get_value("Видео", "borderless"):
		%Borderless.button_pressed = true
	
	%VSync.selected = SettingsLoader.config.get_value("Видео", "vsync")
	
func _on_fullscreen_toggled() -> void:
	if %Fullscreen.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		SettingsLoader.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_FULLSCREEN)
		%Borderless.button_pressed = false

	# elif %Borderless.button_pressed == true:
	# 	pass

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		SettingsLoader.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	SettingsLoader.save_data()

func _on_borderless_toggled(toggled_on: bool) -> void:
	if %Borderless.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SettingsLoader.config.set_value("Видео", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
		%Fullscreen.button_pressed = false
		
	# elif %Fullscreen.button_pressed == true:
	# 	pass
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	SettingsLoader.config.set_value("Видео", "borderless", toggled_on)
	SettingsLoader.save_data()
	
func _on_v_sync_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index)
	SettingsLoader.config.set_value("Видео", "vsync", index)
	SettingsLoader.save_data()	
