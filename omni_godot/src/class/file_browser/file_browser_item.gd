extends DatabaseMarginContainer

class_name FileBrowserItem

@export var icon_rect:TextureRect
@export var image_icon_rect:TextureRect
@export var label:RichTextLabel
@export var selected_panel:Panel

var file_browser:OmniFileBrowser

var file_item:FileItem = null

var item_right_click_menu

var being_clicked: bool = false
var click_delta: float = 0.0
var check_double_click: bool = false
var double_click_initial_release_time: float = 0.25
var double_click_second_press_time: float = 0.25

var right_click_context:Dictionary = {}
var right_click_menu:ContextMenu = null

func _ready(): setup()

func setup():
	add_to_group("browser_item")
	
	if file_item.file_type: icon_rect.texture = file_item.file_type.file_browser_item_icon
	
	var file_name = file_item.file_path.get_file(); if not file_name: file_name = File.get_folder(file_item.file_path)
	label.text = file_name
	
	gui_input.connect(gui_event)
	setup_context_menu()

func setup_context_menu() -> void:
	right_click_context.clear()
	right_click_context = {}
	
	#right_click_context.set("undo", App.undo)
	#right_click_context.set("redo", App.redo)
	right_click_context.set("open", file_browser.open_item.bind(file_item))
	right_click_context.set("copy", file_browser.copy_item.bind(file_item))
	right_click_context.set("cut", file_browser.cut_item.bind(file_item))
	if file_item.file_type.is_folder: right_click_context.set("paste", file_browser.paste.bind(file_item.file_path))
	right_click_context.set("toggle_favorite", file_browser.toggle_favorite.bind(file_item.file_path))
	right_click_context.set("delete", file_browser.delete_item.bind(file_item))
	
	right_click_menu = ContextMenu.setup(self, right_click_context, ContextMenu.MENU_TYPES.RIGHT_CLICK)
	right_click_menu.spawned_menu.connect(Main.main.new_window_needs_theme)

func enter_cut_state() -> void: modulate = Color(0.5,0.5,0.5,0.5)
func exit_cut_state() -> void: modulate = Color(1.0,1.0,1.0,1.0)

func deselect() -> void: selected_panel.visible = false
func select() -> void: selected_panel.visible = true

func _process(delta: float) -> void: if being_clicked or check_double_click: click_delta += delta



func gui_event(event:InputEvent) -> void: _gui_event(event)
func _gui_event(event:InputEvent) -> void:
	var mouse_global_pos: Vector2 = get_global_mouse_position()
	
	if not being_clicked and event.is_action_pressed("lmb") and not event.is_echo(): 
		being_clicked = true
		if file_item.is_selected: file_browser.deselect_item(file_item)
		else: file_browser.select_item(file_item)
	
	if being_clicked and event.is_action_released("lmb") and not event.is_echo():
			being_clicked = false
			
			if check_double_click:
				if click_delta <= double_click_second_press_time:
					if not file_browser.multi_select and file_item.file_type.is_folder: file_browser.open_directory(file_item.file_path)
					check_double_click = false
			elif click_delta <= double_click_initial_release_time: check_double_click = true
			
			click_delta = 0.0
