extends Core

class_name App

signal theme_name_changed(new_theme_name:String)

const APP_UI = preload("res://src/scene/ui/app_ui.tscn")

static var ui: AppUI

static var console: OmniConsole
static var file_browser: OmniFileBrowser

static var theme_name: String = "dark":
	set(s):
		theme_name = s
		if instance: instance.theme_name_changed.emit(s)

func _pre_core_start() -> Error:
	
	#get_window().borderless = true
	get_window().min_size = Vector2i(0, 0)
	get_tree().get_root().set_transparent_background(true)
	get_window().set_wrap_controls(true)
	
	get_window().size = Vector2i(250, 0)
	
	refresh_window()
	
	return await Cast.wait()



func _start() -> Error:
	
	
	
	# ---
	
	chat(str("engine args: " + str(OS.get_cmdline_args())))
	chat(str("user args: " + str(OS.get_cmdline_user_args())))
	if debug: print(" ")
	
	print_rich(BBCode.color("omni", BBCode.COLORS.black))
	print("+    +")
	print_rich(BBCode.color(" omni", BBCode.COLORS.cyan))
	print("+    +")
	#print_rich(BBCode.color("omni", BBCode.COLORS.black))
	print(" ")
	
	#chat(str("omni is running on: " + str(OS.get_distribution_name()) + "; " + str(OS.get_model_name())))
	print_rich(BBCode.color(str("omni is running on: " + str(OS.get_distribution_name())), BBCode.COLORS.white))
	print(" ")
	
	# ---
	
	chat(str("model: " + str(OS.get_model_name())))
	chat(str("cpu: " + str(OS.get_processor_name())))
	chat(str("cores: " + str(OS.get_processor_count())))
	if debug: print(" ")
	
	
	chat(str("memory: " + str(OS.get_memory_info())))
	if debug: print(" ")
	
	chat(str("locale: " + str(OS.get_locale())))
	if debug: print(" ")
	
	# ---
	
	chat(str("data dir: " + OS.get_data_dir()))
	chat(str("user data dir: " + OS.get_user_data_dir()))
	chat(str("config dir: " + str(OS.get_config_dir())))
	chat(str("cache dir: " + str(OS.get_cache_dir())))
	if debug: print(" ")
	
	# ---
	
	get_window().borderless = false
	
	ui = APP_UI.instantiate()
	await Cast.make_node_child(ui, get_parent())
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await get_tree().create_timer(1.0)
	
	setup_theme_settings()
	
	return OK


func reset_theme_settings(b):
	if not b: return
	if FileAccess.file_exists("user://settings/theme/theme.json"):
		DirAccess.remove_absolute("user://settings/theme/theme.json")
	
	setup_theme_settings()

func setup_theme_settings():
	
	
	var theme_settings: Settings = Settings.initialize_settings("theme", "user://settings/theme/")
	var theme_func = func():
		return theme_name
	
	theme_settings.prepare_setting(
		"current_theme", # setting_name
		["dropdown_buttons"], # setting_widget(s)
		change_theme_index, # setting_value_changed_callable_function
		[0], # default_setting_widget_value(s)
		[ # widget_parameter_dictionary(s)
			{
				"WINDOW_TITLE" : "themes", # telling the dropdown widget to have a title above list
				"ITEM_0" : "dark", # simply adding an item button to the dropdown as a string
				"ITEM_1" : { "ITEM_NAME" : "light" }, # alternatively adding an item to dropdown as Dictionary
				"ITEM_2" : { "ITEM_NAME" : "custom", "ACCEL" : KEY_C } # optional accel shortcut can be added
			}
		]
	)
	
	var clr_func = func():
		var default_panel_clr: Color = Color.WHITE
		if ui.back_panel.has_theme_stylebox_override("panel") and ui.back_panel.get("theme_override_styles/panel") is StyleBoxFlat: default_panel_clr = ui.back_panel.get("theme_override_styles/panel").bg_color
	
	theme_settings.prepare_setting(
		"window_panel_color", 
		["color"], 
		ui.change_window_panel_color,
		[clr_func],
		[{}]
	)
	
	theme_settings.prepare_setting(
		"reset_theme_settings", 
		["boolean"], 
		reset_theme_settings,
		[false],
		[{}]
	)
	
	theme_settings.finish_prepare_settings()


func change_theme_index(new_index:int):
	match new_index:
		0:
			theme_name = "dark"
		1:
			theme_name = "light"
		2:
			theme_name = "custom"


static func open_directory(at_path:String=console.current_directory_path) -> void:
	console.current_directory_path = at_path
	file_browser.parse_directory(at_path)

static func toggle_file_browser(toggle:bool) -> void:
	if not Core.instance: return
	var app: App = Core.instance as App
	app.ui.toggle_file_browser(toggle)


static func resize(new_size:Vector2i=Vector2i(0, 0)) -> void:
	if not Core.instance: return
	if not instance.get_window(): return
	if new_size == Vector2i(0, 0): return
	instance.get_window().size = new_size
	#print("NEW SIZE: " + str(new_size))
	#print(instance.get_window().size)

static func refresh_window(new_size:Vector2i=Vector2i(0, 0)):
	if not Core.instance: return
	if not instance.get_window(): return
	resize(new_size)
	instance.get_window().child_controls_changed()
	#print(instance.get_window().size)

#static func execute(order:String) -> Variant:
	#if not console: return ""
	#return console.execute(order)
#
#
#static func print_out(text:String) -> void:
	#if not console: return
	#console.print_out(text)
