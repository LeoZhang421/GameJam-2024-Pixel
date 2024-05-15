extends Node2D
var pathfinder
var tile_map

# 测试寻路的代码
func _ready():
	tile_map = $TileMap_Test
	pathfinder = Pathfinder.new(tile_map)
	$HUD.main = self
	$Camera2D.offset = tile_map.tile_set.tile_size + get_viewport().size/2
	$Camera2D.limit_left = - get_viewport().size.x/2
	$Camera2D.limit_top = - get_viewport().size.y/2
	$Camera2D.limit_right = (pathfinder.room_borders.size.x - 2) * pathfinder.scale - get_viewport().size.x/2
	$Camera2D.limit_bottom = (pathfinder.room_borders.size.y - 2) * pathfinder.scale - get_viewport().size.y/2
	print(pathfinder.find_path(Vector2(0,300), Vector2(1000,700)))
	print(pathfinder.get_sail_routes())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
