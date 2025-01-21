extends Database

class_name Console

signal operation_started
signal operation_finished

signal directory_focus_changed(new_current_path:String)

var line_count:int = 0

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
	var extension: String = text_line.get_extension()
	
	# First, you should check all commands from Registry to see if one runs. If not, let code below run.
	# TODO
	# !!!
	# Registry.get_registry("console_commands")
	# set operated = true when doing a command
	# !!!
	# TODO
	
	# default non-command behavior below
	
	# this could be a file, or a URL
	if extension.length() > 0:
		# check if file, else check if URL
		var file_paths: Array[String] = FileManager.get_all_filepaths_from_directory(current_directory_path)
		for fp: String in file_paths:
			print(fp)
			if text_line.to_snake_case() == fp.to_snake_case():
				operated = true
				App.print_out("executing file " + text_line.to_snake_case() + "...")
				App.execute(str(current_directory_path + fp))
		
		if not operated:
			operated = true
			var client: HTTPClient = HTTPClient.new()
			if not text_line.begins_with("https://"): text_line = str("https://" + text_line)
			
			print("connecting to url...")
			var connection: Error = await client.connect_to_host(text_line)
			print(str(str(text_line) + error_string(connection)))
			
			if connection == OK:
				var e: Error = await client.request(HTTPClient.METHOD_GET, "", [])
				print(error_string(e))
			else: print("BAD")
	
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
