extends Core

class_name App


func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	get_window().wrap_controls = true
	
	
