extends Database

class_name OmniFileBrowser

signal favorite_added
signal favorite_removed

var file_browser_ui: FileBrowserUI

var grid_mode: bool = true

var dir_history: Array[String] = []
var dir_future: Array[String] = []

var favorites:Dictionary = {}# order int : path String
var new_favorite_index:int = 0

var selected_items: Array[FileBrowserItem] = []
var copied_items: Array[FileBrowserItem] = []
var cut_items: Array[FileBrowserItem] = []


func _init(_file_browser_ui:FileBrowserUI=null,_name:String="file_browser", _key:Variant=_name) -> void:
	super(_name, _key)
	file_browser_ui = _file_browser_ui

func toggle_favorite(item:FileBrowserItem) -> void:
	var file_path:String = item.file_path
	if not remove_favorite(file_path):
		add_favorite(file_path)

func add_favorite(path:String) -> bool:
	if favorites.values().has(path): return false
	
	favorites.set(new_favorite_index, path)
	new_favorite_index += 1
	favorite_added.emit()
	return true

func remove_favorite(path:String) -> bool:
	if not favorites.values().has(path): return false
	
	var favorite_index:int = favorites.values().find(path)
	favorites.erase(favorite_index)
	new_favorite_index -= 1
	favorite_removed.emit()
	return true

func copy_item(item:FileBrowserItem) -> void: 
	if item == null or not is_instance_valid(item): return
	copied_items.clear()
	if not selected_items.has(item): 
		selected_items.clear()
		selected_items.append(item)
	
	for fbi in selected_items: 
		copied_items.append(fbi)

func cut_item(item:FileBrowserItem) -> void: 
	if item == null or not is_instance_valid(item): return
	copied_items.clear()
	if not selected_items.has(item): 
		selected_items.clear()
		selected_items.append(item)
	
	for fbi in selected_items: 
		copied_items.append(fbi)
		fbi.enter_cut_state()
	cut_items = copied_items.duplicate()

func paste() -> void:
	for item in selected_items:
		item.deselect_browser_item()
	for item in copied_items:
		paste_item(item)
	for item in cut_items:
		item.exit_cut_state()
		delete_item(item)
	selected_items.clear()
	copied_items.clear()
	cut_items.clear()

func paste_item(item:FileBrowserItem) -> void:
	if item == null or not is_instance_valid(item): return
	var current:String = Main.console.current_directory_path
	var old_path:String = item.file_path
	var file_name:String = File.get_file_name_from_file_path(old_path, true)
	var new_path:String = str(current + file_name)
	DirAccess.copy_absolute(old_path, new_path)

func delete_item(item:FileBrowserItem) -> void:
	if item == null or not is_instance_valid(item): return
	var old_path:String = item.file_path
	OS.move_to_trash(old_path)

func go_up_directory() -> void: 
	if not Main.can_change_directory(): return
	
	var current:String = Main.console.current_directory_path
	var next:String = current
	var base:String = File.ends_with_slash(File.ends_with_slash(next, false).get_base_dir()); if not base.is_empty(): next = base
	if next != current and DirAccess.dir_exists_absolute(base): 
		Main.open_directory(base)

func go_back_directory() -> void: travel_timeline(dir_history, dir_future)
func go_forward_directory() -> void: travel_timeline(dir_future, dir_history)

func travel_timeline(a:Array[String], b:Array[String]) -> void:
	if not Main.can_change_directory(): return
	var current:String = Main.console.current_directory_path
	var next:String = current
	var this_size:int = a.size()
	if this_size>0:
		b.append(current)
		next = a.get(this_size-1)
		a.remove_at(this_size-1)
	if next != current: 
		Main.open_directory(next, false)
		refresh_ui()

func parse_directory(new_directory_path:String) -> Error:
	dir_history.append(new_directory_path)
	return refresh_ui()

func refresh_ui() -> Error: return setup_directory_ui(Main.console.current_directory_path)

func setup_directory_ui(new_directory_path:String) -> Error:
	file_browser_ui.clear_ui_items()
	
	var all_paths: Array[String] = []
	
	var folder_paths = DirAccess.get_directories_at(new_directory_path)
	for p in folder_paths: all_paths.append(new_directory_path + File.ends_with_slash(p))
	
	var file_paths = DirAccess.get_files_at(new_directory_path)
	for p in file_paths: all_paths.append(new_directory_path + p)
	
	for p in all_paths:
		var ft := FileType.get_file_type_from_path(p)
		if ft: file_browser_ui.add_item(p, ft)
	
	file_browser_ui.refresh_grid_size()
	return OK
