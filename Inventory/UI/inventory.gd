extends PanelContainer

const SLOT = preload("res://Inventory/UI/slot.tscn")

@onready var item_grid = $MarginContainer/ItemGrid

func populate_item_grid(inventory_data : InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		item_grid.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)

func set_inventory_data(inventory_data : InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
