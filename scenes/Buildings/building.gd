extends StaticBody2D

@export var max_health := 100.0
@export var cur_health := 100.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var hit_timer : Timer= $HitTimer
	
func is_destroyed() -> bool:
	return cur_health <= 0

func get_health() -> float:
	return cur_health

func _on_hit_area_area_entered(area):
	print("Hit to building")
	if multiplayer.is_server() and hit_timer.is_stopped() and not is_destroyed():
		var enemy : Node = area.get_parent()
		cur_health -= enemy.get_damage()
		
		hit_timer.start()
		update_visuals.rpc()
		
		if is_destroyed():
			queue_free()

@rpc("any_peer", "call_local")
func update_visuals() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "position:x", -1, 0.05)
	tween.tween_property($Sprite2D, "position:x", 2, 0.1)
	tween.tween_property($Sprite2D, "position:x", -1, 0.05)
	
	var health_percent : float = (max_health-cur_health)/max_health
	sprite.material.set_shader_parameter("health_percent",  clampf(1.0 - health_percent, 0, 1))
