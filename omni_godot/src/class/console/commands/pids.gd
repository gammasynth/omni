#|*******************************************************************
# pids.gd
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
extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["pids"]
	command_description = "List all information related to external processes from this current session, or info about a specific process only, if a pid int is sent as an argument."
	return


func _perform_command(text_line:String) -> bool:
	var keyword:String = ""
	for kw:String in keywords:
		if text_line.begins_with(kw):
			keyword = kw
			break
	
	var remaining_text:String = text_line.substr(keyword.length())
	while remaining_text.begins_with(" "): remaining_text = remaining_text.substr(1)
	
	var pid_attempt:int = -1
	if remaining_text.is_valid_int(): pid_attempt = int(remaining_text)
	
	console.print_out(text_line)
	var empty:bool = true
	if pid_attempt == -1:
		#pass# print all session pid infos
		console.print_out("# ALL EXTERNAL PROCESSES INFO #")
		if (console as OmniConsole).running_process_pids.size() > 0:
			console.print_out("## Active external processes: ")
			for pid:int in (console as OmniConsole).running_process_pids:#Array[int]
				var pid_info:Dictionary = (console as OmniConsole).running_processes_info.get(pid)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
			empty = false
		
		if (console as OmniConsole).process_ran_history.size() > 0:
			console.print_out("## Terminated external processes: ")
			for pid:int in (console as OmniConsole).process_ran_history:#Array[int]
				var pid_info:Dictionary = (console as OmniConsole).processes_ran_info.get(pid)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
			empty = false
		
	else:
		#pass# print a specific pid's info, if has
		console.print_out("# EXTERNAL PROCESS INFO @PID: <" + str(pid_attempt) + "> #")
		var found:bool=false
		if (console as OmniConsole).running_process_pids.size() > 0:
			if (console as OmniConsole).running_process_pids.has(pid_attempt):
				var pid_info:Dictionary = (console as OmniConsole).running_processes_info.get(pid_attempt)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
				found = true
			empty = false
		
		if (console as OmniConsole).process_ran_history.size() > 0:
			if (console as OmniConsole).process_ran_history.has(pid_attempt):
				var pid_info:Dictionary = (console as OmniConsole).processes_ran_info.get(pid_attempt)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
				found = true
			empty = false
		
		if not found: console.print_out("No process found @PID: <" + str(pid_attempt) + "> !")
	
	if empty: console.print_out("No active or terminated session external processes!")
	
	return true
