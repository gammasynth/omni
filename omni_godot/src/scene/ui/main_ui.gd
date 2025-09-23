extends AppUI

class_name MainUI

const TRAP_ARROW_DOWN_SMOOTH = preload("res://resource/texture/ui/trap_arrow_down_smooth.png")
const TRAP_ARROW_UP_BRIGHT = preload("res://resource/texture/ui/trap_arrow_up_bright.png")

@onready var h_split = $h_split
@onready var v_split = $h_split/v_split

@onready var back_panel: Panel = $back_panel
@onready var custom_back_panel: Panel = $custom_back_panel

@onready var icon: TextureRect = $boot_vbox/icon
@onready var raw_console: RichTextLabel = $boot_vbox/console_pc/console_margin/raw_console
@onready var boot_vbox: VBoxContainer = $boot_vbox

static var console_ui: ConsoleUI
static var file_browser_ui: FileBrowserUI
static var omni_worker_ui: OmniWorkerUI
var main_console_ui: ConsoleUI: 
	get: return console_ui
var main_file_browser_ui: FileBrowserUI:
	get: return file_browser_ui
var main_omni_worker_ui: OmniWorkerUI:
	get: return omni_worker_ui

var user_theme_path:String = "user://settings/theme/user_custom.theme"
var unique_back_panel_stylebox: StyleBox = null
var modified_back_panel: bool = false
var unique_back_panel_color:Color=Color.BLACK

func toggle_omni_worker() -> void: omni_worker_ui.visible = not omni_worker_ui.visible

func get_user_theme() -> Theme:
	var base_theme: Theme = preload("res://lib/gd_app_ui/resource/theme/blank_theme.theme")
	var user_theme: Theme = null
	DirAccess.make_dir_recursive_absolute(user_theme_path.get_base_dir())
	if FileAccess.file_exists(user_theme_path): user_theme = await load(user_theme_path)
	if not user_theme: user_theme = base_theme.duplicate(true)
	return user_theme

func _app_ui_initialized() -> void: pass
	#theme = await get_user_theme()
	#current_theme = Registry.pull("themes", "darkscale_modified.theme")
	#App.instance.theme_name_changed.connect(theme_name_changed)
	#theme_changed.connect(func(): back_panel.remove_theme_stylebox_override("panel"))

func _ready_up():RefInstance.chat_mirror_callable = raw_output

func raw_output(text:String) -> void: raw_console.text = str(raw_console.text + "\n"  + text)

func theme_was_changed(new_theme:Theme) -> void: 
	theme = new_theme
	if theme == null:
		change_window_panel_color(unique_back_panel_color, false)
	else:
		var panel_color:Color=theme.get_stylebox("panel", "Panel").bg_color
		change_window_panel_color(panel_color, false)

func theme_name_changed(theme_name:String) -> void:
	
	if theme_name == "custom":
		#theme = null # TODO MAKE CUSTOM USER THEME
		back_panel.visible = false
		custom_back_panel.visible = true
		modified_back_panel = true
		#if unique_back_panel_stylebox and not custom_back_panel.has_theme_stylebox_override("panel"): custom_back_panel.add_theme_stylebox_override("panel", unique_back_panel_stylebox)
		return
	else:
		modified_back_panel = false
		back_panel.visible = true
		custom_back_panel.visible = false
	
	# BUG I DONT KNOW WHAT IS WRONG WITH THIS BELOW
	#var theme_key: String = THEME_KEYS.get(theme_name)
	#var theme_res: Theme = Registry.pull("themes", theme_key)
	
	#current_theme = theme_res
	#if back_panel.has_theme_stylebox_override("panel"): back_panel.remove_theme_stylebox_override("panel")
	
	pass




#const WINDOW_PANEL_COLORS : Dictionary = { "dark" : Color(0.03, 0.03, 0.03, 0.61), "light" : Color(1.0, 1.0, 1.0, 0.78)}
var window_panel_color: Color = Color.WHITE:
	set(c):
		last_window_panel_color = window_panel_color
		window_panel_color = c

var last_window_panel_color: Color = Color.WHITE

var view_boot_box:bool = true
var boot_box_tweener:Tween


