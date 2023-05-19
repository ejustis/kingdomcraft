extends Node

const MAX_PLAYERS := 8
const SERVER_PORT := 20666
const SPAWN_RANDOM := 20.0

const PLAYER_NODE := preload("res://scenes/Player/player.tscn")

var IS_ONLINE := Steam.loggedOn()
var STEAM_ID := Steam.getSteamID()
var IS_OWNED := Steam.isSubscribed()

var steam_active : bool = false
var players_ready : Array

func _ready() -> void:
	_initialize_Steam()

func _process(_delta) -> void:
	if steam_active:
		Steam.run_callbacks()

func _initialize_Steam() -> void:
	var INIT: Dictionary = Steam.steamInit(false)
	print("Did Steam initialize? " + str(INIT) )

	if INIT['status'] != 1:
		print("Failed to initialize Steam. " + str(INIT['verbal']))
#		get_tree().quit()
		return
	
	if IS_OWNED == false:
		print("User does not own game")
#		get_tree().quit()
		return

	steam_active = true

func host_server() -> bool:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return false
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	
	# Spawn already connected players.
	for id in multiplayer.get_peers():
		_add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		_add_player(1)
	
	return true

func join_server(ip_address: String) -> bool:
	var peer := ENetMultiplayerPeer.new()
	if ip_address.is_empty():
		ip_address = '127.0.0.1'
	peer.create_client(ip_address, SERVER_PORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return false
		
	multiplayer.multiplayer_peer = peer
	return true

func toggle_client_joining(allowed : bool = false) -> void:
	if multiplayer.is_server():
		multiplayer.set_refuse_new_connections(allowed)
		
@rpc("any_peer", "call_local")
func toggle_player_ready():
	if multiplayer.is_server():
		var player_id := multiplayer.get_remote_sender_id()
		if players_ready.has(player_id):
			players_ready.erase(player_id)
			print("Player is not ready: ", player_id)
		else:
			players_ready.append(player_id)
			print("Player is ready: ", player_id)
		
func check_for_all_players_ready() -> bool:
	if multiplayer.is_server():
		return len(multiplayer.get_peers()) + 1 == len(players_ready)
	
	return false
	
func _add_player(id : int) -> void:
	var character := PLAYER_NODE.instantiate()
	
	character.player_id = id
	character.name = str(id)
	
	GlobalUtils.add_persistent_node("Players", character)
	var screen := get_viewport().get_visible_rect().size
	character.position = Vector2(randf_range(0, screen.x), randf_range(0, screen.y))
	print("Player added: ", id)
	
func _del_player(id: int) -> void:
	var removed : bool = GlobalUtils.remove_from_persisitent_node("Players", str(id))
	print("Player removed: ", removed)
