extends Node2D
var pathfinder

# 测试寻路的代码
func _ready():
	print(get_viewport().size.x)
	pathfinder = Pathfinder.new($TileMap_Test)
	print(pathfinder.find_path(Vector2(50,0), Vector2(1000,700)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
