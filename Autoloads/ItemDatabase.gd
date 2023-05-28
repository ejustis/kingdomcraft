extends Node

var items : Array[ItemData] = []

func _ready() -> void:
	var directory = DirAccess.open("res://Inventory/Items")
	directory.list_dir_begin()
	
	var file_name = directory.get_next()
	while (file_name):
		if not directory.current_is_dir():
			items.append(load(file_name))
