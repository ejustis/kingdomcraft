extends Node2D

signal hit(collision_parent)
signal finished

@onready var animations := $AnimationPlayer
@onready var hit_box : Area2D = $HitBox
@onready var audio : AudioStreamPlayer2D = $SlashSound

var min_damage := 9
var max_damage := 12

var orig_pos : Vector2

func _ready():
	disable_weapon()
	orig_pos = position
	
func get_damage() -> int:
	return randi_range(min_damage, max_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func attack(direction: String, speed_scale := 1.0):
	adjust_offset(direction)
	enable_weapon()
	$SlashSound.play()
	animations.play("attack" + direction, -1, speed_scale, false)
	
func enable_weapon():
	hit_box.monitoring = true
	show()
	
func disable_weapon():
	hit_box.monitoring = false
	hide()

func _on_animation_player_animation_finished(_anim_name):
	disable_weapon()
	emit_signal("finished")

func _on_hit_box_area_entered(area):
	var parent : Node2D = area.get_parent()
	emit_signal("hit", parent)
	
func adjust_offset(direction : String):
	position = orig_pos
	
	if direction == "Up":
		position.y -= 6
	elif direction == "Left":
		position.x -= 4
		position.y -= 3
	elif direction == "Right":
		position.x += 4
		position.y -= 3
