extends Resource
class_name BuildingData

@export var initial_spawn_time := 10
@export var initial_damage := 1
@export var required_materials : Dictionary
@export var can_shoot := false
@export var projectile : PackedScene
@export var additional_effects : Array[AdditionalEffect]
@export var texture: Texture

enum AdditionalEffect{
	BURN,
	SLOW,
	PARALYZE,
	KNOCKBACK
}
