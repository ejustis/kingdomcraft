extends Node

@onready var wave_timer : Timer = $NextWave

@export var wave_interval : float = 30.0
@export var spawn_points : Array[Node2D]
@export var wave_data : WaveData

var current_wave := 1
var enemies_alive := 0

var next_enemies : Array[Node2D]
var calculating := false
var spawning := false

func _ready() -> void:
	if spawn_points.is_empty():
		print("No spawn points found")
		GlobalUtils.return_to_lobby()
	
	wave_timer.wait_time = wave_interval
	
	print("Starting waves...")
	calculate_next_enemies()
	wave_timer.start()
	
func _process(_delta):
	if wave_timer.is_stopped() and not spawning:
		wave_timer.start()
		
func calculate_next_enemies():
	calculating = true
	var start_time := Time.get_ticks_msec()
	
	#Calculate the number of enemies to be in the wave
	var max_enemies : int = ceili((wave_data.min_enemies * randf_range(1, wave_data.difficulty_modifier)) + (randf_range(0.1, 1.0) * current_wave))
	var enemies_in_wave = randi_range(wave_data.min_enemies, max_enemies)
	
	#Calculate the number of bosses in the wave
	var can_have_bosses = floori(current_wave / 5.0) > 0
	var min_bosses : int = floori(current_wave / 5.0)
	var max_bosses : int = min_bosses + floori(current_wave * wave_data.difficulty_modifier/10)
	var bosses_in_wave : int = randi_range(min_bosses, max_bosses)
	
	
	#Create the array of next enemies to spawn
	var possible_enemies := determine_possible_enemies(wave_data.enemies)
	add_enemies_to_next_wave(possible_enemies, enemies_in_wave)
		
	#Create the array of next bosses to spawn
	if can_have_bosses:
		var possible_bosses := determine_possible_enemies(wave_data.bosses)
		add_enemies_to_next_wave(possible_bosses, bosses_in_wave)
			
	calculating = false
	print("Enemy calculations took: " + str(Time.get_ticks_msec() - start_time))
	
func determine_possible_enemies(enemy_list : Array[EnemyInWave]) -> Array[PackedScene]:
	#Determine the possible enemies that can spawn in this wave
	var possible_enemies : Array[PackedScene] = []
	for enemy in enemy_list:
		# If this enemy isn't for this wave skip
		if enemy.start_wave > current_wave:
			continue
	
		possible_enemies.append(enemy.enemy)
	
	return possible_enemies

func add_enemies_to_next_wave(possible_enemies : Array[PackedScene], wave_limit : int) -> void:
	var possible_enemy_size : int = len(possible_enemies)
	while len(next_enemies) < wave_limit:
		var enemy_index : int = randi_range(0, possible_enemy_size-1)
		
		var new_enemy : Node2D = possible_enemies[enemy_index].instantiate()
		new_enemy.adjust_stats(current_wave, wave_data.difficulty_modifier)
	
		next_enemies.append(new_enemy)

func spawn_enemies() -> void:
	spawning = true
	
	for enemy in next_enemies:
		var spawn_point : Node2D = spawn_points[randi_range(0, len(spawn_points)-1)]
		enemy.name = "enemy_" + str(GlobalUtils.get_next_enemy_id())
	
		enemy.hide()
		add_child(enemy)
		
		var spawn_loc := spawn_point.global_position
		spawn_loc.x = randf_range(spawn_loc.x - 10, spawn_loc.x + 10)
		spawn_loc.y = randf_range(spawn_loc.y, spawn_loc.y + 10)
		enemy.global_position = spawn_loc
		
		enemy.show()
		# Wait half a second before spawning the next monster
		await get_tree().create_timer(0.7).timeout
	
	next_enemies.clear()
	spawning = false

func _on_next_wave_timeout():
	wave_timer.stop()
	spawn_enemies()
	current_wave += 1
	calculate_next_enemies()
