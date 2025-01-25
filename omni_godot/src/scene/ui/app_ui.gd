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

const THEME_KEYS: Dictionary = {
	"dark" : "darkscale_modified.theme",
	"light" : "lightscale_alpha.theme"
	}

var current_theme:Theme = null:
	set(t):
		last_theme = current_theme
		current_theme = t
		theme = current_theme

var last_theme:Theme = load(ProjectSettings.get_setting("gui/theme/custom"))


func theme_name_changed(theme_name:String) -> void:
	
	if theme_name == "custom":
		current_theme = null
		return
	
	var theme_key: String = THEME_KEYS.get(theme_name)
	var theme_res: Theme = Registry.pull("themes", theme_key)
	current_theme = theme_res
	pass


func _ready():
	
	console_ui = Registry.pull("app_elements", "omni_console_ui.tscn").instantiate()
	file_browser_ui = Registry.pull("app_elements", "omni_file_browser_ui.tscn").instantiate()
	
	App.instance.theme_name_changed.connect(theme_name_changed)
	
	current_theme = Registry.pull("themes", "darkscale_modified.theme")
	
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
