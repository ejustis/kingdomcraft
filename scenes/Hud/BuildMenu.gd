extends PanelContainer

var container : TextureRect
var timer : Timer

func _ready():
	container = $TextureRect
	container.hide()
	
	timer = $Timer
	timer.connect("timeout", on_timeout)
	
# Called when the node enters the scene tree for the first time.
func populate(blueprint: BuildingData, showMenu : bool):
	container.set_texture(blueprint.texture)
	if showMenu:
		container.show()
		timer.start()

func on_timeout():
	container.hide()
