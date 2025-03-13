extends Node
class_name ScreenshotManager

static func save_image(floder_path: String, image_viewport: Image) -> Image:
	image_viewport.save_jpg(floder_path)
	return image_viewport

static func load_image(base_path: String, file_name: String, extension: String) -> Image:
	var image: Image
	var path: String = PathManager.build_path(base_path, file_name, extension)
	if FileAccess.file_exists(path):
		image = Image.load_from_file(path)
		
	return image
