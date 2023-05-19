extends Node

const PERSISTENT_NODES = "/root/Main/PersistentNodes/"
const PLAYERS_NODE = PERSISTENT_NODES + "Players"
const LEVEL_NODE = "/root/Main/Level"
const UI_NODE = "/root/Main/UI"
const CAMERA = "/root/Main/PersistentNodes/Camera2D"

var player_health_bar : Control
var player_camera : Camera2D

func add_node(parent_path : String, node_instance : Node) -> void:
	get_node(parent_path).add_child(node_instance, true)
	
func add_node_at(parent_path : String, node_instance : Node, location : Vector2) -> void:
	add_node(parent_path, node_instance)

	node_instance.global_position = location

func add_persistent_node(parent : String, node_instance : Node) -> void:
	add_node(PERSISTENT_NODES + parent, node_instance)

func add_persistent_node_at(parent : String, node_instance : Node, location : Vector2) -> void:
	add_node_at(PERSISTENT_NODES + parent, node_instance, location)

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
			player.global_position = position

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
