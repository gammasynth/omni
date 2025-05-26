extends App

class_name Main

signal theme_name_changed(new_theme_name:String)


static var console: OmniConsole
static var file_browser: OmniFileBrowser

static var theme_name: String = "dark":
	set(s):
		theme_name = s
		if instance: instance.theme_name_changed.emit(s)




func _start() -> Error:
	
	#get_window().borderless = false
	#
	#ui = APP_UI.instantiate()
	#await Cast.make_node_child(ui, get_parent())
	#await RenderingServer.frame_post_draw
	#await get_tree().process_frame
	#await get_tree().create_timer(1.0)
	
	
	ui.start()
	
	setup_theme_settings()
	
	return OK


func reset_theme_settings(b):
	if not b: return
	if FileAccess.file_exists("user://settings/theme/theme.json"):
		DirAccess.remove_absolute("user://settings/theme/theme.json")
	
	setup_theme_settings()

func setup_theme_settings():
	
	
	var theme_settings: Settings
	if not Settings.all_settings.has("theme"):
		theme_settings = Settings.initialize_settings("theme", "user://settings/theme/")
	else:
		theme_settings = Settings.all_settings["theme"]
		theme_settings.finish_prepare_settings()
		return
	
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
	
	var clr_func = func() -> Color:
		var default_panel_clr: Color = Color.WHITE
		if ui.back_panel.has_theme_stylebox_override("panel") and ui.back_panel.get("theme_override_styles/panel") is StyleBoxFlat: 
			default_panel_clr = ui.back_panel.get("theme_override_styles/panel").bg_color
		return default_panel_clr
	
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
	App.ui.toggle_file_browser(toggle)





	#print(instance.get_window().size)

#static func execute(order:String) -> Variant:
	#if not console: return ""
	#return console.execute(order)
#
#
#static func print_out(text:String) -> void:
	#if not console: return
	#console.print_out(text)
