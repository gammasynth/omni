extends DatabasePanelContainer

class_name ConsoleUI


var console: Console:
	get: 
		if not console:
			console = OmniConsole.new(name)
			db = console
			#console.uses_threads = true
			console.uses_piped = true
		return db

@onready var vbox: VBoxContainer = $vbox

@onready var code: RichTextLabel = $vbox/code_split/code

@onready var spacer: Control = $vbox/spacer

@onready var line: LineEdit = $vbox/line_hbox/line

@onready var spacer_2: Control = $vbox/spacer2
@onready var sep: HSeparator = $vbox/sep
@onready var spacer_3: Control = $vbox/spacer3

@onready var menu: MenuBar = $vbox/menu
@onready var file: PopupMenu = $vbox/menu/File
@onready var edit: PopupMenu = $vbox/menu/Edit
@onready var settings: PopupMenu = $vbox/menu/Settings


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

const TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED = preload("res://resource/texture/ui/console/trap_outline_symbol_filled_flipped.png")
const TRAP_OUTLINE_SYMBOL_SHINY = preload("res://resource/texture/ui/console/trap_outline_symbol_shiny.png")

const U_DARKER = preload("res://resource/texture/ui/console/u_darker.png")
const U_SHINY = preload("res://resource/texture/ui/console/u_shiny.png")

const FILE_BROWSER_BUTTON_BRIGHT = preload("res://resource/texture/ui/console/file_browser_button_bright.png")
const FILE_BROWSER_BUTTON_DARK = preload("res://resource/texture/ui/console/file_browser_button_dark.png")

var animating_line_icon: bool = false
var processing_command:bool = false



func _ready_up():
	get_window().mouse_entered.connect(line.grab_focus)
	get_window().files_dropped.connect(func(f): print(f))# TODO add drop files
	
	App.ui.console_ui = self
	Main.console = console
	
	console.rich_label = code
	console.line_edit = line
	
	console.operation_started.connect(func(): line.editable = false)
	console.operation_finished.connect(func(): line.editable = true)
	console.operation_finished.connect(func(): line.grab_focus.call_deferred())
	
	console.directory_focus_changed.connect(directory_focus_changed)
	
	console.process_started.connect(thread_process_started)
	
	console.menu_bar_mode = false; toggle_menu_bar_mode()
	console.command_history_mode = true; toggle_command_history()
	console.file_browser_mode = false; toggle_file_browser()
	
	refresh_console_label()
	
	
	play_line_icon_anim()
	display_greeting()
	#current_directory_path = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)
	#$HTTPRequest.request("https://github.com")
	
	line.grab_focus.call_deferred()

func thread_process_started() -> void: processing_command = true

func _process(delta: float) -> void: if processing_command: console.process(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console_cancel") and not event.is_echo(): console.force_stop_pipe()



func directory_focus_changed(new_path:String) -> void: path_label.text = new_path

#func setup_settings():
	#var settings : Settings = Settings.initialize_settings("console")
	#settings.prepare_setting("background", ["boolean"], func(b): background.visible = b, [true], [{}] )
	#settings.finish_prepare_settings()
	#
	#await settings.instance_ui(vbox)

func clear_console_history():
	var undo:Callable = (func(x,y): code.text = x; console.line_count = y).bind(code.text, console.line_count)
	var redo:Callable = (func(): code.text = ""; console.line_count = 0)
	App.record_action(GenericAppAction.new(undo, redo))
	console.clear_console_history()

func display_greeting():
	console.greeting = true
	display_sentient_message("welcome, user.")
	console.print_out("omni")
	console.print_out("[ gammasynth ]")
	console.print_out(" ")
	line.grab_click_focus()



func standby():display_sentient_message()

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
	path_label.text = console.current_directory_path


func toggle_menu_bar_mode(toggle:bool=console.menu_bar_mode) -> void:
	if toggle: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_SHINY
	else: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED
	
	spacer_2.visible = toggle
	sep.visible = toggle
	spacer_3.visible = toggle
	menu.visible = toggle
	sep_2.visible = toggle
	spacer_4.visible = toggle
	
	App.ui.refresh_window()

func toggle_command_history(toggle:bool=console.command_history_mode, can_undo:bool=true) -> void:
	if can_undo:
		var undo:Callable = toggle_command_history.bind(not toggle, false)
		var redo:Callable = toggle_command_history.bind(toggle, false)
		App.record_action(GenericAppAction.new(undo, redo))
	if toggle: 
		console_history_toggler.icon = U_SHINY
	else: console_history_toggler.icon = U_DARKER
	
	code.visible = toggle
	#spacer.visible = toggle
	
	App.ui.refresh_window()

func toggle_file_browser(toggle:bool=console.file_browser_mode) -> void:
	if toggle: file_browser_toggler.icon = FILE_BROWSER_BUTTON_BRIGHT
	else: file_browser_toggler.icon = FILE_BROWSER_BUTTON_DARK
	
	Main.toggle_file_browser(toggle)
	
	App.ui.refresh_window()

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

func _on_file_index_pressed(index: int) -> void:
	match index:
		0: console.parse_text_line("file")
		1: console.parse_text_line("folder")
		2: Main.file_browser.open()
		3: OS.create_instance([])

func _on_edit_index_pressed(index: int) -> void:
	match index:
		0: App.undo()
		1: App.redo()
		2: Main.file_browser.copy()
		3: Main.file_browser.cut()
		4: Main.file_browser.paste()
		5: Main.file_browser.delete()

func pop_settings(by_name:String) -> void: 
	var settings: Settings = Settings.all_settings.get(by_name); settings.instance_ui_window(App.instance)

func _on_settings_index_pressed(index: int) -> void:
	if index == 0: pop_settings("theme")


func _on_file_about_to_popup() -> void:
	file.set_item_disabled(2, not Main.file_browser.has_selected_files())


func _on_edit_about_to_popup() -> void:
	edit.set_item_disabled(0, App.undo_disabled())
	edit.set_item_disabled(1, App.redo_disabled())
	edit.set_item_disabled(2, not Main.file_browser.has_selected_files())
	edit.set_item_disabled(3, not Main.file_browser.has_selected_files())
	edit.set_item_disabled(4, not Main.file_browser.has_copied_files())
	edit.set_item_disabled(5, not Main.file_browser.has_selected_files())


func _on_settings_about_to_popup() -> void:
	pass # Replace with function body.
