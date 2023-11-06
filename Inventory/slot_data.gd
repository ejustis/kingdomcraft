extends Resource
class_name SlotData

@export var item_data : ItemData
@export var quantity : int = 1 : set = set_quantity

func can_fully_merge(slot_data : SlotData) -> bool:
	return item_data == slot_data.item_data \
		and item_data.stackable \
		and quantity + slot_data.quantity < item_data.max_stack
		
func fully_merge(slot_data : SlotData) -> void:
	quantity += slot_data.quantity

func set_quantity(value : int) -> void:
	quantity = value
	if quantity > 1 and not item_data.stackable:
		quantity = 1

# Removes the given value from the quantity
# and returns if the slot is marked for removal
func remove_amount(value : int) -> bool:
	quantity -= value
	
	return quantity <= 0
