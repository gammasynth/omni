#|*******************************************************************
# favorites_pc.gd
#*******************************************************************
# This file is part of omni. 
# https://github.com/gammasynth/omni
# 
# omni is an open-source software.
# omni is licensed under the MIT license.
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************
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
