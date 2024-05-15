extends CanvasItem
class_name HUD
@onready var is_prebuilding := false
@onready var is_preexpanding := false
@onready var is_predemolishing := false
@onready var main
@onready var life_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Life/Life_Value
@onready var money_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Money/Money_Value
@onready var expand_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Expand_Button/Expand_Text
@onready var build_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Build_Button/Build_Text
@onready var demolish_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Demolish_Button/Demolish_Text
# Called when the node enters the scene tree for the first time.
func _ready():
	#life_value.text = str(main.current_life)
	#money_value.text = str(main.current_money)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#life_value.text = str(main.current_life)
	#money_value.text = str(main.current_money)
	if is_prebuilding:
		if main.pathfinder.is_constructable_land(get_global_mouse_position()):
			print("can build!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				build(load("res://Scenes/Buildings/TurrentExample.tscn"), get_global_mouse_position())
		else:
			print("cannot build!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
	if is_preexpanding:
		if main.pathfinder.is_shallow_water(get_global_mouse_position()):
			print("can expand!")
			if Input.is_action_just_pressed("click"):
				expand(get_global_mouse_position())
		else: print("cannot expand!")
	if is_predemolishing:
		if main.pathfinder.is_building(get_global_mouse_position()):
			print("can demolish!")
			if Input.is_action_just_pressed("click"):
				demolish(get_global_mouse_position())
		else: print("cannot demolish!")

func _on_expand_button_pressed():
	if not is_preexpanding:
		start_preexpanding()
	else:
		stop_preexpanding()

func _on_build_button_pressed():
	if not is_prebuilding:
		start_prebuilding("TurrentExample")
	else:
		stop_prebuilding()

func _on_demolish_button_pressed():
	start_predemolishing()

func start_prebuilding(building_name:String):
	stop_preexpanding()
	stop_predemolishing()
	is_prebuilding = true
	build_button_text.text = "Cancel!"
	var building_texture = load("res://Assets/Buildings/turrents_1_left.png")
	main.get_node("Cursor/Sprite2D").texture = building_texture

func stop_prebuilding():
	is_prebuilding = false
	build_button_text.text = "Build!"
	main.get_node("Cursor/Sprite2D").texture = null
	
func start_preexpanding():
	stop_prebuilding()
	stop_predemolishing()
	is_preexpanding = true
	expand_button_text.text = "Cancel!"

func stop_preexpanding():
	is_preexpanding = false
	expand_button_text.text = "Expand!"
	
func start_predemolishing():
	stop_prebuilding()
	stop_preexpanding()
	is_predemolishing = true
	demolish_button_text.text = "Cancel!"

func stop_predemolishing():
	is_predemolishing = false
	demolish_button_text.text = "Demolish!"
	
func build(building_scene:PackedScene, position:Vector2):
	if not main.pathfinder.is_constructable_land(position):
		pass
	else:
		var building = building_scene.instantiate()
		building.start_location = main.pathfinder.get_tile_center(position)
		main.get_node("BuildingLayer").add_child(building)
		main.pathfinder.maze_add_building(position)
		stop_prebuilding()
		
func expand(position:Vector2):
	if not main.pathfinder.is_shallow_water(position):
		pass
	else:
		main.tile_map.erase_cell(0, main.pathfinder.get_standard_position(position))
		main.tile_map.set_cells_terrain_connect(1, [main.pathfinder.get_standard_position(position)], 0, 0)
		main.pathfinder.maze_update("ground", position)
		stop_preexpanding()
		
func demolish(position:Vector2):
	if not main.pathfinder.is_building(position):
		pass
	else:
		for i in main.get_node("BuildingLayer").get_children():
			if i.global_position  == main.pathfinder.get_tile_center(position):
				i.queue_free()
				break
		main.pathfinder.maze_update("ground", position)
		stop_predemolishing()
