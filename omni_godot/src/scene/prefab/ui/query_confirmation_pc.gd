extends PanelContainer
class_name QueryConfirmationPC

var prompt:String
var desc:String
var confirm:Callable
var deny:Callable

@onready var query_prompt_label: RichTextLabel = $margin/vbox/prompt_pc/margin/query_prompt_label
@onready var query_desc_label: RichTextLabel = $margin/vbox/query_desc_label
@onready var cancel_button: Button = $margin/vbox/hbox/cancel_button
@onready var confirm_button: Button = $margin/vbox/hbox/confirm_button

func setup(_prompt:String, _desc:String, _confirm:Callable, _deny:Callable, _show:bool=true) -> void:
	prompt = _prompt
	desc = _desc
	confirm = _confirm
	deny = _deny
	
	query_prompt_label.text = prompt
	query_desc_label.text = _desc
	
	if _show: visible = true

func _on_cancel_button_button_down() -> void: 
	deny.call()
	visible = false

func _on_confirm_button_button_down() -> void: 
	confirm.call()
	visible = false
