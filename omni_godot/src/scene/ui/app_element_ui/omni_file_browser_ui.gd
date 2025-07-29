extends DatabaseMarginContainer

class_name FileBrowserUI

var file_browser: OmniFileBrowser:
	get: 
		if not file_browser: 
			file_browser = OmniFileBrowser.new(self)
			db = file_browser
		return db

const FILE_BROWSER_GRID_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_grid_item.tscn")
const FILE_BROWSER_LIST_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_list_item.tscn")

@onready var scroll_box: ScrollContainer = $vbox/h_split/scroll_box
@onready var file_grid: GridContainer = $vbox/h_split/scroll_box/file_grid
@onready var file_list: VBoxContainer = $vbox/h_split/scroll_box/file_list

var favorite_folders: Array[String] = []

func _ready():
	App.ui.file_browser_ui = self
	Main.file_browser = file_browser
	resized.connect(refresh_grid_size)


func add_item(file_path:String, file_type:FileType) -> void:
	var item_base = FILE_BROWSER_GRID_ITEM
	if not file_browser.grid_mode: item_base = FILE_BROWSER_LIST_ITEM
	
	var browser = file_grid
	if not file_browser.grid_mode: browser = file_list
	
	var item = item_base.instantiate()
	item.file_path = file_path
	item.file_type = file_type
	await Make.child(item, browser)
	return


func clear_ui_items() -> void:
	for child in file_grid.get_children():
		child.queue_free()
	for child in file_list.get_children():
		child.queue_free()


func refresh_grid_size() -> void:
	file_grid.columns = floor(size.x / (64.0 + 25.0))


func _on_grid_mode_toggler_button_down() -> void:
	file_browser.grid_mode = !file_browser.grid_mode
	
	if file_browser.grid_mode:
		file_list.visible = false
		file_grid.visible = true
	else:
		file_list.visible = true
		file_grid.visible = false
	
	Main.open_directory()


func _on_button_up() -> void:
	pass # Replace with function body.
