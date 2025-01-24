extends Core

class_name App

const APP_UI = preload("res://src/scene/ui/app_ui.tscn")

static var ui: AppUI

static var console: Console
static var file_browser: FileBrowser


func _pre_core_start() -> Error:
	
	#get_window().borderless = true
	get_window().min_size = Vector2i(0, 0)
	get_tree().get_root().set_transparent_background(true)
	get_window().set_wrap_controls(true)
	
	get_window().size = Vector2i(250, 0)
	
	refresh_window()
	
	return await Cast.wait()



func _start() -> Error:
	
	
	
	# ---
	
	chat(str("engine args: " + str(OS.get_cmdline_args())))
	chat(str("user args: " + str(OS.get_cmdline_user_args())))
	if debug: print(" ")
	
	print_rich(BBCode.color("omni", BBCode.COLORS.black))
	print("+    +")
	print_rich(BBCode.color(" omni", BBCode.COLORS.cyan))
	print("+    +")
	#print_rich(BBCode.color("omni", BBCode.COLORS.black))
	print(" ")
	
	#chat(str("omni is running on: " + str(OS.get_distribution_name()) + "; " + str(OS.get_model_name())))
	print_rich(BBCode.color(str("omni is running on: " + str(OS.get_distribution_name())), BBCode.COLORS.white))
	print(" ")
	
	# ---
	
	chat(str("model: " + str(OS.get_model_name())))
	chat(str("cpu: " + str(OS.get_processor_name())))
	chat(str("cores: " + str(OS.get_processor_count())))
	if debug: print(" ")
	
	
	chat(str("memory: " + str(OS.get_memory_info())))
	if debug: print(" ")
	
	chat(str("locale: " + str(OS.get_locale())))
	if debug: print(" ")
	
	# ---
	
	chat(str("data dir: " + OS.get_data_dir()))
	chat(str("user data dir: " + OS.get_user_data_dir()))
	chat(str("config dir: " + str(OS.get_config_dir())))
	chat(str("cache dir: " + str(OS.get_cache_dir())))
	if debug: print(" ")
	
	# ---
	
	get_window().borderless = false
	
	ui = APP_UI.instantiate()
	get_parent().add_child(ui)
	
	return OK


static func open_directory(at_path:String=console.current_directory_path) -> void:
	console.current_directory_path = at_path
	file_browser.parse_directory(at_path)

static func toggle_file_browser(toggle:bool) -> void:
	if not Core.instance: return
	var app: App = Core.instance as App
	app.ui.toggle_file_browser(toggle)


static func resize(new_size:Vector2i=Vector2i(0, 0)) -> void:
	if not Core.instance: return
	if not instance.get_window(): return
	if new_size == Vector2i(0, 0): return
	instance.get_window().size = new_size
	#print("NEW SIZE: " + str(new_size))
	#print(instance.get_window().size)

static func refresh_window(new_size:Vector2i=Vector2i(0, 0)):
	if not Core.instance: return
	if not instance.get_window(): return
	resize(new_size)
	instance.get_window().child_controls_changed()
	#print(instance.get_window().size)

static func execute(order:String) -> Variant:
	var output: Array = []
	if order.contains(" "):
		order = str("\"" + order + "\"")
	OS.execute(order, [], output, true)
	#print(output)
	return output


static func print_out(text:String) -> void:
	if not Core.instance: return
	if not ui: return
	ui.print_out(text)
