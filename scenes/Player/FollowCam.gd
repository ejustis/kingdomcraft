extends Camera2D

# Called when the node enters the scene tree for the first time.
func update_boundaries(tilemap: TileMap):
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.cell_quadrant_size
	
	var world_pixel_size = map_rect.size * tile_size
	limit_right = world_pixel_size.x + tile_size
	limit_bottom = world_pixel_size.y
