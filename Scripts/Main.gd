extends Node2D
var pathfinder

# 测试寻路的代码
func _ready():
	$HUD.main = self
	pathfinder = Pathfinder.new($TileMap_Test)
	$Camera2D.offset = $TileMap_Test.tile_set.tile_size
	$Camera2D.limit_left = 0
	$Camera2D.limit_top = 0
	$Camera2D.limit_right = pathfinder.room_borders.size.x * pathfinder.scale - 2 * pathfinder.scale
	$Camera2D.limit_bottom = pathfinder.room_borders.size.y * pathfinder.scale - 2 * pathfinder.scale
	print(pathfinder.find_path(Vector2(0,300), Vector2(1000,700)))
	print(pathfinder.get_sail_routes())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
