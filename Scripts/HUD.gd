extends CanvasLayer
class_name HUD
@onready var is_prebuilding := false
@onready var is_preexpanding := false
@onready var is_predemolishing := false
@onready var is_prebuildingship := false
@onready var is_presummoningmercenary := false
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
@onready var mercenary_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Mercenary_Button/Mercenary_Text
@onready var building_list = $Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/BuildingList
@onready var ship_list = $Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/ShipList
@onready var mercenary_list = $Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/MercenaryList
@onready var introduction = $Container/VBoxContainer/MarginContainer3/VBoxContainer/Introduction
@onready var skill_list = $Container/MarginContainer/Skill_List
# Called when the node enters the scene tree for the first time.
func _ready():
	$Start_Sound.play()
	$Level_Control/Turn_Display.label_settings.font_size = 100
	life_value.text = str(Character.current_hp)
	money_value.text = str(Character.gold)
	level_info.text = "Level " + str(Level.get_current_level())
	ship_list.visible = false
	title.text = Level.get_current_phase()
	done.visible = (Level.get_current_phase() == "preparation")
	$Level_Control/Turn_Display.set_text("Turn " + str(Level.get_current_turn()))
	$Turn_Count_Timer.start()
	mercenary_button_text.self_modulate = Color.RED
	Character.character_die.connect(_on_character_die)

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
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				build(pending_scene, main.get_global_mouse_position())
		else:
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
			if Input.is_action_just_pressed("click"):
				build(pending_scene, main.get_global_mouse_position())
			
	if is_preexpanding:
		if main.pathfinder.is_shallow_water(main.get_global_mouse_position()):
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				expand(main.get_global_mouse_position())
		else:
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
			if Input.is_action_just_pressed("click"):
				expand(main.get_global_mouse_position())
			
	if is_predemolishing:
		if main.pathfinder.is_building(main.get_global_mouse_position()):
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				demolish(main.get_global_mouse_position())
		else:
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
			if Input.is_action_just_pressed("click"):
				demolish(main.get_global_mouse_position())
			
	if is_prebuildingship:
		if main.pathfinder.is_shallow_water(main.get_global_mouse_position()) || main.pathfinder.is_deep_water(main.get_global_mouse_position()):
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				buildship(pending_scene, main.get_global_mouse_position())
		else:
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
			if Input.is_action_just_pressed("click"):
				buildship(pending_scene, main.get_global_mouse_position())
			
	if is_presummoningmercenary:
		if main.pathfinder.is_shallow_water(main.get_global_mouse_position()) || main.pathfinder.is_deep_water(main.get_global_mouse_position()):
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				summonmercenary(pending_scene, main.get_global_mouse_position())
		else:
			main.get_node("Cursor/Sprite2D").self_modulate = Color(1,0,0,0.5)
			if Input.is_action_just_pressed("click"):
				summonmercenary(pending_scene, main.get_global_mouse_position())

func _on_expand_button_pressed():
	if Level.get_current_phase() == "preparation":
		if not is_preexpanding:
			start_preexpanding()
		else:
			stop_preexpanding()
	introduction.text = "Cost:20\nAllows you to turn 1 shallow water into land."

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
	introduction.text = "Cost: 0\nSelect a building and demolish, return half its cost as gold."
		
func _on_buildship_button_pressed():
	if Level.get_current_phase() == "preparation":
		stop_prebuilding()
		stop_preexpanding()
		stop_predemolishing()
		ship_list.visible = !ship_list.visible
		building_list.visible = false
		if is_prebuildingship:
			stop_prebuildingship()
			
func _on_mercenary_button_pressed():
	if Level.get_current_phase() == "action":
		mercenary_list.visible = !mercenary_list.visible
		if is_presummoningmercenary:
			stop_presummoningmercenary()

func start_prebuilding(building_name:String):
	stop_preexpanding()
	stop_predemolishing()
	stop_prebuildingship()
	is_prebuilding = true
	build_button_text.text = "Cancel!"
	var cursor_texture = get_node("Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/BuildingList/" + building_name + "Container/Build_" + building_name).icon
	main.get_node("Cursor/Sprite2D").scale = Vector2(main.tile_map.tile_set.tile_size)/cursor_texture.get_size()
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
	main.get_node("Cursor/Sprite2D").scale = Vector2(main.tile_map.tile_set.tile_size)/cursor_texture.get_size()
	main.get_node("Cursor/Sprite2D").texture = cursor_texture
	pending_scene = load("res://Scenes/Ships/" + ship_name + ".tscn").instantiate()

