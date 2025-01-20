extends MarginContainer

class_name AppUI

@onready var v_split: VSplitContainer = $v_split
@onready var h_split: HSplitContainer = $h_split

var active_split: SplitContainer = v_split:
	set(s):
		active_split = s
		swap_splits_children()


var console: Console
var file_browser: FileBrowser


func _ready():
	file_browser.parse_directory(console.current_directory_path)


func swap_splits() -> void:
	pass


func swap_splits_children() -> void:
	var old_split: SplitContainer = v_split
	if active_split == old_split: old_split = h_split
	
	for child in old_split.get_children():
		old_split.remove_child(child)
		active_split.add_child(child)
