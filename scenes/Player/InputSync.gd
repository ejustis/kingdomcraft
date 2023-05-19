extends MultiplayerSynchronizer

@export var attack : bool = false
@export var direction : Vector2 = Vector2()

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
func _process(_delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	attack = Input.is_action_pressed("attack")
