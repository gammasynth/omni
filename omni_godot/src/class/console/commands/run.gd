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
