extends Resource
class_name ItemData

@export var name : String
@export var sprite : Texture
@export var stackable : bool = false
@export var type : ItemType

enum ItemType {
	MATERIAL,
	CONSUMABLE
}
