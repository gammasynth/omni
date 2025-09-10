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
