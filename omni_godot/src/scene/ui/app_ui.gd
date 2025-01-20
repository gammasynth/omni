extends MarginContainer

class_name AppUI

@onready var v_split = $v_split
@onready var h_split = $h_split


var console: Console
var file_browser: FileBrowser


func _ready():
	file_browser.parse_directory(console.current_directory_path)


func toggle_file_browser(toggle:bool) -> void:
	file_browser.visible = toggle
