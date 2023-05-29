extends Resource
class_name SlotData

const MAX_STACK : int = 9999

@export var item_data : ItemData
@export_range(1, MAX_STACK) var quantity : int = 1 : set = set_quantity

func can_fully_merge(slot_data : SlotData) -> bool:
	return item_data == slot_data.item_data \
		and item_data.stackable \
		and quantity + slot_data.quantity < MAX_STACK
		
func fully_merge(slot_data : SlotData) -> void:
	quantity += slot_data.quantity

func set_quantity(value : int) -> void:
	quantity = value
	if quantity > 1 and not item_data.stackable:
		quantity = 1
