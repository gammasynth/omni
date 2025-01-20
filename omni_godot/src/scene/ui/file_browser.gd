extends MarginContainer

class_name FileBrowser


const FILE_BROWSER_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_item.tscn")

@onready var grid_container: GridContainer = $GridContainer

func _ready():
	App.instance.ui.file_browser = self

func parse_directory(new_directory_path:String) -> Error:
	var all_paths: Array[String] = []
	
	var file_paths = DirAccess.get_files_at(new_directory_path)
	for p in file_paths:
		all_paths.append(new_directory_path + p)
	
	var folder_paths = DirAccess.get_directories_at(new_directory_path)
	for p in folder_paths:
		all_paths.append(new_directory_path + FileManager.ends_with_slash(p))
	
	for p in all_paths:
		
		var ft: FileType = FileType.get_file_type_from_path(p)
		if not ft: continue
		
		var item: FileBrowserItem = FILE_BROWSER_ITEM.instantiate()
		item.file_path = p
		item.file_type = ft
		
		#var file_item_error: Error = item.setup_from_file_path(p)
		#if file_item_error != OK: item.queue_free(); continue
		
		await Cast.make_node_child(item, grid_container)
		
	
	grid_container.columns = size.x / 16.0
	
	return OK
