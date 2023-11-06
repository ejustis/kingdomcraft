extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)

@export var slot_datas : Array[SlotData]

func pickup_slot_data(slot_data: SlotData) -> bool:
	var empty_slot : int = -1
	
	for index in slot_datas.size():
		if empty_slot < 0 and not slot_datas[index]:
			empty_slot = index
			continue
		
		if slot_datas[index] and slot_datas[index].can_fully_merge(slot_data):
			slot_datas[index].fully_merge(slot_data)
			inventory_updated.emit(self)
			return true
			
	if empty_slot >= 0:
		slot_datas[empty_slot] = slot_data
		inventory_updated.emit(self)
		return true
		
	return false

func drop_slot_data(slot_data: SlotData) -> void:
	pass
	
func remove_quantity(item_data : ItemData, amount : int) -> void:
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].item_data == item_data:
			if slot_datas[index].remove_amount(amount):
				slot_datas[index] = null
	
	inventory_updated.emit(self)

func has_amount_of_item(item_data : ItemData, amount : int) -> bool:
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].item_data == item_data \
				and slot_datas[index].quantity >= amount:
			return true
			
	return false
