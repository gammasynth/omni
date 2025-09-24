extends DatabaseMarginContainer

class_name FileBrowserItem

@export var icon_rect:TextureRect
@export var image_icon_rect:TextureRect
@export var label:RichTextLabel
@export var selected_panel:Panel
@export var hover_panel:Panel
@export var outline_panel:Panel

var file_browser:OmniFileBrowser

var file_item:FileItem = null

var item_right_click_menu
var right_click_able:bool=true
var right_click_context:Dictionary = {}
var right_click_menu:ContextMenu = null

var being_dragged: bool = false
var being_clicked: bool = false
var click_delta: float = 0.0
var check_double_click: bool = false
var double_click_initial_release_time: float = 0.25
var double_click_second_press_time: float = 0.25

var selectable:bool = true
var draggable:bool = true

var size_tweener:Tween

func _ready(): setup()

func setup():
	add_to_group("browser_item")
	
	if file_item.file_type: icon_rect.texture = file_item.file_type.file_browser_item_icon
	
	var file_name = file_item.file_path.get_file(); if not file_name: file_name = File.get_folder(file_item.file_path)
	label.text = file_name
	
	gui_input.connect(gui_event)
	mouse_entered.connect(mouse_entered_rect)
	mouse_exited.connect(mouse_left_rect)
	if right_click_able: setup_context_menu()

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

func deselect() -> void: selected_panel.visible = false#; print("DESELECT")
func select() -> void: selected_panel.visible = true

func _process(delta: float) -> void: if being_clicked or check_double_click: click_delta += delta

func tween_hover_size(up:bool=true) -> void:
	if size_tweener is Tween and is_instance_valid(size_tweener):
		if size_tweener.is_running(): size_tweener.pause()
		size_tweener.kill()
		size_tweener = null
	
	var icon_mod: float = 1.0
	var image_icon_mod: float = 1.0
	if file_browser.grid_mode:
		icon_mod = 4.0
		image_icon_mod = 2.0
	
	var new_icon_size:Vector2 = Vector2.ONE
	var new_image_icon_size:Vector2 = Vector2.ONE
	
	if up:
		if MainUI.ui.dragging_browser_items: 
			if file_item.file_type.is_folder:
				new_icon_size = Vector2(24.0, 24.0) * icon_mod
				new_image_icon_size = Vector2(24.0, 24.0) * image_icon_mod
			else:
				new_icon_size = Vector2(8.0, 8.0) * icon_mod
				new_image_icon_size = Vector2(8.0, 8.0) * image_icon_mod
		else:
			new_icon_size = Vector2(24.0, 24.0) * icon_mod
			new_image_icon_size = Vector2(24.0, 24.0) * image_icon_mod
	else:
		new_icon_size = Vector2(16.0, 16.0) * icon_mod
		new_image_icon_size = Vector2(16.0, 16.0) * image_icon_mod
	
	size_tweener = create_tween()
	size_tweener.set_parallel()
	size_tweener.tween_property(icon_rect, "custom_minimum_size", new_icon_size, 0.25)
	size_tweener.tween_property(image_icon_rect, "custom_minimum_size", new_image_icon_size, 0.25)

func mouse_entered_rect() -> void: 
	if being_dragged: return
	file_browser.file_browser_ui.hovered_browser_item = self
	if MainUI.ui.dragging_browser_items and file_item.file_type.is_folder:
		hover_panel.visible = true
	tween_hover_size()
	return
func mouse_left_rect() -> void: 
	if being_dragged: return
	check_double_click = false
	if draggable and selectable and being_clicked:
		# try to drag the file
		being_clicked = false
		if not file_item.is_selected: file_browser.select_item(file_item)
		MainUI.ui.start_item_drag(file_browser.file_browser_ui.selected_browser_items)
	tween_hover_size(false)
	hover_panel.visible = false
	if file_browser.file_browser_ui.hovered_browser_item == self:
		file_browser.file_browser_ui.hovered_browser_item = null

func gui_event(event:InputEvent) -> void: _gui_event(event)
func _gui_event(event:InputEvent) -> void:
	var mouse_global_pos: Vector2 = get_global_mouse_position()
	
	if MainUI.ui.dragging_browser_items:
		check_double_click = false
		if event.is_action_released("lmb") and not event.is_echo():
			if file_item.file_type.is_folder:
				print("released at : " + file_item.file_path)
				MainUI.ui.end_item_drag(file_item.file_path)
			else:
				print("browser released at : " + file_browser.current_directory_path)
				MainUI.ui.end_item_drag(file_browser.current_directory_path)
	else:
		
		if being_clicked and event.is_action_released("lmb") and not event.is_echo():
			being_clicked = false
			
			if check_double_click and  click_delta > double_click_second_press_time: check_double_click = false
			if not check_double_click: file_browser.select_item(file_item)
			
			if check_double_click:
				if click_delta <= double_click_second_press_time:
					if not file_browser.multi_select: # TODO more versatile opening
						if file_item.file_type.is_folder: file_browser.open_directory(file_item.file_path)
						else: file_browser.open()
					check_double_click = false
			elif click_delta <= double_click_initial_release_time: check_double_click = true
			else: check_double_click = false
			
			click_delta = 0.0
		
		if not being_clicked and event.is_action_pressed("lmb") and not event.is_echo(): being_clicked = true
