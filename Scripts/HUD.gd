extends CanvasLayer
class_name HUD
@onready var is_prebuilding := false
@onready var is_preexpanding := false
@onready var is_predemolishing := false
@onready var is_prebuildingship := false
@onready var main
@onready var pending_scene
@onready var title = $Level_Control/Title
@onready var done = $Level_Control/Done_Button
@onready var level_info = $Container/VBoxContainer/MarginContainer/VBoxContainer/Title
@onready var life_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Life/Life_Value
@onready var money_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Money/Money_Value
@onready var expand_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Expand_Button/Expand_Text
@onready var build_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Build_Button/Build_Text
@onready var demolish_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Demolish_Button/Demolish_Text
@onready var buildship_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Buildship_Button/Buildship_Text
@onready var building_list = $Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/BuildingList
@onready var ship_list = $Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/ShipList
@onready var introduction = $Container/VBoxContainer/MarginContainer3/VBoxContainer/Introduction
@onready var skill_list = $Container/MarginContainer/Skill_List
# Called when the node enters the scene tree for the first time.
func _ready():
	life_value.text = str(Character.current_hp)
	money_value.text = str(Character.gold)
	level_info.text = "Level " + str(Level.get_current_level())
	ship_list.visible = false
	title.text = Level.get_current_phase()
	done.visible = (Level.get_current_phase() == "preparation")
	$Level_Control/Turn_Display.set_text("Turn " + str(Level.get_current_turn()))
	$Turn_Count_Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life_value.text = str(Character.current_hp)
	money_value.text = str(Character.gold)
	if is_prebuilding:
		var can_build:bool
		if pending_scene.is_on_land:
			can_build = main.pathfinder.is_constructable_land(main.get_global_mouse_position())
		else:
			can_build = main.pathfinder.is_shallow_water(main.get_global_mouse_position())
		if can_build:
			print("can build!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				build(pending_scene, main.get_global_mouse_position())
		else:
			print("cannot build!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
	if is_preexpanding:
		if main.pathfinder.is_shallow_water(main.get_global_mouse_position()):
			print("can expand!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				expand(main.get_global_mouse_position())
		else:
			print("cannot expand!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
	if is_predemolishing:
		if main.pathfinder.is_building(main.get_global_mouse_position()):
			print("can demolish!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				demolish(main.get_global_mouse_position())
		else:
			print("cannot demolish!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
	if is_prebuildingship:
		if main.pathfinder.is_shallow_water(main.get_global_mouse_position()) || main.pathfinder.is_deep_water(main.get_global_mouse_position()):
			print("can buildship!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				buildship(pending_scene, main.get_global_mouse_position())
		else:
			print("cannot buildship!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)

func _on_expand_button_pressed():
	if Level.get_current_phase() == "preparation":
		if not is_preexpanding:
			start_preexpanding()
		else:
			stop_preexpanding()

func _on_build_button_pressed():
	if Level.get_current_phase() == "preparation":
		stop_preexpanding()
		stop_predemolishing()
		building_list.visible = !building_list.visible
		ship_list.visible = false
		if is_prebuilding:
			stop_prebuilding()

func _on_demolish_button_pressed():
	if Level.get_current_phase() == "preparation":
		if not is_predemolishing:
			start_predemolishing()
		else:
			stop_predemolishing()
		
func _on_buildship_button_pressed():
	if Level.get_current_phase() == "preparation":
		stop_preexpanding()
		stop_predemolishing()
		ship_list.visible = !ship_list.visible
		building_list.visible = false
		if is_prebuildingship:
			stop_prebuildingship()

func start_prebuilding(building_name:String):
	stop_preexpanding()
	stop_predemolishing()
	stop_prebuildingship()
	is_prebuilding = true
	build_button_text.text = "Cancel!"
	var cursor_texture = get_node("Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/BuildingList/" + building_name + "Container/Build_" + building_name).icon
	main.get_node("Cursor/Sprite2D").texture = cursor_texture
	pending_scene = load("res://Scenes/Buildings/" + building_name + "Example.tscn").instantiate()

func stop_prebuilding():
	is_prebuilding = false
	build_button_text.text = "Build!"
	main.get_node("Cursor/Sprite2D").texture = null
	building_list.visible = false
	
func start_preexpanding():
	stop_prebuilding()
	stop_predemolishing()
	stop_prebuildingship()
	is_preexpanding = true
	expand_button_text.text = "Cancel!"
	var cursor_texture = load("res://Assets/Utility/Select_Cursor_0001.png")
	main.get_node("Cursor/Sprite2D").scale = Vector2(main.tile_map.tile_set.tile_size)/cursor_texture.get_size()
	main.get_node("Cursor/Sprite2D").texture = cursor_texture

func stop_preexpanding():
	is_preexpanding = false
	expand_button_text.text = "Expand!"
	main.get_node("Cursor/Sprite2D").texture = null
	main.get_node("Cursor/Sprite2D").scale = Vector2(1, 1)
	
func start_predemolishing():
	stop_prebuilding()
	stop_preexpanding()
	stop_prebuildingship()
	is_predemolishing = true
	demolish_button_text.text = "Cancel!"
	var cursor_texture = load("res://Assets/Utility/Select_Cursor_0001.png")
	main.get_node("Cursor/Sprite2D").scale = Vector2(main.tile_map.tile_set.tile_size)/cursor_texture.get_size()
	main.get_node("Cursor/Sprite2D").texture = cursor_texture

func stop_predemolishing():
	is_predemolishing = false
	demolish_button_text.text = "Demolish!"
	main.get_node("Cursor/Sprite2D").texture = null
	main.get_node("Cursor/Sprite2D").scale = Vector2(1, 1)
	
func start_prebuildingship(ship_name:String):
	stop_prebuilding()
	stop_preexpanding()
	stop_predemolishing()
	is_prebuildingship = true
	buildship_button_text.text = "Cancel!"
	var cursor_texture = get_node("Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/ShipList/" + ship_name + "Container/Build_" + ship_name).icon
	main.get_node("Cursor/Sprite2D").texture = cursor_texture
	pending_scene = load("res://Scenes/Ships/" + ship_name + "Example.tscn").instantiate()

func stop_prebuildingship():
	is_prebuildingship = false
	buildship_button_text.text = "Buildship!"
	main.get_node("Cursor/Sprite2D").texture = null
	ship_list.visible = false
	
	
func build(building_scene:Object, position:Vector2):
	var can_build:bool
	if building_scene.is_on_land:
		can_build = main.pathfinder.is_constructable_land(position)
	else:
		can_build = main.pathfinder.is_shallow_water(position)
	if not can_build:
		pass
	else:
		var building = building_scene
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
				i.demolish()
				break
		main.pathfinder.delete_building(position)
		stop_predemolishing()
		
func buildship(ship_scene:Object, position:Vector2):
		if Character.current_built_ships >= Character.max_buildable_ships:
			pass
		else:
			var ship = ship_scene
			ship.start_location = main.pathfinder.get_tile_center(position)
			main.get_node("ShipLayer").add_child(ship)
			main.pathfinder.maze_add_ship(position)
			stop_prebuildingship()
			Character.current_built_ships += 1


func _on_build_turrent_pressed():
	start_prebuilding("Turrent")


func _on_done_button_pressed():
	stop_prebuilding()
	building_list.visible = false
	stop_predemolishing()
	stop_preexpanding()
	title.text = "action"
	done.visible = false
	Level.complete_phase()
	main.get_node("Music").fade_out()
	main.get_node("Pirate_Music").volume_db = 0
	main.get_node("Pirate_Invasion_Timer").start()
	$TestTimer.start()
	main.get_node("MerchantLayer").reset(main.pathfinder.get_sail_routes())
	main.get_node("MerchantLayer").start_action()

func _on_build_ship_pressed():
	if not is_prebuilding:
		start_prebuildingship("Ship")


func _on_turn_count_timer_timeout():
	$Level_Control/Turn_Display.visible = false
	
	
func _on_build_shipyard_pressed():
	start_prebuilding("Shipyard")
	introduction.text = "This is Shipyard"


func complete_turn():
	Character.current_built_ships = 0
	main.pathfinder.reload_map_data(main)
	Level.complete_turn()
	building_list.visible = false
	if Level.get_current_level() > main.current_level:
		$Level_Control/Turn_Display.set_text("Victory!")
		$Level_Control/Turn_Display.visible = true
		$Level_Control/Next_Level_Button.visible = true
	else:
		title.text = Level.get_current_phase()
		done.visible = (Level.get_current_phase() == "preparation")
		$Level_Control/Turn_Display.set_text("Turn " + str(Level.get_current_turn()))
		$Level_Control/Turn_Display.visible = true
		$Turn_Count_Timer.start()
		main.get_node("Pirate_Music").fade_out()
		main.get_node("Music").volume_db = -10
		main.get_node("Music").play()


func _on_test_timer_timeout():
	complete_turn()


func _on_next_level_button_pressed():
	get_tree().reload_current_scene()
