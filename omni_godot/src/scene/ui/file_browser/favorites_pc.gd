extends PanelContainer
class_name FavoritesPC

const FILE_BROWSER_LIST_ITEM = preload("res://src/scene/prefab/ui/file_browser/file_browser_list_item.tscn")

@onready var scroll_box: ScrollContainer = $scroll_box
@onready var vbox: VBoxContainer = $scroll_box/vbox

var item_uis:Dictionary[FileItem, FileBrowserItem]

func connect_refresher() -> void:
	Main.file_browser.favorite_added.connect(refresh)
	Main.file_browser.favorite_removed.connect(refresh)
	Main.file_browser.file_browser_ui.favorites_window_toggled.connect(refresh)

func refresh() -> void:
	item_uis.clear()
	Make.clear_children(vbox)
	for id:int in Main.file_browser.favorites:
		var favorite:String = Main.file_browser.favorites.get(id)
		add_item(favorite)

func add_item(file_path:String) -> void:
	var item_base = FILE_BROWSER_LIST_ITEM
	var item = item_base.instantiate()
	var file_item = FileItem.new(file_path)
	item.file_item = file_item
	item.file_browser = Main.file_browser
	item.selectable = false
	item.draggable = false
	item_uis.set(file_item, item)
	await Make.child(item, vbox)
	return
