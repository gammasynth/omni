extends ExecutiveConsole

class_name OmniConsole

signal runnable_added(runnable_info:Dictionary)
signal runnable_finished(runnable_info:Dictionary)

var menu_bar_mode: bool = false
var command_history_mode: bool = false
var file_browser_mode: bool = false

var greeting: bool = false

var using_placeholder: bool = false:
	set(b):
		using_placeholder = b
		if not b:
			greeting = false
			# etc...

var console_session_duration:float = 0.0

## List of the process pids that are currently running after Omni executed them.
var running_process_pids:Array[int] = []

## Information dictionaries about actively running processes that Omni has executed, keyed by their pids.
var running_processes_info:Dictionary[int, Dictionary] = {} 

## List of the process pids that have been ran and terminated after Omni executed them.
var process_ran_history:Array[int] = []

## Information dictionaries from running_processes_info after the processes have terminated.
var processes_ran_info:Dictionary[int, Dictionary] = {}

func _init(_name:String="omni_console", _key:Variant=_name) -> void:
	super(_name, _key)

func console_process(delta:float) -> void:
	console_session_duration += delta
	process_runnables(delta)
	

func process_runnables(delta:float) -> void:
	var active_pids:Array[int] = []
	var idx:int = 0
	for pid:int in running_process_pids:
		var pinfo:Dictionary = running_processes_info.get(pid)
		if OS.is_process_running(pid): 
			var started: float = pinfo.get("time_started")
			var elapsed: float = float(console_session_duration - started)
			pinfo.set("elapsed", elapsed)
			active_pids.append(pid)
		else: 
			if idx == 0 and last_print != " " and last_print != "": print_out(" ")
			remove_running_process(pid)
			if idx == running_process_pids.size() - 1 and last_print != " " and last_print != "":  print_out(" ")
		idx += 1
	running_process_pids = active_pids

func execute_as_runnable(order:String) -> void:
	print_out(["Executing..."])
	var process_name:String = order
	
	var schar:String = ""; if process_name.contains(" "): schar = " "
	if schar.length() > 0: process_name = process_name.substr(0, process_name.find(schar))
	process_name = File.ends_with_slash(process_name, false)
	process_name = File.begins_with_slash(process_name, false)
	#process_name = File.get_file_name_from_file_path(process_name)# overkill
	
	var new_pid:int = perform_runnable_execution(order)
	if new_pid == -1: print_out("Run process execution failed!")
	else: added_new_running_process(process_name, new_pid)

func remove_running_process(pid:int) -> void:
	var pinfo:Dictionary = running_processes_info.get(pid)
	pinfo.set("active", bool(false))
	pinfo.set("os_time_ended", Dictionary(Time.get_time_dict_from_system()))
	pinfo.set("time_ended", float(console_session_duration))
	
	running_process_pids.erase(pid)
	running_processes_info.erase(pid)
	
	process_ran_history.append(pid)
	processes_ran_info.set(pid, pinfo)
	
	print_out(str("Running process terminated at pid: " + str(pid)))
	runnable_finished.emit(pinfo)

func added_new_running_process(process_name:String, new_pid:int) -> void:
	running_process_pids.append(new_pid)
	
	var new_process_info:Dictionary ={}
	new_process_info.set("process_name", String(process_name))
	new_process_info.set("active", bool(true))
	new_process_info.set("pid", int(new_pid))
	new_process_info.set("os_time_started", Dictionary(Time.get_time_dict_from_system()))
	new_process_info.set("time_started", float(console_session_duration))
	new_process_info.set("elapsed", float(0.0))
	new_process_info.set("time_ended", float(-1.0))
	
	running_processes_info.set(new_pid, new_process_info)
	print_out(str("New running process id: " + str(new_pid)))
	runnable_added.emit(new_process_info)

func _refresh() -> void: 
	change_directory(current_directory_path, false, false)
	Main.file_browser.refresh()
