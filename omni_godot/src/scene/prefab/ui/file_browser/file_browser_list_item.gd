extends DatabaseMarginContainer

class_name FileBrowserListItem

@onready var hbox: HBoxContainer = $hbox
@onready var aspect_ratio_container: AspectRatioContainer = $hbox/AspectRatioContainer

@onready var icon_rect: TextureRect = $hbox/AspectRatioContainer/icon_rect
@onready var icon_margin: MarginContainer = $hbox/AspectRatioContainer/icon_margin
@onready var image_icon_rect: TextureRect = $hbox/AspectRatioContainer/icon_margin/image_icon_rect

@onready var label: RichTextLabel = $hbox/label

@onready var item_button: Button = $item_button
@onready var item_right_click_menu: PopupMenu = $item_button/item_right_click_menu


var file_path: String = ""
var file_type: FileType = null

var being_clicked: bool = false
var click_delta: float = 0.0

var single_click_open_time: float = 0.15
var double_click_initial_release_time: float = 0.1
var double_click_second_press_time: float = 0.1


func _ready():
	setup()

func setup():
	
	if file_type: icon_rect.texture = file_type.file_browser_item_icon
	
	var file_name = file_path.get_file()
	if not file_name:
		file_name = File.get_folder(file_path)
	
	label.text = file_name


func _process(delta: float) -> void:
	if being_clicked:
		click_delta += delta


func _on_item_button_gui_input(event: InputEvent) -> void:
	
	var mouse_global_pos: Vector2 = get_global_mouse_position()
	
	if being_clicked:
		if event.is_action_released("lmb"):
			being_clicked = false
			
			if click_delta >= single_click_open_time:
				if file_type.is_folder:
					Main.open_directory(file_path)
			
			click_delta = 0.0
	else:
		if event.is_action_pressed("lmb"):
			print("mouse click item")
			being_clicked = true
	
	if event.is_action_pressed("rmb"):
			#print("RIGHT mouse click item A")
			item_right_click_menu.popup(Rect2i(Vector2i(mouse_global_pos), Vector2i.ZERO))


func _on_item_right_click_menu_index_pressed(_index: int) -> void:
	pass # Replace with function body.
