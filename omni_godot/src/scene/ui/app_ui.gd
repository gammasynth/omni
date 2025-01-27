extends DatabaseMarginContainer

class_name AppUI


@onready var h_split = $h_split
@onready var v_split = $h_split/v_split

@onready var back_panel: Panel = $back_panel


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
var unique_back_panel_stylebox: StyleBox = null


func theme_name_changed(theme_name:String) -> void:
	
	if theme_name == "custom":
		current_theme = null
		if unique_back_panel_stylebox and not back_panel.has_theme_stylebox_override("panel"): back_panel.add_theme_stylebox_override("panel", unique_back_panel_stylebox)
		return
	
	var theme_key: String = THEME_KEYS.get(theme_name)
	var theme_res: Theme = Registry.pull("themes", theme_key)
	current_theme = theme_res
	if back_panel.has_theme_stylebox_override("panel"): back_panel.remove_theme_stylebox_override("panel")
	
	pass




#const WINDOW_PANEL_COLORS : Dictionary = { "dark" : Color(0.03, 0.03, 0.03, 0.61), "light" : Color(1.0, 1.0, 1.0, 0.78)}
var window_panel_color: Color = Color.WHITE:
	set(c):
		last_window_panel_color = window_panel_color
		window_panel_color = c

var last_window_panel_color: Color = Color.WHITE

func change_window_panel_color(color:Color): 
	var stylebox: StyleBox = null
	
	if back_panel.has_theme_stylebox_override("panel"): stylebox = back_panel.get("theme_override_styles/panel")
	
	if not stylebox and current_theme: stylebox = current_theme.get_stylebox("panel", "panel")
	if not stylebox and last_theme: stylebox = last_theme.get_stylebox("panel", "panel")
	
	if not stylebox: stylebox = StyleBoxFlat.new()
	
	if not unique_back_panel_stylebox or unique_back_panel_stylebox and unique_back_panel_stylebox != stylebox:
		unique_back_panel_stylebox = stylebox.duplicate()
		stylebox = unique_back_panel_stylebox
	
	print("setting color")
	if stylebox: 
		if not back_panel.has_theme_stylebox_override("panel"):
			back_panel.add_theme_stylebox_override("panel", stylebox)
		if back_panel.has_theme_stylebox_override("panel") and back_panel.get("theme_override_styles/panel") != stylebox: 
			back_panel.remove_theme_stylebox_override("panel")
			back_panel.add_theme_stylebox_override("panel", stylebox)
		
		back_panel.get("theme_override_styles/panel").set("bg_color",(color))
		#window_panel_color = color
	else:
		warn("PANELCONTAINER STYLEBOX ERROR!")
	
	App.theme_name = "custom"






func _ready():
	
	current_theme = await load("res://src/resources/theme/darkscale_modified.theme")
	
	console_ui = Registry.pull("app_elements", "omni_console_ui.tscn").instantiate()
	file_browser_ui = Registry.pull("app_elements", "omni_file_browser_ui.tscn").instantiate()
	
	App.instance.theme_name_changed.connect(theme_name_changed)
	#theme_changed.connect(func(): back_panel.remove_theme_stylebox_override("panel"))
	
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
