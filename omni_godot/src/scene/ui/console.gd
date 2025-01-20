extends DatabasePanelContainer

class_name Console

@onready var vbox: VBoxContainer = $vbox

@onready var code: CodeEdit = $vbox/code

@onready var spacer: Control = $vbox/spacer

@onready var line: LineEdit = $vbox/line

@onready var spacer_2: Control = $vbox/spacer2
@onready var sep: HSeparator = $vbox/sep
@onready var spacer_3: Control = $vbox/spacer3

@onready var menu: MenuBar = $vbox/menu

@onready var sep_2: HSeparator = $vbox/sep2
@onready var spacer_4: Control = $vbox/spacer4

@onready var hbox: HBoxContainer = $vbox/hbox

@onready var console_menu_toggler: Button = $vbox/hbox/console_menu_toggler
@onready var console_history_toggler: Button = $vbox/hbox/console_history_toggler

@onready var sep_01: VSeparator = $vbox/hbox/sep

@onready var path_panel_container: PanelContainer = $vbox/hbox/path_panel_container
@onready var path_label: RichTextLabel = $vbox/hbox/path_panel_container/path_label

@onready var spacer_01: Control = $vbox/hbox/spacer
@onready var sep_02: VSeparator = $vbox/hbox/sep2

@onready var console_label: RichTextLabel = $vbox/hbox/console_label
@onready var omni_button: Button = $vbox/hbox/omni_button


const TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED = preload("res://src/assets/texture/ui/console/trap_outline_symbol_filled_flipped.png")
const TRAP_OUTLINE_SYMBOL_SHINY = preload("res://src/assets/texture/ui/console/trap_outline_symbol_shiny.png")

const U_DARKER = preload("res://src/assets/texture/ui/console/u_darker.png")
const U_SHINY = preload("res://src/assets/texture/ui/console/u_shiny.png")

var menu_bar_mode: bool = false
var command_history_mode: bool = false

var animating_line_icon: bool = false

var greeting: bool = false

var sentient_line: bool = false:
	set(b):
		sentient_line = b
		if not b:
			greeting = false
			# etc...


var current_directory_path: String = "C:/"


func _ready_up():
	menu_bar_mode = false
	toggle_menu_bar_mode()
	
	command_history_mode = false
	toggle_command_history()
	
	refresh_console_label()
	play_line_icon_anim()
	
	display_greeting()
	
	#current_directory_path = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)
	print("E")
	print(FileManager.get_all_directories_from_directory(current_directory_path))
	
	get_window().files_dropped.connect(func(f): print(f))
	App.instance.ui.console = self
	
	


func display_greeting():
	greeting = true
	display_sentient_message("welcome, user.")


func standby():
	display_sentient_message()

func display_sentient_message(text:String=""):
	if not text.is_empty(): sentient_line = true
	else: sentient_line = false
	
	line.placeholder_text = text


func refresh_console_label() -> void:
	var info: String = "[pulse freq=0.75 color=#00abab80 ease=-1.5][url=https://gammasynth.itch.io/omni]Amn1[/url][/pulse]__v._"
	var version : String = ProjectSettings.get_setting("application/config/version")
	console_label.text = str(info + version)
	


func toggle_menu_bar_mode(toggle:bool=menu_bar_mode) -> void:
	if toggle: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_SHINY
	else: console_menu_toggler.icon = TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED
	
	spacer_2.visible = toggle
	sep.visible = toggle
	spacer_3.visible = toggle
	menu.visible = toggle
	sep_2.visible = toggle
	spacer_4.visible = toggle
	
	App.refresh_window()

func toggle_command_history(toggle:bool=command_history_mode) -> void:
	if toggle: console_history_toggler.icon = U_SHINY
	else: console_history_toggler.icon = U_DARKER
	
	code.visible = toggle
	spacer.visible = toggle
	
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
	menu_bar_mode = !menu_bar_mode
	toggle_menu_bar_mode()




func _on_console_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_console_label_meta_hover_started(meta: Variant) -> void:
	pass # Replace with function body.

func _on_console_label_meta_hover_ended(meta: Variant) -> void:
	pass # Replace with function body.


func _on_console_history_toggler_button_down() -> void:
	console_history_toggler.release_focus()
	command_history_mode = !command_history_mode
	toggle_command_history()



func _on_line_text_submitted(new_text: String) -> void:
	
	
	chat("text entered: " + new_text)
	line.clear()
	
	play_line_icon_anim()


func _on_line_mouse_entered() -> void:
	standby()


func _on_line_mouse_exited() -> void:
	if line.text.is_empty():
		display_sentient_message("omni | Enter a command...")
	standby()
