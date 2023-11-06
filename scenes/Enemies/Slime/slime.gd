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
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var has_died := false
var last_hit_node : Node2D
var target : Node2D
var move_speed : float

func _ready():
	health_stats.change_max_health(enemy_data.max_health, true)
	health_bar.change_value_range(0, health_stats.max_health)
	attack_timer.wait_time = enemy_data.attack_speed
	move_speed =enemy_data.move_speed
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("calculate_new_target")
	
func _process(_delta):
	if has_died and not death_particles.emitting:
		queue_free()
	
	if not has_died and (target == null or target.is_destroyed()):
		call_deferred("calculate_new_target")
	else:
		# Now that the navigation map is no longer empty, set the movement target.
		set_movement_target(target.global_position)
	
func _physics_process(_delta):
	if not has_died:
		if navigation_agent.is_navigation_finished():
			return
		
		if target:
			update_velocity()
		move_and_slide()
	
func update_velocity() -> void:
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized() 
	
	velocity = new_velocity * move_speed
		
	update_animation(new_velocity)
	
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
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	var buildings := GlobalUtils.get_undestroyed_buildings()
	var temp_target = null
	
	for building in buildings:
		if not temp_target:
			temp_target = building
			continue
		
		if temp_target.get_health() > building.get_health():
			temp_target = building
			
	target = temp_target
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_health_stats_dead():
	if multiplayer.is_server():
		death_particles.emitting = true
		$HitBox.set_deferred("monitoring", false)
		$HitBox.collision_layer = 0
		
		print("Global pos: %s", global_position)
		enemy_data.drop_items(global_position)
		
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
