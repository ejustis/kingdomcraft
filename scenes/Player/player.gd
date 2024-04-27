extends CharacterBody2D

@export var player_id := 1 :
	set(id):
		player_id = id
		# Give authority over the player input to the appropriate peer.
		$InputSync.set_multiplayer_authority(id)
		
@export var target_pos : Vector2 = Vector2.INF

@export var character_sheet : CompressedTexture2D
@export var inventory_data : InventoryData
@export var learned_blueprints : Array[BuildingData]
		
@export var current_weapon : Node2D:
	set(weapon):
		if current_weapon:
			current_weapon.hit.disconnect(_on_weapon_hit)
			remove_child(current_weapon)
			
		current_weapon = weapon
		
		if current_weapon:
			add_child(current_weapon)
			current_weapon.hit.connect(_on_weapon_hit)
		
		print_debug("Current weapon: " + str(current_weapon))

@onready var animations := $AnimationPlayer
@onready var attack_cooldown := $AttackCooldown
@onready var damage_cooldown := $DamageCooldown
@onready var hit_sound := $HitSound
@onready var health_stats := $HealthStats
@onready var sprite := $Sprite2D
@onready var input := $InputSync
@onready var buildMenu := $BuildMenu

const SPEED = 50.0

var health_bar : Control
var inventory_ui : Control

var can_attack := true
var is_attacking := false
var direction := "Down"
var invincible := false
var current_blueprint : int = 0

func _ready():
	sprite.set_texture(character_sheet)
	buildMenu.populate(learned_blueprints[current_blueprint], false)
	
	if player_id == multiplayer.get_unique_id():
		GlobalUtils.add_player_dependencies(get_node("."))
		
		health_bar = GlobalUtils.player_health_bar
		health_bar.hide()
		
		health_stats.change_max_health(100, true)
		health_bar.change_value_range(0, health_stats.max_health)
		
		inventory_ui = GlobalUtils.player_inventory
		
func _process(delta):
	if input.is_multiplayer_authority():
		health_bar.update_health(health_stats.cur_health)
	else:
		global_position = GlobalUtils.client_interpolate(global_position, target_pos, delta)
	
func _physics_process(_delta):
	handle_input()
	move_and_slide()
	target_pos = global_position
	updateAnimation()

func handle_input():
	velocity = input.direction * SPEED
	
	calculate_direction_name()
	
	if input.build:
		if have_all_materials(learned_blueprints[current_blueprint]):
			build.rpc_id(1)
		else:
			print("Not enough materials")
	
	
	if input.attack && current_weapon:
		is_attacking = true
	else:
		is_attacking = false
		
	if input.scrollBuildMenu != 0:
		current_blueprint += input.scrollBuildMenu
		if current_blueprint < 0:
			current_blueprint = len(learned_blueprints)-1
		elif current_blueprint >= len(learned_blueprints):
			current_blueprint = 0
			
		buildMenu.populate(learned_blueprints[current_blueprint], true)

func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		animations.play("walk" + direction)
		
	if can_attack and is_attacking :
		can_attack = false
		attack_cooldown.start()
		current_weapon.attack.rpc(direction)

func calculate_direction_name() -> void:
	if velocity != Vector2.ZERO:
		if velocity.y > 0 : direction = "Down"
		elif velocity.x < 0 : direction = "Left"
		elif velocity.x > 0 : direction = "Right"
		elif  velocity.y <  0 : direction = "Up"

@rpc("any_peer", "call_local")
func take_damage(damage : int):
	if not invincible:
		var tween = create_tween()
		tween.tween_property($Sprite2D, "self_modulate", Color(1, 0, 0, 1), 0.1)
		tween.tween_property($Sprite2D, "self_modulate", Color(1, 1, 1, 1), 0.1)
		
		damage_cooldown.start()
		invincible = true
		health_stats.take_damage(damage)

@rpc("any_peer", "call_local")
func enable():
	health_stats.reset_health()
	show()
	if health_bar:
		health_bar.show()
	
	inventory_ui.show()
	
func _on_hit_box_area_entered(area):
	if multiplayer.is_server():
		var parent = area.get_parent()
		if parent.is_in_group("Enemy"):
			take_damage.rpc(parent.get_damage())
		
func _on_weapon_hit(parent):
	hit_sound.play()
	if parent.is_in_group("Enemy"):
		parent.take_damage(get_damage())
		
func get_damage() -> int:
	var damage = 10
	if current_weapon:
		damage += current_weapon.get_damage()
	
	# Calculate critical chance
	
	return damage

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_damage_cooldown_timeout():
	invincible = false

func get_kill_stats():
	return get_node("KillStats").kill_counts
	
func is_destroyed() -> bool:
	return health_stats.cur_health <= 0
	
func have_all_materials(blueprint : BuildingData) -> bool:
	for key in blueprint.required_materials.keys():
		if not inventory_data.has_amount_of_item(key, blueprint.required_materials[key]):
			return false
			
	return true

@rpc("any_peer", "call_local")
func build():
	if multiplayer.is_server():
		print("Building it!")
		var blueprint : BuildingData = learned_blueprints[current_blueprint]
		
		# Remove the building materials from the inventory
		for key in blueprint.required_materials.keys():
			inventory_data.remove_quantity(key, blueprint.required_materials[key])
		
		# Build the building in front of the player
		var building_pos : Vector2 = global_position
		
	#	if direction == "Up":
	#		building_pos.y -= 32
	#	elif direction == "Left":
	#		building_pos.x -= 32
	#	elif direction == "Right":
	#		building_pos.x += 32
	#	else:
	#		building_pos.y += 32
		
		GlobalUtils.create_new_building(blueprint, building_pos)
			
