extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["file"]
	command_description = "Create a new file, give a file name as argument to name the file."
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
	
	if remaining_text.length() == 0: remaining_text = "new_file.txt"
	if remaining_text.get_extension().is_empty(): remaining_text = str(remaining_text+".file")
	
	var path:String = File.ends_with_slash((console as OmniConsole).current_directory_path)
	var ext:String = remaining_text.get_extension(); if ext.length() > 0: ext = str("." + ext)
	var file_name:String = remaining_text.substr(0, remaining_text.find(ext))
	var used_file_name:String = file_name
	var r:int = 1
	while FileAccess.file_exists(str(path + used_file_name + ext)):
		used_file_name = str(file_name + "_" + str(r))
		r += 1
	
	var final_path:String = str(used_file_name + ext)
	#var file: FileAccess = FileAccess.open(final_path, FileAccess.WRITE_READ)
	#print(FileAccess.get_open_error())
	#file.store_line(" ")
	#file = null
	console.print_out(text_line)
	console.print_out(str("Making new file: " + final_path))
	match OS.get_name():
		"Windows": (console as OmniConsole).execute.call_deferred(str("echo. > " + final_path))
		"Linux": (console as OmniConsole).execute.call_deferred(str("touch " + final_path))
		"Android": (console as OmniConsole).execute.call_deferred(str("touch " + final_path))
	#(console as OmniConsole).refresh()
	return true
