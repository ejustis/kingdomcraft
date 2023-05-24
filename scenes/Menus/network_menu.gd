extends Control

var players_ready : Array
var waiting_for_players : bool = false

func _ready() -> void:
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()
		
func _process(_delta) -> void:
	if multiplayer.is_server() and waiting_for_players:
		if Network.check_for_all_players_ready():
			load_level()
		
func _on_host_pressed() -> void:
	if Network.host_server():
		show_lobby()

func _on_join_pressed() -> void:
	var ip : String = $HostOrJoin/VBoxContainer/Ip.text
	if Network.join_server(ip):
		show_lobby()
	
func show_lobby() -> void:
	waiting_for_players = true
	# Hide the UI and unpause to start the game.
	$HostOrJoin.hide()
	$ReadyUp.show()

func _on_ready_toggled(_button_pressed) -> void:
	Network.toggle_player_ready.rpc()
	
func load_level() -> void:
	hide_menus.rpc()
	waiting_for_players = false
	print("Loading the selected level")
	GlobalUtils.change_level.call_deferred(load("res://scenes/Levels/Forest/Forest.tscn"))
	
@rpc("any_peer", "call_local")
func hide_menus():
	$HostOrJoin.hide()
	$ReadyUp.hide()
	