func change_window_panel_color(color:Color, enable:bool=true): 
	if enable:
		modified_back_panel = true
		back_panel.visible = false
		custom_back_panel.visible = true
		unique_back_panel_color = color
	
	var stylebox: StyleBoxFlat = null
	
	if custom_back_panel.has_theme_stylebox_override("panel"): stylebox = back_panel.get("theme_override_styles/panel")
	
	if not stylebox and theme: stylebox = theme.get_stylebox("panel", "panel")
	#if not stylebox: 
		#var user_theme = await get_user_theme()
		#stylebox = user_theme.get_stylebox("panel", "panel")
	
	if not stylebox: stylebox = StyleBoxFlat.new()
	
	if not unique_back_panel_stylebox or unique_back_panel_stylebox and unique_back_panel_stylebox != stylebox:
		unique_back_panel_stylebox = stylebox.duplicate()
		stylebox = unique_back_panel_stylebox
	
	chatf("setting color")
	if stylebox: 
		stylebox.draw_center = true
		if not custom_back_panel.has_theme_stylebox_override("panel"):
			custom_back_panel.add_theme_stylebox_override("panel", stylebox)
		if custom_back_panel.has_theme_stylebox_override("panel") and custom_back_panel.get("theme_override_styles/panel") != stylebox: 
			custom_back_panel.remove_theme_stylebox_override("panel")
			custom_back_panel.add_theme_stylebox_override("panel", stylebox)
		
		stylebox.set_bg_color(color)
		#window_panel_color = color
	else:
		warn("PANELCONTAINER STYLEBOX ERROR!")
	
	#Main.theme_name = "custom" # added disable for this color picker if not already in custom theme

func _start():
	console_ui = preload("res://src/scene/ui/console/omni_console_ui.tscn").instantiate()
	file_browser_ui = preload("res://src/scene/ui/file_browser/omni_file_browser_ui.tscn").instantiate()
	omni_worker_ui = preload("res://src/scene/ui/work_pc/work_pc.tscn").instantiate()
	# TODO PERHAPS use registry for being able to pull modded versions of the console/file browser
	#console_ui = Registry.pull("app_elements", "omni_console_ui.tscn").instantiate()
	#file_browser_ui = Registry.pull("app_elements", "omni_file_browser_ui.tscn").instantiate()
	
	Make.fade(icon, 1.5).tween_callback(icon.set_visible.bind(false)).set_delay(1.5)
	
	await Make.child(file_browser_ui, v_split)
	await Make.child(console_ui, v_split)
	file_browser_ui.grid_mode = Main.file_browser.grid_mode
	
	Main.console.directory_focus_changed.connect(Main.file_browser.open_directory.bind(true, true, false))
	Main.console.open_directory()
	Main.file_browser.directory_focus_changed.connect(console_ui.file_browser_directory_changed)
	
	omni_worker_ui.visible = false
	await Make.child(omni_worker_ui, h_split)
	
	toggle_boot_vbox()
	

func toggle_boot_vbox() -> void:
	if boot_box_tweener: boot_box_tweener.kill()
	view_boot_box = not view_boot_box
	if view_boot_box:
		boot_vbox.visible = true
		boot_box_tweener = Make.fade_in(boot_vbox, 1.5, false)
	else: 
		boot_box_tweener = Make.fade(boot_vbox, 1.5, false)
		boot_box_tweener.tween_callback(boot_vbox.set_visible.bind(false)).set_delay(1.5)
	


func toggle_file_browser(toggle:bool) -> void: file_browser_ui.visible = toggle
	#if toggle:
		#console_ui.set_v_size_flags(Control.SIZE_FILL)
	#else:
		#console_ui.set_v_size_flags(Control.SIZE_EXPAND_FILL)


var current_base_dragged_browser_item:FileBrowserItem
var dragged_browser_item:FileBrowserItem
var dragging_browser_item:bool=false
var mouse_control:Control

func end_item_drag() -> void:
	if current_base_dragged_browser_item != null and is_instance_valid(current_base_dragged_browser_item):
		current_base_dragged_browser_item.visible = true
	if dragged_browser_item != null and is_instance_valid(dragged_browser_item):
		dragged_browser_item.queue_free()
		dragged_browser_item = null
	dragging_browser_item = false

func start_item_drag(new_dragged_browser_item:FileBrowserItem) -> void:
	end_item_drag()
	var dragged_item: FileItem = dragged_browser_item.file_item
	new_dragged_browser_item.visible = false
	current_base_dragged_browser_item = new_dragged_browser_item
	dragging_browser_item = true
	dragged_browser_item = new_dragged_browser_item.duplicate()
	dragged_browser_item.file_item = new_dragged_browser_item.file_item
	dragged_browser_item.file_browser = new_dragged_browser_item.file_browser
	dragged_browser_item.right_click_able = false
	dragged_browser_item.being_dragged = true
	
	if not mouse_control: 
		mouse_control = Control.new()
		await Make.child(mouse_control, get_window())
	
	Make.disable_control(dragged_browser_item)
	await Make.child(dragged_browser_item, mouse_control) 

func _process(delta: float) -> void:
	# TODO
	#  this should probably be done somewhere else!
	# if requested_next_scene != null: set_scene(requested_next_scene)
	if mouse_control and is_instance_valid(mouse_control):
		mouse_control.global_position = get_window().get_mouse_position()

func print_out(text:String) -> void: console_ui.print_out(text)
