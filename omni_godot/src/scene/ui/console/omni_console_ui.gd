extends DatabasePanelContainer
class_name ConsoleUI

var console: OmniConsole:
	get: 
		if not console:
			console = OmniConsole.new(name)
			db = console
			console.uses_threads = false
			console.uses_piped = true
			console.uses_process = true
			console.refresh_during_process = false
		return db

var app_theme:AppTheme:
	get: return Main.current_app_theme

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

#@onready var spacer_01: Control = $vbox/hbox/spacer
@onready var sep_02: VSeparator = $vbox/hbox/sep2

@onready var console_label: RichTextLabel = $vbox/hbox/console_label
@onready var omni_button: Button = $vbox/hbox/omni_button

@onready var background: Control = $vbox/code_split/background
@onready var worker_menu_toggler: Button = $vbox/hbox/worker_menu_toggler

var processing_command:bool = false
var line_edited :bool = false


func _ready_up():
	get_window().mouse_entered.connect(line.grab_click_focus)
	get_window().files_dropped.connect(func(f): print(f))# TODO add drop files
	
	App.ui.console_ui = self
	Main.console = console
	
	console.rich_label = code
	console.line_edit = line
	
	console.operation_started.connect(started_command_operation)
	console.operation_finished.connect(finished_command_operation)
	
	console.directory_focus_changed.connect(directory_focus_changed)
	
	console.process_started.connect(thread_process_started)
	
	toggle_menu_bar_mode(false)
	toggle_command_history(true)
	toggle_file_browser(false)
	
	display_greeting()
	#current_directory_path = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)
	#$HTTPRequest.request("https://github.com")
	finished_command_operation()

#func setup_settings():
	#var settings : Settings = Settings.initialize_settings("console")
	#settings.prepare_setting("background", ["boolean"], func(b): background.visible = b, [true], [{}] )
	#settings.finish_prepare_settings()
	#
	#await settings.instance_ui(vbox)

func directory_focus_changed(new_path:String) -> void: path_label.text = new_path
func thread_process_started() -> void: processing_command = true
func started_command_operation() -> void: pass#line.editable = false
func finished_command_operation(do_first_space:bool=false, do_after_space:bool=true) -> void:
	refresh()
	if not console.console_processing:
		processing_command = false
		if do_first_space: console.print_out(" ")
		console.print_out(console.current_directory_path)
		if do_after_space: console.print_out(" ")

func file_browser_directory_changed(_new_current_path:String="") -> void:
	console.open_directory(Main.file_browser.current_directory_path, true, false)
	finished_command_operation(false, false)


func _process(delta: float) -> void: console.console_process(delta); if processing_command: console.process(delta)
func _input(event: InputEvent) -> void:
	if not line_edited and event.is_action_pressed("console_cancel") and not event.is_echo(): 
		if console.is_piping: console.force_stop_pipe()

#region Display Control
func clear_console_history():
	var undo:Callable = (func(x,y): code.text = x; console.line_count = y).bind(code.text, console.line_count)
	var redo:Callable = (func(): code.text = ""; console.line_count = 0)
	App.record_action(GenericAppAction.new(undo, redo))
	console.clear_console_history()

func display_greeting():
	console.greeting = true
	display_placeholder_message("welcome, user.")
	console.print_out(["omni", "[ gammasynth ]", " "])
	refresh()

func standby(): display_placeholder_message()
func display_placeholder_message(text:String=""):
	if not text.is_empty() and console.using_placeholder: return
	if not line.text.is_empty(): line.placeholder_text = ""; console.using_placeholder = false; return
	if not text.is_empty(): console.using_placeholder = true
	else: console.using_placeholder = false
	line.placeholder_text = text

func refresh_console_label() -> void:
	var info: String = "[pulse freq=0.75 color=#00abab80 ease=-1.5][url=https://gammasynth.itch.io/omni]Amn1[/url][/pulse]_"
	var version : String = ProjectSettings.get_setting("application/config/version")
	console_label.text = str(info + version)
	path_label.text = console.current_directory_path

func play_line_icon_anim():
	var stop_anim = func(): line.right_icon.current_frame = 14; line.right_icon.pause = true
	var start_anim = func(): line.right_icon.current_frame = 0; line.right_icon.pause = false
	stop_anim.call(); start_anim.call(); get_tree().create_timer(0.5).timeout.connect(stop_anim)

func refresh() -> void:
	App.ui.refresh_window()
	refresh_console_label()
	line.grab_focus.call_deferred()
	play_line_icon_anim()
#endregion

