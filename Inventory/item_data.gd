extends Resource
class_name ItemData

@export var name : String
@export var sprite : Texture
@export var stackable : bool = false
@export var max_stack : int = 1

func use(target) -> void:
	pass
