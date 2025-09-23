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
