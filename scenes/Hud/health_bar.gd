extends Control

@onready var progress_bar = $TextureProgressBar

var min_value := 0
var max_value := 100

func _ready():
	progress_bar.min_value = min_value
	progress_bar.max_value = max_value
	progress_bar.value = max_value

func change_value_range(min_val : int, max_val : int):
	min_value = min_val
	max_value = max_val

func update_health(value : float):
	if value < progress_bar.min_value:
		value = progress_bar.min_value

	if value > progress_bar.max_value:
		value = progress_bar.max_value
		
	progress_bar.value = roundi(value)
