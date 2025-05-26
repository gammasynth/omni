extends Database

class_name OmniFileBrowser

var file_browser_ui: FileBrowserUI

var grid_mode: bool = true


func _init(_file_browser_ui:FileBrowserUI=null,_name:String="file_browser", _key:Variant=_name) -> void:
	super(_name, _key)
	file_browser_ui = _file_browser_ui


func parse_directory(new_directory_path:String) -> Error:
	
	file_browser_ui.clear_ui_items()
	
	var all_paths: Array[String] = []
	
	
	var folder_paths = DirAccess.get_directories_at(new_directory_path)
	for p in folder_paths:
		all_paths.append(new_directory_path + File.ends_with_slash(p))
	
	
	var file_paths = DirAccess.get_files_at(new_directory_path)
	for p in file_paths:
		all_paths.append(new_directory_path + p)
	
	
	
	for p in all_paths:
		
		var ft: FileType = FileType.get_file_type_from_path(p)
		if not ft: continue
		
		file_browser_ui.add_item(p, ft)
		
		#var file_item_error: Error = item.setup_from_file_path(p)
		#if file_item_error != OK: item.queue_free(); continue
		
		
		
	
	file_browser_ui.refresh_grid_size()
	
	return OK
