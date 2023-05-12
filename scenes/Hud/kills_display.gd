extends Control

@export var player_obj : CharacterBody2D

@onready var slime_count : Label = $Panel/VBoxContainer/Slimes

var string_format := "%s%14d"

func _process(_delta):
	if Input.is_action_pressed("Stats"):
		update_counts()
		show()
	else:
		hide()

func update_counts():
	var kill_counts : Dictionary = player_obj.get_kill_stats()
	slime_count.text = string_format % ["Slimes", kill_counts[Enums.ENEMY_TYPE.SLIME]]
