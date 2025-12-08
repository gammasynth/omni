#|*******************************************************************
# app_theme.gd
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