func stop_prebuildingship():
	is_prebuildingship = false
	buildship_button_text.text = "Buildship!"
	main.get_node("Cursor/Sprite2D").texture = null
	ship_list.visible = false
	
func start_presummoningmercenary(mercenary_name:String):
	is_presummoningmercenary = true
	mercenary_button_text.text = "Cancel!"
	var cursor_texture = get_node("Container/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/MercenaryList/" + mercenary_name + "Container/Summon_" + mercenary_name).icon
	main.get_node("Cursor/Sprite2D").scale = Vector2(main.tile_map.tile_set.tile_size)/cursor_texture.get_size()
	main.get_node("Cursor/Sprite2D").texture = cursor_texture
	pending_scene = load("res://Scenes/Mercenary/" + mercenary_name + "Example.tscn").instantiate()

func stop_presummoningmercenary():
	is_presummoningmercenary = false
	mercenary_button_text.text = "Mercenary!"
	main.get_node("Cursor/Sprite2D").texture = null
	mercenary_list.visible = false
	
	
	
	
func build(building_scene:Object, position:Vector2):
	var can_build:bool
	if building_scene.is_on_land:
		can_build = main.pathfinder.is_constructable_land(position)
	else:
		can_build = main.pathfinder.is_shallow_water(position)
	if not can_build:
		$Error_Sound.play()
	else:
		if Character.loss_gold(building_scene.cost):
			var building = building_scene
			building.start_location = main.pathfinder.get_tile_center(position)
			main.get_node("BuildingLayer").add_child(building)
			main.pathfinder.maze_add_building(position)
			stop_prebuilding()
			$Build_Sound.play()
		else:
			$Error_Sound.play()
		
func expand(position:Vector2):
	if not main.pathfinder.is_shallow_water(position):
		$Error_Sound.play()
	else:
		if Character.loss_gold(20):
			main.tile_map.erase_cell(0, main.pathfinder.get_standard_position(position))
			main.tile_map.set_cells_terrain_connect(1, [main.pathfinder.get_standard_position(position)], 0, 0)
			main.pathfinder.maze_update("ground", position)
			stop_preexpanding()
		else:
			$Error_Sound.play()
		
func demolish(position:Vector2):
	if not main.pathfinder.is_building(position):
		$Error_Sound.play()
	else:
		for i in main.get_node("BuildingLayer").get_children():
			if i.global_position  == main.pathfinder.get_tile_center(position):
				i.demolish()
				break
		main.pathfinder.delete_building(position)
		stop_predemolishing()
		$Demolish_Sound.play()
		
func buildship(ship_scene:Object, position:Vector2):
		if Character.current_built_ships >= Character.max_buildable_ships:
			$Error_Sound.play()
		else:
			if Character.loss_gold(ship_scene.cost):
				var ship = ship_scene
				ship.start_location = main.pathfinder.get_tile_center(position)
				main.get_node("ShipLayer").add_child(ship)
				main.pathfinder.maze_add_ship(position)
				stop_prebuildingship()
				Character.current_built_ships += 1
				$Buildship_Sound.play()
			else:
				$Error_Sound.play()
			
func summonmercenary(mercenary_scene:Object, position:Vector2):
	if main.pathfinder.is_shallow_water(main.get_global_mouse_position()) || main.pathfinder.is_deep_water(main.get_global_mouse_position()):
		if Character.loss_gold(mercenary_scene.cost):
			var mercenary = mercenary_scene
			mercenary.start_location = main.pathfinder.get_tile_center(position)
			main.get_node("ShipLayer").add_child(mercenary)
			main.pathfinder.maze_add_ship(position)
			stop_presummoningmercenary()
			$Summon_Mercenary_Sound.play()
		else:
			$Error_Sound.play()
	else:
		$Error_Sound.play()


func _on_build_turrent_pressed():
	start_prebuilding("Turrent")
	introduction.text = "cost:10\nBasic defence building, with elegant range and moderate fire power."


