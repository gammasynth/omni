extends PanelContainer
class_name FavoritesPC

const FILE_BROWSER_LIST_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_list_item.tscn")

@onready var scroll_box: ScrollContainer = $scroll_box
@onready var vbox: VBoxContainer = $scroll_box/vbox

func connect_refresher() -> void:
	Main.file_browser.favorite_added.connect(refresh)
	Main.file_browser.favorite_removed.connect(refresh)
	Main.file_browser.file_browser_ui.favorites_window_toggled.connect(refresh)

func refresh() -> void:
	Make.clear_children(vbox)
	for id:int in Main.file_browser.favorites:
		var favorite:String = Main.file_browser.favorites.get(id)
		var ft := FileType.get_file_type_from_path(favorite)
		if ft: add_item(favorite, ft)

func add_item(file_path:String, file_type:FileType) -> void:
	var item_base = FILE_BROWSER_LIST_ITEM
	
	var item = item_base.instantiate()
	item.file_path = file_path
	item.file_type = file_type
	await Make.child(item, vbox)
	return
