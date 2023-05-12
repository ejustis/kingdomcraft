extends CharacterBody2D

signal killed_by(character_node: Node2D)

const type := Enums.ENEMY_TYPE.SLIME
const SPEED := 20.0
const LIMIT := 0.5

@export var end_marker : Marker2D
@export var damage := 9.5 :
	get:
		return randf_range(0, 2.2) + damage

@onready var animations := $AnimationPlayer
@onready var health_stats := $HealthStats
@onready var health_bar := $HealthBar
@onready var death_particles := $DeathParticles

var start_pos : Vector2
var end_pos : Vector2
var has_died := false
var last_hit_node : Node2D

func _ready():
	start_pos = global_position
	end_pos = end_marker.global_position
	
	health_stats.change_max_health(50, true)
	health_bar.change_value_range(0, health_stats.max_health)
	
func _process(delta):
	if has_died and not death_particles.emitting:
		queue_free()
	
func _physics_process(delta):
	if not has_died:
		update_velocity()
		move_and_slide()
		update_animation()
	
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

func take_damage(value : int):
	var tween = create_tween()
	tween.tween_property($Sprite2D, "self_modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property($Sprite2D, "self_modulate", Color(1, 1, 1, 1), 0.1)
	
	health_stats.take_damage(value)
	health_bar.update_health(health_stats.cur_health)

func _on_health_stats_dead():
	death_particles.emitting = true
	$HitBox.monitoring = false
	$HitBox.collision_layer = 0
	
	if not has_died and last_hit_node and last_hit_node.is_in_group("Player"):
		last_hit_node.find_child("KillStats").add_kill(type)
		last_hit_node = null
		
	has_died = true
	
	if animations.is_playing():
		animations.stop()

func _on_hit_box_area_entered(area):
	var area_parent : Node2D = area.get_parent()
	if area_parent.is_in_group("Weapon"):
		var character := area_parent.get_parent()
		if character.is_in_group("Player") or character.is_in_group("NPC"):
			last_hit_node = character
			take_damage(character.get_damage())
