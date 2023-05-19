extends Control

@export var player_obj : CharacterBody2D

@onready var slime_count : Label = $VBoxContainer/Slimes
@onready var beast_count : Label = $VBoxContainer/Beasts
@onready var undead_count : Label = $VBoxContainer/Undead
@onready var ent_count : Label = $VBoxContainer/Ents
@onready var cyclops_count : Label = $VBoxContainer/Cyclops

var string_format := "%s%8d"

func _process(_delta):
	if Input.is_action_pressed("Stats"):
		update_counts()
		show()
	else:
		hide()

func update_counts():
	var kill_counts : Dictionary = player_obj.get_kill_stats()
	slime_count.text = string_format % ["Slimes", kill_counts[Enums.ENEMY_TYPE.SLIME]]
	beast_count.text = string_format % ["Beasts", kill_counts[Enums.ENEMY_TYPE.BEAST]]
	undead_count.text = string_format % ["Undead", kill_counts[Enums.ENEMY_TYPE.UNDEAD]]
	ent_count.text = string_format % ["Ents", kill_counts[Enums.ENEMY_TYPE.ENT]]
	cyclops_count.text = string_format % ["Cyclops", kill_counts[Enums.ENEMY_TYPE.CYCLOPS]]
