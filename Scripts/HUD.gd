extends CanvasLayer
class_name HUD
@onready var is_prebuilding := false
@onready var is_preexpanding := false
@onready var is_predemolishing := false
@onready var main
@onready var title = $Level_Control/Title
@onready var done = $Level_Control/Done_Button
@onready var life_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Life/Life_Value
@onready var money_value = $Container/VBoxContainer/MarginContainer/VBoxContainer/Money/Money_Value
@onready var expand_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Expand_Button/Expand_Text
@onready var build_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Build_Button/Build_Text
@onready var demolish_button_text = $Container/VBoxContainer/MarginContainer2/VBoxContainer/Demolish_Button/Demolish_Text
@onready var building_list = $Container/VBoxContainer/MarginContainer3/BuildingList
@onready var skill_list = $Container/MarginContainer/Skill_List
# Called when the node enters the scene tree for the first time.
func _ready():
	#life_value.text = str(main.current_life)
	#money_value.text = str(main.current_money)
	building_list.visible = false
	title.text = Level.get_current_phase()
	done.visible = (Level.get_current_phase() == "preparation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#life_value.text = str(main.current_life)
	#money_value.text = str(main.current_money)
	if is_prebuilding:
		if main.pathfinder.is_constructable_land(main.get_global_mouse_position()):
			print("can build!")
			main.get_node("Cursor/Sprite2D").self_modulate = Color(0,1,0,0.5)
			if Input.is_action_just_pressed("click"):
				build(load("res://Scenes/Buildings/TurrentExample.tscn"), main.get_global_mouse_position())
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

func _on_expand_button_pressed():
	if Level.get_current_phase() == "preperation":
		if not is_preexpanding:
			start_preexpanding()
		else:
			stop_preexpanding()

func _on_build_button_pressed():
	if Level.get_current_phase() == "preperation":
		stop_preexpanding()
		stop_predemolishing()
		building_list.visible = !building_list.visible
		if is_prebuilding:
			stop_prebuilding()

func _on_demolish_button_pressed():
	if Level.get_current_phase() == "preperation":
		start_predemolishing()

func start_prebuilding(building_name:String):
	stop_preexpanding()
	stop_predemolishing()
	is_prebuilding = true
	build_button_text.text = "Cancel!"
	var cursor_texture = load("res://Assets/Buildings/turrents_1_left.png")
	main.get_node("Cursor/Sprite2D").texture = cursor_texture

func stop_prebuilding():
	is_prebuilding = false
	build_button_text.text = "Build!"
	main.get_node("Cursor/Sprite2D").texture = null
	
func start_preexpanding():
	stop_prebuilding()
	stop_predemolishing()
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


func _on_build_turrent_pressed():
	if not is_prebuilding:
		start_prebuilding("TurrentExample")


func _on_done_button_pressed():
	stop_prebuilding()
	building_list.visible = false
	stop_predemolishing()
	stop_preexpanding()
	title.text = "action"
	done.visible = false
	Level.complete_phase()
