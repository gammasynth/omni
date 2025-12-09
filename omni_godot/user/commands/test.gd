extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["test"]
	command_description = "This is an example of a command, you can simply duplicate this command in the /user/commands/ directory, change the keyword String, and add code to the _perform_command function."
	return


func _perform_command(_text_line:String) -> bool:
	console.print_out("The test command has been executed successfully.")
	return true
