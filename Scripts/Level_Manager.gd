class_name Level_Manager
extends Node
var all_levels = 3
var current_level = 0
var all_turns = 3
var current_turn = 0
var phase = {"preparation":0, "action":0}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_current_level():
	return current_level

func get_current_turn():
	return current_turn

func get_current_phase():
	return phase.find_key(1)

func complete_phase():
	if get_current_phase() == "preparation":
		phase["preparation"] = 0
		phase["action"] = 1
	elif get_current_phase() == "action":
		phase["preparation"] = 1
		phase["action"] = 0
	elif get_current_phase() == null:
		phase["preparation"] = 1
		current_turn = 1
		complete_level()

func complete_turn():
	current_turn += 1
	Character.current_built_ships = 0
	phase["preparation"] = 1
	phase["action"] = 0
	if current_turn > all_turns:
		complete_level()

func complete_level():
	current_level += 1
	current_turn = 1
	phase["preparation"] = 1
	phase["action"] = 0
	
func complete_game():
	pass
