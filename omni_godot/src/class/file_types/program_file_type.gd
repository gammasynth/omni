extends FileType

## Override this function in an extended script to add a new file extension.
func _refresh_info(at_path:String="") -> void:
	is_base_file = true
	extensions = ["exe", "x86_64", "bin"]
	
	file_browser_item_icon = get_file_icon("black_box_exe_generic.png")
	
