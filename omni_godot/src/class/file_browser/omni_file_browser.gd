extends FileBrowser

class_name OmniFileBrowser

var file_browser_ui: FileBrowserUI
var grid_mode: bool = true

func _init(_file_browser_ui:FileBrowserUI=null,_name:String="file_browser", _key:Variant=_name) -> void:
	super(_name, _key)
	file_browser_ui = _file_browser_ui
	
	favorite_added.connect(favorite_was_added)
	favorite_removed.connect(favorite_was_removed)
	
	items_copied.connect(items_were_copied)
	items_cut.connect(items_were_cut)
	
	items_pasted.connect(items_were_pasted)
	items_deleted.connect(items_were_deleted)
	
	FileType.default_file_icon = Registry.pull("file_icons", "data_object.png")

func _directory_change_prevented(at_path:String) -> void: 
	AlertSystem.create_warning("Console Busy!", "Can't change directory during active main console process. Try a runnable command instead to free the Omni.")

func _can_change_directory() -> bool: 
	if Main.console.operating: return false
	if Main.console.console_processing: return false
	return true

func favorite_was_added(file_path:String) -> void: record_favorite_action(file_path, true); AlertSystem.create_alert("Favorite Added: ", file_path)
func favorite_was_removed(file_path:String) -> void: record_favorite_action(file_path, false); AlertSystem.create_alert("Favorite Removed: ", file_path)
func record_favorite_action(file_path:String, b:bool): 
	App.record_action(GenericAppAction.new(toggle_favorite.bind(file_path, not b), toggle_favorite.bind(file_path, b)))

func items_were_copied(such_items:Array[FileItem]) -> void:
	var list:String = ""
	for item:FileItem in such_items:
		list = str(list + item.file_path + " \n")
	AlertSystem.create_alert("Items copied: ", list)

func items_were_cut(such_items:Array[FileItem]) -> void:
	var list:String = ""
	for item:FileItem in such_items:
		list = str(list + item.file_path + " \n")
	AlertSystem.create_alert("Items cut: ", list)

func undo_paste(
	_pasted_to_path:String,
	_copied_from_items: Array[FileItem],
	pasted_items:Array[FileItem], 
	cut_out_items:Array[FileItem], 
	temp_deleted_items:Array[FileItem], 
	cut_out_items_info:Dictionary[FileItem, FileItem]
	) -> void:
	
	for item:FileItem in pasted_items:
		remove_item(item)
	
	for item:FileItem in cut_out_items:
		var temp_item:FileItem = cut_out_items_info.get(item)
		if FileAccess.file_exists(temp_item.file_path):
			DirAccess.copy_absolute(temp_item.file_path, item.file_path)
	focus_directory()

func redo_paste(
	pasted_to_path:String,
	copied_from_items: Array[FileItem],
	pasted_items:Array[FileItem], 
	cut_out_items:Array[FileItem], 
	temp_deleted_items:Array[FileItem], 
	cut_out_items_info:Dictionary[FileItem, FileItem]
	) -> void:
	paste_action(pasted_to_path, copied_from_items, cut_out_items)
	focus_directory()

func items_were_pasted(paste_info:Dictionary[String, Variant]) -> void:
	var pasted_to_path: String = paste_info.get("pasted_to_path")
	var copied_from_items: Array[FileItem] = paste_info.get("copied_from_items")
	var pasted_items: Array[FileItem] = paste_info.get("pasted_items")
	var cut_out_items: Array[FileItem] = paste_info.get("cut_out_items")
	var temp_deleted_items: Array[FileItem] = paste_info.get("temp_deleted_items")
	var cut_out_items_info: Dictionary[FileItem, FileItem] = paste_info.get("cut_out_items_info")
	var list:String = ""
	for item:FileItem in pasted_items:
		list = str(list + item.file_path + " \n")
	AlertSystem.create_alert("Items pasted: ", list)
	App.record_action(
		GenericAppAction.new(
			undo_paste.bind(
				pasted_to_path,
				copied_from_items,
				pasted_items,
				cut_out_items,
				temp_deleted_items,
				cut_out_items_info
				),
			redo_paste.bind(
				pasted_to_path,
				copied_from_items,
				pasted_items,
				cut_out_items,
				temp_deleted_items,
				cut_out_items_info
				)
			)
		)

func undo_delete(deleted_items:Array[FileItem], backup_items:Array[FileItem], backup_info:Dictionary[FileItem, FileItem]) -> void:
	for item:FileItem in deleted_items:
		var backup_item:FileItem = backup_info.get(item)
		if FileAccess.file_exists(backup_item.file_path):
			DirAccess.copy_absolute(backup_item.file_path, item.file_path)
	focus_directory()

func redo_delete(deleted_items:Array[FileItem], backup_items:Array[FileItem], backup_info:Dictionary[FileItem, FileItem]) -> void:
	for item:FileItem in deleted_items:
		if FileAccess.file_exists(item.file_path):
			remove_item(item, false)
	focus_directory()

func items_were_deleted(delete_info:Dictionary[String, Variant]) -> void:
	var deleted_items:Array[FileItem] = delete_info.get("deleted_items")
	var backup_items:Array[FileItem] = delete_info.get("backup_items")
	var backup_info:Dictionary[FileItem, FileItem] = delete_info.get("backup_info")
	var list:String = ""
	for item:FileItem in deleted_items:
		list = str(list + item.file_path + " \n")
	AlertSystem.create_alert("Items deleted: ", list)
	App.record_action(
		GenericAppAction.new(
			undo_delete.bind(deleted_items, backup_items, backup_info),
			redo_delete.bind(deleted_items, backup_items, backup_info)
			)
		)
