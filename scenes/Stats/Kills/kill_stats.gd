extends Node

var kill_counts := {
	Enums.ENEMY_TYPE.SLIME: 0
}

func add_kill(type):
	kill_counts[type] += 1
