extends ExecutiveConsole

class_name OmniConsole

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

var running_process_pids:Array[int] = []

func execute_as_runnable(order:String) -> void:
	print_out(["executing..."])
	var new_pid:int = perform_runnable_execution(order)
	if new_pid == -1: print_out("process execution failed!")
	else: added_new_running_process(new_pid)


func added_new_running_process(new_pid:int) -> void:
	running_process_pids.append(new_pid)
	print_out(str("new process id: " + str(new_pid)))

func _refresh() -> void: 
	change_directory(current_directory_path, false, false)
	Main.file_browser.refresh()
