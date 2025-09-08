extends DatabaseMarginContainer

class_name FileBrowserUI

signal favorites_window_toggled
signal grid_mode_ui_changed

var file_browser: OmniFileBrowser:
	get: 
		if not file_browser: 
			file_browser = OmniFileBrowser.new(self)
			db = file_browser
		return db

const OMNI_RETRO_ARROW_SYMBOL = preload("res://resource/texture/ui/omni_retro_arrow_symbol.png")
const OMNI_RETRO_ARROW_SYMBOL_DARK = preload("res://resource/texture/ui/omni_retro_arrow_symbol_dark.png")

const FILE_BROWSER_GRID_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_grid_item.tscn")
const FILE_BROWSER_LIST_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_list_item.tscn")

@onready var favorites_button: Button = $vbox/file_browser_toolbar/toolbar_hbox/favorites_button
@onready var d_back_button: Button = $vbox/file_browser_toolbar/toolbar_hbox/d_back_button
@onready var d_up_button: Button = $vbox/file_browser_toolbar/toolbar_hbox/d_up_button
@onready var d_forward_button: Button = $vbox/file_browser_toolbar/toolbar_hbox/d_forward_button

@onready var git_info_title: RichTextLabel = $vbox/file_browser_toolbar/toolbar_hbox/git_info_title
@onready var folder_title: RichTextLabel = $vbox/file_browser_toolbar/toolbar_hbox/folder_title

@onready var grid_mode_toggler: Button = $vbox/file_browser_toolbar/toolbar_hbox/grid_mode_toggler

@onready var file_grid: GridContainer = $vbox/h_split/list_pc/scroll_box/file_grid
@onready var file_list: VBoxContainer = $vbox/h_split/list_pc/scroll_box/file_list

@onready var favorites_pc: PanelContainer = $vbox/h_split/favorites_pc

var favorites_window_visible:bool = false:
	set(b):
		favorites_pc.visible = b
		favorites_window_visible = b
		favorites_window_toggled.emit()
		if b: favorites_button.icon = OMNI_RETRO_ARROW_SYMBOL
		else: favorites_button.icon = OMNI_RETRO_ARROW_SYMBOL_DARK

var grid_mode:bool = false:
	set(b):
		grid_mode = b
		grid_mode_ui_changed.emit()

var browser_settings:Settings

func grid_mode_change() -> void:
	file_grid.visible = grid_mode; file_list.visible = not grid_mode
	
	file_browser.grid_mode = grid_mode
	Main.refresh_directory()

func _ready():
	App.ui.file_browser_ui = self
	Main.file_browser = file_browser
	resized.connect(refresh_grid_size)
	grid_mode_ui_changed.connect(grid_mode_change)
	favorites_pc.connect_refresher()

func setup_file_browser_settings() -> void:
	browser_settings = Settings.initialize_settings("app", true, "user://settings/app/browser/")
	browser_settings.prepare_setting("favorite_paths", [], (func(_x): return), [{}], [{}], false)
	
	browser_settings.finish_prepare_settings()
	# BUGFIX for settings turning everything to strings
	var favs:Dictionary = browser_settings.get_setting_value("favorite_paths").get(0)
	var new_favs:Dictionary = {}
	for key in favs.keys():
		new_favs.set(int(key), favs.get(key))
	
	file_browser.favorites = new_favs
	file_browser.favorite_added.connect(update_favorites_setting)
	file_browser.favorite_removed.connect(update_favorites_setting)

func update_favorites_setting() -> void:
	browser_settings.set_setting_value("favorite_paths", [file_browser.favorites])
	browser_settings.save_settings()

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
	for child in file_grid.get_children(): child.queue_free()
	for child in file_list.get_children(): child.queue_free()

func refresh_grid_size() -> void: file_grid.columns = floor(size.x / (64.0 + 25.0))

func _on_grid_mode_toggler_button_down() -> void: grid_mode = not file_browser.grid_mode

func _on_favorites_button_button_down() -> void: favorites_window_visible = not favorites_window_visible

func _on_d_back_button_button_down() -> void: file_browser.go_back_directory()
func _on_d_up_button_button_down() -> void: file_browser.go_up_directory()
func _on_d_forward_button_button_down() -> void: file_browser.go_forward_directory()

func _on_d_back_button_button_up() -> void: pass
func _on_d_up_button_button_up() -> void: pass
func _on_d_forward_button_button_up() -> void: pass
