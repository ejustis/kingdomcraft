extends Resource
class_name EnemyData

const PICK_UP = preload("res://scenes/Items/PickUp.tscn")

@export var name : String
@export var description : String

@export var max_health : int = 50
@export var move_speed : float = 20.0
@export var attack_speed : float = 0.2

@export var max_damage : float = 10
@export var min_damage : float = 5

@export var drops : Array[DropData]

func drop_items(pos : Vector2) -> void:
	for drop in drops:
		var is_dropped : bool = drop.drop_chance >= randi_range(0, 100)
		if is_dropped:
			print("Dropped item: %s" % drop.item_data.name)
			var item := PICK_UP.instantiate()
			item.hide()
			
			item.name = "drop_%s" % GlobalUtils.get_next_drop_id()
			GlobalUtils.add_to_level_tilemap(item)
			
			item.slot_data.item_data = drop.item_data
			item.slot_data.quantity = randi_range(1, drop.max_stack)
			item.update_sprite()
			
			var spawn_loc := pos
			print("Initial loc: %s" % spawn_loc)
			
			spawn_loc.x = randf_range(spawn_loc.x - 20, spawn_loc.x + 20) - 50
			spawn_loc.y = randf_range(spawn_loc.y - 20, spawn_loc.y + 20) - 27
			item.global_position = spawn_loc
			print("Adjusted loc: %s" % spawn_loc)
			
			item.show()
