extends RefCounted
class_name AppTheme

var theme_name:String = "default"
var theme:Theme=null

var main_menu_icon_on:Texture2D
var main_menu_icon_off:Texture2D

var worker_menu_icon_on:Texture2D
var worker_menu_icon_off:Texture2D

var console_output_icon_on:Texture2D
var console_output_icon_off:Texture2D

var file_browser_icon_on:Texture2D
var file_browser_icon_off:Texture2D

var db_console_output_icon_on:Texture2D
var db_console_output_icon_off:Texture2D

func setup() -> void: _setup()

## Override this function in an extended class to set settings and textures for an AppTheme.
func _setup() -> void:
	theme_name = "default"
	theme = load("res://lib/gd_app_ui/resource/theme/default_pixel.theme")
	set_default_icon_textures()

func set_default_icon_textures() -> void:
	main_menu_icon_on = load("res://resource/texture/ui/console/trap_outline_symbol_shiny.png")
	main_menu_icon_off = load("res://resource/texture/ui/console/trap_outline_symbol_filled_flipped.png")
	
	worker_menu_icon_on = load("res://resource/texture/ui/console/right_panel_u_white.png")
	worker_menu_icon_off = load("res://resource/texture/ui/console/right_panel_u_dark.png")
	
	console_output_icon_on = load("res://resource/texture/ui/console/u_shiny.png")
	console_output_icon_off = load("res://resource/texture/ui/console/u_darker.png")
	
	file_browser_icon_on = load("res://resource/texture/ui/console/file_browser_button_bright.png")
	file_browser_icon_off = load("res://resource/texture/ui/console/file_browser_button_dark.png")
	
	db_console_output_icon_on = load("res://resource/texture/icon_inverted_debug.png")
	db_console_output_icon_off = load("res://resource/texture/icon.png")
