extends CharacterBody2D

signal killed_by(character_node: Node2D)

const type := Enums.ENEMY_TYPE.SLIME
const LIMIT := 12

@export var enemy_data : EnemyData

@onready var animations := $AnimationPlayer
@onready var health_stats := $HealthStats
@onready var health_bar := $HealthBar
@onready var death_particles := $DeathParticles
@onready var attack_box : CollisionShape2D = $AttackArea/AttackBox
@onready var attack_timer : Timer = $AttackTimer

var has_died := false
var last_hit_node : Node2D
var target : Node2D
var move_speed : float

func _ready():
	health_stats.change_max_health(enemy_data.max_health, true)
	health_bar.change_value_range(0, health_stats.max_health)
	attack_timer.wait_time = enemy_data.attack_speed
	move_speed =enemy_data.move_speed
	
func _process(_delta):
	if has_died and not death_particles.emitting:
		queue_free()
	
	if not has_died and (target == null or target.is_destroyed()):
		calculate_new_target()
	
func _physics_process(_delta):
	if not has_died:
		if target:
			update_velocity()
		move_and_slide()
	
func update_velocity() -> void:
	var move_dir = target.global_position - global_position
	if move_dir.length() >= LIMIT:
		velocity = move_dir.normalized() * move_speed
	else:
		velocity = Vector2(0,0)
		
	update_animation(move_dir)
	
func update_animation(move_dir: Vector2) -> void:
	move_dir = move_dir.normalized()
	var direction := "Down"
	if move_dir.x < 0: direction = "Left"
	elif move_dir.x > 0: direction = "Right"
	elif  move_dir.y <  0: direction = "Up"
	
	animations.play("move" + direction)

func adjust_stats(current_wave : int, difficulty_modifier : float) -> void:
	pass

func get_damage() -> float:
	attack_box.set_deferred("disabled", true)
	attack_timer.start()
	return randf_range(enemy_data.min_damage, enemy_data.max_damage)

@rpc("any_peer", "call_local")
func take_damage(value : int):
	var tween = create_tween()
	tween.tween_property($Sprite2D, "self_modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property($Sprite2D, "self_modulate", Color(1, 1, 1, 1), 0.1)
	
	health_stats.take_damage(value)
	health_bar.update_health(health_stats.cur_health)

func calculate_new_target() -> void:
	var buildings := GlobalUtils.get_undestroyed_buildings()
	var temp_target = null
	
	for building in buildings:
		if not temp_target:
			temp_target = building
			continue
		
		if temp_target.get_health() > building.get_health():
			temp_target = building
			
	target = temp_target

func _on_health_stats_dead():
	death_particles.emitting = true
	$HitBox.set_deferred("monitoring", false)
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
			
			#Set the target to whoever attacked it
			target = last_hit_node
			if multiplayer.is_server():
				take_damage.rpc(character.get_damage())


func _on_attack_timer_timeout():
	attack_box.set_deferred("disabled", false)
