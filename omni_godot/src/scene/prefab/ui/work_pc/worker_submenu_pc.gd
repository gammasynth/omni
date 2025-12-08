#|*******************************************************************
# worker_submenu_pc.gd
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
@tool
extends PanelContainer
class_name WorkerSubMenuPC

var changing_title:bool=false
@export var title_name:String = "":
	set(t):
		title_name = t
		if Engine.is_editor_hint() or changing_title: title_label.text = t
		changing_title = false

@export var title_label:RichTextLabel
@export var minimize_button:Button
@export var body_container:Container
@export var original_body_vbox:VBoxContainer

func _init() -> void: ready.connect(prepare)
func prepare() -> void: if minimize_button: minimize_button.button_down.connect(_minimize_button_down)

func change_title(new_title:String) -> void: changing_title = true; title_name = new_title

func toggle_body(toggle:bool) -> void:
	if toggle: 
		body_container.visible = true
		minimize_button.icon = MainUI.TRAP_ARROW_UP_BRIGHT
	else:
		body_container.visible = false# TODO USE AppTheme ICONS INSTEAD
		minimize_button.icon = MainUI.TRAP_ARROW_DOWN_SMOOTH

func _minimize_button_down() -> void:
	if body_container.visible: toggle_body(false)
	else: toggle_body(true)
