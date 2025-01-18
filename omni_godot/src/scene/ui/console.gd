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

@onready var sep_01: VSeparator = $vbox/hbox/sep

@onready var path_panel_container: PanelContainer = $vbox/hbox/path_panel_container
@onready var path_label: RichTextLabel = $vbox/hbox/path_panel_container/path_label

@onready var spacer_01: Control = $vbox/hbox/spacer
@onready var sep_02: VSeparator = $vbox/hbox/sep2

@onready var console_label: RichTextLabel = $vbox/hbox/console_label
@onready var omni_button: Button = $vbox/hbox/omni_button


const TRAP_OUTLINE_SYMBOL_FILLED_FLIPPED = preload("res://src/assets/texture/ui/console/trap_outline_symbol_filled_flipped.png")
const TRAP_OUTLINE_SYMBOL_SHINY = preload("res://src/assets/texture/ui/console/trap_outline_symbol_shiny.png")


var menu_bar_mode: bool = false


func _ready_up():
	menu_bar_mode = false
	toggle_menu_bar_mode()
	refresh_console_label()


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

func _on_console_menu_toggler_button_down() -> void:
	menu_bar_mode = !menu_bar_mode
	toggle_menu_bar_mode()




func _on_console_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_console_label_meta_hover_started(meta: Variant) -> void:
	pass # Replace with function body.

func _on_console_label_meta_hover_ended(meta: Variant) -> void:
	pass # Replace with function body.
