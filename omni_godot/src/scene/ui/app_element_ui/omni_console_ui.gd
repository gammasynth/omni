extends DatabasePanelContainer

class_name ConsoleUI

func _get_database(o:Database) -> Database:
	if not o: o = OmniConsole.new(name)
	#if not o.name == name: o.name = name
	
	database = o
	
	return o

var console: Console:
	get: return db

@onready var vbox: VBoxContainer = $vbox

@onready var code: CodeEdit = $vbox/code_split/code

@onready var spacer: Control = $vbox/spacer

@onready var line: LineEdit = $vbox/line_hbox/line

@onready var spacer_2: Control = $vbox/spacer2
@onready var sep: HSeparator = $vbox/sep
@onready var spacer_3: Control = $vbox/spacer3

@onready var menu: MenuBar = $vbox/menu

@onready var sep_2: HSeparator = $vbox/sep2
@onready var spacer_4: Control = $vbox/spacer4

@onready var hbox: HBoxContainer = $vbox/hbox

@onready var console_menu_toggler: Button = $vbox/hbox/console_menu_toggler
@onready var console_history_toggler: Button = $vbox/hbox/console_history_toggler
@onready var file_browser_toggler: Button = $vbox/hbox/file_browser_toggler

@onready var sep_01: VSeparator = $vbox/hbox/sep

@onready var path_panel_container: PanelContainer = $vbox/hbox/path_panel_container
@onready var path_label: RichTextLabel = $vbox/hbox/path_panel_container/path_label

@onready var spacer_01: Control = $vbox/hbox/spacer
@onready var sep_02: VSeparator = $vbox/hbox/sep2

@onready var console_label: RichTextLabel = $vbox/hbox/console_label
@onready var omni_button: Button = $vbox/hbox/omni_button

@onready var background: Control = $vbox/code_split/background

const TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED = preload("res://src/assets/texture/ui/console/trap_outline_symbol_filled_flipped.png")
const TRAP_OUTLINE_SYMBOL_SHINY = preload("res://src/assets/texture/ui/console/trap_outline_symbol_shiny.png")

const U_DARKER = preload("res://src/assets/texture/ui/console/u_darker.png")
const U_SHINY = preload("res://src/assets/texture/ui/console/u_shiny.png")

const FILE_BROWSER_BUTTON_BRIGHT = preload("res://src/assets/texture/ui/console/file_browser_button_bright.png")
const FILE_BROWSER_BUTTON_DARK = preload("res://src/assets/texture/ui/console/file_browser_button_dark.png")



var animating_line_icon: bool = false



func _ready_up():
	
	get_window().focus_entered.connect(line.grab_focus)
	
	get_window().files_dropped.connect(func(f): print(f))
	App.ui.console_ui = self
	App.console = console
	
	console.text_edit = code
	console.line_edit = line
	# - - -
	
	App.console.operation_started.connect(func(): line.editable = false)
	App.console.operation_finished.connect(func(): line.editable = true)
	
	
	# - - -
	
	console.menu_bar_mode = false
	toggle_menu_bar_mode()
	
	console.command_history_mode = false
	toggle_command_history()
	
	console.file_browser_mode = false
	toggle_file_browser()
	
	refresh_console_label()
	path_label.text = console.current_directory_path
	console.directory_focus_changed.connect(func(new_path:String): path_label.text = new_path)
	
	clear_console_history()
	# - - -
	
	play_line_icon_anim()
	display_greeting()
	
	#current_directory_path = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)
	
	
	App.refresh_window(Vector2i(250,50))
	
	#await setup_settings()
	$HTTPRequest.request("https://github.com")


func setup_settings():
	var settings : Settings = Settings.initialize_settings("console")
	settings.prepare_setting("background", ["boolean"], func(b): background.visible = b, [true], [{}] )
	settings.finish_prepare_settings()
	
	await settings.instance_ui(vbox)


func clear_console_history():
	console.clear_console_history()

func display_greeting():
	console.greeting = true
	display_sentient_message("welcome, user.")
	print_out("omni")
	print_out("[ gammasynth ]")
	print_out(" ")
	print_out(console.current_directory_path)


func print_out(text:Variant) -> void:
	#code.insert_text(text, code.get_line_count(), 0)
	#code.set_line(code.get_line_count(), text)
	#code.insert_line_at(code.get_line_count(), text)
	
	console.print_out(text)
	
	#print(code.text)
	update_screen_size()


func standby():
	display_sentient_message()

