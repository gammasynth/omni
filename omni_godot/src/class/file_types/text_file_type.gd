extends FileType

## Override this function in an extended script to add a new file extension.
func _refresh_info(at_path:String="") -> void:
	is_base_file = true
	extensions = ["txt"]
	
	file_browser_item_icon = get_file_icon("empty_file.png")
	
	if at_path.is_empty(): return
	if not FileAccess.file_exists(at_path): return
	
	var file: FileAccess = File.get_file(at_path)
	var bytes:int = file.get_length()
	
	if bytes > 1: file_browser_item_icon = get_file_icon("written_file.png")
