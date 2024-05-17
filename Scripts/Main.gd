extends Node2D
var pathfinder
var tile_map

# 测试寻路的代码
func _ready():
	tile_map = get_node("TileMap_Test" + str(Level.current_level))
	pathfinder = Pathfinder.new(self)
	$HUD.main = self
	$Camera2D.offset = tile_map.tile_set.tile_size + get_viewport().size/2
	$Camera2D.limit_left = - get_viewport().size.x/2
	$Camera2D.limit_top = - get_viewport().size.y/2
	$Camera2D.limit_right = (pathfinder.room_borders.size.x - 2) * pathfinder.scale - get_viewport().size.x/2
	$Camera2D.limit_bottom = (pathfinder.room_borders.size.y - 2) * pathfinder.scale - get_viewport().size.y/2
	print("Test pathfind: ", pathfinder.find_path(Vector2(0,300), Vector2(1000,700)))
	print("Sail Routes: ", pathfinder.get_sail_routes())
	#$MerchantLayer.sail_routes = pathfinder.get_sail_routes()
	#$MerchantLayer.generate_merchants()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_music_finished():
	$Music.play()


func _on_sound_effect_finished():
	$Sound_Effect.play()


func _on_pirate_music_finished():
	$Pirate_Music.play()


func _on_pirate_invasion_timer_timeout():
	$Pirate_Music.play()
