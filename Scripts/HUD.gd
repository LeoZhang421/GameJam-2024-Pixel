extends CanvasItem
class_name HUD
@onready var is_prebuilding := false
@onready var is_preexpanding := false
@onready var is_predemolishing := false
@onready var main:Object
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
			if Input.is_action_just_pressed("click"):
				build(load("res://Scenes/Buildings/TurrentExample.tscn"), get_global_mouse_position())
		else: print("cannot build!")
	if is_preexpanding:
		if main.pathfinder.is_shallow_water(get_global_mouse_position()):
			print("can expand!")
			if Input.is_action_just_pressed("click"):
				expand(get_global_mouse_position())
		else: print("cannot expand!")

func _on_expand_button_pressed():
	if not is_preexpanding:
		start_preexpanding()
	else:
		stop_preexpanding()

func _on_build_button_pressed():
	if not is_prebuilding:
		start_prebuilding()
	else:
		stop_prebuilding()

func _on_demolish_button_pressed():
	pass # Replace with function body.

func start_prebuilding():
	stop_preexpanding()
	is_prebuilding = true
	build_button_text.text = "Cancel!"

func stop_prebuilding():
	is_prebuilding = false
	build_button_text.text = "Build!"
	
func start_preexpanding():
	stop_prebuilding()
	is_preexpanding = true
	expand_button_text.text = "Cancel!"

func stop_preexpanding():
	is_preexpanding = false
	expand_button_text.text = "Expand!"
	
func build(building_scene:PackedScene, position:Vector2):
	if not main.pathfinder.is_constructable_land(position):
		pass
	else:
		var building = building_scene.instantiate()
		building.start_location = main.pathfinder.get_tile_center(position)
		main.add_child(building)
		main.pathfinder.maze_add_building(position)
		stop_prebuilding()
		
func expand(position:Vector2):
	if not main.pathfinder.is_shallow_water(position):
		pass
	else:
		main.pathfinder.maze_update(position)
