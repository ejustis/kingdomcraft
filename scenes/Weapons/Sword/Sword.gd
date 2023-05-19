extends Node2D

signal hit(collision_parent)
signal finished

@onready var animations := $AnimationPlayer
@onready var collision : CollisionShape2D = $HitBox/CollisionShape2D
@onready var audio : AudioStreamPlayer2D = $SlashSound

var min_damage := 9
var max_damage := 12

var orig_pos : Vector2

func _ready():
	disable_weapon()
	orig_pos = position
	
func get_damage() -> int:
	return randi_range(min_damage, max_damage)

@rpc("any_peer", "call_local")
func attack(direction: String, speed_scale := 1.0):
	adjust_offset(direction)
	enable_weapon()
	$SlashSound.play()
	animations.play("attack" + direction, -1, speed_scale, false)

func enable_weapon():
	collision.disabled = false
	show()

@rpc("any_peer", "call_local")	
func disable_weapon():
	collision.disabled = true
	hide()

func _on_animation_player_animation_finished(_anim_name):
	if multiplayer.is_server():
		disable_weapon.rpc()
		emit_signal("finished")
	
func adjust_offset(direction : String):
	position = orig_pos
	
	if direction == "Up":
		position.y -= 6
	elif direction == "Left":
		position.x -= 5
		position.y -= 3
	elif direction == "Right":
		position.x += 5
		position.y -= 3
