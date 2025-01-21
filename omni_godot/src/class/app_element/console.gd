extends Database

class_name Console

signal operation_started
signal operation_finished

signal directory_focus_changed(new_current_path:String)

var menu_bar_mode: bool = false
var command_history_mode: bool = false
var file_browser_mode: bool = false

var greeting: bool = false

var sentient_line: bool = false:
	set(b):
		sentient_line = b
		if not b:
			greeting = false
			# etc...


var current_directory_path: String = "C:/":
	set(path):
		current_directory_path = path
		directory_focus_changed.emit(path)


var operating: bool = false:
	set(b):
		if b: operation_started.emit()
		else: operation_finished.emit()
		operating = b


func parse_text_line(text_line:String) -> void:
	if operating: 
		# here is where we can introduce a "parse line queue"
		return# TODO
	operating = true
	# - - -
	
	var operated: bool = false
	
	
	# if text is the above directory's folder name
	if not operated: operated = is_text_line_above_folder(text_line)
	
	# if text is a folder name within the current directory
	if not operated: operated = is_text_line_a_subfolder(text_line)
	
	# - - -
	operating = false
	return


func is_text_line_above_folder(text_line:String) -> bool:
	var cp:String = current_directory_path
	
	while true:
		while cp.right(1) == "/" or cp.right(1) == "\\": cp = FileManager.ends_with_slash(cp, false)
		
		if not cp.containsn("/") and not cp.containsn("\\"): return false
		
		var slash_index:int = cp.rfind("/")
		if slash_index == -1: slash_index = cp.rfind("\\")
		if slash_index == -1: return false
		
		cp = cp.left(slash_index)
		var above_folder_name:String = FileManager.no_slashes(cp).replacen(":","").to_snake_case()
		var line_name: String = FileManager.no_slashes(text_line).to_snake_case()
		
		
		if line_name == above_folder_name:
			cp = FileManager.ends_with_slash(cp)
			if DirAccess.dir_exists_absolute(cp):
				App.open_directory(cp)
				return true
	
	return false

func is_text_line_a_subfolder(text_line) -> bool:
	var folder_paths: Array[String] = FileManager.get_all_directories_from_directory(current_directory_path, true)
	
	var folder_name: String = FileManager.no_slashes(text_line).to_snake_case()
	for fp: String in folder_paths:
		var fn:String = FileManager.no_slashes(fp).to_snake_case()
		if folder_name == fn:
			App.open_directory(fp)
			return true
	
	return false