func display_sentient_message(text:String=""):
	
	if not text.is_empty() and console.sentient_line: return
	
	if not line.text.is_empty(): 
		line.placeholder_text = ""
		console.sentient_line = false
		return
	
	
	if not text.is_empty(): console.sentient_line = true
	else: console.sentient_line = false
	
	line.placeholder_text = text


func refresh_console_label() -> void:
	var info: String = "[pulse freq=0.75 color=#00abab80 ease=-1.5][url=https://gammasynth.itch.io/omni]Amn1[/url][/pulse]_"
	var version : String = ProjectSettings.get_setting("application/config/version")
	console_label.text = str(info + version)
	


func toggle_menu_bar_mode(toggle:bool=console.menu_bar_mode) -> void:
	if toggle: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_SHINY
	else: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED
	
	spacer_2.visible = toggle
	sep.visible = toggle
	spacer_3.visible = toggle
	menu.visible = toggle
	sep_2.visible = toggle
	spacer_4.visible = toggle
	
	App.refresh_window()

func toggle_command_history(toggle:bool=console.command_history_mode) -> void:
	if toggle: 
		console_history_toggler.icon = U_SHINY
		update_screen_size()
	else: console_history_toggler.icon = U_DARKER
	
	code.visible = toggle
	spacer.visible = toggle
	
	App.refresh_window()

func update_screen_size():
	var command_history_min_y:int = 0
	if console.command_history_mode: 
		command_history_min_y = clamp(
			(console.line_count * 24) * 2,
			 0,
			 DisplayServer.screen_get_size(get_window().current_screen).y - floor(get_window().position.y) / 4)
	
	var file_browser_min_y:int = 0; if console.file_browser_mode: file_browser_min_y = floor(App.ui.file_browser_ui.custom_minimum_size.y)
	
	var menu_min_y:int = 0
	if console.menu_bar_mode: 
		menu_min_y += floor(spacer_2.size.y)
		menu_min_y += floor(sep.size.y)
		menu_min_y += floor(spacer_3.size.y)
		menu_min_y += floor(menu.size.y)
		menu_min_y += floor(sep_2.size.y)
		menu_min_y += floor(spacer_4.size.y)
	
	var min_y: int = command_history_min_y + file_browser_min_y + menu_min_y
	var size_y: int = get_window().size.y
	if min_y > size_y: size_y = min_y
	
	App.resize(
			Vector2i(
				get_window().size.x,
				#console.line_count * 128
				size_y
				)
			)


func toggle_file_browser(toggle:bool=console.file_browser_mode) -> void:
	if toggle: file_browser_toggler.icon = FILE_BROWSER_BUTTON_BRIGHT
	else: file_browser_toggler.icon = FILE_BROWSER_BUTTON_DARK
	
	App.toggle_file_browser(toggle)
	
	App.refresh_window()




func play_line_icon_anim():
	animating_line_icon = true
	line.right_icon.current_frame = 0
	line.right_icon.pause = false
	
	var e = func():
		if animating_line_icon: return
		line.right_icon.current_frame = 14
		line.right_icon.pause = true
	
	get_tree().create_timer(0.5).timeout.connect(func(): animating_line_icon = false)
	get_tree().create_timer(0.51).timeout.connect(e)







func _on_console_menu_toggler_button_down() -> void:
	console_menu_toggler.release_focus()
	console.menu_bar_mode = !console.menu_bar_mode
	toggle_menu_bar_mode()




func _on_console_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_console_label_meta_hover_started(_meta: Variant) -> void:
	pass # Replace with function body.

func _on_console_label_meta_hover_ended(_meta: Variant) -> void:
	pass # Replace with function body.


func _on_console_history_toggler_button_down() -> void:
	console_history_toggler.release_focus()
	console.command_history_mode = !console.command_history_mode
	toggle_command_history()



func _on_line_text_submitted(new_text: String) -> void:
	
	if console.operating: return
	
	line.clear()
	play_line_icon_anim()
	
	console.parse_text_line(new_text)
	


func _on_line_mouse_entered() -> void:
	standby()


func _on_line_mouse_exited() -> void:
	
	standby()
	display_sentient_message("omni")
	


func _on_file_browser_toggler_button_down() -> void:
	file_browser_toggler.release_focus()
	console.file_browser_mode = !console.file_browser_mode
	toggle_file_browser()


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	#print(result)
	#print(response_code)
	#print(headers)
	#print(body)
	pass


func _on_edit_index_pressed(index: int) -> void:
	if index == 0: # Edit Theme
		var settings: Settings = Settings.all_settings.get("theme")
		settings.instance_ui_window(App.instance)
