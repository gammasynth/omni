extends Core

class_name App

const APP_UI = preload("res://src/scene/ui/app_ui.tscn")

var ui: AppUI

func _start() -> Error:
	get_tree().get_root().set_transparent_background(true)
	get_window().wrap_controls = true
	
	ui = APP_UI.instantiate()
	get_parent().add_child(ui)
	return OK
