extends DatabaseMarginContainer

class_name FileBrowserItem

@export var icon_rect:TextureRect
@export var image_icon_rect:TextureRect
@export var label:RichTextLabel
@export var selected_panel:Panel


var item_right_click_menu

var file_path: String = ""
var file_type: FileType = null

var shifting:bool = false
var controlling:bool = false

var being_clicked: bool = false
var click_delta: float = 0.0
var check_double_click: bool = false
var double_click_initial_release_time: float = 0.25
var double_click_second_press_time: float = 0.25

var is_selected:bool = false:
	set(b):
		if selected_panel: selected_panel.visible = b
		is_selected = b

var right_click_context:Dictionary = {}
var right_click_menu:ContextMenu = null

func _ready(): setup()

func setup():
	
	add_to_group("browser_item")
	
	if file_type: icon_rect.texture = file_type.file_browser_item_icon
	
	var file_name = file_path.get_file(); if not file_name: file_name = File.get_folder(file_path)
	label.text = file_name
	
	gui_input.connect(gui_event)
	setup_context_menu()

func setup_context_menu() -> void:
	right_click_context.clear()
	right_click_context = {}
	
	right_click_context.set("copy", Main.file_browser.copy_item.bind(self))
	right_click_context.set("cut", Main.file_browser.cut_item.bind(self))
	right_click_context.set("paste", Main.file_browser.paste)
	right_click_context.set("toggle_favorite", Main.file_browser.toggle_favorite.bind(self))
	right_click_context.set("delete", Main.file_browser.delete_item.bind(self))
	
	right_click_menu = ContextMenu.setup(self, right_click_context, ContextMenu.MENU_TYPES.RIGHT_CLICK)

func enter_cut_state() -> void: modulate = Color(0.5,0.5,0.5,0.5)
func exit_cut_state() -> void: modulate = Color(1.0,1.0,1.0,1.0)

func deselect_browser_item() -> void: is_selected = false

func select_browser_item() -> void:
	var additive:bool = false; if shifting or controlling: additive = true
	if not additive: get_tree().call_group("browser_item", "deselect_browser_item")
	await get_tree().process_frame
	is_selected = true

func _process(delta: float) -> void: if being_clicked or check_double_click: click_delta += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("control") and not event.is_echo(): controlling = true
	if event.is_action_released("control") and not event.is_echo(): controlling = false
	
	if event.is_action_pressed("shift") and not event.is_echo(): shifting = true
	if event.is_action_released("shift") and not event.is_echo(): shifting = false

func gui_event(event:InputEvent) -> void: _gui_event(event)
func _gui_event(event:InputEvent) -> void:
	var mouse_global_pos: Vector2 = get_global_mouse_position()
	
	if not being_clicked and event.is_action_pressed("lmb") and not event.is_echo(): 
		being_clicked = true
		if is_selected: 
			if controlling or shifting: deselect_browser_item.call()
			else: select_browser_item.call()
		else: select_browser_item.call()
	
	if being_clicked and event.is_action_released("lmb") and not event.is_echo():
			being_clicked = false
			
			if check_double_click:
				if click_delta <= double_click_second_press_time:
					if not shifting and not controlling and file_type.is_folder: Main.open_directory(file_path)
					check_double_click = false
			elif click_delta <= double_click_initial_release_time: check_double_click = true
			
			click_delta = 0.0
	
	
	
	#if event.is_action_pressed("rmb"):
			##print("RIGHT mouse click item A")
			#item_right_click_menu.popup(Rect2i(Vector2i(mouse_global_pos), Vector2i.ZERO))
