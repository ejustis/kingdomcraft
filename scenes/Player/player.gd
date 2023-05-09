extends CharacterBody2D

@export var health_bar : Control

const SPEED = 50.0
@onready var animations := $AnimationPlayer

var max_health := 100
var cur_health := max_health

func _ready():
	if health_bar:
		health_bar.change_value_range(0, max_health)

func handle_input():
	var moveDirection := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = moveDirection * SPEED

func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction := "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif  velocity.y <  0: direction = "Up"
		
		animations.play("walk" + direction)

func _physics_process(delta):
	handle_input()
	move_and_slide()
	updateAnimation()

func _on_hit_box_area_entered(area):
	var parent = area.get_parent()
	if parent.is_in_group("Enemy"):
		cur_health -= parent.damage
		health_bar.update_health(cur_health)
