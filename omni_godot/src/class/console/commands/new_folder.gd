extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["folder"]
	command_description = "Create a new folder (directory), give a folder name as argument to name the folder."
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
	
	if remaining_text.length() == 0: remaining_text = "new_folder"
	
	var path:String = (console as OmniConsole).current_directory_path
	var file_name:String = remaining_text
	var used_file_name:String = file_name
	var r:int = 1
	while DirAccess.dir_exists_absolute(str(path + used_file_name)):
		used_file_name = str(file_name + "_" + str(r))
		r += 1
	
	var final_path:String = str(used_file_name)
	var output = final_path
	#var file: FileAccess = FileAccess.open(final_path, FileAccess.WRITE_READ)
	#print(FileAccess.get_open_error())
	#file.store_line(" ")
	#file = null
	console.print_out(text_line)
	match OS.get_name():
		"Windows": (console as OmniConsole).execute.call_deferred(str("mkdir " + output))
		"Linux": (console as OmniConsole).execute.call_deferred(str("mkdir " + output))
		"Android": (console as OmniConsole).execute.call_deferred(str("mkdir " + output))
	#(console as OmniConsole).refresh()
	return true
