#|*******************************************************************
# run.gd
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
	keywords = ["run"]
	command_description = "Executes a command into a new console window."
	return


func _perform_command(text_line:String) -> bool:
	# this command is meant for an ExecutiveConsole, or at least a FileConsole
	var keyword:String = ""
	for kw:String in keywords:
		if text_line.begins_with(kw):
			keyword = kw
			break
	
	var remaining_text:String = text_line.substr(keyword.length())
	while remaining_text.begins_with(" "): remaining_text = remaining_text.substr(1)
	
	#var file: FileAccess = FileAccess.open(final_path, FileAccess.WRITE_READ)
	#print(FileAccess.get_open_error())
	#file.store_line(" ")
	#file = null
	console.print_out(text_line)
	match OS.get_name():
		"Windows": (console as OmniConsole).execute_as_runnable.call(remaining_text)
		"Linux": (console as OmniConsole).execute_as_runnable.call(remaining_text)
		"Android": (console as OmniConsole).execute_as_runnable.call(remaining_text)
	#(console as OmniConsole).refresh()
	return true
