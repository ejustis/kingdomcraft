extends CharacterBody2D

@export var player_id := 1 :
	set(id):
		player_id = id
		# Give authority over the player input to the appropriate peer.
		$InputSync.set_multiplayer_authority(id)
		

@export var character_sheet : CompressedTexture2D
@export var inventory_data : InventoryData
		
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

const SPEED = 50.0

var health_bar : Control
var inventory_ui : Control

var can_attack := true
var is_attacking := false
var direction := "Down"
var invincible := false

func _ready():
	sprite.set_texture(character_sheet)
	
	if player_id == multiplayer.get_unique_id():
		GlobalUtils.add_player_dependencies(get_node("."))
		
		health_bar = GlobalUtils.player_health_bar
		health_bar.hide()
		
		health_stats.change_max_health(100, true)
		health_bar.change_value_range(0, health_stats.max_health)
		
		inventory_ui = GlobalUtils.player_inventory
		
func _process(_delta):
	if input.is_multiplayer_authority():
		health_bar.update_health(health_stats.cur_health)
	
func _physics_process(_delta):
	handle_input()
	move_and_slide()
	updateAnimation()

func handle_input():
	velocity = input.direction * SPEED
	
	calculate_direction_name()
	
	if input.build and inventory_data.has_amount_of_item(preload("res://Inventory/Items/SlimeGoo.tres"), 1):
		print("Build da stuff")
	
	if input.attack && current_weapon:
		is_attacking = true
	else:
		is_attacking = false

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