func _on_done_button_pressed():
	expand_button_text.self_modulate = Color.RED
	build_button_text.self_modulate = Color.RED
	demolish_button_text.self_modulate = Color.RED
	buildship_button_text.self_modulate = Color.RED
	mercenary_button_text.self_modulate = Color.WHITE
	stop_prebuilding()
	stop_predemolishing()
	stop_preexpanding()
	stop_prebuildingship()
	title.text = "action"
	done.visible = false
	Level.complete_phase()
	main.get_node("Music").fade_out()
	main.get_node("Pirate_Music").volume_db = 0
	main.get_node("Pirate_Invasion_Timer").start()
	main.get_node("MerchantLayer").reset(main.pathfinder.get_sail_routes())
	main.get_node("MerchantLayer").start_action()
	for i in main.get_children():
		if i.is_in_group("UI"):
			i.visible = false
	for i in main.monster_generator:
		i.start_generating()
	$Combat_Start_Sound.play()

func _on_build_ship_pressed():
	if not is_prebuildingship:
		start_prebuildingship("ShipExample")
	introduction.text = "Cost: 10\nBasic battle ship, with moderate armor and firepower.\n#requires a shipyard."
	
func _on_build_full_rigged_pressed():
	if not is_prebuildingship:
		start_prebuildingship("ShipFullrigged")
	introduction.text = "Cost: 20\nequipped with better sail, moves faster and hits harder.\n#requires a shipyard."

func _on_build_ship_iron_clag_pressed():
	if not is_prebuildingship:
		start_prebuildingship("ShipIronClag")
	introduction.text = "Cost: 30\nSteampower warship built with iron, tough and pwoerful.\n#requires a shipyard."

func _on_build_shipyard_pressed():
	start_prebuilding("Shipyard")
	introduction.text = "Cost: 20\nA special building that can only placed on shallow water.\nEach shipyard allows you to build 1 ship per turn."

func _on_summon_mercenary_pressed():
	if not is_presummoningmercenary:
		start_presummoningmercenary("Mercenary")
	introduction.text = "Cost: 40\ncheapest of all kinds, but still quite expensive."

func _on_turn_count_timer_timeout():
	$Level_Control/Turn_Display.visible = false
	


func complete_turn():
	expand_button_text.self_modulate = Color.WHITE
	build_button_text.self_modulate = Color.WHITE
	demolish_button_text.self_modulate = Color.WHITE
	buildship_button_text.self_modulate = Color.WHITE
	mercenary_button_text.self_modulate = Color.RED
	Character.current_built_ships = 0
	main.pathfinder.reload_map_data(main)
	Level.complete_turn()
	building_list.visible = false
	if Level.get_current_level() > main.current_level:
		if Level.get_current_level() > 3:
			$Level_Control/Turn_Display.set_text("Thanks for playing Defense of the Aqua!")
			$Level_Control/Turn_Display.label_settings.font_size = 48
			$Level_Control/Turn_Display.visible = true
			$Level_Control/Credits.visible = true
		else:
			$Level_Control/Turn_Display.set_text("Victory!")
			$Level_Control/Turn_Display.visible = true
			$Level_Control/Next_Level_Button.visible = true
		$Victory_Sound.play()
	else:
		title.text = Level.get_current_phase()
		done.visible = (Level.get_current_phase() == "preparation")
		$Level_Control/Turn_Display.set_text("Turn " + str(Level.get_current_turn()))
		$Level_Control/Turn_Display.visible = true
		$Turn_Count_Timer.start()
		main.get_node("Pirate_Music").fade_out()
		main.get_node("Music").volume_db = -10
		main.get_node("Music").play()
		for i in main.get_children():
			if i.is_in_group("UI"):
				i.visible = true
		$Combat_Victory_Sound.play()


func _on_character_die():
	$Level_Control/Turn_Display.set_text("Level Failed!")
	$Level_Control/Turn_Display.visible = true
	$Level_Control/Start_Over_Button.visible = true
	$Fail_Sound.play()


func _on_next_level_button_pressed():
	Character.reset()
	get_tree().reload_current_scene()


func _on_start_over_button_pressed():
	Character.reset()
	get_tree().reload_current_scene()
