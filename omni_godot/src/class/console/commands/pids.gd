extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["pids"]
	command_description = "List all information related to external processes from this current session, or info about a specific process only, if a pid int is sent as an argument."
	return


func _perform_command(text_line:String) -> bool:
	var keyword:String = ""
	for kw:String in keywords:
		if text_line.begins_with(kw):
			keyword = kw
			break
	
	var remaining_text:String = text_line.substr(keyword.length())
	while remaining_text.begins_with(" "): remaining_text = remaining_text.substr(1)
	
	var pid_attempt:int = -1
	if remaining_text.is_valid_int(): pid_attempt = int(remaining_text)
	
	console.print_out(text_line)
	var empty:bool = true
	if pid_attempt == -1:
		#pass# print all session pid infos
		console.print_out("# ALL EXTERNAL PROCESSES INFO #")
		if (console as OmniConsole).running_process_pids.size() > 0:
			console.print_out("## Active external processes: ")
			for pid:int in (console as OmniConsole).running_process_pids:#Array[int]
				var pid_info:Dictionary = (console as OmniConsole).running_processes_info.get(pid)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
			empty = false
		
		if (console as OmniConsole).process_ran_history.size() > 0:
			console.print_out("## Terminated external processes: ")
			for pid:int in (console as OmniConsole).process_ran_history:#Array[int]
				var pid_info:Dictionary = (console as OmniConsole).processes_ran_info.get(pid)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
			empty = false
		
	else:
		#pass# print a specific pid's info, if has
		console.print_out("# EXTERNAL PROCESS INFO @PID: <" + str(pid_attempt) + "> #")
		var found:bool=false
		if (console as OmniConsole).running_process_pids.size() > 0:
			if (console as OmniConsole).running_process_pids.has(pid_attempt):
				var pid_info:Dictionary = (console as OmniConsole).running_processes_info.get(pid_attempt)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
				found = true
			empty = false
		
		if (console as OmniConsole).process_ran_history.size() > 0:
			if (console as OmniConsole).process_ran_history.has(pid_attempt):
				var pid_info:Dictionary = (console as OmniConsole).processes_ran_info.get(pid_attempt)#Dictionary[int, Dictionary]
				console.print_out(pid_info)
				found = true
			empty = false
		
		if not found: console.print_out("No process found @PID: <" + str(pid_attempt) + "> !")
	
	if empty: console.print_out("No active or terminated session external processes!")
	
	return true
