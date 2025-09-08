extends App

class_name Main

#signal theme_name_changed(new_theme_name:String)
#signal custom_back_panel_privilege(allowed:bool)

static var main:Main = null
static var console: OmniConsole
static var file_browser: OmniFileBrowser

static var theme_name: String = "dark"#:
	#set(s):
		#theme_name = s
		#if instance: instance.theme_name_changed.emit(s)
static var theme_index: int = 0
static var current_theme:Theme

var theme_settings: Settings
var app_settings: Settings

func _pre_app_start() -> Error: 
	main = self
	
	setup_theme_settings()
	setup_app_settings()
	
	get_window().size_changed.connect(window_size_changed)
	return OK

func _start() -> Error:
	
	#get_window().borderless = false
	#
	#ui = APP_UI.instantiate()
	#await Cast.make_node_child(ui, get_parent())
	#await RenderingServer.frame_post_draw
	#await get_tree().process_frame
	#await get_tree().create_timer(1.0)
	
	
	await ui.start()
	
	return OK

func window_size_changed() -> void: 
	app_settings.set_setting_value("window_size", [get_window().size])
	app_settings.save_settings()

func setup_app_settings():
	app_settings = Settings.initialize_settings("app", true, "user://settings/app/")
	app_settings.prepare_setting("window_size", [], (func(_x): return), [get_window().size], [{}], false)
	app_settings.finish_prepare_settings()
	app_settings.spawned_window.connect(new_window_needs_theme)



func reset_theme_settings(b):
	if not b: return
	if FileAccess.file_exists("user://settings/theme/theme.json"):
		DirAccess.remove_absolute("user://settings/theme/theme.json")
	
	setup_theme_settings()

func setup_theme_settings():
	theme_settings = Settings.initialize_settings("theme", true, "user://settings/theme/")
	
	#var theme_func = func():
		#return theme_name
	
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
	
	#var clr_func = func() -> Color:
		#var default_panel_clr: Color = Color.WHITE
		#if ui.back_panel.has_theme_stylebox_override("panel") and ui.back_panel.get("theme_override_styles/panel") is StyleBoxFlat: 
			#default_panel_clr = ui.back_panel.get("theme_override_styles/panel").bg_color
		#return default_panel_clr
	
	var default_panel_clr: Color = Color.BLACK
	if ui.back_panel.has_theme_stylebox_override("panel") and ui.back_panel.get("theme_override_styles/panel") is StyleBoxFlat: 
		default_panel_clr = ui.back_panel.get("theme_override_styles/panel").bg_color
	
	var window_panel_color_widget_params:Dictionary ={}
	#window_panel_color_widget_params.set("disabled_callable", is_custom_back_panel_allowed)
	#window_panel_color_widget_params.set("connect_disable_signal", custom_back_panel_privilege)
	theme_settings.prepare_setting(
		"window_panel_color", 
		["color"], 
		change_window_panel_color,
		[default_panel_clr],
		[window_panel_color_widget_params]
	)
	
	theme_settings.prepare_setting(
		"reset_theme_settings", 
		["button"], 
		reset_theme_settings,
		[false],
		[{}]
	)
	
	var load_theme:bool=false
	if not FileAccess.file_exists(theme_settings.settings_file_path): change_theme_index(0)
	else: load_theme = true
	
	theme_settings.finish_prepare_settings()
	if load_theme: 
		var theme_setting = theme_settings.get_setting_value("current_theme")
		if theme_setting is Array and theme_setting.size() == 1: theme_setting = theme_setting.get(0)
		change_theme_index(int(theme_setting))
	
	theme_settings.spawned_window.connect(new_window_needs_theme)

func change_window_panel_color(new_color:Color) -> void:
	theme_settings.set_setting_value("window_panel_color", [new_color])
	ui.change_window_panel_color(new_color)

func is_custom_back_panel_allowed() -> bool:
	if theme_name == "custom": return true
	else: return false

func new_window_needs_theme(new_window:Window) -> void: new_window.theme = current_theme

func change_theme_index(new_index:Variant):
	var idx:int = int(new_index)
	theme_index = idx
	match idx:
		0: theme_name = "dark"
		1: theme_name = "light"
		2: theme_name = "custom"
	
	var new_theme:Theme = null
	match theme_name:
		"light": new_theme = preload("res://resource/theme/light_pixel_omni.theme")
		"dark": new_theme = preload("res://resource/theme/dark_pixel_omni.theme")
	
	current_theme = new_theme
	
	#if theme_name == "custom": custom_back_panel_privilege.emit(true)
	#else: custom_back_panel_privilege.emit(false)
	
	ui.theme_name_changed(theme_name)
	ui.theme_was_changed(new_theme)
	
	for child in get_children():
		if child is Window: 
			child.theme = new_theme
			var cc:int = child.get_child_count()
			if cc == 1 :
				var c = child.get_child(0)
				if c is ModularSettingsMenu:
					if c.settings.name == "theme":
						
						if current_theme == null:
							var o:ModularSettingOption = c.options.get("window_panel_color")
							o.update_setting_value_from_external(ui.unique_back_panel_color)
						else:
							if current_theme.has_stylebox("panel", "Panel"):
								var panel_color:Color=current_theme.get_stylebox("panel", "Panel").bg_color
								var o:ModularSettingOption = c.options.get("window_panel_color")
								o.update_setting_value_from_external(panel_color)
							
							var t:ModularSettingOption = c.options.get("current_theme")
							t.update_setting_value_from_external(idx)
							
							#var r:ModularSettingOption = c.options.get("reset_theme_settings")
							#r.update_setting_value_from_external(false)

static func can_change_directory(try_path:String="") -> bool:
	if Main.console.operating:
		AlertSystem.create_warning("Active Process!", "Can't change directory during an active process!")
		return false
	return true
static func refresh_directory() -> void: file_browser.refresh_ui()
static func open_directory(at_path:String=console.current_directory_path, refresh_ui:bool=true) -> void:
	if not Main.can_change_directory(): return
	console.current_directory_path = at_path
	if refresh_ui: file_browser.parse_directory(at_path)

static func toggle_file_browser(toggle:bool) -> void:
	App.ui.toggle_file_browser(toggle)


#static func execute(order:String) -> Variant:
	#if not console: return ""
	#return console.execute(order)
#
#
#static func print_out(text:String) -> void:
	#if not console: return
	#console.print_out(text)
