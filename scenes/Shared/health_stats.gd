extends Node

signal dead

@export var max_health := 50
var cur_health := max_health

func change_max_health(new_max : int, heal_all := false):
	max_health = new_max
	if heal_all:
		cur_health = max_health

func heal(value : int):
	if value > 0 and cur_health < max_health:
		cur_health += value
		if cur_health > max_health:
			cur_health = max_health

func take_damage(value : int):
	cur_health -= value
	if cur_health < 0:
		emit_signal("dead")
