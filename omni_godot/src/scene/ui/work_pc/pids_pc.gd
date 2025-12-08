#|*******************************************************************
# pids_pc.gd
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
extends WorkerSubMenuPC
class_name PIDsPC



const EXECUTED_RUNNABLE_PC = preload("res://src/scene/prefab/ui/work_pc/executed_runnable_pc.tscn")

@export var body_vbox: VBoxContainer

@export var terminated_pids_container: WorkerSubMenuPC
@export var active_pids_container: WorkerSubMenuPC
@export var empty_label: RichTextLabel

@export var terminated_pids_body_vbox: VBoxContainer
@export var active_pids_body_vbox: VBoxContainer


var active_pcs:Dictionary[int, ExecutedRunnablePC] = {}
var terminated_pcs:Dictionary[int, ExecutedRunnablePC] = {}

func _ready() -> void:
	Main.console.runnable_added.connect(runnable_added)
	Main.console.runnable_finished.connect(runnable_finished)

func runnable_added(runnable_info:Dictionary) -> void:
	active_pids_container.visible = true
	empty_label.visible = false
	var runnable_pc:ExecutedRunnablePC = EXECUTED_RUNNABLE_PC.instantiate()
	active_pcs.set(runnable_info.get("pid"), runnable_pc)
	await Make.child(runnable_pc, active_pids_body_vbox)
	runnable_pc.runnable_setup(runnable_info)

func runnable_finished(runnable_info:Dictionary) -> void:
	terminated_pids_container.visible = true
	empty_label.visible = false
	var runnable_pc:ExecutedRunnablePC = EXECUTED_RUNNABLE_PC.instantiate()
	var this_pid:int = runnable_info.get("pid")
	if active_pcs.has(this_pid):
		var this_pc:ExecutedRunnablePC = active_pcs.get(this_pid)
		if active_pids_body_vbox.has_node(this_pc.get_path()): active_pids_body_vbox.remove_child(this_pc)
		active_pcs.erase(this_pid)
		if active_pids_body_vbox.get_child_count() == 0: active_pids_container.visible = false
	terminated_pcs.set(this_pid, runnable_pc)
	await Make.child(runnable_pc, terminated_pids_body_vbox)
	runnable_pc.runnable_setup(runnable_info)
	
