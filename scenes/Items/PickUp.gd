extends Node2D

@export var slot_data : SlotData

func _ready() -> void:
	update_sprite()
	
func update_sprite() -> void:
	$Sprite2D.texture = slot_data.item_data.sprite

func _on_pickup_zone_body_entered(body):
	if body.inventory_data.pickup_slot_data(slot_data):
		queue_free()
