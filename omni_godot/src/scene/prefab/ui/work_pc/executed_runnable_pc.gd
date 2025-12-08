#|*******************************************************************
# executed_runnable_pc.gd
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
extends WorkerSubMenuPC
class_name ExecutedRunnablePC

@export var pid_label: RichTextLabel

@export var os_time_started_label: RichTextLabel
@export var active_label: RichTextLabel
@export var elapsed_label: RichTextLabel
@export var os_time_ended_label: RichTextLabel

var pinfo:Dictionary = {}

func _process(delta: float) -> void:
	if not pinfo.is_empty():
		if pinfo.has("elapsed"):
			var elapsed: float = pinfo.get("elapsed")
			elapsed_label.text = str(str(snappedf(elapsed, 0.001)) + "s")

func runnable_setup(runnable_info:Dictionary) -> void:
	toggle_body(false)
	pinfo = runnable_info
	var process_name: String = runnable_info.get("process_name")
	var new_pid: int = runnable_info.get("pid")
	var active: bool = runnable_info.get("active")
	
	var time_started: float = runnable_info.get("time_started")
	var elapsed: float = runnable_info.get("elapsed")
	var time_ended: float = runnable_info.get("time_ended")
	
	var os_time_started:Dictionary = runnable_info.get("os_time_started")#(Time.get_time_dict_from_system()))
	var os_time_ended:Dictionary = {}; if runnable_info.has("os_time_ended"): os_time_ended = runnable_info.get("os_time_ended")# Dictionary(Time.get_time_dict_from_system()))
	
	change_title(str(process_name))
	pid_label.text = str("PID: " + str(new_pid))
	
	os_time_started_label.text = str("a@: " + str(os_time_started.hour)+":"+str(os_time_started.minute)+":"+str(os_time_started.second))
	
	active_label.text = str("ACTIVE"); active_label.modulate = Color(0.25,1.0,0.25,1.0)
	if not active: active_label.text = str("DEAD"); active_label.modulate = Color(1.0,0.25,0.25,1.0)
	elapsed_label.text = str(str(elapsed) + "s")
	
	if os_time_ended.is_empty(): os_time_ended_label.text = str("b@: !")
	else: os_time_ended_label.text = str("b@: " + str(os_time_ended.hour)+":"+str(os_time_ended.minute)+":"+str(os_time_ended.second))
