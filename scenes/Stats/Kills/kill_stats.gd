extends Node

var kill_counts := {
	Enums.ENEMY_TYPE.SLIME: 0,
	Enums.ENEMY_TYPE.BEAST: 0,
	Enums.ENEMY_TYPE.UNDEAD: 0,
	Enums.ENEMY_TYPE.ENT: 0,
	Enums.ENEMY_TYPE.CYCLOPS: 0
}

func add_kill(type):
	kill_counts[type] += 1
