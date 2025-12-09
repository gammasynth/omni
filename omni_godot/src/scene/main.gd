#|*******************************************************************
# main.gd
#*******************************************************************
# This file is part of omni. 
# https://github.com/gammasynth/omni
# 
# omni is an open-source software.
# omni is licensed under the MIT license.
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************
extends App

class_name Main

static var main:Main = null
static var console: OmniConsole
static var file_browser: OmniFileBrowser
var main_console: OmniConsole:
	get: return console
var main_file_browser: OmniFileBrowser:
	get: return file_browser

static var theme_name: String = "dark"#:
static var theme_index: int = 0
static var current_theme:Theme
static var current_app_theme:AppTheme

var all_app_themes:Dictionary[String, AppTheme] = {}
var all_app_theme_indexes:Dictionary[int, String] = {}

const THEME_SETTINGS_PATH:String = "user://settings/app/theme/"
const APP_SETTINGS_PATH:String = "user://settings/app/"
const LAST_THEME_FILEPATH:String = "user://settings/app/theme/last_theme.theme"
var theme_settings: Settings
var app_settings: Settings

var changing_window_size: bool = false

func _pre_registry_start() -> Error: 
	main = self
	establish_user_filebase()
	#print(File.search_for_file_paths_recursively("res://", false, true, false, ["lib", "g_libs", "gd_app", "gd_app_ui"], ["LICENSE.md", "README.md"]))
	return OK

func establish_user_filebase() -> void:
	# User content directories + base template user content from res://
	for directory_name:String in DirAccess.get_directories_at("res://user/"):
		var other_dir:String = File.ends_with_slash(str("user://" + directory_name))
		DirAccess.make_dir_absolute(other_dir)
		for file:String in File.get_all_filepaths_from_directory(File.ends_with_slash(str("res://user/" + directory_name)), "", true):
			if file.ends_with(".uid"): continue
			var other_file:String = str(other_dir + File.get_file_name_from_file_path(file, true))
			if FileAccess.file_exists(other_file): continue
			DirAccess.copy_absolute(file, other_file)
	
	# Application settings data directories
	DirAccess.make_dir_absolute("user://settings/")
	DirAccess.make_dir_absolute("user://settings/app/")
	DirAccess.make_dir_absolute("user://settings/app/theme/")
	
	if FileAccess.file_exists(LAST_THEME_FILEPATH):
		current_theme = ResourceLoader.load(LAST_THEME_FILEPATH)
		ui.theme_was_changed(current_theme)
	#if not FileAccess.file_exists("user://settings/app/theme/last_theme.")

func _start() -> Error: 
	
	gather_all_app_themes()
	setup_theme_settings()
	setup_app_settings()
	
	return await ui.start()


func gather_all_app_themes() -> void:
	all_app_themes.clear()
	all_app_theme_indexes.clear()
	var app_themes_registry:Registry = Registry.get_registry("app_themes")
	var idx:int = 0
	for keyat:String in app_themes_registry.data:
		var value:Variant = app_themes_registry.data.get(keyat)
		if value is GDScript and (value.new() is AppTheme):
			var new_app_theme:AppTheme = value.new()
			new_app_theme.setup()
			all_app_themes.set(new_app_theme.theme_name, new_app_theme)
			all_app_theme_indexes.set(idx, new_app_theme.theme_name)
			idx += 1
		elif value is RegistryEntry:
			for keyatu in value.data:
				var valuetu:Variant = value.data.get(keyatu)
				if valuetu is GDScript and (valuetu.new() is AppTheme):
					var new_app_theme:AppTheme = valuetu.new()
					new_app_theme.setup()
					all_app_themes.set(new_app_theme.theme_name, new_app_theme)
					all_app_theme_indexes.set(idx, new_app_theme.theme_name)
					idx += 1

func setup_app_settings():
	app_settings = Settings.initialize_settings("app", true, APP_SETTINGS_PATH)
	app_settings.prepare_setting("window_size", [], force_update_change_window_size, [get_window().size], [{}], false)
	
	app_settings.prepare_setting("h_split_size", [], ui.resize_h_split, [ui.h_split.split_offset], [{}], false)
	app_settings.prepare_setting("v_split_size", [], ui.resize_v_split, [ui.v_split.split_offset], [{}], false)
	
	get_window().size_changed.connect(window_size_changed)
	app_settings.finish_prepare_settings()
	app_settings.spawned_window.connect(new_window_needs_theme)

