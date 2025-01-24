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