#region Toggle UI Sections
func toggle_menu_bar_mode(toggle:bool = not console.menu_bar_mode) -> void:
	console.menu_bar_mode = toggle
	toggle_section(
		toggle, 
		console_menu_toggler, 
		[spacer_2, sep, spacer_3, menu, sep_2, spacer_4], 
		app_theme.main_menu_icon_on, 
		app_theme.main_menu_icon_off
		)

func toggle_worker_menu(toggle:bool = not MainUI.ui.omni_worker_ui.visible) -> void:
	MainUI.ui.toggle_omni_worker()
	toggle_section(toggle, worker_menu_toggler, [], app_theme.worker_menu_icon_on, app_theme.worker_menu_icon_off)

func toggle_command_history(toggle:bool = not console.command_history_mode) -> void:
	console.command_history_mode = !console.command_history_mode
	toggle_section(
		toggle, 
		console_history_toggler, 
		[code], 
		app_theme.console_output_icon_on, 
		app_theme.console_output_icon_off
		)

func toggle_file_browser(toggle:bool = not console.file_browser_mode) -> void:
	console.file_browser_mode = toggle
	MainUI.ui.toggle_file_browser(toggle)
	toggle_section(
		toggle, 
		file_browser_toggler, 
		[], 
		app_theme.file_browser_icon_on, 
		app_theme.file_browser_icon_off
		)

func toggle_db_console(toggle:bool = not MainUI.ui.view_boot_box) -> void:
	MainUI.ui.toggle_boot_vbox()
	toggle_section(
		toggle, 
		omni_button, 
		[], 
		app_theme.db_console_output_icon_on, 
		app_theme.db_console_output_icon_off
		)

func toggle_section(
	toggle:bool, 
	button:Button, 
	controls:Array[Control], 
	icon_on:Texture2D=null, 
	icon_off:Texture2D=null
	) -> void:
	if toggle and icon_on: button.icon = icon_on
	if not toggle and icon_off: button.icon = icon_off
	
	for control:Control in controls: control.visible = toggle
	
	button.release_focus()
	refresh()
#endregion

#region UI Interaction
func _on_console_label_meta_hover_started(_meta: Variant) -> void: pass # Replace with function body.
func _on_console_label_meta_hover_ended(_meta: Variant) -> void: pass # Replace with function body.
func _on_console_label_meta_clicked(meta: Variant) -> void: OS.shell_open(str(meta))

func _on_line_mouse_entered() -> void: standby()
func _on_line_mouse_exited() -> void: display_placeholder_message("omni")
func _on_line_editing_toggled(toggled_on: bool) -> void: line_edited = toggled_on
func _on_line_text_submitted(new_text: String) -> void:
	line.clear()
	play_line_icon_anim()
	console.parse_text_line(new_text)

func _on_console_menu_toggler_button_down() -> void: toggle_menu_bar_mode()
func _on_worker_menu_toggler_button_down() -> void: toggle_worker_menu()
func _on_console_history_toggler_button_down() -> void: toggle_command_history()
func _on_file_browser_toggler_button_down() -> void: toggle_file_browser()
func _on_omni_button_button_down() -> void: toggle_db_console()
#endregion

#region MenuBar
func _on_file_about_to_popup() -> void: file.set_item_disabled(2, not Main.file_browser.has_selected_files())
func _on_file_index_pressed(index: int) -> void:
	match index:
		0: console.parse_text_line(str("file " + MainUI.console_ui.line.text))
		1: console.parse_text_line(str("folder " + MainUI.console_ui.line.text))
		2: Main.file_browser.open()
		3: OS.create_instance([])

func _on_edit_about_to_popup() -> void:
	edit.set_item_disabled(0, App.undo_disabled())
	edit.set_item_disabled(1, App.redo_disabled())
	edit.set_item_disabled(2, not Main.file_browser.has_selected_files())
	edit.set_item_disabled(3, not Main.file_browser.has_selected_files())
	edit.set_item_disabled(4, not Main.file_browser.has_copied_files())
	edit.set_item_disabled(5, not Main.file_browser.has_selected_files())
func _on_edit_index_pressed(index: int) -> void:
	match index:
		0: App.undo()
		1: App.redo()
		2: Main.file_browser.copy()
		3: Main.file_browser.cut()
		4: Main.file_browser.paste()
		5: Main.file_browser.delete()

func _on_settings_about_to_popup() -> void: pass # Replace with function body.
func _on_settings_index_pressed(index: int) -> void: if index == 0: pop_settings("theme")

func pop_settings(by_name:String) -> void: 
	var settings:Settings = Settings.all_settings.get(by_name); settings.instance_ui_window(App.instance)
#endregion

func _on_http_request_request_completed(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray
	) -> void:
	#print(result)
	#print(response_code)
	#print(headers)
	#print(body)
	pass
