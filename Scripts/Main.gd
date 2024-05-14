extends Node2D
var pathfinder

# 测试寻路的代码
func _ready():
	print(get_viewport().size.x)
	pathfinder = Pathfinder.new($TileMap_Test)
	print(pathfinder.find_path(Vector2(0,300), Vector2(1000,700)))
	print(pathfinder.get_sail_routes())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
