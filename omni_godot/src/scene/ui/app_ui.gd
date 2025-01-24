extends DatabaseMarginContainer

class_name AppUI

@onready var h_split = $h_split
@onready var v_split = $h_split/v_split



var console_ui: ConsoleUI
var file_browser_ui: FileBrowserUI

var console: Console:
	get: return App.console

var file_browser: OmniFileBrowser:
	get: return App.file_browser


func _ready():
	
	console_ui = Registry.pull("app_elements", "omni_console_ui.tscn").instantiate()
	file_browser_ui = Registry.pull("app_elements", "omni_file_browser_ui.tscn").instantiate()
	
	await Cast.make_node_child(file_browser_ui, v_split)
	await Cast.make_node_child(console_ui, v_split)
	
	App.open_directory()


func toggle_file_browser(toggle:bool) -> void:
	file_browser_ui.visible = toggle
	
	if toggle:
		console_ui.set_v_size_flags(Control.SIZE_FILL)
	else:
		console_ui.set_v_size_flags(Control.SIZE_EXPAND_FILL)

func print_out(text:String) -> void:
	console_ui.print_out(text)
