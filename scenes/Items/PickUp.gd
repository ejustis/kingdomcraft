extends Node2D

@export var slot_data : SlotData

@onready var sprite_2d = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.sprite

func _on_pickup_zone_body_entered(body):
	if body.inventory_data.pickup_slot_data(slot_data):
		queue_free()
