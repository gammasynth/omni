extends ConsoleCommand



func _setup_command() -> void:
	is_base_command = true
	has_args = false
	keyword = "create"
	command_description = "Create new node."
	#args = {neweA}
	return


func _perform_command(text_line:String) -> bool:
	await Cast.wait()
	console.print_out("command: help")
	
	Core.easel.create_from_console(command_args)
	
	return true
