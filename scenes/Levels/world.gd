extends Node2D

func _ready():
	GlobalUtils.player_camera.update_boundaries(get_node("TileMap"))
	GlobalUtils.enable_players()
	
