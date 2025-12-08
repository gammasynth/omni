#|*******************************************************************
# folder_file_type.gd
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
extends FileType

## Override this function in an extended script to add a new file extension.
func _refresh_info(at_path:String="") -> void:
	is_base_file = true
	is_folder = true
	extensions = []
	
	file_browser_item_icon = get_file_icon("empty_folder.png")
	
	if at_path.is_empty(): return
	if not DirAccess.dir_exists_absolute(at_path): return
	
	var folders : Array[String] = File.get_all_directories_from_directory(at_path, true)
	var files: Array[String] = File.get_all_filepaths_from_directory(at_path, "", true)
	
	var ft_registry: Registry = Registry.get_registry("file_types")
	var ft_registry_entry: RegistryEntry = ft_registry.grab("file_types")
	var program_ft: FileType = ft_registry_entry.grab("program_file_type").new()
	
	if folders.size() > 0:
		if files.size() > 0:
			var has_program: bool = false
			
			for fp:String in files:
				if FileType.is_file_path_of_file_type(program_ft, at_path):
					has_program = true
					break
			
			if has_program:
				file_browser_item_icon = get_file_icon("folder_program.png")
			else:
				file_browser_item_icon = get_file_icon("folder_in_folder_content.png")
		else:
			file_browser_item_icon = get_file_icon("folder_group.png")
	else:
		if files.size() > 0:
			var has_program: bool = false
			
			for fp:String in files:
				if FileType.is_file_path_of_file_type(program_ft, at_path):
					has_program = true
					break
			
			if has_program:
				file_browser_item_icon = get_file_icon("folder_program.png")
			else:
				file_browser_item_icon = get_file_icon("folder_content.png")
