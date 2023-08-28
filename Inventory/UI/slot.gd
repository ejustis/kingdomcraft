extends PanelContainer

@onready var quantity = $Quantity
@onready var texture_rect = $MarginContainer/TextureRect


func set_slot_data(slot_data: SlotData) -> void:
	texture_rect.texture = slot_data.item_data.sprite
	tooltip_text = "%s" % [slot_data.item_data.name]
	if slot_data.quantity > 1:
		quantity.text = "x%s" % slot_data.quantity
		quantity.show()


func _on_gui_input(event):
	if event is Input:
		pass
