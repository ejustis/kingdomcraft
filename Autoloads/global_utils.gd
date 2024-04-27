extends Node

const PERSISTENT_NODES : String = "/root/Main/PersistentNodes/"
const PLAYERS_NODE : String = PERSISTENT_NODES + "Players"
const LEVEL_NODE : String = "/root/Main/Level"
const UI_NODE : String = "/root/Main/UI"
const CAMERA : String = "/root/Main/PersistentNodes/Camera2D"
const INVENTORY_UI : String = "%s/InventoryInterface" % UI_NODE

const BUILDING_HOLDER : PackedScene = preload("res://scenes/BuildSystem/BuildingHolder.tscn")

var enemy_counter := 1
var drop_counter := 1
var building_counter := 1

var player_health_bar : Control
var player_camera : Camera2D
var player_inventory : Control

func add_node(parent_path : String, node_instance : Node) -> void:
	get_node(parent_path).call_deferred("add_child", node_instance, true)
	
func add_node_at(parent_path : String, node_instance : Node, location : Vector2) -> void:
	add_node(parent_path, node_instance)

	node_instance.global_position = location

func add_persistent_node(parent : String, node_instance : Node) -> void:
	add_node(PERSISTENT_NODES + parent, node_instance)

func add_persistent_node_at(parent : String, node_instance : Node, location : Vector2) -> void:
	add_node_at(PERSISTENT_NODES + parent, node_instance, location)
	
func add_to_level_tilemap(node_instance : Node):
	add_node(LEVEL_NODE + "/World/TileMap", node_instance)

func remove_from_persisitent_node(parent : String, node_name: String) -> bool:
	var parent_node := get_node(PERSISTENT_NODES + parent)
	if parent_node.has_node(node_name):
		parent_node.get_node(node_name).queue_free()
		return true
		
	return false

func set_player_positions():
	var spawn_node : Node2D = get_node(LEVEL_NODE).get_child(0).find_child("PlayerSpawn")
	
	if spawn_node:
		for player in get_node(PLAYERS_NODE).get_children():
			var position : Vector2 = spawn_node.global_position
			position.x = randf_range(position.x - 50, position.x + 50)
			position.y = randf_range(position.y - 50, position.y + 50)
			player.move_to_position.rpc(position)

func enable_players():
	for player in get_node(PLAYERS_NODE).get_children():
		if multiplayer.is_server():
			player.enable.rpc()
		var sword = load("res://scenes/Weapons/Sword/sword.tscn").instantiate()
		player.current_weapon = sword
		
func add_player_dependencies(player : Node) -> void:
	player_camera = load("res://scenes/Player/Camera.tscn").instantiate()
	player_camera.name = "camera_" + str(player.player_id)
	add_persistent_node("Players/" + str(player.name), 
		player_camera)
	
	player_health_bar = load("res://scenes/Hud/health_bar.tscn").instantiate()
	player_health_bar.name = "health_bar_" + str(player.player_id)
	add_node(GlobalUtils.UI_NODE, 
		player_health_bar)
		
	player_inventory = get_node(INVENTORY_UI)
	player_inventory.set_player_inventory_data(player.inventory_data)
	
# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level : Node = get_node(LEVEL_NODE)
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
	set_player_positions()
	
func get_players_alive() -> Array[Node]:
	return get_node(PLAYERS_NODE).get_children()
	
func get_undestroyed_buildings() -> Array[Node]:
	var buildings : Array[Node] = []
	
	for building in get_tree().get_nodes_in_group("Building"):
		if not building.is_destroyed():
			buildings.append(building)
			
	return buildings
	
func get_next_enemy_id() -> int:
	var tmp := enemy_counter
	enemy_counter += 1
	return tmp

func get_next_drop_id() -> int:
	var tmp := drop_counter
	drop_counter += 1
	return tmp
	
func get_next_building_id() -> int:
	var tmp := building_counter
	building_counter += 1
	return tmp

func return_to_lobby() -> void:
	pass

func create_new_building(blueprint : BuildingData, pos : Vector2) -> void:
	var new_building := BUILDING_HOLDER.instantiate()
	new_building.hide()
	
	new_building.name = "building_%s" % get_next_building_id()
	add_to_level_tilemap(new_building)
	
	new_building.global_position = pos
	
	new_building.show()
	
func client_interpolate(start_pos: Vector2, target_pos: Vector2, delta: float, lerp_speed: float = 25):
	if target_pos == Vector2.INF:
		return start_pos
		
	if (start_pos - target_pos).length_squared() > 10000:
		return target_pos
		
	return lerp(
		target_pos,
		start_pos,
		pow(0.5, delta * lerp_speed))
