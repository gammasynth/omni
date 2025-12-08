# omni
omni | Console Browser  
  
![omni icon](https://raw.githubusercontent.com/gammasynth/omni/refs/heads/main/omni_branding/omni_symbol_256.png)
  
Omni is an open-source, moddable, high-level programming console.  
  
## App Features
  
- A simple, skinnable, command terminal UI.  
  
- Console output history can be hidden/toggled.  
  
- Window can be resized and UI elements minimized, allowing for a simple single line-entry terminal.  
  
- Current directory, theme, color, UI element size, and UI element visibilities are saved to disk and persistent between runtime sessions.  
  
- User-added command execution via high-level programming.  
  
- The command terminal will call an entered command via the OS terminal, if it does not recognize the entered command as an existing user-added command.  
  
- Optional in-app file browser UI alongside the command terminal.  
  
- Files and folders can be toggled as 'favorites' to be shown in a side-menu in the file browser UI.
  
- Optional DB console output for the internal operation of the omni instance.
  
- Piped & Tracked external executable processes, with data logged per session.  
  
  

## Custom User Commands
  
  
Omni is written in the GDScript programming language, and the app is able to load new user-written command scripts, written in that language, for the terminal to be able to execute them.
  
  
The command terminal can be given new possible command operations by placing ConsoleCommand classtype GDScript files into the app's user directory.  
  
  
Commands directory on Windows Operating Systems:  
  
```
%APPDATA%
/user/AppData/Roaming/gammasynth/omni/commands/
```  
  
  
To write a new command, create a new .gd text file in the /commands/ user folder, and write or copy the basis of an extended ConsoleCommand class in that .gd file.
  
The basis of an extended ConsoleCommand class includes:  
  
- Establishing `extends ConsoleCommand` at the top of the script (first line of code) for class namespace inheritance.  
  
- Establishing a `func _setup_command()` function to apply a String (or multiple) to the `keywords` Array class member, and perhaps a String for the `command_description` member.  
  
- Establishing a `func _perform_command(text_line:String) -> bool` function, to perform the command functionality *(whatever it should do)* upon the terminal catching one of the command's keywords being entered by the terminal user.  
  
  
Within the `_perform_command` function, the ConsoleCommand Script is given a `text_line` String argument, which can be used to further parse the user-submitted text to the terminal, such as pulling arguments.  
  
If you do not want a user generated ConsoleCommand to finish its execution (and therefore prevent other commands or even the OS terminal from handling a terminal input, when a keyword of this command has already been caught), then you can return a `false` at any point within the `_perform_command` function.  
  
If the `_perform_command` returns `true`, then the terminal will finish upon that function for the entered command execution.  
  
If the `_perform_command` returns `false`, then the terminal will ignore that this command has been caught by one of its keywords, and the terminal will continue to parse/execute the user's entry without continued regard for this specific ConsoleCommand.  
  
  
  
One can also copy the following example custom user ConsoleCommand Script, and paste it into a new `test.gd` text file, in their /omni/commands/ user directory.  
  
Example custom user ConsoleCommand Script:
```
  extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = true
	keywords = ["test"]
	command_description = "This is a test command. Place this text in a file like /commands/test.gd"
	return


func _perform_command(text_line:String) -> bool:
	console.print_out("The test command was executed properly.)
	# You can place other GDScript code here in this function, to execute that code with this command in the omni terminal.
	return true
```