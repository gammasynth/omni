@tool
extends PanelContainer
class_name WorkerSubMenuPC

var changing_title:bool=false
@export var title_name:String = "":
	set(t):
		title_name = t
		if Engine.is_editor_hint() or changing_title: title_label.text = t
		changing_title = false

@export var title_label:RichTextLabel
@export var minimize_button:Button
@export var body_container:Container
@export var original_body_vbox:VBoxContainer

func _init() -> void: ready.connect(prepare)
func prepare() -> void: if minimize_button: minimize_button.button_down.connect(_minimize_button_down)

func change_title(new_title:String) -> void: changing_title = true; title_name = new_title

func toggle_body(toggle:bool) -> void:
	if toggle: 
		body_container.visible = true
		minimize_button.icon = MainUI.TRAP_ARROW_UP_BRIGHT
	else:
		body_container.visible = false# TODO USE AppTheme ICONS INSTEAD
		minimize_button.icon = MainUI.TRAP_ARROW_DOWN_SMOOTH

func _minimize_button_down() -> void:
	if body_container.visible: toggle_body(false)
	else: toggle_body(true)
