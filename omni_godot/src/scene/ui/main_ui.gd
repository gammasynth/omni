extends AppUI

class_name MainUI

@onready var h_split = $h_split
@onready var v_split = $h_split/v_split

@onready var back_panel: Panel = $back_panel
@onready var custom_back_panel: Panel = $custom_back_panel

@onready var icon: TextureRect = $boot_vbox/icon
@onready var raw_console: RichTextLabel = $boot_vbox/console_pc/console_margin/raw_console
@onready var boot_vbox: VBoxContainer = $boot_vbox

static var console_ui: ConsoleUI
static var file_browser_ui: FileBrowserUI

var user_theme_path:String = "user://settings/theme/user_custom.theme"
var unique_back_panel_stylebox: StyleBox = null
var modified_back_panel: bool = false
var unique_back_panel_color:Color=Color.BLACK

func get_user_theme() -> Theme:
	var base_theme: Theme = preload("res://lib/gd_app_ui/resource/theme/blank_theme.theme")
	var user_theme: Theme = null
	DirAccess.make_dir_recursive_absolute(user_theme_path.get_base_dir())
	if FileAccess.file_exists(user_theme_path): user_theme = await load(user_theme_path)
	if not user_theme: user_theme = base_theme.duplicate(true)
	return user_theme

func _app_ui_initialized() -> void: pass
	#theme = await get_user_theme()
	#current_theme = Registry.pull("themes", "darkscale_modified.theme")
	#App.instance.theme_name_changed.connect(theme_name_changed)
	#theme_changed.connect(func(): back_panel.remove_theme_stylebox_override("panel"))

func _ready_up():RefInstance.chat_mirror_callable = raw_output

func raw_output(text:String) -> void: raw_console.text = str(raw_console.text + "\n"  + text)

func theme_was_changed(new_theme:Theme) -> void: 
	theme = new_theme
	if theme == null:
		change_window_panel_color(unique_back_panel_color, false)
	else:
		var panel_color:Color=theme.get_stylebox("panel", "Panel").bg_color
		change_window_panel_color(panel_color, false)

func theme_name_changed(theme_name:String) -> void:
	
	if theme_name == "custom":
		#theme = null # TODO MAKE CUSTOM USER THEME
		back_panel.visible = false
		custom_back_panel.visible = true
		modified_back_panel = true
		#if unique_back_panel_stylebox and not custom_back_panel.has_theme_stylebox_override("panel"): custom_back_panel.add_theme_stylebox_override("panel", unique_back_panel_stylebox)
		return
	else:
		modified_back_panel = false
		back_panel.visible = true
		custom_back_panel.visible = false
	
	# BUG I DONT KNOW WHAT IS WRONG WITH THIS BELOW
	#var theme_key: String = THEME_KEYS.get(theme_name)
	#var theme_res: Theme = Registry.pull("themes", theme_key)
	
	#current_theme = theme_res
	#if back_panel.has_theme_stylebox_override("panel"): back_panel.remove_theme_stylebox_override("panel")
	
	pass




#const WINDOW_PANEL_COLORS : Dictionary = { "dark" : Color(0.03, 0.03, 0.03, 0.61), "light" : Color(1.0, 1.0, 1.0, 0.78)}
var window_panel_color: Color = Color.WHITE:
	set(c):
		last_window_panel_color = window_panel_color
		window_panel_color = c

var last_window_panel_color: Color = Color.WHITE



func change_window_panel_color(color:Color, enable:bool=true): 
	if enable:
		modified_back_panel = true
		back_panel.visible = false
		custom_back_panel.visible = true
		unique_back_panel_color = color
	
	var stylebox: StyleBoxFlat = null
	
	if custom_back_panel.has_theme_stylebox_override("panel"): stylebox = back_panel.get("theme_override_styles/panel")
	
	if not stylebox and theme: stylebox = theme.get_stylebox("panel", "panel")
	#if not stylebox: 
		#var user_theme = await get_user_theme()
		#stylebox = user_theme.get_stylebox("panel", "panel")
	
	if not stylebox: stylebox = StyleBoxFlat.new()
	
	if not unique_back_panel_stylebox or unique_back_panel_stylebox and unique_back_panel_stylebox != stylebox:
		unique_back_panel_stylebox = stylebox.duplicate()
		stylebox = unique_back_panel_stylebox
	
	chatf("setting color")
	if stylebox: 
		stylebox.draw_center = true
		if not custom_back_panel.has_theme_stylebox_override("panel"):
			custom_back_panel.add_theme_stylebox_override("panel", stylebox)
		if custom_back_panel.has_theme_stylebox_override("panel") and custom_back_panel.get("theme_override_styles/panel") != stylebox: 
			custom_back_panel.remove_theme_stylebox_override("panel")
			custom_back_panel.add_theme_stylebox_override("panel", stylebox)
		
		stylebox.set_bg_color(color)
		#window_panel_color = color
	else:
		warn("PANELCONTAINER STYLEBOX ERROR!")
	
	#Main.theme_name = "custom" # added disable for this color picker if not already in custom theme

func _start():
	console_ui = preload("res://src/scene/ui/console/omni_console_ui.tscn").instantiate()
	file_browser_ui = preload("res://src/scene/ui/file_browser/omni_file_browser_ui.tscn").instantiate()
	# TODO PERHAPS use registry for being able to pull modded versions of the console/file browser
	#console_ui = Registry.pull("app_elements", "omni_console_ui.tscn").instantiate()
	#file_browser_ui = Registry.pull("app_elements", "omni_file_browser_ui.tscn").instantiate()
	
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(icon, "modulate", Color(0.0,0.0,0.0,0.0), 0.35)
	tween.tween_property(raw_console, "modulate", Color(0.0,0.0,0.0,0.0), 0.35)
	tween.tween_callback(func(): icon.visible = false).set_delay(0.35)
	tween.tween_callback(func(): raw_console.visible = false).set_delay(0.35)
	
	await Make.child(file_browser_ui, v_split)
	await Make.child(console_ui, v_split)
	file_browser_ui.grid_mode = Main.file_browser.grid_mode
	
	Main.console.directory_focus_changed.connect(Main.file_browser.open_directory.bind(false))
	Main.console.open_directory()
	Main.file_browser.directory_focus_changed.connect(Main.console.open_directory.bind(false, true))
	
	Make.fade(boot_vbox, 1.5, false)


func toggle_file_browser(toggle:bool) -> void: file_browser_ui.visible = toggle
	#if toggle:
		#console_ui.set_v_size_flags(Control.SIZE_FILL)
	#else:
		#console_ui.set_v_size_flags(Control.SIZE_EXPAND_FILL)

func print_out(text:String) -> void: console_ui.print_out(text)
