extends CharacterBody2D

const SPEED := 20.0
const LIMIT := 0.5

@export var end_marker : Marker2D
@export var damage := 9.5 :
	get:
		return randf_range(0, 2.2) + damage

@onready var animations := $AnimationPlayer
@onready var health_stats := $HealthStats
@onready var health_bar := $HealthBar

var start_pos : Vector2
var end_pos : Vector2

func _ready():
	start_pos = global_position
	end_pos = end_marker.global_position
	
	health_stats.change_max_health(50, true)
	health_bar.change_value_range(0, health_stats.max_health)
	
func update_velocity():
	var move_dir = end_pos - global_position
	if move_dir.length() <= LIMIT:
		change_direction()
		
	velocity = move_dir.normalized() * SPEED
	
func change_direction():
	var temp_end = end_pos
	end_pos = start_pos
	start_pos = temp_end
	
func update_animation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction := "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif  velocity.y <  0: direction = "Up"
		
		animations.play("move" + direction)
	
func _physics_process(delta):
	update_velocity()

	move_and_slide()
	update_animation()

func take_damage(value : int):
	health_stats.take_damage(value)

	health_bar.update_health(health_stats.cur_health)


func _on_health_stats_dead():
	queue_free()
