extends Node

var items : Dictionary

func add_item(item: Node):
	if items.has(item.type)
