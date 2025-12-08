#|*******************************************************************
# test_node.gd
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
extends Node

func _ready() -> void:
	test_instances()
	#test_nodes()


func test_instances():# 6 ms
	print(Time.get_ticks_msec())
	var tests:Array = []
	for i in 1000:
		var test = RefInstance.new()
		tests.append(test)
	print(Time.get_ticks_msec())

func test_db_instances():# 10 ms # almost twice as much as RefInstance
	print(Time.get_ticks_msec())
	var tests:Array = []
	for i in 1000:
		var test = Database.new()
		tests.append(test)
	print(Time.get_ticks_msec())

func test_db_nodes():# 43 ms
	print(Time.get_ticks_msec())
	for i in 1000:
		var test = DatabaseNode.new()
		add_child(test)
	print(Time.get_ticks_msec())

func test_nodes():# 2 ms
	print(Time.get_ticks_msec())
	for i in 1000:
		var test = Node.new()
		add_child(test)
	print(Time.get_ticks_msec())
