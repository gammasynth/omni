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

var shifting:bool = false
var controlling:bool = false
var hovered_browser_item: FileBrowserItem

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

var item_uis:Dictionary[FileItem, FileBrowserItem]

var right_click_context:Dictionary = {}
var right_click_menu:ContextMenu = null

var selected_browser_items:Array[FileBrowserItem] = []

func _ready():
	App.ui.file_browser_ui = self
	Main.file_browser = file_browser
	
	resized.connect(refresh_grid_size)
	grid_mode_ui_changed.connect(grid_mode_change)
	favorites_pc.connect_refresher()
	
	file_browser.directory_focused.connect(directory_focused)
	
	file_browser.item_selected.connect(item_selected)
	file_browser.item_deselected.connect(item_deselected)
	
	file_browser.item_entered_cut_state.connect(item_entered_cut_state)
	file_browser.item_exited_cut_state.connect(item_exited_cut_state)
	
	file_browser.favorite_added.connect(update_favorites_setting)
	file_browser.favorite_removed.connect(update_favorites_setting)
	
	setup_context_menu()
	setup_file_browser_settings()


func setup_context_menu() -> void:
	right_click_context.clear()
	right_click_context = {}
	
	right_click_context.set("undo", App.undo)
	right_click_context.set("redo", App.redo)
	
	right_click_context.set("copy", file_browser.copy)
	right_click_context.set("cut", file_browser.cut)
	right_click_context.set("paste", file_browser.paste)
	#right_click_context.set("toggle_favorite", file_browser.toggle_favorite.bind(file_item.file_path))#disable for multi
	right_click_context.set("delete", file_browser.delete)
	
	right_click_menu = ContextMenu.setup(self, right_click_context, ContextMenu.MENU_TYPES.RIGHT_CLICK)
	right_click_menu.spawned_menu.connect(Main.main.new_window_needs_theme)

#region File Browser Settings
func setup_file_browser_settings() -> void:
	browser_settings = Settings.initialize_settings("browser", true, "user://settings/app/browser/")
	browser_settings.prepare_setting("favorite_paths", [], (func(_x): return), [{}], [{}], false)
	
	browser_settings.finish_prepare_settings()
	# BUGFIX for settings turning everything to strings
	var favs:Dictionary = browser_settings.get_setting_value("favorite_paths")
	var new_favs:Dictionary = {}
	for key in favs.keys():
		new_favs.set(int(key), favs.get(key))
	
	file_browser.favorites = new_favs

func update_favorites_setting(_file_path:String) -> void:
	browser_settings.set_setting_value("favorite_paths", [file_browser.favorites])
	browser_settings.save_settings()
#endregion

#region Directory Management
func get_item_ui(item:FileItem) -> FileBrowserItem: 
	if item_uis.has(item): return item_uis.get(item)
	if favorites_pc.item_uis.has(item): return favorites_pc.item_uis.get(item)
	for item_ui_key:FileItem in item_uis:
		var browser_item:FileBrowserItem = item_uis.get(item_ui_key)
		if browser_item.file_item.file_path == item.file_path:
			return browser_item
	for item_ui_key:FileItem in favorites_pc.item_uis:
		var browser_item:FileBrowserItem = favorites_pc.item_uis.get(item_ui_key)
		if browser_item.file_item.file_path == item.file_path:
			return browser_item
	return null

func item_selected(selected_item:FileItem) -> void: 
	var item_ui:FileBrowserItem = get_item_ui(selected_item)
	if not item_ui: return
	item_ui.select()
	selected_browser_items.append(item_ui)

func item_deselected(deselected_item:FileItem) -> void: 
	var item_ui:FileBrowserItem = get_item_ui(deselected_item)
	if not item_ui: return
	item_ui.deselect()
	if selected_browser_items.has(item_ui): selected_browser_items.erase(item_ui)

func item_entered_cut_state(item:FileItem) -> void: 
	var item_ui:FileBrowserItem = get_item_ui(item)
	if not item_ui or not is_instance_valid(item_ui): return
	item_ui.enter_cut_state()
func item_exited_cut_state(item:FileItem) -> void: 
	var item_ui:FileBrowserItem = get_item_ui(item)
	if not item_ui or not is_instance_valid(item_ui): return
	item_ui.exit_cut_state()
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if MainUI.ui.dragging_browser_items and event.is_action_released("lmb") and not event.is_echo():
		if hovered_browser_item and is_instance_valid(hovered_browser_item) and hovered_browser_item.file_item.file_type.is_folder:
			print("folder released at : " + hovered_browser_item.file_item.file_path)
			MainUI.ui.end_item_drag(hovered_browser_item.file_item.file_path)
		else:
			print("browser released at : " + file_browser.current_directory_path)
			MainUI.ui.end_item_drag()
	
	if event.is_action_pressed("control") and not event.is_echo(): controlling = true
	if event.is_action_released("control") and not event.is_echo(): controlling = false
	
	if event.is_action_pressed("shift") and not event.is_echo(): shifting = true
	if event.is_action_released("shift") and not event.is_echo(): shifting = false
	
	if shifting or controlling: file_browser.multi_select = true
	else: file_browser.multi_select = false

#region Directory Render
func add_item(item:FileItem) -> void:
	var item_base = FILE_BROWSER_GRID_ITEM
	if not file_browser.grid_mode: item_base = FILE_BROWSER_LIST_ITEM
	
	var browser = file_grid
	if not file_browser.grid_mode: browser = file_list
	
	var item_ui = item_base.instantiate()
	item_ui.file_item = item
	item_ui.file_browser = file_browser
	item_uis.set(item, item_ui)
	await Make.child(item_ui, browser)
	return

func directory_focused() -> void:
	clear_ui_items()
	
	for item:FileItem in file_browser.directory_items:
		add_item(item)
	refresh_grid_size()
	
	for item:FileItem in file_browser.cut_items:
		item_entered_cut_state(item)
	
	selected_browser_items.clear()
	for item:FileItem in file_browser.selected_items:
		item_selected(item)
	
	var at:String = file_browser.current_directory_path
	at = File.ends_with_slash(at, false)
	at = File.begins_with_slash(at, false)
	at = File.begins_with_slash(at, true)
	if file_browser.has_favorite(file_browser.current_directory_path): at = str(at + "[*]")
	folder_title.text = str("@ " + at)
	# TODO here we can check for git info for git_info_title

func clear_ui_items() -> void:
	item_uis.clear()
	for child in file_grid.get_children(): child.queue_free()
	for child in file_list.get_children(): child.queue_free()

func refresh_grid_size() -> void: file_grid.columns = floor(size.x / (64.0 + 25.0))

func grid_mode_change() -> void:
	file_grid.visible = grid_mode; file_list.visible = not grid_mode
	
	file_browser.grid_mode = grid_mode
	directory_focused()
#endregion


#region UI Button Triggers
func _on_grid_mode_toggler_button_down() -> void: grid_mode = not file_browser.grid_mode

func _on_favorites_button_button_down() -> void: favorites_window_visible = not favorites_window_visible

func _on_d_back_button_button_down() -> void: file_browser.go_back_directory()
func _on_d_up_button_button_down() -> void: file_browser.go_up_directory()
func _on_d_forward_button_button_down() -> void: file_browser.go_forward_directory()

func _on_d_back_button_button_up() -> void: pass
func _on_d_up_button_button_up() -> void: pass
func _on_d_forward_button_button_up() -> void: pass
#endregion


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb") and not event.is_echo(): file_browser.deselect_all_items()
