extends Node2D

@export var buildingData: BuildingData

func _ready():
	if multiplayer.is_server():
		if buildingData:
			$Sprite2D.set_texture(buildingData.texture)
			
		var timer := $Timer
		timer.connect("timeout", on_timeout)
		timer.wait_time = buildingData.initial_spawn_time
		timer.start()
	
func on_timeout():
	if multiplayer.is_server():
		queue_free()

func slow_enemy() -> int:
	if BuildingData.AdditionalEffect.SLOW in buildingData.additional_effects:
		return 300
	
	return 0

func get_damage() ->int:
	if buildingData.can_shoot:
		return 0
		
	return buildingData.initial_damage