func force_update_change_window_size(new_size:Variant) -> void:
	# TODO fix string vector conversion probably in g_libs File classes (or maybe in gd_app_ui Settings)
	changing_window_size = true
	var t:String = new_size
	var a:int = int(t.substr(1).left(t.find(",")-1))
	var b:int = int(t.substr(t.find(",")+1).left(-1))
	var vec: Vector2i = Vector2i(a,b)
	get_window().size = vec

func setup_theme_settings():
	theme_settings = Settings.initialize_settings("theme", true, THEME_SETTINGS_PATH)
	
	var theme_settings_widget_params : Dictionary = {}
	theme_settings_widget_params.set("WINDOW_TITLE", "themes")
	var theme_item_idx:int = 0
	for app_theme_name:String in all_app_themes:
		#var this_app_theme:AppTheme = all_app_themes.get(app_theme_name)
		theme_settings_widget_params.set(str("ITEM_"+str(theme_item_idx)), app_theme_name)
		theme_item_idx += 1
	
	theme_settings.prepare_setting(
		"theme", # setting_name
		["dropdown_buttons"], # setting_widget(s)
		change_theme_index, # setting_value_changed_callable_function
		[0], # default_setting_widget_value(s)
		[ # widget_parameter_dictionary(s)
			theme_settings_widget_params
		]
	)
	
	var window_panel_color_widget_params:Dictionary ={}
	#window_panel_color_widget_params.set("disabled_callable", is_custom_back_panel_allowed)
	#window_panel_color_widget_params.set("connect_disable_signal", custom_back_panel_privilege)
	theme_settings.prepare_setting(
		"window_panel_color", 
		["color"], 
		change_window_panel_color,
		[Color.BLACK],
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
	if load_theme: change_theme_index(int(theme_settings.get_setting_value("theme")))
	
	theme_settings.spawned_window.connect(new_window_needs_theme)

func change_theme_index(new_index:Variant, can_undo:bool=true):
	var idx:int = int(new_index)
	if can_undo and theme_index != idx:
		var undo:Callable = change_theme_index.bind(theme_index, false)
		var redo:Callable = change_theme_index.bind(idx, false)
		App.record_action(GenericAppAction.new(undo, redo))
	theme_index = idx
	var theme_name:String = all_app_theme_indexes.get(theme_index)
	current_app_theme = all_app_themes.get(theme_name)
	
	var new_theme:Theme = current_app_theme.theme
	current_theme = new_theme
	
	if FileAccess.file_exists(LAST_THEME_FILEPATH):
		DirAccess.remove_absolute(LAST_THEME_FILEPATH)
	
	ResourceSaver.save(current_theme, LAST_THEME_FILEPATH)
	
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
							
							var t:ModularSettingOption = c.options.get("theme")
							t.update_setting_value_from_external(idx)
							
							#var r:ModularSettingOption = c.options.get("reset_theme_settings")
							#r.update_setting_value_from_external(false)

func change_window_panel_color(new_color:Color) -> void:
	theme_settings.set_setting_value("window_panel_color", [new_color], false, true)
	ui.change_window_panel_color(new_color)


func is_custom_back_panel_allowed() -> bool:
	if theme_name == "custom": return true
	else: return false

func new_window_needs_theme(new_window:Window) -> void: new_window.theme = current_theme

func window_size_changed() -> void: 
	if changing_window_size: 
		changing_window_size = false
		return
	app_settings.set_setting_value("window_size", [get_window().size], false, true)

func reset_theme_settings(b):
	if not b: return
	if FileAccess.file_exists(THEME_SETTINGS_PATH): DirAccess.remove_absolute(THEME_SETTINGS_PATH)
	setup_theme_settings()

#static func can_change_directory(try_path:String="") -> bool:
	#if Main.console.operating:
		#AlertSystem.create_warning("Active Process!", "Can't change directory during an active process!")
		#return false
	#return true
#static func refresh_directory() -> void: file_browser.refresh_ui()
#static func open_directory(at_path:String=console.current_directory_path) -> void:
	#console.current_directory_path = at_path
	#console.print_out(at_path)

#static func toggle_file_browser(toggle:bool) -> void: App.ui.toggle_file_browser(toggle)
#

#static func execute(order:String) -> Variant:
	#if not console: return ""
	#return console.execute(order)
#
#
#static func print_out(text:String) -> void:
	#if not console: return
	#console.print_out(text)
