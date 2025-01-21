extends MarginContainer

class_name AppUI

@onready var h_split = $h_split
@onready var v_split = $h_split/v_split



var console_ui: ConsoleUI
var file_browser_ui: FileBrowserUI

var console: Console:
	get: return App.console

var file_browser: FileBrowser:
	get: return App.file_browser


func _ready():
	file_browser_ui.parse_directory(console.current_directory_path)


func toggle_file_browser(toggle:bool) -> void:
	file_browser_ui.visible = toggle
	
	if toggle:
		console_ui.set_v_size_flags(Control.SIZE_FILL)
	else:
		console_ui.set_v_size_flags(Control.SIZE_EXPAND_FILL)
