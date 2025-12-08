#|*******************************************************************
# query_confirmation_pc.gd
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
extends PanelContainer
class_name QueryConfirmationPC

var prompt:String
var desc:String
var confirm:Callable
var deny:Callable

@onready var query_prompt_label: RichTextLabel = $margin/vbox/prompt_pc/margin/query_prompt_label
@onready var query_desc_label: RichTextLabel = $margin/vbox/query_desc_label
@onready var cancel_button: Button = $margin/vbox/hbox/cancel_button
@onready var confirm_button: Button = $margin/vbox/hbox/confirm_button

func setup(_prompt:String, _desc:String, _confirm:Callable, _deny:Callable, _show:bool=true) -> void:
	prompt = _prompt
	desc = _desc
	confirm = _confirm
	deny = _deny
	
	query_prompt_label.text = prompt
	query_desc_label.text = _desc
	
	if _show: visible = true

func _on_cancel_button_button_down() -> void: 
	deny.call()
	visible = false

func _on_confirm_button_button_down() -> void: 
	confirm.call()
	visible = false
